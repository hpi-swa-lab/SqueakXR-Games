"
A falling drop of water that expires after a short lifetime.
"
Class {
	#name : #SRWaterDrop,
	#superclass : #SRObject,
	#instVars : [
		'velocity',
		'age'
	],
	#category : #'SWAGame-WateringCan',
	#'squeak_changestamp' : '<historical>'
}

{
	#category : #constants,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:06'
}
SRWaterDrop class >> color [

	^ Color r: 0.35 g: 0.6 b: 1.0
]

{
	#category : #constants,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:06'
}
SRWaterDrop class >> gravity [

	^ 0 @ -9.81 @ 0
]

{
	#category : #constants,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:06'
}
SRWaterDrop class >> lifetime [
	"in seconds"

	^ 1.2
]

{
	#category : #constants,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:06'
}
SRWaterDrop class >> size [

	^ 0.8cm @ 1.2cm @ 0.8cm
]

{
	#category : #initialization,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:06'
}
SRWaterDrop >> initialize [

	super initialize.
	
	age := 0.
	velocity := Vector3 zero.
]

{
	#category : #testing,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:06'
}
SRWaterDrop >> isExpired [

	^ age > self class lifetime or: [self globalTranslation y < 0]
]

{
	#category : #rendering,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:06'
}
SRWaterDrop >> renderOn: aSRRenderer [

	aSRRenderer
		renderSphereTransformed: self globalTransform * (Matrix4x4 withScale: self class size)
		withColor: self class color.
]

{
	#category : #stepping,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:17'
}
SRWaterDrop >> step: deltaTime [

	| from |
	age := age + deltaTime.
	self isExpired ifTrue: [^ self remove].
	
	from := self globalTranslation.
	velocity := velocity + (self class gravity * deltaTime).
	self globalTranslation: from + (velocity * deltaTime).
	(self watersTargetFrom: from to: self globalTranslation) ifTrue: [self remove].
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:06'
}
SRWaterDrop >> velocity [

	^ velocity
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:06'
}
SRWaterDrop >> velocity: aVector3 [

	velocity := aVector3.
]

{
	#category : #stepping,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:17'
}
SRWaterDrop >> watersTargetFrom: start to: end [

	self world ifNil: [^ false].
	^ self world children anySatisfy: [:each |
		(each respondsTo: #wateredFrom:to:)
			and: [each wateredFrom: start to: end]]
]
