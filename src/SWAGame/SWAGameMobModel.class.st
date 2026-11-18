"
A blocky animal built from 1/16-block voxels. Voxels are grouped by limb and pivot; the swagameMob vertex shader swings each group, reading the limb code from the vertex colour alpha and the pivot (y z, in pixels) from the texcoords.
"
Class {
	#name : #SWAGameMobModel,
	#superclass : #Object,
	#instVars : [
		'groups',
		'pixelScale',
		'strideCells',
		'gait',
		'lieLift'
	],
	#category : #'SWAGame-XR',
	#'squeak_changestamp' : '<historical>'
}

{
	#category : #limbs,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 15:25'
}
SWAGameMobModel class >> codeOf: aLimb [
	^ (self limbCodes indexOf: aLimb) - 1
]

{
	#category : #meshing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 15:25'
}
SWAGameMobModel class >> faceTable [
	"Normal and corners per face, counter-clockwise seen from outside."
	^ #(
		#((1 0 0) ((1 0 0) (1 1 0) (1 1 1) (1 0 1)))
		#((-1 0 0) ((0 0 0) (0 0 1) (0 1 1) (0 1 0)))
		#((0 1 0) ((0 1 0) (0 1 1) (1 1 1) (1 1 0)))
		#((0 -1 0) ((0 0 0) (1 0 0) (1 0 1) (0 0 1)))
		#((0 0 1) ((0 0 1) (1 0 1) (1 1 1) (0 1 1)))
		#((0 0 -1) ((0 0 0) (0 1 0) (1 1 0) (1 0 0))))
]

{
	#category : #'instance creation',
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 15:26'
}
SWAGameMobModel class >> forSpecies: aSymbol [
	aSymbol == #rabbit ifTrue: [^ self rabbit].
	aSymbol == #fox ifTrue: [^ self fox].
	^ self error: 'No model for ', aSymbol printString
]

{
	#category : #'instance creation',
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 15:26'
}
SWAGameMobModel class >> fox [
	| orange white dark |
	orange := Color r: 0.89 g: 0.47 b: 0.17.
	white := Color r: 0.96 g: 0.93 b: 0.88.
	dark := Color r: 0.2 g: 0.13 b: 0.1.
	^ self new
		pixelScale: 0.6;
		strideCells: 0.8;
		gait: #trot;
		lieLift: 4;
		part: #body box: #(-3 4 -6 3 9 5) color: orange;
		part: #body box: #(-3 4 -4 3 5 4) color: white;
		part: #body box: #(-3 4 4 3 7 5) color: white;
		part: #tail pivot: #(7 -6) box: #(-2 5 -14 2 9 -6) color: orange;
		part: #tail pivot: #(7 -6) box: #(-2 5 -14 2 9 -11) color: white;
		part: #head pivot: #(9 5) box: #(-4 6 4 4 12 10) color: orange;
		part: #head pivot: #(9 5) box: #(-4 6 4 4 8 10) color: white;
		part: #head pivot: #(9 5) box: #(-2 6 10 2 9 13) color: white;
		part: #head pivot: #(9 5) box: #(-1 8 12 1 9 13) color: dark;
		part: #head pivot: #(9 5) box: #(-3 10 9 -2 11 10) color: dark;
		part: #head pivot: #(9 5) box: #(2 10 9 3 11 10) color: dark;
		part: #head pivot: #(9 5) box: #(-4 12 6 -1 14 7) color: orange;
		part: #head pivot: #(9 5) box: #(-4 14 6 -2 15 7) color: dark;
		part: #head pivot: #(9 5) box: #(1 12 6 4 14 7) color: orange;
		part: #head pivot: #(9 5) box: #(2 14 6 4 15 7) color: dark;
		leg: #legsA x: -3 z: 2 orange: orange dark: dark;
		leg: #legsB x: 1 z: 2 orange: orange dark: dark;
		leg: #legsB x: -3 z: -5 orange: orange dark: dark;
		leg: #legsA x: 1 z: -5 orange: orange dark: dark;
		yourself
]

{
	#category : #limbs,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 15:25'
}
SWAGameMobModel class >> limbCodes [
	"The index minus one is the code the swagameMob shader switches on."
	^ #(#body #legsA #legsB #head #tail)
]

