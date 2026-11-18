Class {
	#name : #SWAGameNavigatorTest,
	#superclass : #SWAGameTestCase,
	#instVars : [
		'world',
		'nav'
	],
	#category : #'SWAGame-Tests'
}

{
	#category : #support,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:29'
}
SWAGameNavigatorTest >> neighbourCellsOf: aKey [
	| cells |
	cells := OrderedCollection new.
	nav neighboursOf: aKey do: [:each | cells add: (nav xOf: each) @ (nav zOf: each)].
	^ cells
]

{
	#category : #running,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:29'
}
SWAGameNavigatorTest >> setUp [
	"A flat floor four blocks deep, so the surface is at y = 4."
	super setUp.
	world := SWAGameWorld gridSize: 32 maxHeight: 20.
	world ensureVoxels.
	world voxels clear.
	0 to: 31 do: [:x |
		0 to: 31 do: [:z |
			0 to: 3 do: [:y | world voxels at: x at: y at: z put: 1]]].
	world removeAllMobs.
	nav := SWAGameNavigator on: world.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:29'
}
SWAGameNavigatorTest >> testADeepDropIsNotTaken [
	"Falling does no harm, but a mob that jumps into a pit it cannot climb out of
	is stuck there."
	0 to: 3 do: [:y | world voxels at: 11 at: y at: 8 put: 0].
	self deny: ((self neighbourCellsOf: (nav keyX: 10 y: 4 z: 8)) includes: 11 @ 8).
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:29'
}
SWAGameNavigatorTest >> testAMobThatMakesNoProgressGivesUp [
	"Sent straight at a wall it cannot climb, as a hunt without a route would be."
	| mob |
	self wallAtX: 12 height: 2 gapAtZ: nil.
	mob := SWAGameRabbit new positionX: 10.5 y: 4 z: 8.5; movementStrategy: nil; yourself.
	world addMobNow: mob.
	mob target: 20.5 @ 8.5.
	100 timesRepeat: [mob stepOn: world].
	self assert: mob target isNil.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:29'
}
SWAGameNavigatorTest >> testAMobWalksRoundAWallInsteadOfJumpingAtIt [
	| mob |
	self wallAtX: 16 height: 2 gapAtZ: 14.
	mob := SWAGameRabbit new positionX: 10.5 y: 4 z: 8.5; movementStrategy: nil; yourself.
	world addMobNow: mob.
	mob followRoute: (nav routeFrom: (nav nodeFor: mob) toX: 22 z: 8 limit: 2000) on: world.
	600 timesRepeat: [mob stepOn: world].
	self assert: mob cellX equals: 22.
	self assert: mob cellZ equals: 8.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:29'
}
SWAGameNavigatorTest >> testAOneBlockStepIsClimbed [
	| next |
	world voxels at: 11 at: 4 at: 8 put: 1.
	nav neighboursOf: (nav keyX: 10 y: 4 z: 8) do: [:each |
		((nav xOf: each) = 11 and: [(nav zOf: each) = 8]) ifTrue: [next := each]].
	self assert: (nav yOf: next) equals: 5.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:29'
}
SWAGameNavigatorTest >> testARouteGoesThroughTheGapInAWall [
	| route |
	self wallAtX: 16 height: 2 gapAtZ: 25.
	route := nav routeFrom: (nav keyX: 10 y: 4 z: 8) toX: 24 z: 8 limit: 2000.
	self assert: route last equals: 24.5 @ 8.5.
	self assert: (route select: [:p | p x = 16.5]) asArray equals: {16.5 @ 25.5}.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:29'
}
SWAGameNavigatorTest >> testATwoBlockWallIsNotClimbed [
	self wallAtX: 11 height: 2 gapAtZ: nil.
	self deny: ((self neighbourCellsOf: (nav keyX: 10 y: 4 z: 8)) includes: 11 @ 8).
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:29'
}
SWAGameNavigatorTest >> testAnUnreachableColumnHasNoRoute [
	self wallAtX: 16 height: 2 gapAtZ: nil.
	self assert: (nav routeFrom: (nav keyX: 10 y: 4 z: 8) toX: 24 z: 8 limit: 2000) isNil.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:29'
}
SWAGameNavigatorTest >> testFleeingNeverRunsPastTheThreat [
	| rabbit fox route |
	rabbit := SWAGameRabbit new positionX: 16.5 y: 4 z: 16.5; yourself.
	fox := SWAGameFox new positionX: 13.5 y: 4 z: 16.5; yourself.
	world addMobNow: rabbit.
	world addMobNow: fox.
	world rebuildMobIndexes.
	route := rabbit movementStrategy nextRouteFor: rabbit on: world.
	self assert: rabbit alarmed.
	self assert: (route allSatisfy: [:p | (p x - fox x) squared + (p y - fox z) squared >= 4]).
	self assert: route last x > rabbit x.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:29'
}
SWAGameNavigatorTest >> testGrazersIgnoreGrassTheyCannotReach [
	| mob route |
	0 to: 31 do: [:x | 0 to: 31 do: [:z | world grassAt: x @ z put: 0]].
	"A plateau two blocks up right beside the mob, and a smaller meal further off on the floor."
	12 to: 14 do: [:x |
		6 to: 10 do: [:z |
			world voxels at: x at: 4 at: z put: 1.
			world voxels at: x at: 5 at: z put: 1.
			world grassAt: x @ z put: world maxGrass]].
	world grassAt: 8 @ 12 put: 2.
	mob := SWAGameRabbit new positionX: 10.5 y: 4 z: 8.5; yourself.
	world addMobNow: mob.
	route := (SWAGameGrazeStrategy new searchRadius: 6; yourself) nextRouteFor: mob on: world.
	self assert: route last equals: 8.5 @ 12.5.
]

{
	#category : #support,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:29'
}
SWAGameNavigatorTest >> wallAtX: wx height: h gapAtZ: gz [
	0 to: 31 do: [:z |
		z = gz ifFalse: [
			4 to: 3 + h do: [:y | world voxels at: wx at: y at: z put: 1]]].
]
