"
A labelled cube with an action block, for the XR panels.
"
Class {
	#name : #SWAGameButton,
	#superclass : #SRObject,
	#instVars : [
		'buttonColor',
		'label',
		'action',
		'selected'
	],
	#category : #SWAGame,
	#'squeak_changestamp' : '<historical>'
}

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 5/13/2026 17:08'
}
SWAGameButton >> action: aBlock [
	action := aBlock
]

{
	#category : #rendering,
	#'squeak_changestamp' : 'MCPServer 5/13/2026 17:08'
}
SWAGameButton >> collisionGeometry [
	"Provide a collision box so the button can be raycasted/clicked."
	^ SRCollisionBox new
		center: self globalTranslation;
		halfExtents: self globalScale / 2.0;
		rotation: self globalRotation;
		object: self
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 5/13/2026 17:08'
}
SWAGameButton >> color [
	^ buttonColor
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 5/13/2026 17:08'
}
SWAGameButton >> color: aColor [
	buttonColor := aColor
]

{
	#category : #initialization,
	#'squeak_changestamp' : 'MCPServer 5/13/2026 17:54'
}
SWAGameButton >> initialize [
	super initialize.
	buttonColor := Color gray.
	label := 'Button'.
	action := [].
	selected := false
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 5/13/2026 17:08'
}
SWAGameButton >> label: aString [
	label := aString
]

{
	#category : #events,
	#'squeak_changestamp' : 'MCPServer (jl) 11/10/2026 19:16'
}
SWAGameButton >> onButtonPress: aButtonEvent [

	aButtonEvent button == #trigger ifTrue: [action value].
]

{
	#category : #events,
	#'squeak_changestamp' : 'MCPServer 5/13/2026 17:08'
}
SWAGameButton >> onRaycast: aSRRayIntersectionResult [
	"Execute the action block when clicked."
	super onRaycast: aSRRayIntersectionResult.
	action value
]

{
	#category : #rendering,
	#'squeak_changestamp' : 'MCPServer 5/13/2026 17:55'
}
SWAGameButton >> renderOn: aSRRenderer [
	"Draw button as a colored cube. When selected, draw a bright yellow wireframe."
	| transform |
	transform := self globalTransform.
	aSRRenderer renderCubeTransformed: transform withColor: buttonColor.
	(selected ifNil: [false]) ifTrue: [
		Raylib rlPushMatrix;
			rlMultMatrixfMatf: transform transposed.
		Raylib
			drawCubeWiresPosition: Vector3 zero asRlVector
				width: 1.15 height: 1.15 length: 1.15
				color: Color yellow asRlColor.
		Raylib rlPopMatrix]
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 5/13/2026 17:54'
}
SWAGameButton >> selected [
	^ selected ifNil: [false]
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 5/13/2026 17:54'
}
SWAGameButton >> selected: aBoolean [
	selected := aBoolean
]
