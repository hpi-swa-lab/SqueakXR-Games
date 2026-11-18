"
Face-culling mesher: one SRMesh per 16-cube, at most SWAGameXR>>chunkRebuildBudget rebuilt per frame.
"
Class {
	#name : #SWAGameVoxelChunks,
	#superclass : #Object,
	#instVars : [
		'grid',
		'gridWidth',
		'gridHeight',
		'gridDepth',
		'worldScale',
		'chunkSize',
		'chunkEntries',
		'dirtyCursor',
		'faceTable',
		'space',
		'retiredMeshes'
	],
	#category : #SWAGame,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}

{
	#category : #'instance creation',
	#'squeak_changestamp' : 'MCPServer 10/15/2026 16:16'
}
SWAGameVoxelChunks class >> grid: aGrid width: w height: h depth: d worldScale: s [

	^ self new
		setGrid: aGrid width: w height: h depth: d worldScale: s;
		yourself
]

{
	#category : #meshing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameVoxelChunks >> buildChunkForKey: aKey [
	"Must decode the window #keyForChunkX:y:z: encodes."

	| cz cy cx rest |
	cz := (aKey + 512 \\ 1024) - 512.
	rest := aKey + 512 // 1024.
	cy := rest \\ 1024.
	cx := rest // 1024.
	^ self buildChunkX: cx y: cy z: cz
]

{
	#category : #meshing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameVoxelChunks >> buildChunkX: cx y: cy z: cz [
	"nil when no face is visible."
	| x0 y0 z0 x1 y1 z1 faceCount |
	x0 := cx * chunkSize.
	y0 := cy * chunkSize.
	z0 := cz * chunkSize.
	x1 := x0 + chunkSize - 1.
	y1 := y0 + chunkSize - 1 min: gridHeight - 1.
	z1 := z0 + chunkSize - 1.
	(chunkSize = SWAGameChunk sectionHeight
		and: [(grid hasBlocksInSectionAtX: x0 y: y0 z: z0) not])
			ifTrue: [^ nil].
	faceCount := self countFacesX0: x0 y0: y0 z0: z0 x1: x1 y1: y1 z1: z1.
	faceCount = 0 ifTrue: [^ nil].
	^ self meshX0: x0 y0: y0 z0: z0 x1: x1 y1: y1 z1: z1 faceCount: faceCount
]

