"
A placed block as its own object, from before terrain was meshed.

Unused: nothing in the image sends it.
"
Class {
	#name : #SWAGameCube,
	#superclass : #SRObject,
	#instVars : [
		'gridCoord',
		'cube'
	],
	#category : #SWAGame,
	#'squeak_changestamp' : '<historical>'
}

{
	#category : #'xr menu',
	#'squeak_changestamp' : 'MCPServer 8/3/2026 13:36'
}
SWAGameCube class >> xrMenuSpawn: aMenu [
	<xrMenu: #(world spawn) label: 'SWACube' priority: 110>
	| cube |
	cube := self new
		position: aMenu position;
		scale: 10cm asVector3;
		color: Color green;
		yourself.
	aMenu world addChild: cube.
	^ cube
]

{
	#category : #rendering,
	#'squeak_changestamp' : 'MCPServer 4/30/2026 11:54'
}
SWAGameCube >> collisionGeometry [

	^ SRCollisionBox new
		center: self globalTranslation;
		halfExtents: self globalScale / 2.0;
		rotation: self globalRotation;
		object: self
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 4/28/2026 14:48'
}
SWAGameCube >> color [

	^ cube color
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 4/28/2026 14:48'
}
SWAGameCube >> color: aColor [

	cube color: aColor
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 4/22/2026 17:52'
}
SWAGameCube >> gridCoord [

	^ gridCoord
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 4/22/2026 17:52'
}
SWAGameCube >> gridCoord: aGridCoord [

	gridCoord := aGridCoord
]

{
	#category : #initialization,
	#'squeak_changestamp' : 'MCPServer (jl) 11/16/2026 11:37'
}
SWAGameCube >> initialize [

	super initialize.
	cube := SRCube new.
	cube color: Color green.
	self addChild: cube.
	"SRCube has its own collision box, so rays hit it before me."
	cube grabTarget: self.
]

{
	#category : #events,
	#'squeak_changestamp' : 'MCPServer 4/22/2026 18:01'
}
SWAGameCube >> onGrabStartFrom: aSRHand [

	| game |
	
	game := self parent.
	(gridCoord notNil and: [game notNil and: [game respondsTo: #removeBoxAt:]]) ifTrue: [
		game removeBoxAt: gridCoord].
	
	"Do not keep grabbing cubes in SWAGame3D; grabbing deletes them."
	(aSRHand notNil and: [aSRHand respondsTo: #stopGrabbing]) ifTrue: [
		aSRHand stopGrabbing].
]

{
	#category : #events,
	#'squeak_changestamp' : 'MCPServer 4/22/2026 18:00'
}
SWAGameCube >> onGrabStopFrom: aSRHand [

	"No-op: cubes are deleted on grab start in SWAGame3D."
]

{
	#category : #events,
	#'squeak_changestamp' : 'MCPServer 4/22/2026 17:52'
}
SWAGameCube >> onRaycast: aSRRayIntersectionResult [

	| aboveCoord |
	
	super onRaycast: aSRRayIntersectionResult.
	self color: Color red.
	
	(gridCoord isNil or: [self parent isNil]) ifTrue: [^ self].
	aboveCoord := gridCoord x @ (gridCoord y + 1) @ gridCoord z.
	self parent placeBoxAt: aboveCoord.
]

{
	#category : #hierarchy,
	#'squeak_changestamp' : 'MCPServer (jl) 11/16/2026 11:28'
}
SWAGameCube >> wantsGrab [

	^ true
]