{
	#category : #'instance creation',
	#'squeak_changestamp' : 'MCPServer (jl) 11/17/2026 14:35'
}
SWAGameMobModel class >> rabbit [
	^ self rabbitCoat: #white
]

{
	#category : #'instance creation',
	#'squeak_changestamp' : 'MCPServer (jl) 11/17/2026 14:35'
}
SWAGameMobModel class >> rabbitCoat: anAllele [
	| colors fur saddle pink eye |
	colors := SWAGameRabbit coatColors at: anAllele.
	fur := colors first.
	saddle := colors second.
	pink := Color r: 0.96 g: 0.62 b: 0.68.
	eye := Color r: 0.15 g: 0.08 b: 0.08.
	^ self new
		pixelScale: 0.6;
		strideCells: 0.5;
		gait: #hop;
		lieLift: 3;
		part: #body box: #(-3 2 -4 3 7 3) color: fur;
		part: #body box: #(-2 6 -4 2 7 1) color: saddle;
		part: #tail pivot: #(5 -4) box: #(-1 4 -6 1 6 -4) color: Color white;
		part: #head pivot: #(6 3) box: #(-2 5 2 2 10 7) color: fur;
		part: #head pivot: #(6 3) box: #(-1 7 6 1 8 7) color: pink;
		part: #head pivot: #(6 3) box: #(-2 8 5 -1 9 6) color: eye;
		part: #head pivot: #(6 3) box: #(1 8 5 2 9 6) color: eye;
		part: #head pivot: #(6 3) box: #(-2 10 3 -1 14 5) color: fur;
		part: #head pivot: #(6 3) box: #(1 10 3 2 14 5) color: fur;
		part: #head pivot: #(6 3) box: #(-2 10 4 -1 13 5) color: pink;
		part: #head pivot: #(6 3) box: #(1 10 4 2 13 5) color: pink;
		part: #legsA pivot: #(3 1) box: #(-3 0 0 -1 2 2) color: fur;
		part: #legsA pivot: #(3 1) box: #(-2 2 0 -1 3 2) color: fur;
		part: #legsA pivot: #(3 1) box: #(1 0 0 3 2 2) color: fur;
		part: #legsA pivot: #(3 1) box: #(1 2 0 2 3 2) color: fur;
		part: #legsB pivot: #(3 -1) box: #(-3 0 -3 -1 2 1) color: fur;
		part: #legsB pivot: #(3 -1) box: #(-2 2 -3 -1 3 1) color: fur;
		part: #legsB pivot: #(3 -1) box: #(1 0 -3 3 2 1) color: fur;
		part: #legsB pivot: #(3 -1) box: #(1 2 -3 2 3 1) color: fur;
		yourself
]

{
	#category : #animating,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 15:26'
}
SWAGameMobModel >> bobAt: phase swing: swing [
	"Lift of the whole body in pixels. A hop leaves the ground while the legs are stretched."
	gait == #hop ifTrue: [^ (phase sin max: 0.0) * 3.0 * swing].
	^ (phase * 2) sin abs * 0.5 * swing
]

{
	#category : #meshing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 15:27'
}
SWAGameMobModel >> faceCount [
	| count |
	count := 0.
	self facesDo: [:group :xyz :face :color | count := count + 1].
	^ count
]

{
	#category : #meshing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 15:27'
}
SWAGameMobModel >> facesDo: aBlock [
	"aBlock takes the group key {code. pivotY. pivotZ}, the voxel position {x. y. z}, a face table entry and the voxel colour. Faces between voxels of the same group are skipped; between groups they are kept, since a swinging limb uncovers them."
	groups keysAndValuesDo: [:group :cells |
		cells keysAndValuesDo: [:key :color |
			| x y z |
			x := (key bitShift: -16) - 128.
			y := ((key bitShift: -8) bitAnd: 255) - 128.
			z := (key bitAnd: 255) - 128.
			self class faceTable do: [:face |
				| n |
				n := face first.
				(cells includesKey: (self keyX: x + n first y: y + n second z: z + n third))
					ifFalse: [aBlock value: group value: {x. y. z} value: face value: color]]]].
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 15:25'
}
SWAGameMobModel >> gait [
	^ gait
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 15:25'
}
SWAGameMobModel >> gait: anObject [
	gait := anObject.
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/3/2026 18:51'
}
SWAGameMobModel >> includesVoxelX: x y: y z: z [

	| key |
	((x between: -128 and: 127) and: [(y between: -128 and: 127) and: [z between: -128 and: 127]])
		ifFalse: [^ false].
	key := self keyX: x y: y z: z.
	^ groups anySatisfy: [:cells | cells includesKey: key]
]

