"
Tests drawing and launching with SRBow.
"
Class {
	#name : #SRBowTest,
	#superclass : #TestCase,
	#instVars : [
		'scene',
		'bow',
		'bowHand',
		'stringHand'
	],
	#category : #'SWAGame-Tests',
	#'squeak_changestamp' : '<historical>'
}

{
	#category : #helpers,
	#'squeak_changestamp' : 'leo-MCPServer 11/18/2026 18:01'
}
SRBowTest >> assertVector: aVector closeTo: anotherVector [

	self assert: (aVector - anotherVector) length < 0.001
]

{
	#category : #helpers,
	#'squeak_changestamp' : 'leo-MCPServer 11/18/2026 17:57'
}
SRBowTest >> grabString [

	stringHand globalTranslation: (bow globalTransform localPointToGlobal: bow nockPoint).
	bow string startGrabbing: stringHand.
	bow step: 0.01
]

{
	#category : #helpers,
	#'squeak_changestamp' : 'leo-MCPServer 11/18/2026 18:01'
}
SRBowTest >> moveStringHandTo: aBowPoint [

	stringHand globalTranslation: (bow globalTransform localPointToGlobal: aBowPoint).
	bow step: 0.01
]

{
	#category : #helpers,
	#'squeak_changestamp' : 'leo-MCPServer 11/18/2026 18:01'
}
SRBowTest >> pullTo: aDepth [

	self moveStringHandTo: 0 @ SRBow arrowHeight @ (SRBow braceHeight + aDepth)
]

{
	#category : #helpers,
	#'squeak_changestamp' : 'leo-MCPServer 11/18/2026 17:56'
}
SRBowTest >> releaseString [

	bow string stopGrabbing: stringHand
]

{
	#category : #running,
	#'squeak_changestamp' : 'leo-MCPServer 11/18/2026 17:57'
}
SRBowTest >> setUp [

	super setUp.
	scene := SRObject new.
	bow := SRBow new.
	scene addChild: bow.
	bowHand := SRBowTestHand new.
	stringHand := SRBowTestHand new.
	bow startGrabbing: bowHand
]

{
	#category : #tests,
	#'squeak_changestamp' : 'leo-MCPServer 11/18/2026 17:56'
}
SRBowTest >> testGrabbingTheStringNocksAnArrow [

	self assert: bow nockedArrow isNil.
	self grabString.
	self assert: bow nockedArrow notNil.
	self assert: bow nockedArrow parent == bow
]

{
	#category : #tests,
	#'squeak_changestamp' : 'leo-MCPServer 11/18/2026 17:56'
}
SRBowTest >> testHoldingHidesTheControllerModelUntilReleased [

	self deny: bowHand body visible.
	bow stopGrabbing: bowHand.
	self assert: bowHand body visible
]

{
	#category : #tests,
	#'squeak_changestamp' : 'leo-MCPServer 11/18/2026 17:56'
}
SRBowTest >> testLaunchedArrowsAreBounded [

	| first |
	SRBow maxLaunchedArrows + 1 timesRepeat: [
		self grabString.
		self pullTo: 30cm.
		self releaseString.
		first ifNil: [first := bow launchedArrows first]].
	self assert: bow launchedArrows size equals: SRBow maxLaunchedArrows.
	self assert: first parent isNil
]

{
	#category : #tests,
	#'squeak_changestamp' : 'leo-MCPServer 11/18/2026 18:01'
}
SRBowTest >> testPullingStraightBackDrawsAlongTheBow [

	self grabString.
	self pullTo: 30cm.
	self assert: (bow string draw closeTo: 30cm).
	self assertVector: bow nockedArrow forward closeTo: bow forward
]

{
	#category : #tests,
	#'squeak_changestamp' : 'leo-MCPServer 11/18/2026 17:56'
}
SRBowTest >> testRegrabbingTheBowWhileHoldingTheStringStartsANewDraw [

	self grabString.
	self pullTo: 30cm.
	bow stopGrabbing: bowHand.
	bow startGrabbing: bowHand.
	bow step: 0.01.
	self assert: bow nockedArrow notNil.
	self assert: bow string draw equals: 0.
	self pullTo: 40cm.
	self assert: (bow string draw closeTo: 10cm)
]

{
	#category : #tests,
	#'squeak_changestamp' : 'leo-MCPServer 11/18/2026 18:01'
}
SRBowTest >> testReleasingLaunchesAlongTheArrowsAim [

	| arrow aim speed |
	bow globalRotation: (Quaternion angle: 30 axis: Vector3 up).
	self grabString.
	self moveStringHandTo: 15cm @ 10cm @ (SRBow braceHeight + 35cm).
	arrow := bow nockedArrow.
	aim := arrow forward.
	speed := SRBow maxArrowSpeed * bow string draw / SRBow maxDraw.
	self deny: ((aim dot: bow forward) closeTo: 1).
	self releaseString.
	self assertVector: arrow velocity normalized closeTo: aim.
	self assert: (arrow velocity length closeTo: speed)
]

