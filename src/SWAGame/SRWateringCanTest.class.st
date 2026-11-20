"
Tests SRWateringCan.
"
Class {
	#name : #SRWateringCanTest,
	#superclass : #TestCase,
	#instVars : [
		'scene',
		'can'
	],
	#category : #'SWAGame-Tests',
	#'squeak_changestamp' : '<historical>'
}

{
	#category : #running,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:07'
}
SRWateringCanTest >> setUp [

	super setUp.
	scene := SRObject new.
	can := SRWateringCan new.
	scene addChild: can.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:07'
}
SRWateringCanTest >> testATiltedCanPoursFromTheSpout [

	self tilt.
	self assert: can isPouring.
	can step: 0.1.
	self deny: can drops isEmpty.
	self assert: (can drops allSatisfy: [:each |
		each parent == scene and: [(each globalTranslation - can spoutTip) length < 0.0001]]).
]

{
	#category : #tests,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:07'
}
SRWateringCanTest >> testAnUprightCanDoesNotPour [

	self deny: can isPouring.
	can step: 1.
	self assert: can drops isEmpty.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:07'
}
SRWateringCanTest >> testExpiredDropsAreForgotten [

	self tilt.
	can step: 0.1.
	can drops do: [:each | each step: SRWaterDrop lifetime * 2].
	can rotation: Quaternion identity.
	can step: 0.
	self assert: can drops isEmpty.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:07'
}
SRWateringCanTest >> testPouringStopsWhenUpright [

	| count |
	self tilt.
	can step: 0.1.
	count := can drops size.
	can rotation: Quaternion identity.
	can step: 1.
	self assert: can drops size = count.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:07'
}
SRWateringCanTest >> testTheNumberOfDropsIsBounded [

	self tilt.
	can step: 100.
	can step: 100.
	self assert: can drops size = SRWateringCan maxDrops.
]

{
	#category : #running,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:07'
}
SRWateringCanTest >> tilt [

	can rotation: (Quaternion angle: -90 axis: Vector3 right).
]
