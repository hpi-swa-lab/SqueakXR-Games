"
Tests SRArrow flight.
"
Class {
	#name : #SRArrowTest,
	#superclass : #TestCase,
	#instVars : [
		'scene',
		'arrow',
		'savedDespawnHeight'
	],
	#category : #'SWAGame-Tests',
	#'squeak_changestamp' : '<historical>'
}

{
	#category : #running,
	#'squeak_changestamp' : 'leo-MCPServer 11/18/2026 17:56'
}
SRArrowTest >> setUp [

	super setUp.
	savedDespawnHeight := SRArrow classPool at: #DespawnHeight.
	SRArrow despawnHeight: nil.
	scene := SRObject new.
	arrow := SRArrow new.
	scene addChild: arrow
]

{
	#category : #running,
	#'squeak_changestamp' : 'leo-MCPServer 11/18/2026 17:56'
}
SRArrowTest >> tearDown [

	SRArrow despawnHeight: savedDespawnHeight.
	super tearDown
]

{
	#category : #tests,
	#'squeak_changestamp' : 'leo-MCPServer 11/18/2026 17:57'
}
SRArrowTest >> testAStraightDownFlightStaysWellDefined [

	arrow globalTranslation: 0 @ 2m @ 0.
	arrow launchWith: 0 @ -10 @ 0.
	arrow step: 0.1.
	self assert: ((arrow forward dot: Vector3 down) closeTo: 1).
	self deny: arrow globalTranslation y isNaN
]

{
	#category : #tests,
	#'squeak_changestamp' : 'leo-MCPServer 11/18/2026 17:56'
}
SRArrowTest >> testGravityPullsTheFlightDown [

	arrow globalTranslation: 0 @ 2m @ 0.
	arrow launchWith: 0 @ 0 @ -20.
	arrow step: 0.1.
	self assert: (arrow velocity - (0 @ -0.981 @ -20)) length < 0.0001.
	self assert: (arrow globalTranslation - (0 @ 1.9019m @ -2m)) length < 0.0001
]

{
	#category : #tests,
	#'squeak_changestamp' : 'leo-MCPServer 11/18/2026 17:56'
}
SRArrowTest >> testOnlyFlyingArrowsStep [

	self deny: arrow isStepping.
	arrow launchWith: 0 @ 0 @ -10.
	self assert: arrow isStepping
]

{
	#category : #tests,
	#'squeak_changestamp' : 'leo-MCPServer 11/18/2026 17:56'
}
SRArrowTest >> testTheArrowDespawnsBelowTheThreshold [

	SRArrow despawnHeight: -1m.
	arrow globalTranslation: 0 @ -0.95m @ 0.
	arrow launchWith: 0 @ -1 @ 0.
	arrow step: 0.01.
	self assert: arrow parent == scene.
	arrow step: 0.1.
	self assert: arrow parent isNil
]

{
	#category : #tests,
	#'squeak_changestamp' : 'leo-MCPServer 11/18/2026 17:56'
}
SRArrowTest >> testTheArrowPointsAlongItsFlight [

	arrow globalTranslation: 0 @ 2m @ 0.
	arrow launchWith: 0 @ 0 @ -20.
	10 timesRepeat: [arrow step: 0.1].
	self assert: ((arrow forward dot: arrow velocity normalized) closeTo: 1)
]

{
	#category : #tests,
	#'squeak_changestamp' : 'leo-MCPServer 11/18/2026 17:56'
}
SRArrowTest >> testTheDefaultDespawnHeightIsBelowTheGround [

	self assert: SRArrow despawnHeight equals: -5m
]
