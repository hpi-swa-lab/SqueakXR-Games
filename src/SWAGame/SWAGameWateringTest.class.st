"
Tests how SWAGameXR takes water poured onto its terrain.
"
Class {
	#name : #SWAGameWateringTest,
	#superclass : #SWAGameTestCase,
	#instVars : [
		'xr'
	],
	#category : #'SWAGame-Tests',
	#'squeak_changestamp' : '<historical>'
}

{
	#category : #helpers,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:19'
}
SWAGameWateringTest >> dropFrom: startHeight to: endHeight [

	^ xr
		wateredFrom: (xr globalPositionForCellX: 5.5 y: startHeight z: 7.5)
		to: (xr globalPositionForCellX: 5.5 y: endHeight z: 7.5)
]

{
	#category : #helpers,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:19'
}
SWAGameWateringTest >> garden [

	^ xr gameWorld garden
]

{
	#category : #helpers,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:19'
}
SWAGameWateringTest >> pour: aNumber [

	aNumber timesRepeat: [self dropFrom: 4.2 to: 3.8].
]

{
	#category : #helpers,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:19'
}
SWAGameWateringTest >> putBlock: aSymbol [

	xr gridHandle at: 5 at: 3 at: 7 put: (SWAGameBlocks idFor: aSymbol).
	xr syncHeightMapForColumnX: 5 z: 7.
]

{
	#category : #running,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:19'
}
SWAGameWateringTest >> setUp [

	super setUp.
	xr := SWAGameXR new.
	self putBlock: #dirt.
]

{
	#category : #running,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:19'
}
SWAGameWateringTest >> tearDown [

	xr ifNotNil: [[xr destroy] on: Error do: [:e | nil]].
	xr := nil.
	super tearDown.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:19'
}
SWAGameWateringTest >> testADropLandingOnAColumnWatersIt [

	self assert: (self dropFrom: 4.2 to: 3.8).
	self assert: (self garden waterAt: 5 @ 7) equals: 1.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:19'
}
SWAGameWateringTest >> testADropStillInTheAirIsNotAbsorbed [

	self deny: (self dropFrom: 4.6 to: 4.2).
	self assert: self garden isEmpty.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:19'
}
SWAGameWateringTest >> testDiggingTheBlockUprootsItsPlants [

	self pour: SWAGameGarden dropsPerStage.
	xr digAtX: 5 y: 3 z: 7.
	self assert: (self garden stageAt: 5 @ 7) equals: 0.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:19'
}
SWAGameWateringTest >> testEachStageRaisesTheGrass [

	xr gameWorld grassAt: 5 @ 7 put: 0.
	self pour: SWAGameGarden dropsPerStage.
	self assert: (xr gameWorld grassAt: 5 @ 7) equals: 1.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:19'
}
SWAGameWateringTest >> testNothingGrowsOnWater [

	self putBlock: #water.
	self assert: (self dropFrom: 4.2 to: 3.8).
	self assert: self garden isEmpty.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:19'
}
SWAGameWateringTest >> testPlantsStandOnTheColumn [

	self assert: (xr vegetationBaseFor: 5 @ 7) equals: (xr objectPosForCellX: 5.5 y: 4 z: 7.5).
]
