"
An arrow. Once launched, it flies under gravity until it sticks into a morph panel or falls below the despawn height.
"
Class {
	#name : #SRArrow,
	#superclass : #SRObject,
	#instVars : [
		'velocity',
		'hitSound'
	],
	#classVars : [
		'DespawnHeight'
	],
	#category : #'SWAGame-Bow',
	#'squeak_changestamp' : '<historical>'
}

{
	#category : #preferences,
	#'squeak_changestamp' : 'leo-MCPServer 11/18/2026 18:26'
}
SRArrow class >> despawnHeight [
	<preference: 'Arrow despawn height'
		category: 'SWAGame'
		description: 'Flying arrows are removed once they fall below this world height in meters.'
		type: #Number>

	^ DespawnHeight ifNil: [-5m]
]

{
	#category : #preferences,
	#'squeak_changestamp' : 'leo-MCPServer 11/18/2026 17:55'
}
SRArrow class >> despawnHeight: aNumber [

	DespawnHeight := aNumber
]

{
	#category : #constants,
	#'squeak_changestamp' : 'leo-MCPServer 11/18/2026 17:55'
}
SRArrow class >> gravity [

	^ 0 @ -9.81 @ 0
]

{
	#category : #constants,
	#'squeak_changestamp' : 'leo-MCPServer 11/18/2026 17:55'
}
SRArrow class >> length [

	^ 75cm
]

{
	#category : #constants,
	#'squeak_changestamp' : 'leo-MCPServer 11/23/2026 15:00'
}
SRArrow class >> penetrationDepth [

	^ 3cm
]

{
	#category : #constants,
	#'squeak_changestamp' : 'leo-MCPServer 11/23/2026 15:00'
}
SRArrow class >> tipDistance [

	^ self length + 2cm
]

{
	#category : #initialization,
	#'squeak_changestamp' : 'leo-MCPServer 11/18/2026 17:55'
}
SRArrow >> buildModel [

	| length shaft head fletching |
	length := self class length.
	shaft := Color r: 0.85 g: 0.7 b: 0.45.
	head := Color r: 0.8 g: 0.85 b: 0.9.
	fletching := Color r: 0.95 g: 0.2 b: 0.35.
	self addChildren: {
		SRCube color: shaft from: 0 @ 0 @ 0 to: 0 @ 0 @ length negated thickness: 0.8cm.
		SRCube color: head size: 1.6cm @ 1.6cm @ 4cm at: 0 @ 0 @ (2cm - length).
		SRCube color: head size: 0.6cm @ 0.6cm @ 2cm at: 0 @ 0 @ (-1cm - length).
		SRCube color: fletching size: 0.2cm @ 3cm @ 9cm at: 0 @ 0 @ -6cm.
		SRCube color: fletching size: 3cm @ 0.2cm @ 9cm at: 0 @ 0 @ -6cm.
		SRCube color: Color white size: 1cm @ 1cm @ 1.5cm at: 0 @ 0 @ 0}
]

{
	#category : #initialization,
	#'squeak_changestamp' : 'leo-MCPServer 11/26/2026 18:41'
}
SRArrow >> initialize [

	super initialize.
	isStepping := false.
	velocity := Vector3 zero.
	self buildModel.
	self initializeSounds
]

{
	#category : #initialization,
	#'squeak_changestamp' : 'leo-MCPServer 11/26/2026 18:41'
}
SRArrow >> initializeSounds [

	hitSound := SRAudioPlayer new filepath: (SRBow soundPath: 'arrow-hit.ogg').
	self addChild: hitSound
]

{
	#category : #testing,
	#'squeak_changestamp' : 'leo-MCPServer 11/23/2026 15:00'
}
SRArrow >> isStuck [

	^ parent notNil and: [parent isMorphPanel]
]

{
	#category : #flying,
	#'squeak_changestamp' : 'leo-MCPServer 11/18/2026 17:55'
}
SRArrow >> launchWith: aVelocity [

	velocity := aVelocity.
	isStepping := true.
	self pointAlongVelocity
]

{
	#category : #sticking,
	#'squeak_changestamp' : 'leo-MCPServer 11/23/2026 15:00'
}
SRArrow >> panelHitFrom: start to: end [

	| segment hit |
	segment := end - start.
	segment isZero ifTrue: [^ nil].
	hit := (SRRay origin: start forward: segment normalized) castNearestObjects: self panelSurfaces.
	hit ifNil: [^ nil].
	^ (start distanceTo: hit point) <= segment length
		ifTrue: [hit]
]

{
	#category : #sticking,
	#'squeak_changestamp' : 'leo-MCPServer 11/23/2026 15:00'
}
SRArrow >> panelSurfaces [

	^ Array streamContents: [:stream |
		self sceneRoot allDo: [:each |
			each isMorphPanel ifTrue: [stream nextPut: each plane]]]
]

{
	#category : #flying,
	#'squeak_changestamp' : 'leo-MCPServer 11/18/2026 18:23'
}
SRArrow >> pointAlongVelocity [

	| forward |
	velocity isZero ifTrue: [^ self].
	forward := velocity normalized.
	self globalRotation: (Quaternion forward: forward up: (self tangentUpFor: forward))
]

{
	#category : #stepping,
	#'squeak_changestamp' : 'leo-MCPServer 11/23/2026 15:00'
}
SRArrow >> step: deltaTime [

	| tip |
	tip := self tip.
	velocity := velocity + (self class gravity * deltaTime).
	self globalTranslation: self globalTranslation + (velocity * deltaTime).
	self pointAlongVelocity.
	(self panelHitFrom: tip to: self tip) ifNotNil: [:hit | ^ self stickInto: hit].
	self globalTranslation y < self class despawnHeight ifTrue: [self remove]
]

{
	#category : #sticking,
	#'squeak_changestamp' : 'leo-MCPServer 11/26/2026 18:41'
}
SRArrow >> stickInto: anIntersection [

	| transform |
	velocity := Vector3 zero.
	isStepping := false.
	self globalTranslation: anIntersection point - (self forward * (self class tipDistance - self class penetrationDepth)).
	transform := self globalTransform copy.
	anIntersection object parent addChild: self.
	self globalTransform: transform.
	self allDo: [:each | each ignoreCollision: true].
	hitSound play
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'leo-MCPServer 11/23/2026 15:00'
}
SRArrow >> tip [

	^ self globalTranslation + (self forward * self class tipDistance)
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'leo-MCPServer 11/18/2026 17:55'
}
SRArrow >> velocity [

	^ velocity
]