{
	#category : #initialization,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 15:25'
}
SWAGameMobModel >> initialize [
	super initialize.
	groups := OrderedDictionary new.
	pixelScale := 1.0.
	strideCells := 0.5.
	gait := #trot.
	lieLift := 3.
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/3/2026 18:51'
}
SWAGameMobModel >> intersectsSegmentFrom: start to: end [
	"In model space, pixels. Walks the voxels the segment passes through (Amanatides-Woo). The limbs are tested in their rest pose."

	| origin delta voxel step tDelta tMax axis |
	origin := {start x. start y. start z}.
	delta := {end x - start x. end y - start y. end z - start z}.
	voxel := origin collect: [:each | each floor].
	step := delta collect: [:each | each sign].
	tDelta := delta collect: [:each | each = 0 ifTrue: [Float infinity] ifFalse: [1.0 / each abs]].
	tMax := (1 to: 3) collect: [:i |
		(delta at: i) = 0
			ifTrue: [Float infinity]
			ifFalse: [((voxel at: i) + ((delta at: i) > 0 ifTrue: [1] ifFalse: [0]) - (origin at: i)) / (delta at: i)]].
	[(self includesVoxelX: voxel first y: voxel second z: voxel third) ifTrue: [^ true].
	axis := (tMax at: 1) <= (tMax at: 2)
		ifTrue: [(tMax at: 1) <= (tMax at: 3) ifTrue: [1] ifFalse: [3]]
		ifFalse: [(tMax at: 2) <= (tMax at: 3) ifTrue: [2] ifFalse: [3]].
	(tMax at: axis) > 1] whileFalse: [
		voxel at: axis put: (voxel at: axis) + (step at: axis).
		tMax at: axis put: (tMax at: axis) + (tDelta at: axis)].
	^ false
]

{
	#category : #meshing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 15:25'
}
SWAGameMobModel >> keyX: x y: y z: z [
	^ ((x + 128) bitShift: 16) + ((y + 128) bitShift: 8) + (z + 128)
]

{
	#category : #building,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 15:39'
}
SWAGameMobModel >> leg: aLimb x: x z: z orange: orange dark: dark [
	"A fox leg, 2 by 2 pixels and 4 below the body. The stub reaching into the body hides the gap at the hip as the leg swings; it is inset by a pixel because a face in the plane of the body side would z-fight with it."
	| pivot inner |
	pivot := {5. z + 1}.
	inner := x < 0 ifTrue: [x + 1] ifFalse: [x].
	self
		part: aLimb pivot: pivot box: {x. 0. z. x + 2. 4. z + 2} color: orange;
		part: aLimb pivot: pivot box: {x. 0. z. x + 2. 3. z + 2} color: dark;
		part: aLimb pivot: pivot box: {inner. 4. z. inner + 1. 6. z + 2} color: orange.
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 15:25'
}
SWAGameMobModel >> lieLift [
	^ lieLift
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 15:25'
}
SWAGameMobModel >> lieLift: anObject [
	lieLift := anObject.
]

