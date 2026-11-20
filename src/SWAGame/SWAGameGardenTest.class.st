"
Tests SWAGameGarden and how SWAGameVegetation stages it.
"
Class {
	#name : #SWAGameGardenTest,
	#superclass : #SWAGameTestCase,
	#instVars : [
		'garden'
	],
	#category : #'SWAGame-Tests',
	#'squeak_changestamp' : '<historical>'
}

{
	#category : #running,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:19'
}
SWAGameGardenTest >> pour: aNumber on: aCell [

	aNumber timesRepeat: [garden pourOn: aCell].
]

{
	#category : #running,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:19'
}
SWAGameGardenTest >> setUp [

	super setUp.
	garden := SWAGameGarden new.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:19'
}
SWAGameGardenTest >> testAGardenSurvivesItsArrayForm [

	| copy |
	self pour: SWAGameGarden dropsPerStage + 1 on: -1 @ 2.
	copy := SWAGameGarden fromArray: garden asArray.
	self assert: (copy waterAt: -1 @ 2) equals: SWAGameGarden dropsPerStage + 1.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:19'
}
SWAGameGardenTest >> testClearingACellRemovesItsPlant [

	self pour: SWAGameGarden dropsPerStage on: 1 @ 2.
	garden clearAt: 1 @ 2.
	self assert: garden isEmpty.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:19'
}
SWAGameGardenTest >> testEveryStageTakesTheSameAmountOfWater [

	self pour: SWAGameGarden dropsPerStage - 1 on: 1 @ 2.
	self assert: (garden stageAt: 1 @ 2) equals: 0.
	self assert: (garden pourOn: 1 @ 2).
	self assert: (garden stageAt: 1 @ 2) equals: 1.
	self deny: (garden pourOn: 1 @ 2).
]

{
	#category : #tests,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:19'
}
SWAGameGardenTest >> testFlowersOnlyBloomOnWellWateredCells [

	self assert: (SWAGameVegetation flowersAt: SWAGameGarden flowerStage - 1) equals: 0.
	self assert: (SWAGameVegetation flowersAt: SWAGameGarden flowerStage) > 0.
	self assert: (SWAGameVegetation bladesAt: 1) > 0.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:19'
}
SWAGameGardenTest >> testGrowthStopsAtTheLastStage [

	self pour: SWAGameGarden maxWater + SWAGameGarden dropsPerStage on: 1 @ 2.
	self assert: (garden stageAt: 1 @ 2) equals: SWAGameGarden maxStage.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:19'
}
SWAGameGardenTest >> testOnlyGrownCellsArePlants [

	| plants |
	self pour: 1 on: 1 @ 2.
	self pour: SWAGameGarden dropsPerStage on: 3 @ 4.
	plants := Dictionary new.
	garden plantsDo: [:cell :stage | plants at: cell put: stage].
	self assert: plants equals: (Dictionary new at: 3 @ 4 put: 1; yourself).
]
