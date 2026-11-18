"
One 3D-DDA march of a ray through the voxels.

Split into small methods because as a single 1552-byte method Cog's ARM64 JIT miscompiled it, and merely calling it crashed SqueakXR on the Quest. Keep them small. See journal/2026-07-29-arm-jit-voxel-collider-crash.md.
"
Class {
	#name : #SWAGameVoxelRayWalk,
	#superclass : #Object,
	#instVars : [
		'game',
		'grid',
		'gxLo',
		'gxHi',
		'gyHi',
		'gzLo',
		'gzHi',
		'ws',
		'ox',
		'oy',
		'oz',
		'dx',
		'dy',
		'dz',
		'tEnter',
		'tExit',
		'tHit',
		'nx',
		'ny',
		'nz',
		'gx',
		'gy',
		'gz',
		'stepX',
		'stepY',
		'stepZ',
		'tMaxX',
		'tMaxY',
		'tMaxZ',
		'tDeltaX',
		'tDeltaY',
		'tDeltaZ'
	],
	#category : #'SWAGame-XR',
	#'squeak_changestamp' : '<historical>'
}

{
	#category : #'instance creation',
	#'squeak_changestamp' : 'MCPServer 7/29/2026 15:29'
}
SWAGameVoxelRayWalk class >> game: aGame ray: aRay [
	"Answer a walk ready to march aRay through aGame's grid, or nil if the ray
	 or the game cannot be used."
	^ self new setGame: aGame ray: aRay
]

{
	#category : #clipping,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 17:31'
}
SWAGameVoxelRayWalk >> clipAxis: axisIndex origin: o direction: d from: lo to: hi [
	"Clip the ray against one pair of slab planes, narrowing tEnter/tExit. When
	 this axis becomes the entry face, remember its normal. Answer false if the
	 ray misses this slab entirely."
	| t1 t2 swap |
	d abs < self tiny ifTrue: [
		"Parallel to this axis: either we are inside the slab for the whole ray,
		 or we never are."
		^ o >= lo and: [o <= hi]].
	t1 := lo - o / d.
	t2 := hi - o / d.
	t1 > t2 ifTrue: [swap := t1. t1 := t2. t2 := swap].
	t1 > tEnter ifTrue: [
		tEnter := t1.
		self entryNormalAxis: axisIndex sign: (d > 0 ifTrue: [-1] ifFalse: [1])].
	tExit := tExit min: t2.
	^ true
]

{
	#category : #clipping,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 17:31'
}
SWAGameVoxelRayWalk >> clipToGrid [
	"Slab-clip against the grid box so we start marching at the surface of the
	 grid, not at the camera. The clip also gives us the entry face for free.
	 Answer whether any part of the ray is inside the box."
	tEnter := 0.0.
	tExit := Float infinity.
	self entryNormalAxis: 2 sign: 1.
	(self clipAxis: 1 origin: ox direction: dx from: gxLo to: gxHi) ifFalse: [^ false].
	(self clipAxis: 2 origin: oy direction: dy from: 0 to: gyHi) ifFalse: [^ false].
	(self clipAxis: 3 origin: oz direction: dz from: gzLo to: gzHi) ifFalse: [^ false].
	^ tExit >= tEnter and: [tExit >= 0]
]

{
	#category : #clipping,
	#'squeak_changestamp' : 'MCPServer 7/29/2026 15:29'
}
SWAGameVoxelRayWalk >> entryNormalAxis: axisIndex sign: aSign [
	"The face we entered through, as a unit normal along one axis."
	nx := 0. ny := 0. nz := 0.
	axisIndex = 1 ifTrue: [^ nx := aSign].
	axisIndex = 2 ifTrue: [^ ny := aSign].
	nz := aSign
]

{
	#category : #marching,
	#'squeak_changestamp' : 'MCPServer 7/29/2026 15:29'
}
SWAGameVoxelRayWalk >> findHit [
	"Answer {gx. gy. gz. faceNormal. gridEntryPoint} for the first solid voxel the
	 ray enters, or nil if it misses the terrain."
	self clipToGrid ifFalse: [^ nil].
	self prepareStepping.
	^ self march
]

{
	#category : #initialization,
	#'squeak_changestamp' : 'MCPServer 7/29/2026 15:29'
}
SWAGameVoxelRayWalk >> hasUsableRay [
	"An untracked XR controller pose yields a zero-length direction, and
	 Vector3>>normalize silently turns that into NaN. Every comparison against NaN
	 answers false, so NaN would slip through the whole slab clip below and only
	 blow up much later at #floor. Reject it here: a ray we cannot interpret
	 simply hits nothing."
	^ ox isFinite and: [oy isFinite and: [oz isFinite
		and: [dx isFinite and: [dy isFinite and: [dz isFinite]]]]]
]

{
	#category : #marching,
	#'squeak_changestamp' : 'MCPServer 7/29/2026 15:30'
}
SWAGameVoxelRayWalk >> hitResult [
	"{gx. gy. gz. faceNormal. gridEntryPoint} -- the shape SWAGameVoxelCollider
	 and SWAGameXR expect."
	^ {gx. gy. gz.
		Vector3 x: nx y: ny z: nz.
		Vector3
			x: ox + (tHit * dx)
			y: oy + (tHit * dy)
			z: oz + (tHit * dz)}
]

{
	#category : #testing,
	#'squeak_changestamp' : 'MCPServer 7/29/2026 15:30'
}
SWAGameVoxelRayWalk >> isCurrentVoxelSolid [
	^ (grid at: gx at: gy at: gz) ~= 0
]

{
	#category : #testing,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 17:31'
}
SWAGameVoxelRayWalk >> isInsideGrid [
	^ (gx between: gxLo and: gxHi - 1)
		and: [(gy between: 0 and: gyHi - 1)
			and: [gz between: gzLo and: gzHi - 1]]
]

