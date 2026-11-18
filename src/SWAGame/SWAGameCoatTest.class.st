Class {
	#name : #SWAGameCoatTest,
	#superclass : #SWAGameTestCase,
	#instVars : [
		'world'
	],
	#category : #'SWAGame-Tests'
}

{
	#category : #helpers,
	#'squeak_changestamp' : 'MCPServer (jl) 11/17/2026 14:36'
}
SWAGameCoatTest >> phenotypesOf: aCount youngOf: aRabbit [
	^ (1 to: aCount) collect: [:i |
		aRabbit energy: 100.
		(aRabbit makeOffspringOn: world) coatPhenotype]
]

{
	#category : #helpers,
	#'squeak_changestamp' : 'MCPServer (jl) 11/17/2026 14:36'
}
SWAGameCoatTest >> rabbitAtX: x z: z coat: aPair [
	| rabbit |
	rabbit := SWAGameRabbit new
		positionX: x y: 4 z: z;
		movementStrategy: nil;
		coat: aPair;
		age: 1000;
		yourself.
	^ world addMobNow: rabbit
]

{
	#category : #running,
	#'squeak_changestamp' : 'MCPServer (jl) 11/17/2026 14:36'
}
SWAGameCoatTest >> setUp [
	super setUp.
	world := SWAGameWorld gridSize: 32 maxHeight: 20.
	world ensureVoxels.
	world voxels clear.
	0 to: 31 do: [:x |
		0 to: 31 do: [:z |
			0 to: 3 do: [:y | world voxels at: x at: y at: z put: 1]]].
	world removeAllMobs.
	world instVarNamed: 'random' put: (Random seed: 4711).
	world parameter: #coatMutationChance of: #rabbit put: 0.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 11/17/2026 14:37'
}
SWAGameCoatTest >> testABreedingRabbitPassesItsCoatOnInATick [
	| mother young |
	mother := self rabbitAtX: 8.5 z: 8.5 coat: #(#cream #cream).
	mother
		reproduceThreshold: 0;
		reproduceChance: 1.0e6;
		energy: 70.
	world tick.
	young := world mobs detect: [:each | each ~~ mother].
	self assert: young coat equals: #(#cream #cream).
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 11/17/2026 14:36'
}
SWAGameCoatTest >> testACoatSurvivesSavingAndLoading [
	| loaded |
	self rabbitAtX: 8.5 z: 8.5 coat: #(#cream #black).
	loaded := SWAGameWorld fromJson: world asJson.
	self assert: (loaded mobsOfSpecies: #rabbit) first coat equals: #(#cream #black).
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 11/17/2026 14:36'
}
SWAGameCoatTest >> testALoneRabbitIsItsOwnMate [
	| loner phenotypes |
	loner := self rabbitAtX: 8.5 z: 8.5 coat: #(#black #white).
	self rabbitAtX: 20.5 z: 20.5 coat: #(#cream #cream).
	self assert: (loner mateOn: world) == loner.
	phenotypes := self phenotypesOf: 40 youngOf: loner.
	self assert: (phenotypes asSet copyWithout: #black) asArray equals: #(#white).
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 11/17/2026 14:36'
}
SWAGameCoatTest >> testAMutationBringsInAnAlleleNeitherParentHas [
	| mother alleles |
	world parameter: #coatMutationChance of: #rabbit put: 100.
	mother := self rabbitAtX: 8.5 z: 8.5 coat: #(#white #white).
	self rabbitAtX: 9.5 z: 8.5 coat: #(#white #white).
	alleles := Set new.
	50 timesRepeat: [
		mother energy: 100.
		alleles addAll: (mother makeOffspringOn: world) coat].
	self assert: alleles size > 1.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 11/17/2026 14:36'
}
SWAGameCoatTest >> testARabbitWithoutACoatIsWhite [
	"Rabbits that were alive when coats came in have none."
	| rabbit |
	rabbit := SWAGameRabbit new.
	rabbit instVarNamed: 'coat' put: nil.
	self assert: rabbit coatPhenotype equals: #white.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 11/17/2026 14:36'
}
SWAGameCoatTest >> testASaveFromBeforeCoatsLoadsWhiteRabbits [
	| json loaded |
	self rabbitAtX: 8.5 z: 8.5 coat: #(#black #black).
	json := Json readFrom: world asJson readStream.
	json at: #mobs put: ((json at: #mobs) collect: [:fields | fields first: 8]).
	loaded := SWAGameWorld fromJson: (Json render: json).
	self assert: (loaded mobsOfSpecies: #rabbit) first coatPhenotype equals: #white.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 11/17/2026 14:36'
}
SWAGameCoatTest >> testAYoungTakesOneAlleleFromEachParent [
	| mother young |
	mother := self rabbitAtX: 8.5 z: 8.5 coat: #(#black #black).
	self rabbitAtX: 9.5 z: 8.5 coat: #(#white #white).
	10 timesRepeat: [
		mother energy: 100.
		young := mother makeOffspringOn: world.
		self assert: young coat asSet equals: #(#black #white) asSet].
	self assert: young coatPhenotype equals: #black.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 11/17/2026 14:36'
}
SWAGameCoatTest >> testEveryColourHasItsOwnModel [
	| models |
	models := SWAGameRabbit coatAlleles collect: [:allele | (SWAGameRabbit new coat: {allele. allele}; yourself) newModel].
	models with: SWAGameRabbit coatAlleles do: [:model :allele |
		| colors |
		colors := Set new.
		model facesDo: [:group :xyz :face :color | colors add: color].
		self assert: (colors includes: (SWAGameRabbit furColorOf: allele))].
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 11/17/2026 14:36'
}
SWAGameCoatTest >> testFoundersCarryEveryColour [
	| census |
	200 timesRepeat: [
		world addMobNow: ((world newMobOfSpecies: #rabbit)
			positionX: 8.5 y: 4 z: 8.5;
			yourself)].
	census := world coatCensus.
	self assert: census size equals: 200.
	self assert: census asSet equals: SWAGameRabbit coatAlleles asSet.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 11/17/2026 14:36'
}
SWAGameCoatTest >> testTheFurColourIsThePhenotypes [
	| rabbit |
	rabbit := SWAGameRabbit new coat: #(#white #black); yourself.
	self assert: rabbit color equals: (SWAGameRabbit furColorOf: #black).
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 11/17/2026 14:36'
}
SWAGameCoatTest >> testTheMostDominantAlleleShows [
	| rabbit |
	rabbit := SWAGameRabbit new.
	#(	#(#white #white) #white
		#(#white #black) #black
		#(#cream #agouti) #agouti
		#(#cream #white) #cream
		#(#black #cream) #black) pairsDo: [:pair :shown |
			rabbit coat: pair.
			self assert: rabbit coatPhenotype equals: shown].
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 11/17/2026 14:36'
}
SWAGameCoatTest >> testTheMutationChanceIsAGameParameter [
	| rabbit |
	world parameter: #coatMutationChance of: #rabbit put: 7.
	rabbit := world newMobOfSpecies: #rabbit.
	self assert: rabbit coatMutationChance equals: 7.
	self assert: SWAGameRabbit coatMutationChance equals: 1.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 11/17/2026 14:36'
}
SWAGameCoatTest >> testTheNearestGrownRabbitIsTheMate [
	| mother near child |
	mother := self rabbitAtX: 8.5 z: 8.5 coat: #(#black #black).
	near := self rabbitAtX: 10.5 z: 8.5 coat: #(#cream #cream).
	self rabbitAtX: 12.5 z: 8.5 coat: #(#agouti #agouti).
	child := self rabbitAtX: 9 z: 8.5 coat: #(#white #white).
	child age: 0.
	self assert: (mother mateOn: world) == near.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 11/17/2026 14:36'
}
SWAGameCoatTest >> testTheRendererSharesAModelPerColour [
	| renderer black otherBlack white |
	renderer := SWAGameMobRenderer new.
	black := SWAGameRabbit new coat: #(#black #white); yourself.
	otherBlack := SWAGameRabbit new coat: #(#black #black); yourself.
	white := SWAGameRabbit new.
	self assert: (renderer modelFor: black) == (renderer modelFor: otherBlack).
	self deny: (renderer modelFor: black) == (renderer modelFor: white).
	self assert: (renderer modelFor: SWAGameFox new) == (renderer modelFor: SWAGameFox new).
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 11/17/2026 14:36'
}
SWAGameCoatTest >> testTwoCarriersHaveRecessiveYoungInAQuarter [
	"Mendel: black/white times black/white is one white in four. 400 young: about 100, the bounds are over four standard deviations."
	| mother whites |
	mother := self rabbitAtX: 8.5 z: 8.5 coat: #(#black #white).
	self rabbitAtX: 9.5 z: 8.5 coat: #(#white #black).
	whites := (self phenotypesOf: 400 youngOf: mother) count: [:each | each == #white].
	self assert: (whites between: 60 and: 140).
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 11/17/2026 14:36'
}
SWAGameCoatTest >> testWithoutMutationsAWhiteHerdStaysWhite [
	| mother |
	mother := self rabbitAtX: 8.5 z: 8.5 coat: #(#white #white).
	self rabbitAtX: 9.5 z: 8.5 coat: #(#white #white).
	self assert: (self phenotypesOf: 50 youngOf: mother) asSet asArray equals: #(#white).
]