{
	#category : #tests,
	#'squeak_changestamp' : 'leo-MCPServer 11/18/2026 18:01'
}
SRBowTest >> testReleasingLaunchesAlongTheBowWithSpeedFromTheDraw [

	| arrow |
	bow globalRotation: (Quaternion angle: 30 axis: Vector3 up).
	self grabString.
	self pullTo: SRBow maxDraw / 2.
	arrow := bow nockedArrow.
	self releaseString.
	self assert: arrow parent == scene.
	self assert: bow nockedArrow isNil.
	self assert: bow string draw equals: 0.
	self assert: (arrow velocity - (bow forward * (SRBow maxArrowSpeed / 2))) length < 0.01
]

{
	#category : #tests,
	#'squeak_changestamp' : 'leo-MCPServer 11/18/2026 17:56'
}
SRBowTest >> testReleasingTheBowCancelsTheDraw [

	| arrow |
	self grabString.
	self pullTo: 30cm.
	arrow := bow nockedArrow.
	bow stopGrabbing: bowHand.
	self assert: arrow parent isNil.
	self assert: bow string draw equals: 0.
	self releaseString.
	self assert: bow launchedArrows isEmpty
]

{
	#category : #tests,
	#'squeak_changestamp' : 'leo-MCPServer 11/18/2026 17:56'
}
SRBowTest >> testReleasingWithoutDrawingDoesNotLaunch [

	| arrow |
	self grabString.
	arrow := bow nockedArrow.
	self releaseString.
	self assert: arrow parent isNil.
	self assert: bow launchedArrows isEmpty
]

{
	#category : #tests,
	#'squeak_changestamp' : 'leo-MCPServer 11/18/2026 18:01'
}
SRBowTest >> testSidewaysAimIsLimited [

	| aim |
	self grabString.
	self moveStringHandTo: 60cm @ SRBow arrowHeight @ (SRBow braceHeight + 5cm).
	aim := (bow string nock - SRBow arrowRestPoint) normalized.
	self assert: ((aim dot: Vector3 backward) closeTo: SRBow maxAimAngle degreesToRadians cos)
]

{
	#category : #tests,
	#'squeak_changestamp' : 'leo-MCPServer 11/18/2026 18:01'
}
SRBowTest >> testTheArrowPointsFromTheNockThroughTheRest [

	bow globalRotation: (Quaternion angle: 30 axis: Vector3 up).
	self grabString.
	self moveStringHandTo: 12cm @ 0 @ (SRBow braceHeight + 25cm).
	self assertVector: bow nockedArrow forward
		closeTo: (bow globalTransform localDirToGlobal: SRBow arrowRestPoint - bow string nock) normalized.
	self assert: (bow nockedArrow up y > 0)
]

{
	#category : #tests,
	#'squeak_changestamp' : 'leo-MCPServer 11/18/2026 17:56'
}
SRBowTest >> testTheDrawFollowsTheBowWhenItMoves [

	self grabString.
	self pullTo: 30cm.
	bow globalTranslation: 0 @ 0 @ -10cm.
	bow step: 0.01.
	self assert: (bow string draw closeTo: 40cm)
]

{
	#category : #tests,
	#'squeak_changestamp' : 'leo-MCPServer 11/18/2026 17:56'
}
SRBowTest >> testTheDrawIsLimited [

	self grabString.
	self pullTo: 2m.
	self assert: bow string draw equals: SRBow maxDraw
]

{
	#category : #tests,
	#'squeak_changestamp' : 'leo-MCPServer 11/18/2026 18:01'
}
SRBowTest >> testTheDrawLengthIsLimitedInEveryDirection [

	self grabString.
	self moveStringHandTo: 30cm @ 0 @ 2m.
	self assert: (bow string draw closeTo: SRBow maxDraw).
	self assert: ((bow string nock distanceTo: SRBow arrowRestPoint) closeTo: SRBow braceHeight + SRBow maxDraw)
]

{
	#category : #tests,
	#'squeak_changestamp' : 'leo-MCPServer 11/18/2026 18:01'
}
SRBowTest >> testTheNockFollowsTheHandSideways [

	| hand |
	self grabString.
	hand := 10cm @ (SRBow arrowHeight + 5cm) @ (SRBow braceHeight + 30cm).
	self moveStringHandTo: hand.
	self assertVector: bow string nock closeTo: hand.
	self assertVector: bow nockedArrow localTranslation closeTo: hand.
	self assert: (bow string draw closeTo: (hand distanceTo: SRBow arrowRestPoint) - SRBow braceHeight)
]

{
	#category : #tests,
	#'squeak_changestamp' : 'leo-MCPServer 11/18/2026 18:01'
}
SRBowTest >> testTheStringBendsToTheNock [

	self grabString.
	self moveStringHandTo: 15cm @ SRBow arrowHeight @ (SRBow braceHeight + 20cm).
	self assertVector: bow string localTranslation closeTo: bow string nock
]

{
	#category : #tests,
	#'squeak_changestamp' : 'leo-MCPServer 11/18/2026 17:57'
}
SRBowTest >> testTheStringCannotBeGrabbedWithoutHoldingTheBow [

	bow stopGrabbing: bowHand.
	self deny: bow string canGrab
]
