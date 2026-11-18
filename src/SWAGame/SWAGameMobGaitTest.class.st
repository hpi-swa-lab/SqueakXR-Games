Class {
	#name : #SWAGameMobGaitTest,
	#superclass : #TestCase,
	#instVars : [
		'gait'
	],
	#category : #'SWAGame-Tests'
}

{
	#category : #running,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 15:40'
}
SWAGameMobGaitTest >> setUp [
	super setUp.
	gait := SWAGameMobGait new.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 15:40'
}
SWAGameMobGaitTest >> testABodyStopsTurning [
	gait advance: 0.05 in: 0.05 headingX: 1.0 z: 0.0 stride: 0.5.
	gait settle.
	self assert: (gait yawAt: 0) equals: (gait yawAt: 1).
	self assert: (gait swingAt: 0) equals: 0.0.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 15:40'
}
SWAGameMobGaitTest >> testInterpolatesBetweenTicks [
	gait advance: 0.25 in: 0.05 headingX: 0.0 z: 1.0 stride: 0.5.
	self assert: ((gait phaseAt: 0.5) - (Float pi / 2)) abs < 1.0e-9.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 15:40'
}
SWAGameMobGaitTest >> testKeepsItsHeadingWhenStanding [
	20 timesRepeat: [gait advance: 0.05 in: 0.05 headingX: 1.0 z: 0.0 stride: 0.5].
	gait advance: 0.0 in: 0.05 headingX: 0.0 z: 0.0 stride: 0.5.
	self assert: ((gait yawAt: 1) - (Float pi / 2)) abs < 0.01.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 15:40'
}
SWAGameMobGaitTest >> testPhaseFollowsDistanceNotTime [
	gait advance: 0.25 in: 0.05 headingX: 0.0 z: 1.0 stride: 0.5.
	self assert: ((gait phaseAt: 1) - Float pi) abs < 1.0e-9.
	gait advance: 0.0 in: 0.05 headingX: 0.0 z: 0.0 stride: 0.5.
	self assert: ((gait phaseAt: 1) - Float pi) abs < 1.0e-9.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 15:40'
}
SWAGameMobGaitTest >> testStandingStillLowersTheLegs [
	5 timesRepeat: [gait advance: 0.1 in: 0.05 headingX: 0.0 z: 1.0 stride: 0.5].
	self assert: (gait swingAt: 1) > 0.4.
	10 timesRepeat: [gait advance: 0.0 in: 0.05 headingX: 0.0 z: 0.0 stride: 0.5].
	self assert: (gait swingAt: 1) < 0.01.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 15:40'
}
SWAGameMobGaitTest >> testTurnsTheShortWayRound [
	"From facing +x to facing -x by way of -z, not back through +z."
	20 timesRepeat: [gait advance: 0.05 in: 0.05 headingX: 1.0 z: 0.0 stride: 0.5].
	gait advance: 0.05 in: 0.05 headingX: -1.0 z: -0.01 stride: 0.5.
	self assert: (gait yawAt: 1) > (Float pi / 2).
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 15:40'
}
SWAGameMobGaitTest >> testTurnsTowardTheHeading [
	20 timesRepeat: [gait advance: 0.05 in: 0.05 headingX: 1.0 z: 0.0 stride: 0.5].
	self assert: ((gait yawAt: 1) - (Float pi / 2)) abs < 0.01.
]