{
	#category : #marching,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 17:31'
}
SWAGameVoxelRayWalk >> march [
	"Walk voxel by voxel until we hit something solid, leave the grid, or run past
	 the exit point. Bounded by the longest possible path through the box."
	| maxSteps |
	maxSteps := gxHi - gxLo + gyHi + (gzHi - gzLo) + 3.
	maxSteps timesRepeat: [
		self isInsideGrid ifFalse: [^ nil].
		self isCurrentVoxelSolid ifTrue: [^ self hitResult].
		self stepToNextVoxel.
		tHit > tExit ifTrue: [^ nil]].
	^ nil
]

{
	#category : #marching,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 17:31'
}
SWAGameVoxelRayWalk >> prepareStepping [
	"Start at the voxel holding the entry point, clamped: entering exactly on the
	 far face floors to the upper bound, which is one past the last voxel."
	tHit := tEnter.
	gx := ((ox + (tEnter * dx)) floor max: gxLo) min: gxHi - 1.
	gy := ((oy + (tEnter * dy)) floor max: 0) min: gyHi - 1.
	gz := ((oz + (tEnter * dz)) floor max: gzLo) min: gzHi - 1.
	stepX := self stepFor: dx.
	stepY := self stepFor: dy.
	stepZ := self stepFor: dz.
	tDeltaX := self tDeltaFor: dx.
	tDeltaY := self tDeltaFor: dy.
	tDeltaZ := self tDeltaFor: dz.
	tMaxX := self tMaxFor: dx step: stepX voxel: gx origin: ox.
	tMaxY := self tMaxFor: dy step: stepY voxel: gy origin: oy.
	tMaxZ := self tMaxFor: dz step: stepZ voxel: gz origin: oz
]

{
	#category : #initialization,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 17:31'
}
SWAGameVoxelRayWalk >> setGame: aGame ray: aRay [
	"World space -> game local space -> grid space. Answer self if the result can
	 be marched, nil otherwise."
	| m o d bounds |
	game := aGame.
	game ifNil: [^ nil].
	grid := game gridHandle.
	grid ifNil: [^ nil].
	ws := game worldScale.
	(ws isNil or: [ws = 0]) ifTrue: [^ nil].
	"The march box grows with the generated world, in both directions; the
	centring offset below stays gridWidth, which is where the object space has
	its origin."
	bounds := game marchBounds.
	gxLo := bounds first.
	gxHi := bounds second.
	gzLo := bounds third.
	gzHi := bounds fourth.
	gyHi := game gridHeight.
	m := game globalTransform.
	o := m globalPointToLocal: aRay origin.
	d := m globalDirToLocal: aRay forward.
	ox := (o x / ws) + (game gridWidth / 2.0).
	oy := o y / ws.
	oz := (o z / ws) + (game gridDepth / 2.0).
	dx := d x / ws. dy := d y / ws. dz := d z / ws.
	^ self hasUsableRay ifTrue: [self] ifFalse: [nil]
]

{
	#category : #marching,
	#'squeak_changestamp' : 'MCPServer 7/29/2026 15:29'
}
SWAGameVoxelRayWalk >> stepFor: aDirectionComponent [
	"Which way we walk along this axis: +1, -1, or 0 when parallel."
	aDirectionComponent > self tiny ifTrue: [^ 1].
	aDirectionComponent < self tiny negated ifTrue: [^ -1].
	^ 0
]

{
	#category : #marching,
	#'squeak_changestamp' : 'MCPServer 7/29/2026 15:30'
}
SWAGameVoxelRayWalk >> stepToNextVoxel [
	"Cross into the neighbouring voxel over the nearest boundary. The axis we
	 stepped along is the face we enter through, hence the normal."
	(tMaxX <= tMaxY and: [tMaxX <= tMaxZ]) ifTrue: [
		tHit := tMaxX.
		gx := gx + stepX.
		tMaxX := tMaxX + tDeltaX.
		^ self entryNormalAxis: 1 sign: stepX negated].
	tMaxY <= tMaxZ ifTrue: [
		tHit := tMaxY.
		gy := gy + stepY.
		tMaxY := tMaxY + tDeltaY.
		^ self entryNormalAxis: 2 sign: stepY negated].
	tHit := tMaxZ.
	gz := gz + stepZ.
	tMaxZ := tMaxZ + tDeltaZ.
	self entryNormalAxis: 3 sign: stepZ negated
]

{
	#category : #marching,
	#'squeak_changestamp' : 'MCPServer 7/29/2026 15:29'
}
SWAGameVoxelRayWalk >> tDeltaFor: aDirectionComponent [
	"How much t advances when crossing one whole voxel along this axis."
	^ (self stepFor: aDirectionComponent) = 0
		ifTrue: [Float infinity]
		ifFalse: [1.0 / aDirectionComponent abs]
]

{
	#category : #marching,
	#'squeak_changestamp' : 'MCPServer 7/29/2026 15:29'
}
SWAGameVoxelRayWalk >> tMaxFor: aDirectionComponent step: aStep voxel: aVoxelIndex origin: anOrigin [
	"t at which the ray first crosses a voxel boundary along this axis."
	| boundary |
	aStep = 0 ifTrue: [^ Float infinity].
	boundary := aStep > 0 ifTrue: [aVoxelIndex + 1] ifFalse: [aVoxelIndex].
	^ boundary - anOrigin / aDirectionComponent
]

{
	#category : #constants,
	#'squeak_changestamp' : 'MCPServer 7/29/2026 15:29'
}
SWAGameVoxelRayWalk >> tiny [
	"Below this a direction component counts as parallel to the axis."
	^ 1.0e-9
]
