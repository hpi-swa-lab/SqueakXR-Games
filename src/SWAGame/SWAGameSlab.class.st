"
The tray XR panels are built on.

Its face is local +y and rows run along local z, so a rotation without a quarter turn about x leaves it looking at the sky.
"
Class {
	#name : #SWAGameSlab,
	#superclass : #SRObject,
	#instVars : [
		'slabWidth',
		'slabHeight',
		'slabDepth',
		'slabColor',
		'wireColor'
	],
	#category : #SWAGame,
	#'squeak_changestamp' : '<historical>'
}

{
	#category : #collisions,
	#'squeak_changestamp' : 'MCPServer 5/18/2026 18:34'
}
SWAGameSlab >> collisionGeometry [
	^ SRCollisionBox new
		center: self globalTranslation;
		halfExtents: self globalScale * (Vector3 x: slabWidth / 2 y: slabDepth / 2 z: slabHeight / 2);
		rotation: self globalRotation;
		object: self
]

{
	#category : #initialization,
	#'squeak_changestamp' : 'MCPServer 5/18/2026 18:33'
}
SWAGameSlab >> initialize [
	super initialize.
	slabWidth := 10.
	slabHeight := 5.
	slabDepth := 0.3.
	slabColor := Color r: 0.05 g: 0.05 b: 0.1.
	wireColor := Color r: 0.3 g: 0.3 b: 0.5
]

{
	#category : #rendering,
	#'squeak_changestamp' : 'MCPServer 5/18/2026 18:34'
}
SWAGameSlab >> renderOn: aSRRenderer [
	Raylib rlPushMatrix;
		rlMultMatrixfMatf: self globalTransform transposed.
	self renderSlab.
	Raylib rlPopMatrix
]

{
	#category : #rendering,
	#'squeak_changestamp' : 'MCPServer 5/18/2026 18:34'
}
SWAGameSlab >> renderSlab [
	"Draw the slab box. Call from within rlPushMatrix/rlPopMatrix."
	Raylib
		drawCubePosition: (Vector3 x: 0 y: 0 z: 0) asRlVector
		width: slabWidth height: slabDepth length: slabHeight
		color: slabColor asRlColor.
	Raylib
		drawCubeWiresPosition: (Vector3 x: 0 y: 0 z: 0) asRlVector
		width: slabWidth height: slabDepth length: slabHeight
		color: wireColor asRlColor
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 5/18/2026 18:33'
}
SWAGameSlab >> slabDepth [
	^ slabDepth
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 5/18/2026 18:40'
}
SWAGameSlab >> slabDepth: aNumber [
	slabDepth := aNumber
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 5/18/2026 18:33'
}
SWAGameSlab >> slabHeight [
	^ slabHeight
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 5/18/2026 18:33'
}
SWAGameSlab >> slabWidth [
	^ slabWidth
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 5/18/2026 18:33'
}
SWAGameSlab >> slabWidth: w height: h [
	slabWidth := w.
	slabHeight := h
]
