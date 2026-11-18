"
Voxel storage as a map of chunk columns, so the cost is the chunks actually touched rather than width * depth * height.
"
Class {
	#name : #SWAGameChunkedGrid,
	#superclass : #Object,
	#instVars : [
		'chunks',
		'width',
		'depth',
		'height',
		'cachedKey',
		'cachedChunk'
	],
	#category : #'SWAGame-Voxels',
	#'squeak_changestamp' : '<historical>'
}

{
	#category : #'instance creation',
	#'squeak_changestamp' : 'MCPServer 10/15/2026 15:31'
}
SWAGameChunkedGrid class >> width: w depth: d height: h [

	^ self new
		initializeWidth: w depth: d height: h;
		yourself
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameChunkedGrid >> at: x at: y at: z [
	"Air outside the height and in chunks never written."

	"Truncated: raycast hits arrive as Floats."

	| chunk ix iy iz |
	ix := x truncated.
	iy := y truncated.
	iz := z truncated.
	(self isValidX: ix y: iy z: iz) ifFalse: [^ 0].
	chunk := self chunkAtX: (ix bitShift: -4) z: (iz bitShift: -4).
	chunk ifNil: [^ 0].
	^ chunk atLocalX: (ix bitAnd: 15) y: iy z: (iz bitAnd: 15)
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameChunkedGrid >> at: x at: y at: z put: aValue [


	| cx cz key chunk ix iy iz |
	ix := x truncated.
	iy := y truncated.
	iz := z truncated.
	(self isValidX: ix y: iy z: iz) ifFalse: [^ aValue].
	cx := ix bitShift: -4.
	cz := iz bitShift: -4.
	chunk := self chunkAtX: cx z: cz.
	chunk ifNil: [
		aValue = 0 ifTrue: [^ aValue].
		key := self chunkKeyX: cx z: cz.
		chunk := SWAGameChunk new initializeHeight: height.
		chunks at: key put: chunk.
		cachedKey := key.
		cachedChunk := chunk].
	^ chunk atLocalX: (ix bitAnd: 15) y: iy z: (iz bitAnd: 15) put: aValue
]

{
	#category : #'game logic',
	#'squeak_changestamp' : 'MCPServer 10/15/2026 15:30'
}
SWAGameChunkedGrid >> canPlaceAt: gridCoord [
	"Empty, and either on the ground or on top of something."

	(self at: gridCoord x at: gridCoord y at: gridCoord z) = 0 ifFalse: [^ false].
	^ self hasSupportAt: gridCoord
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 14:37'
}
SWAGameChunkedGrid >> chunkAtKey: aKey put: aChunk [
	chunks at: aKey put: aChunk.
	cachedKey := nil.
	cachedChunk := nil.
	^ aChunk
]

{
	#category : #private,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameChunkedGrid >> chunkAtX: cx z: cz [
	"A single entry cache: meshing, collision and the ray walk sweep one column at a time."

	| key |
	key := self chunkKeyX: cx z: cz.
	key = cachedKey ifTrue: [^ cachedChunk].
	cachedKey := key.
	cachedChunk := chunks at: key ifAbsent: [nil].
	^ cachedChunk
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameChunkedGrid >> chunkColumnsDo: aBlock [
	chunks keysDo: [:key |
		aBlock value: (SWAGameChunk xOfKey: key) value: (SWAGameChunk zOfKey: key)]
]

{
	#category : #private,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 17:29'
}
SWAGameChunkedGrid >> chunkKeyX: cx z: cz [
	^ SWAGameChunk keyX: cx z: cz
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameChunkedGrid >> chunksDo: aBlock [
	chunks keysAndValuesDo: aBlock
]

{
	#category : #operations,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameChunkedGrid >> clear [
	chunks := Dictionary new.
	cachedKey := nil.
	cachedChunk := nil.
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameChunkedGrid >> hasBlocksInSectionAtX: x y: y z: z [
	| chunk |
	(self isValidX: x y: y z: z) ifFalse: [^ false].
	chunk := self chunkAtX: (x bitShift: -4) z: (z bitShift: -4).
	chunk ifNil: [^ false].
	^ chunk hasSectionAtY: y
]

{
	#category : #'game logic',
	#'squeak_changestamp' : 'MCPServer 10/15/2026 15:30'
}
SWAGameChunkedGrid >> hasSupportAt: gridCoord [

	gridCoord y = 0 ifTrue: [^ true].
	^ (self at: gridCoord x at: gridCoord y - 1 at: gridCoord z) ~= 0
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 14:37'
}
SWAGameChunkedGrid >> height [
	^ height
]

{
	#category : #initialization,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 15:30'
}
SWAGameChunkedGrid >> initializeWidth: w depth: d height: h [

	width := w.
	depth := d.
	height := h.
	chunks := Dictionary new.
	cachedKey := nil.
	cachedChunk := nil.
	^ self
]

{
	#category : #'game logic',
	#'squeak_changestamp' : 'MCPServer 10/15/2026 15:30'
}
SWAGameChunkedGrid >> isOccludedX: x y: y z: z [
	"Return true if the cell at (x,y,z) has all 6 neighbors occupied."

	^ (self at: x - 1 at: y at: z) > 0
		and: [(self at: x + 1 at: y at: z) > 0
		and: [(self at: x at: y - 1 at: z) > 0
		and: [(self at: x at: y + 1 at: z) > 0
		and: [(self at: x at: y at: z - 1) > 0
		and: [(self at: x at: y at: z + 1) > 0]]]]]
]

{
	#category : #private,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameChunkedGrid >> isValidHorizontal: aCell [
	"The range the chunk key can tell apart, not a world extent."

	^ aCell >= (SWAGameChunk minCoordinate * SWAGameChunk size)
		and: [aCell < ((SWAGameChunk maxCoordinate + 1) * SWAGameChunk size)]
]

{
	#category : #private,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameChunkedGrid >> isValidX: x y: y z: z [


	^ y >= 0 and: [y < height
		and: [(self isValidHorizontal: x) and: [self isValidHorizontal: z]]]
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 15:31'
}
SWAGameChunkedGrid >> stats [

	| sectionCount |
	sectionCount := chunks inject: 0 into: [:sum :each | sum + each allocatedSectionCount].
	^ { #chunks -> chunks size.
		#sections -> sectionCount.
		#blockBytes -> (sectionCount * SWAGameChunk sectionHeight * 16 * 16) }
]
