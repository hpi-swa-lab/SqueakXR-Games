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
	#category : #helpers,
	#'squeak_changestamp' : 'leo-MCPServer 11/23/2026 15:00'
}
SRArrowTest >> panelAt: aVector3 [

	| panel |
	panel := SRMorphPanel new.
	scene addChild: panel.
	panel globalTranslation: aVector3.
	^ panel
]

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
	#category : #helpers,
	#'squeak_changestamp' : 'leo-MCPServer 11/23/2026 15:01'
}
SRArrowTest >> shoot [

	arrow globalTranslation: 0 @ 2m @ 0.
	arrow launchWith: 0 @ 0 @ -20.
	5 timesRepeat: [arrow isStepping ifTrue: [arrow step: 0.1]]
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
	#'squeak_changestamp' : 'leo-MCPServer 11/23/2026 15:01'
}
SRArrowTest >> testAStuckArrowLetsRaysThroughToItsPanel [

	| panel hit |
	panel := self panelAt: 0 @ 2m @ -3m.
	self shoot.
	hit := (SRRay origin: arrow globalTranslation - arrow forward forward: arrow forward) castNearest: scene.
	self assert: hit object == panel plane
]

{
	#category : #tests,
	#'squeak_changestamp' : 'leo-MCPServer 11/23/2026 15:01'
}
SRArrowTest >> testAStuckArrowMovesWithItsPanel [

	| panel before |
	panel := self panelAt: 0 @ 2m @ -3m.
	self shoot.
	before := arrow globalTranslation.
	panel globalTranslation: panel globalTranslation + (1m @ 0 @ 0).
	self assert: (arrow globalTranslation - before - (1m @ 0 @ 0)) length < 0.0001
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
	#'squeak_changestamp' : 'leo-MCPServer 11/23/2026 15:01'
}
SRArrowTest >> testTheArrowFliesPastAPanelItMisses [

	self panelAt: 3m @ 2m @ -3m.
	self shoot.
	self assert: arrow parent == scene.
	self assert: arrow isStepping
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
	#'squeak_changestamp' : 'leo-MCPServer 11/23/2026 15:01'
}
SRArrowTest >> testTheArrowSticksIntoAPanelItHits [

	| panel |
	panel := self panelAt: 0 @ 2m @ -3m.
	self shoot.
	self assert: arrow parent == panel.
	self assert: arrow isStuck.
	self deny: arrow isStepping.
	self assert: (arrow tip z - (-3m - SRArrow penetrationDepth)) abs < 1cm
]

{
	#category : #tests,
	#'squeak_changestamp' : 'leo-MCPServer 11/18/2026 17:56'
}
SRArrowTest >> testTheDefaultDespawnHeightIsBelowTheGround [

	self assert: SRArrow despawnHeight equals: -5m
]