{
	#category : #meshing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 15:27'
}
SWAGameMobModel >> meshSource [
	| faces vArr nArr tArr cArr iArr v source |
	faces := self faceCount.
	vArr := SRMeshSourceRaw verticesClass new: faces * 12.
	nArr := SRMeshSourceRaw normalsClass new: faces * 12.
	tArr := SRMeshSourceRaw texcoordsClass new: faces * 8.
	cArr := SRMeshSourceRaw colorsClass new: faces * 16.
	iArr := SRMeshSourceRaw indicesClass new: faces * 6.
	v := 0.
	self facesDo: [:group :xyz :face :color |
		| x y z shade rgba |
		x := xyz first.
		y := xyz second.
		z := xyz third.
		shade := self shadeX: x y: y z: z.
		rgba := {
			(color red * shade * 255) rounded min: 255.
			(color green * shade * 255) rounded min: 255.
			(color blue * shade * 255) rounded min: 255.
			group first * 32}.
		face second doWithIndex: [:corner :k |
			| i |
			i := v + k - 1.
			vArr at: i * 3 + 1 put: (x + corner first) asFloat.
			vArr at: i * 3 + 2 put: (y + corner second) asFloat.
			vArr at: i * 3 + 3 put: (z + corner third) asFloat.
			nArr at: i * 3 + 1 put: face first first asFloat.
			nArr at: i * 3 + 2 put: face first second asFloat.
			nArr at: i * 3 + 3 put: face first third asFloat.
			tArr at: i * 2 + 1 put: group second asFloat.
			tArr at: i * 2 + 2 put: group third asFloat.
			1 to: 4 do: [:c | cArr at: i * 4 + c put: (rgba at: c)]].
		#(0 1 2 0 2 3) doWithIndex: [:offset :k |
			iArr at: v // 4 * 6 + k put: v + offset].
		v := v + 4].
	source := SRMeshSourceRaw new.
	source editDo: [:s |
		s
			vertices: vArr;
			normals: nArr;
			texcoords: tArr;
			colors: cArr;
			indices: iArr].
	^ source
]

{
	#category : #meshing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 15:25'
}
SWAGameMobModel >> newMesh [
	^ SRMesh withSource: self meshSource
]

{
	#category : #building,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 15:25'
}
SWAGameMobModel >> part: aLimb box: aBox color: aColor [
	self part: aLimb pivot: #(0 0) box: aBox color: aColor.
]

{
	#category : #building,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 15:25'
}
SWAGameMobModel >> part: aLimb pivot: aPivot box: aBox color: aColor [
	"aPivot is y z in pixels, aBox x0 y0 z0 x1 y1 z1 in pixels with the upper bounds exclusive. A block is 16 pixels, +z is forward and x = 0 the middle. Later boxes paint over earlier ones of the same group."
	| cells |
	cells := groups
		at: {self class codeOf: aLimb. aPivot first. aPivot second}
		ifAbsentPut: [Dictionary new].
	(aBox at: 1) to: (aBox at: 4) - 1 do: [:x |
		(aBox at: 2) to: (aBox at: 5) - 1 do: [:y |
			(aBox at: 3) to: (aBox at: 6) - 1 do: [:z |
				cells at: (self keyX: x y: y z: z) put: aColor]]].
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 15:25'
}
SWAGameMobModel >> pixelScale [
	^ pixelScale
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 15:25'
}
SWAGameMobModel >> pixelScale: anObject [
	pixelScale := anObject.
]

{
	#category : #meshing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 15:25'
}
SWAGameMobModel >> shadeX: x y: y z: z [
	"A little per-voxel brightness noise, the grain a Minecraft texture has."
	^ 0.9 + ((((x * 73856093) bitXor: (y * 19349663)) bitXor: (z * 83492791)) \\ 6 * 0.02)
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 15:25'
}
SWAGameMobModel >> strideCells [
	^ strideCells
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 15:25'
}
SWAGameMobModel >> strideCells: anObject [
	strideCells := anObject.
]

{
	#category : #animating,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 15:26'
}
SWAGameMobModel >> writePose: aByteArray phase: phase swing: swing eating: isEating time: seconds [
	"Radians, in the order the swagameMob shader reads its pose: legs A, legs B, head pitch (down is positive), tail yaw. A positive leg angle swings the foot backwards."
	| s legA legB head tail |
	s := phase sin * swing.
	gait == #hop
		ifTrue: [
			legA := s negated.
			legB := s * 1.3.
			tail := 0.0]
		ifFalse: [
			legA := s.
			legB := s negated.
			tail := ((seconds * 2.5) sin * 0.2) + ((phase * 0.5) sin * 0.3 * swing)].
	head := isEating
		ifTrue: [0.5 + ((seconds * 14) sin * 0.08)]
		ifFalse: [0.0].
	aByteArray
		floatAt: 1 put: legA;
		floatAt: 5 put: legB;
		floatAt: 9 put: head;
		floatAt: 13 put: tail.
]
