Class {
	#name : #SWAGameScenarioTest,
	#superclass : #SWAGameTestCase,
	#instVars : [
		'liveValues'
	],
	#category : #'SWAGame-Tests'
}

{
	#category : #support,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 14:35'
}
SWAGameScenarioTest >> newGame [
	^ SWAGameWorld gridSize: 16 maxHeight: 10
]

{
	#category : #running,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:29'
}
SWAGameScenarioTest >> setUp [
	liveValues := SWAGameScenario currentValues.
	super setUp.
]

{
	#category : #running,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 12:54'
}
SWAGameScenarioTest >> tearDown [
	"Applying a scenario reaches every living mob, the running game's included,
	so those get their values back before the class variables are restored."
	[(SWAGameScenario named: 'live' values: liveValues) apply]
		ensure: [super tearDown]
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:29'
}
SWAGameScenarioTest >> testAFileMissingAParameterFallsBackToTheDefault [
	| scenario |
	scenario := SWAGameScenario fromJson: '{"name": "old", "rabbit": {"walkSpeed": 1.5}}'.
	self assert: ((scenario resolvedValues at: #rabbit) at: #walkSpeed) equals: 1.5.
	self assert: ((scenario resolvedValues at: #rabbit) at: #burnRate) equals: SWAGameRabbit burnRate.
	self assert: ((scenario resolvedValues at: #fox) at: #runSpeed) equals: SWAGameFox runSpeed.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 14:35'
}
SWAGameScenarioTest >> testAGameParameterLeavesTheImageAndOtherGamesAlone [
	| one other a b |
	one := self newGame.
	other := self newGame.
	a := one addMobNow: SWAGameFox new.
	b := other addMobNow: SWAGameFox new.
	one parameter: #runSpeed of: #fox put: 5.
	self assert: a runSpeed equals: 5.
	self assert: b runSpeed equals: SWAGameFox runSpeed.
	self deny: SWAGameFox runSpeed = 5.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 14:35'
}
SWAGameScenarioTest >> testApplyingSetsTheImageDefaults [
	SWAGameScenario documentary apply.
	self assert: SWAGameScenario documentary isActive.
	self deny: SWAGameScenario balanced isActive.
	self assert: SWAGameRabbit walkSpeed equals: 0.35.
	self assert: SWAGameWorld grassRegrowthPerSecond equals: 0.0075.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:29'
}
SWAGameScenarioTest >> testBuiltInsOnlyNameExistingParameters [
	"They are written as overrides, and a misspelt selector would be carried along
	and never applied."
	| expected |
	expected := SWAGameScenario defaultValues.
	SWAGameScenario builtIns do: [:each |
		expected keysAndValuesDo: [:owner :params |
			self assert: ((each values at: owner) keys asSet) equals: params keys asSet]].
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:29'
}
SWAGameScenarioTest >> testEveryNumericPreferenceIsAParameter [
	| params |
	params := SWAGameScenario parametersOf: SWAGameRabbit.
	self assert: (#(#walkSpeed #runSpeed #restTime #burnRate #detectionRange) allSatisfy: [:each | params includes: each]).
	self assert: (SWAGameScenario parametersOf: SWAGameWorld) equals: #(#grassRegrowthPerSecond).
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 14:35'
}
SWAGameScenarioTest >> testImageDefaultsReachOnlyGamesThatDoNotSetTheirOwn [
	| following own a b |
	following := self newGame.
	own := self newGame.
	own applyScenario: SWAGameScenario oldFastPace.
	a := following addMobNow: SWAGameRabbit new.
	b := own addMobNow: SWAGameRabbit new.
	SWAGameScenario documentary apply.
	self assert: a walkSpeed equals: 0.35.
	self assert: b walkSpeed equals: 0.85.
	self assert: (own isScenarioActive: SWAGameScenario oldFastPace).
	self assert: (following grassRegrowthPerSecond) equals: 0.0075.
	self assert: (own grassRegrowthPerSecond) equals: 0.05.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:29'
}
SWAGameScenarioTest >> testJsonRoundTrip [
	| scenario copy |
	scenario := SWAGameScenario boomAndBust.
	copy := SWAGameScenario fromJson: scenario asJson.
	self assert: copy name equals: scenario name.
	self assert: copy values equals: scenario values.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 14:35'
}
SWAGameScenarioTest >> testNewbornsAndSpawnsTakeTheGamesParameters [
	| game newborn spawned |
	game := self newGame.
	game applyScenario: SWAGameScenario documentary.
	newborn := SWAGameRabbit new.
	game addMob: newborn.
	game harvestDeadAndNewborn.
	self assert: newborn walkSpeed equals: 0.35.
	game parameter: #startingEnergy of: #rabbit put: 33.
	spawned := game newMobOfSpecies: #rabbit.
	self assert: spawned energy equals: 33.
	self assert: spawned eatTime equals: 6.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:29'
}
SWAGameScenarioTest >> testReadingTheDefaultsLeavesTheSettingsAlone [
	SWAGameRabbit classPool at: #DefaultWalkSpeed put: 9.
	self assert: ((SWAGameScenario defaultValues at: #rabbit) at: #walkSpeed) equals: 0.6.
	self assert: SWAGameRabbit walkSpeed equals: 9.
]