{
	#category : #initialization,
	#'squeak_changestamp' : 'MCPServer (leo) 11/3/2026 12:21'
}
SWAGameVoxelChunks >> buildFaceTable [
	"{neighbour offset. normal. 4 corner offsets}, offsets from the min corner."

	^ SWAGameMobModel faceTable collect: [:face | {face first. face first. face second}]
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 17:02'
}
SWAGameVoxelChunks >> chunkCount [
	^ chunkEntries ifNil: [0] ifNotNil: [:d | d size]
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 7/30/2026 10:07'
}
SWAGameVoxelChunks >> chunkSize [
	^ chunkSize
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameVoxelChunks >> chunkSize: anInteger [
	"Must stay at most #maxChunkSizeForIndices."
	anInteger = chunkSize ifTrue: [^ self].
	chunkSize := anInteger max: 1.
	self resetChunks
]

{
	#category : #meshing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameVoxelChunks >> clear [
	self retireAllMeshes.
	chunkEntries := Dictionary new.
	dirtyCursor := 0
]

{
	#category : #meshing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameVoxelChunks >> countFacesX0: x0 y0: y0 z0: z0 x1: x1 y1: y1 z1: z1 [
	"Neighbour lookups cross the chunk border on purpose: that hides the seams."
	| count |
	count := 0.
	x0 to: x1 do: [:x |
		y0 to: y1 do: [:y |
			z0 to: z1 do: [:z |
				(grid at: x at: y at: z) = 0 ifFalse: [
					faceTable do: [:face |
						| n |
						n := face first.
						(grid at: x + n first at: y + n second at: z + n third) = 0
							ifTrue: [count := count + 1]]]]]].
	^ count
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 17:02'
}
SWAGameVoxelChunks >> dirtyCount [
	chunkEntries ifNil: [^ 0].
	^ chunkEntries count: [:entry | entry at: 2]
]

{
	#category : #private,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameVoxelChunks >> entryForKey: aKey [
	"{mesh. dirty}. Marking is one store into slot 2, so a preempted rebuild cannot lose it."

	^ chunkEntries at: aKey ifAbsentPut: [Array with: nil with: false]
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 17:02'
}
SWAGameVoxelChunks >> hasDirtyChunks [
	chunkEntries ifNil: [^ false].
	^ chunkEntries anySatisfy: [:entry | entry at: 2]
]

{
	#category : #initialization,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameVoxelChunks >> initialize [
	super initialize.
	"One mesh chunk per storage section, so empty sections are skipped unscanned."
	chunkSize := SWAGameChunk sectionHeight.
	worldScale := 1.0.
	gridWidth := gridHeight := gridDepth := 0.
	faceTable := self buildFaceTable.
	self resetChunks
]

{
	#category : #private,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameVoxelChunks >> keyForChunkX: cx y: cy z: cz [
	"Only cy is bounded. #buildChunkForKey: decodes cz from -512 to 511."

	(cy >= 0 and: [cy * chunkSize < gridHeight]) ifFalse: [^ nil].
	^ (cx * 1024 + cy) * 1024 + cz
]

{
	#category : #'dirty tracking',
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameVoxelChunks >> markAllDirty [
	| levels |
	chunkEntries ifNil: [chunkEntries := Dictionary new].
	chunkEntries valuesDo: [:entry | entry at: 2 put: true].
	grid ifNil: [^ self].
	levels := (gridHeight + chunkSize - 1) // chunkSize.
	grid chunkColumnsDo: [:cx :cz |
		0 to: levels - 1 do: [:cy |
			(self keyForChunkX: cx y: cy z: cz)
				ifNotNil: [:key | (self entryForKey: key) at: 2 put: true]]]
]

{
	#category : #'dirty tracking',
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameVoxelChunks >> markChunkDirtyX: cx y: cy z: cz [
	| key |
	key := self keyForChunkX: cx y: cy z: cz.
	key ifNil: [^ self].
	(self entryForKey: key) at: 2 put: true
]

{
	#category : #'dirty tracking',
	#'squeak_changestamp' : 'MCPServer 10/15/2026 16:17'
}
SWAGameVoxelChunks >> markDirtyAt: gridCoord [
	"gridCoord is a nested Point, x @ y @ z."
	self markDirtyAtX: gridCoord x y: gridCoord y z: gridCoord z
]

{
	#category : #'dirty tracking',
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameVoxelChunks >> markDirtyAtX: x y: y z: z [
	"The neighbour's face culling reads this voxel: dirty the chunk across every border it touches."
	| cx cy cz last |
	cx := x // chunkSize.
	cy := y // chunkSize.
	cz := z // chunkSize.
	self markChunkDirtyX: cx y: cy z: cz.
	last := chunkSize - 1.
	x \\ chunkSize = 0 ifTrue: [self markChunkDirtyX: cx - 1 y: cy z: cz].
	x \\ chunkSize = last ifTrue: [self markChunkDirtyX: cx + 1 y: cy z: cz].
	y \\ chunkSize = 0 ifTrue: [self markChunkDirtyX: cx y: cy - 1 z: cz].
	y \\ chunkSize = last ifTrue: [self markChunkDirtyX: cx y: cy + 1 z: cz].
	z \\ chunkSize = 0 ifTrue: [self markChunkDirtyX: cx y: cy z: cz - 1].
	z \\ chunkSize = last ifTrue: [self markChunkDirtyX: cx y: cy z: cz + 1]
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameVoxelChunks >> maxChunkSizeForIndices [
	"The worst case is a checkerboard: 12 n^3 vertices below 65536."
	^ 17
]

{
	#category : #meshing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameVoxelChunks >> meshX0: x0 y0: y0 z0: z0 x1: x1 y1: y1 z1: z1 faceCount: faceCount [
	"Arrays are indexed by element, not by byte."
	| vArr nArr tArr cArr iArr vIdx fIdx meshSource |
	vArr := SRMeshSourceRaw verticesClass new: faceCount * 4 * 3.
	nArr := SRMeshSourceRaw normalsClass new: faceCount * 4 * 3.
	tArr := SRMeshSourceRaw texcoordsClass new: faceCount * 4 * 2.
	cArr := SRMeshSourceRaw colorsClass new: faceCount * 4 * 4.
	iArr := SRMeshSourceRaw indicesClass new: faceCount * 2 * 3.
	vIdx := 0.
	fIdx := 0.
	x0 to: x1 do: [:x |
		y0 to: y1 do: [:y |
			z0 to: z1 do: [:z |
				(grid at: x at: y at: z) = 0 ifFalse: [
					| rgba |
					rgba := self rgbaAtX: x y: y z: z.
					faceTable do: [:face |
						| n |
						n := face first.
						(grid at: x + n first at: y + n second at: z + n third) = 0 ifTrue: [
							self writeQuadVerts: vArr normals: nArr texcoords: tArr
								colors: cArr indices: iArr
								vIdx: vIdx fIdx: fIdx
								x: x y: y z: z normal: face second corners: face third rgba: rgba.
							vIdx := vIdx + 4.
							fIdx := fIdx + 1]]]]]].
	meshSource := SRMeshSourceRaw new.
	meshSource editDo: [:s |
		s
			vertices: vArr;
			normals: nArr;
			texcoords: tArr;
			colors: cArr;
			indices: iArr].
	^ SRMesh withSource: meshSource
]

{
	#category : #rendering,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameVoxelChunks >> meshesDo: aBlock [
	"All in one object space, drawn with one transform."
	chunkEntries ifNil: [^ self].
	chunkEntries valuesDo: [:entry |
		(entry at: 1) ifNotNil: [:m | aBlock value: m]]
]

{
	#category : #rendering,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameVoxelChunks >> onCacheInvalidated [
	"The GL context is new after an image restart."
	self meshesDo: [:m | m onCacheInvalidated].
	retiredMeshes := nil.
]

{
	#category : #printing,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 17:03'
}
SWAGameVoxelChunks >> printOn: aStream [
	aStream
		nextPutAll: self class name;
		nextPutAll: '(', chunkSize printString, '^3, ';
		nextPutAll: self chunkCount printString, ' chunks, ';
		nextPutAll: self dirtyCount printString, ' dirty)'
]

{
	#category : #meshing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameVoxelChunks >> rebuildAllDirty [
	"For tests and measurements; the game uses #rebuildUpTo:."
	^ self rebuildUpTo: (self chunkCount max: 1)
]

{
	#category : #meshing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameVoxelChunks >> rebuildUpTo: maxChunks [
	"Round robin from a cursor, so no chunk starves. Cleared before meshing:
	a mark arriving meanwhile is kept."

	| done keys count |
	self unloadRetiredMeshes.
	chunkEntries ifNil: [^ 0].
	keys := chunkEntries keys asArray.
	count := keys size.
	count = 0 ifTrue: [^ 0].
	done := 0.
	1 to: count do: [:scanned |
		| key entry |
		done < maxChunks ifTrue: [
			key := keys at: dirtyCursor \\ count + 1.
			dirtyCursor := dirtyCursor + 1.
			entry := chunkEntries at: key ifAbsent: [nil].
			(entry notNil and: [entry at: 2]) ifTrue: [
				entry at: 2 put: false.
				(entry at: 1) ifNotNil: [:old | old unload].
				entry at: 1 put: (self buildChunkForKey: key).
				done := done + 1]]].
	^ done
]

{
	#category : #initialization,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameVoxelChunks >> resetChunks [
	self retireAllMeshes.
	chunkEntries := Dictionary new.
	dirtyCursor := 0.
	self markAllDirty
]

{
	#category : #meshing,
	#'squeak_changestamp' : 'MCPServer (MCPServer) 10/23/2026 12:28'
}
SWAGameVoxelChunks >> retireAllMeshes [
	"Unloaded by the next #rebuildUpTo:, because a reset can come from a menu and GL belongs to the render process."
	self meshesDo: [:mesh | self retiredMeshes add: mesh].
]

{
	#category : #meshing,
	#'squeak_changestamp' : 'MCPServer (MCPServer) 10/23/2026 12:28'
}
SWAGameVoxelChunks >> retiredMeshes [

	^ retiredMeshes ifNil: [retiredMeshes := OrderedCollection new]
]

{
	#category : #private,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameVoxelChunks >> rgbaAtX: x y: y z: z [
	^ SWAGameBlocks rgbaFor: (grid at: x at: y at: z)
]

{
	#category : #initialization,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 16:16'
}
SWAGameVoxelChunks >> setGrid: aGrid width: w height: h depth: d worldScale: s [

	grid := aGrid.
	gridWidth := w.
	gridHeight := h.
	gridDepth := d.
	worldScale := s.
	self resetChunks
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameVoxelChunks >> space [
	^ space ifNil: [
		space := SWAGameSpace
			worldScale: worldScale
			originX: gridWidth / 2
			originZ: gridDepth / 2]
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 16:08'
}
SWAGameVoxelChunks >> space: aSWAGameSpace [
	"Shared with the owner, so vertex positions and mob positions cannot drift."

	space := aSWAGameSpace
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameVoxelChunks >> stats [
	| nonEmpty verts tris |
	nonEmpty := 0. verts := 0. tris := 0.
	self meshesDo: [:m |
		| src |
		nonEmpty := nonEmpty + 1.
		src := m source.
		verts := verts + src elementCount.
		tris := tris + src triangleCount].
	^ Dictionary newFrom: {
		#chunks -> self chunkCount.
		#drawnChunks -> nonEmpty.
		#dirty -> self dirtyCount.
		#vertices -> verts.
		#triangles -> tris }
]

{
	#category : #meshing,
	#'squeak_changestamp' : 'MCPServer (MCPServer) 10/23/2026 12:28'
}
SWAGameVoxelChunks >> unloadAllMeshes [

	self unloadRetiredMeshes.
	self meshesDo: [:mesh | mesh unload].
]

{
	#category : #meshing,
	#'squeak_changestamp' : 'MCPServer (MCPServer) 10/23/2026 12:28'
}
SWAGameVoxelChunks >> unloadRetiredMeshes [

	retiredMeshes ifNil: [^ self].
	retiredMeshes do: [:mesh | mesh unload].
	retiredMeshes := nil.
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameVoxelChunks >> worldScale: aNumber [
	aNumber = worldScale ifTrue: [^ self].
	worldScale := aNumber.
	self markAllDirty
]

{
	#category : #meshing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameVoxelChunks >> writeQuadVerts: vArr normals: nArr texcoords: tArr colors: cArr indices: iArr vIdx: vIdx fIdx: fIdx x: cx y: cy z: cz normal: faceNormal corners: cornerOffsets rgba: rgba [
	"Texcoords run 0..1 per face: the terrain shader draws the outline from them."
	| baseV s halfW halfD nx ny nz r g b a iBase theSpace |
	theSpace := self space.
	s := theSpace worldScale.
	halfW := theSpace originX.
	halfD := theSpace originZ.
	nx := faceNormal first asFloat.
	ny := faceNormal second asFloat.
	nz := faceNormal third asFloat.
	r := rgba at: 1. g := rgba at: 2. b := rgba at: 3. a := rgba at: 4.
	baseV := vIdx.

	1 to: 4 do: [:k |
		| off vi vBase tBase cBase |
		off := cornerOffsets at: k.
		vi := vIdx + k - 1.
		vBase := vi * 3.
		tBase := vi * 2.
		cBase := vi * 4.
		vArr at: vBase + 1 put: (cx + off first - halfW) * s.
		vArr at: vBase + 2 put: (cy + off second) * s.
		vArr at: vBase + 3 put: (cz + off third - halfD) * s.
		nArr at: vBase + 1 put: nx.
		nArr at: vBase + 2 put: ny.
		nArr at: vBase + 3 put: nz.
		tArr at: tBase + 1 put: ((k = 2 or: [k = 3]) ifTrue: [1.0] ifFalse: [0.0]).
		tArr at: tBase + 2 put: (k >= 3 ifTrue: [1.0] ifFalse: [0.0]).
		cArr at: cBase + 1 put: r.
		cArr at: cBase + 2 put: g.
		cArr at: cBase + 3 put: b.
		cArr at: cBase + 4 put: a].

	iBase := fIdx * 6.
	iArr at: iBase + 1 put: baseV.
	iArr at: iBase + 2 put: baseV + 1.
	iArr at: iBase + 3 put: baseV + 2.
	iArr at: iBase + 4 put: baseV.
	iArr at: iBase + 5 put: baseV + 2.
	iArr at: iBase + 6 put: baseV + 3
]
