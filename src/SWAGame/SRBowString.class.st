"
The grabbable nock point of an SRBow string. Draw is measured along the bow.
"
Class {
	#name : #SRBowString,
	#superclass : #SRObject,
	#instVars : [
		'hand',
		'grabOffset',
		'nock',
		'draw'
	],
	#category : #'SWAGame-Bow',
	#'squeak_changestamp' : '<historical>'
}

{
	#category : #drawing,
	#'squeak_changestamp' : 'leo-MCPServer 11/18/2026 18:01'
}
SRBowString >> aimDirectionFor: anOffset [

	| direction lateral maxAngle |
	direction := anOffset safelyNormalized.
	maxAngle := SRBow maxAimAngle degreesToRadians.
	(direction dot: Vector3 backward) >= maxAngle cos ifTrue: [^ direction].
	lateral := direction x @ direction y @ 0.
	lateral length < 0.001 ifTrue: [^ Vector3 backward].
	^ (lateral normalized * maxAngle sin) + (Vector3 backward * maxAngle cos)
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'leo-MCPServer 11/18/2026 17:55'
}
SRBowString >> bow [

	^ parent
]

{
	#category : #collisions,
	#'squeak_changestamp' : 'leo-MCPServer 11/18/2026 17:55'
}
SRBowString >> collisionGeometry [

	^ SRCollisionBox new
		center: self globalTranslation;
		size: 8cm asVector3;
		rotation: self globalRotation;
		object: self
]

{
	#category : #grabbing,
	#'squeak_changestamp' : 'leo-MCPServer 11/18/2026 17:55'
}
SRBowString >> dragTo: aMatrix4x4 [
	"The bow moves the string along its own axis instead."
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'leo-MCPServer 11/18/2026 17:55'
}
SRBowString >> draw [

	^ draw
]

{
	#category : #drawing,
	#'squeak_changestamp' : 'leo-MCPServer 11/18/2026 18:01'
}
SRBowString >> handPoint [

	^ self bow globalTransform globalPointToLocal: hand globalTranslation
]

{
	#category : #initialization,
	#'squeak_changestamp' : 'leo-MCPServer 11/18/2026 18:01'
}
SRBowString >> initialize [

	super initialize.
	self resetDraw.
	self addChild: (SRCube color: SRBow accentColor size: 1.5cm asVector3 at: 0 @ 0 @ 0)
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'leo-MCPServer 11/18/2026 18:01'
}
SRBowString >> nock [

	^ nock
]

{
	#category : #grabbing,
	#'squeak_changestamp' : 'leo-MCPServer 11/18/2026 18:01'
}
SRBowString >> onGrabStarted: aHand [

	hand := aHand.
	grabOffset := nil
]

{
	#category : #grabbing,
	#'squeak_changestamp' : 'leo-MCPServer 11/18/2026 17:55'
}
SRBowString >> onGrabStopped: aHand [

	hand := nil.
	self bow ifNotNil: [:aBow | aBow release]
]

{
	#category : #drawing,
	#'squeak_changestamp' : 'leo-MCPServer 11/18/2026 18:01'
}
SRBowString >> pullTo: aPoint [

	| offset length |
	offset := aPoint - SRBow arrowRestPoint.
	length := (offset length max: SRBow braceHeight) min: SRBow braceHeight + SRBow maxDraw.
	nock := SRBow arrowRestPoint + ((self aimDirectionFor: offset) * length).
	draw := length - SRBow braceHeight
]

{
	#category : #drawing,
	#'squeak_changestamp' : 'leo-MCPServer 11/18/2026 18:01'
}
SRBowString >> resetDraw [

	grabOffset := nil.
	nock := SRBow restNockPoint.
	draw := 0
]

{
	#category : #drawing,
	#'squeak_changestamp' : 'leo-MCPServer 11/18/2026 18:01'
}
SRBowString >> updateDraw [

	grabOffset ifNil: [grabOffset := self handPoint - nock].
	self pullTo: self handPoint - grabOffset
]

{
	#category : #grabbing,
	#'squeak_changestamp' : 'leo-MCPServer 11/18/2026 17:55'
}
SRBowString >> wantsGrab [

	^ self bow notNil and: [self bow isHeld]
]
