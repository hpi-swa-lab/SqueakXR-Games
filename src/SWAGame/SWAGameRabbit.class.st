"
Eats grass, flees foxes.
"
Class {
	#name : #SWAGameRabbit,
	#superclass : #SWAGameMob,
	#instVars : [
		'coat',
		'coatMutationChance'
	],
	#classVars : [
		'DefaultBurnRate',
		'DefaultCoatMutationChance',
		'DefaultDetectionRange',
		'DefaultEatGain',
		'DefaultEatTime',
		'DefaultLifespan',
		'DefaultMaxEnergy',
		'DefaultOffspringEnergy',
		'DefaultReproduceChance',
		'DefaultReproduceCost',
		'DefaultReproduceThreshold',
		'DefaultRestTime',
		'DefaultRunSpeed',
		'DefaultStartingEnergy',
		'DefaultWalkSpeed'
	],
	#category : #SWAGame,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 18:36'
}

{
	#category : #preferences,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:13'
}
SWAGameRabbit class >> burnRate [
	<preference: 'Rabbit burn rate'
		category: 'SWAGame'
		description: 'Energy spent per second.'
		type: #Number>
	^ DefaultBurnRate ifNil: [0.6]
]

{
	#category : #preferences,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 14:35'
}
SWAGameRabbit class >> burnRate: aNumber [
	DefaultBurnRate := aNumber.
	self defaultsChanged.
]

{
	#category : #genetics,
	#'squeak_changestamp' : 'MCPServer (jl) 11/17/2026 14:35'
}
SWAGameRabbit class >> coatAlleles [
	"Most dominant first: a rabbit shows the first of these it carries."
	^ #(#agouti #black #cream #white)
]

{
	#category : #genetics,
	#'squeak_changestamp' : 'MCPServer (jl) 11/17/2026 14:35'
}
SWAGameRabbit class >> coatColors [
	"Fur and saddle per allele."
	^ Dictionary new
		at: #agouti put: {Color r: 0.56 g: 0.46 b: 0.35. Color r: 0.43 g: 0.35 b: 0.27};
		at: #black put: {Color r: 0.17 g: 0.16 b: 0.16. Color r: 0.10 g: 0.09 b: 0.09};
		at: #cream put: {Color r: 0.92 g: 0.78 b: 0.55. Color r: 0.82 g: 0.64 b: 0.42};
		at: #white put: {Color r: 0.93 g: 0.91 b: 0.87. Color r: 0.78 g: 0.72 b: 0.64};
		yourself
]

{
	#category : #preferences,
	#'squeak_changestamp' : 'MCPServer (jl) 11/17/2026 14:35'
}
SWAGameRabbit class >> coatMutationChance [
	<preference: 'Rabbit coat mutation chance'
		category: 'SWAGame'
		description: 'Percent chance per allele passed to a young rabbit that it comes out as a random coat allele instead.'
		type: #Number>
	^ DefaultCoatMutationChance ifNil: [1]
]

{
	#category : #preferences,
	#'squeak_changestamp' : 'MCPServer (jl) 11/17/2026 14:35'
}
SWAGameRabbit class >> coatMutationChance: aNumber [
	DefaultCoatMutationChance := aNumber.
	self defaultsChanged.
]

{
	#category : #preferences,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 18:36'
}
SWAGameRabbit class >> detectionRange [
	<preference: 'Rabbit detection range'
		category: 'SWAGame'
		description: 'How far rabbit can sense foxes to flee.'
		type: #Number>
	"Short on purpose: a fleeing rabbit does not eat."
	^ DefaultDetectionRange ifNil: [6]
]

{
	#category : #preferences,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 14:35'
}
SWAGameRabbit class >> detectionRange: aNumber [
	DefaultDetectionRange := aNumber.
	self defaultsChanged.
]

{
	#category : #preferences,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 13:46'
}
SWAGameRabbit class >> eatGain [
	<preference: 'Rabbit eat gain'
		category: 'SWAGame'
		description: 'Energy gained from eating grass.'
		type: #Number>
	^ DefaultEatGain ifNil: [6]
]

{
	#category : #preferences,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 14:35'
}
SWAGameRabbit class >> eatGain: aNumber [
	DefaultEatGain := aNumber.
	self defaultsChanged.
]

{
	#category : #preferences,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:36'
}
SWAGameRabbit class >> eatTime [
	<preference: 'Rabbit eat time'
		category: 'SWAGame'
		description: 'Seconds a rabbit stands grazing one tile.'
		type: #Number>
	^ DefaultEatTime ifNil: [3]
]

{
	#category : #preferences,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 14:35'
}
SWAGameRabbit class >> eatTime: aNumber [
	DefaultEatTime := aNumber.
	self defaultsChanged.
]

{
	#category : #genetics,
	#'squeak_changestamp' : 'MCPServer (jl) 11/17/2026 14:35'
}
SWAGameRabbit class >> furColorOf: anAllele [
	^ (self coatColors at: anAllele) first
]

{
	#category : #preferences,
	#'squeak_changestamp' : 'MCPServer (jl) 11/13/2026 10:56'
}
SWAGameRabbit class >> lifespan [
	<preference: 'Rabbit lifespan'
		category: 'SWAGame'
		description: 'Seconds. A rabbit is a child for the first fifth and grows until half of it.'
		type: #Number>
	^ DefaultLifespan ifNil: [300]
]

{
	#category : #preferences,
	#'squeak_changestamp' : 'MCPServer (jl) 11/13/2026 10:56'
}
SWAGameRabbit class >> lifespan: aNumber [
	DefaultLifespan := aNumber.
	self defaultsChanged.
]

{
	#category : #preferences,
	#'squeak_changestamp' : 'MCPServer 5/18/2026 14:13'
}
SWAGameRabbit class >> maxEnergy [
	<preference: 'Rabbit max energy'
		category: 'SWAGame'
		description: 'Maximum energy for bar display.'
		type: #Number>
	^ DefaultMaxEnergy ifNil: [80]
]

{
	#category : #preferences,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 14:35'
}
SWAGameRabbit class >> maxEnergy: aNumber [
	DefaultMaxEnergy := aNumber.
	self defaultsChanged.
]

{
	#category : #preferences,
	#'squeak_changestamp' : 'MCPServer 5/18/2026 14:13'
}
SWAGameRabbit class >> offspringEnergy [
	<preference: 'Rabbit offspring energy'
		category: 'SWAGame'
		description: 'Starting energy of newborn rabbits.'
		type: #Number>
	^ DefaultOffspringEnergy ifNil: [25]
]

{
	#category : #preferences,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 14:35'
}
SWAGameRabbit class >> offspringEnergy: aNumber [
	DefaultOffspringEnergy := aNumber.
	self defaultsChanged.
]

{
	#category : #preferences,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:13'
}
SWAGameRabbit class >> reproduceChance [
	<preference: 'Rabbit reproduce chance'
		category: 'SWAGame'
		description: 'Percent chance per second to reproduce when above threshold.'
		type: #Number>
	^ DefaultReproduceChance ifNil: [2]
]

{
	#category : #preferences,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 14:35'
}
SWAGameRabbit class >> reproduceChance: aNumber [
	DefaultReproduceChance := aNumber.
	self defaultsChanged.
]

{
	#category : #preferences,
	#'squeak_changestamp' : 'MCPServer 5/18/2026 14:13'
}
SWAGameRabbit class >> reproduceCost [
	<preference: 'Rabbit reproduction cost'
		category: 'SWAGame'
		description: 'Energy cost to the parent when reproducing.'
		type: #Number>
	^ DefaultReproduceCost ifNil: [20]
]

{
	#category : #preferences,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 14:35'
}
SWAGameRabbit class >> reproduceCost: aNumber [
	DefaultReproduceCost := aNumber.
	self defaultsChanged.
]

{
	#category : #preferences,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 13:46'
}
SWAGameRabbit class >> reproduceThreshold [
	<preference: 'Rabbit reproduce threshold'
		category: 'SWAGame'
		description: 'Energy needed before a rabbit can reproduce.'
		type: #Number>
	^ DefaultReproduceThreshold ifNil: [55]
]

{
	#category : #preferences,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 14:35'
}
SWAGameRabbit class >> reproduceThreshold: aNumber [
	DefaultReproduceThreshold := aNumber.
	self defaultsChanged.
]

{
	#category : #preferences,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:12'
}
SWAGameRabbit class >> restTime [
	<preference: 'Rabbit rest time'
		category: 'SWAGame'
		description: 'Longest pause, in seconds, after a calm rabbit arrives somewhere.'
		type: #Number>
	^ DefaultRestTime ifNil: [4]
]

{
	#category : #preferences,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 14:35'
}
SWAGameRabbit class >> restTime: aNumber [
	DefaultRestTime := aNumber.
	self defaultsChanged.
]

{
	#category : #preferences,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:12'
}
SWAGameRabbit class >> runSpeed [
	<preference: 'Rabbit run speed'
		category: 'SWAGame'
		description: 'Cells per second when fleeing. Has to stay under the fox run speed, or no hunt is ever won.'
		type: #Number>
	^ DefaultRunSpeed ifNil: [2.6]
]

{
	#category : #preferences,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 14:35'
}
SWAGameRabbit class >> runSpeed: aNumber [
	DefaultRunSpeed := aNumber.
	self defaultsChanged.
]

{
	#category : #preferences,
	#'squeak_changestamp' : 'MCPServer 5/18/2026 14:13'
}
SWAGameRabbit class >> startingEnergy [
	<preference: 'Rabbit starting energy'
		category: 'SWAGame'
		description: 'Energy at birth.'
		type: #Number>
	^ DefaultStartingEnergy ifNil: [40]
]

{
	#category : #preferences,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 14:35'
}
SWAGameRabbit class >> startingEnergy: aNumber [
	DefaultStartingEnergy := aNumber.
	self defaultsChanged.
]

{
	#category : #preferences,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:12'
}
SWAGameRabbit class >> walkSpeed [
	<preference: 'Rabbit walk speed'
		category: 'SWAGame'
		description: 'Cells per second when calm.'
		type: #Number>
	^ DefaultWalkSpeed ifNil: [0.6]
]

{
	#category : #preferences,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 14:35'
}
SWAGameRabbit class >> walkSpeed: aNumber [
	DefaultWalkSpeed := aNumber.
	self defaultsChanged.
]

{
	#category : #behavior,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 18:36'
}
SWAGameRabbit >> actOn: aGame [
	"Only an idle rabbit starts a meal: stopping on every tuft turned a walk into a string of meals."
	mealTimer ifNotNil: [^ self grazeOn: aGame].
	(target isNil
		and: [self alarmed not
		and: [energy < self maxEnergy
		and: [(aGame grassAt: self cell) > 0]]])
			ifTrue: [mealTimer := 0]
]

{
	#category : #genetics,
	#'squeak_changestamp' : 'MCPServer (jl) 11/17/2026 14:35'
}
SWAGameRabbit >> beFounderOn: aGame [
	"No parents to inherit from: both alleles at random, so every colour is in the first generation."
	| alleles |
	alleles := self class coatAlleles.
	self coat: {alleles atRandom: aGame random. alleles atRandom: aGame random}.
]

{
	#category : #behavior,
	#'squeak_changestamp' : 'MCPServer 5/13/2026 15:11'
}
SWAGameRabbit >> canEnter: aPoint on: aGame [
	"Rabbits cannot swim - rivers block them"
	^ (aGame isRiverAt: aPoint) not
]

{
	#category : #behavior,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 15:10'
}
SWAGameRabbit >> canReproduceOn: aGame [
	"reproduceChance is percent per second."

	^ energy > reproduceThreshold
		and: [aGame random next < (reproduceChance / 100.0 * aGame secondsPerTick)]
]

{
	#category : #genetics,
	#'squeak_changestamp' : 'MCPServer (jl) 11/17/2026 14:35'
}
SWAGameRabbit >> coat [
	"Two alleles, one from each parent. Rabbits from before coats existed have none and count as white."
	^ coat ifNil: [#(#white #white)]
]

{
	#category : #genetics,
	#'squeak_changestamp' : 'MCPServer (jl) 11/17/2026 14:35'
}
SWAGameRabbit >> coat: aPair [
	coat := aPair asArray.
	color := self class furColorOf: self coatPhenotype.
]

{
	#category : #genetics,
	#'squeak_changestamp' : 'MCPServer (jl) 11/17/2026 14:35'
}
SWAGameRabbit >> coatDescription [
	^ self coatPhenotype asString, ' (', self coat first asString, '/', self coat second asString, ')'
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/17/2026 14:35'
}
SWAGameRabbit >> coatMutationChance [
	^ coatMutationChance ifNil: [self class coatMutationChance]
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/17/2026 14:35'
}
SWAGameRabbit >> coatMutationChance: aNumber [
	coatMutationChance := aNumber
]

{
	#category : #genetics,
	#'squeak_changestamp' : 'MCPServer (jl) 11/17/2026 14:35'
}
SWAGameRabbit >> coatPhenotype [
	"Asked per frame by the renderer, so no blocks that allocate."
	| alleles pair |
	alleles := self class coatAlleles.
	pair := self coat.
	1 to: alleles size do: [:i |
		| allele |
		allele := alleles at: i.
		((pair at: 1) == allele or: [(pair at: 2) == allele]) ifTrue: [^ allele]].
	^ alleles last
]

{
	#category : #behavior,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:36'
}
SWAGameRabbit >> grazeOn: aGame [
	"Two rabbits can share a tile; the one finishing first leaves the other
	nothing to finish."
	(aGame grassAt: self cell) > 0 ifFalse: [^ mealTimer := nil].
	self gainEnergy: eatGain * aGame secondsPerTick / self eatTime.
	mealTimer := mealTimer + aGame secondsPerTick.
	mealTimer >= self eatTime ifTrue: [
		aGame grassAt: self cell put: 0.
		mealTimer := nil]
]

{
	#category : #initialization,
	#'squeak_changestamp' : 'MCPServer (jl) 11/17/2026 14:35'
}
SWAGameRabbit >> initialize [
	super initialize.
	self coat: #(#white #white).
	startingEnergy := self class startingEnergy.
	energy := startingEnergy.
	maxEnergy := self class maxEnergy.
	reproduceThreshold := self class reproduceThreshold.
	reproduceChance := self class reproduceChance.
	reproduceCost := self class reproduceCost.
	offspringEnergy := self class offspringEnergy.
	eatGain := self class eatGain.
	burnRate := self class burnRate.
	walkSpeed := self class walkSpeed.
	runSpeed := self class runSpeed.
	lifespan := self class lifespan.
	coatMutationChance := self class coatMutationChance.
	huntRadius := 0.
	movementStrategy := SWAGameFleeStrategy new
		threatSpecies: #fox;
		detectionRange: self class detectionRange;
		calmStrategy: SWAGameGrazeStrategy new;
		yourself
]

{
	#category : #behavior,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 18:36'
}
SWAGameRabbit >> makeOffspring [
	energy := energy - reproduceCost.
	^ self class new
		positionX: x y: y z: z;
		energy: offspringEnergy;
		yourself
]

{
	#category : #behavior,
	#'squeak_changestamp' : 'MCPServer (jl) 11/17/2026 14:35'
}
SWAGameRabbit >> makeOffspringOn: aGame [
	| mate |
	energy := energy - reproduceCost.
	mate := self mateOn: aGame.
	^ self class new
		positionX: x y: y z: z;
		energy: offspringEnergy;
		coat: {self passCoatAlleleOn: aGame. mate passCoatAlleleOn: aGame};
		yourself
]

{
	#category : #genetics,
	#'squeak_changestamp' : 'MCPServer (jl) 11/17/2026 14:35'
}
SWAGameRabbit >> mateOn: aGame [
	"The nearest grown rabbit in range. With none, the parent stands in for the mate, so a lone carrier can still have recessive young."
	| mate best |
	mate := self.
	best := nil.
	(aGame mobsNear: x @ z radius: self mateRange ofSpecies: #rabbit) do: [:other |
		| dx dz d |
		(other ~~ self and: [other isChild not]) ifTrue: [
			dx := other x - x.
			dz := other z - z.
			d := (dx * dx) + (dz * dz).
			(best isNil or: [d < best]) ifTrue: [
				best := d.
				mate := other]]].
	^ mate
]

{
	#category : #genetics,
	#'squeak_changestamp' : 'MCPServer (jl) 11/17/2026 14:35'
}
SWAGameRabbit >> mateRange [
	^ 6
]

{
	#category : #rendering,
	#'squeak_changestamp' : 'MCPServer (jl) 11/17/2026 14:35'
}
SWAGameRabbit >> modelKey [
	^ self coatPhenotype
]

{
	#category : #rendering,
	#'squeak_changestamp' : 'MCPServer (jl) 11/17/2026 14:35'
}
SWAGameRabbit >> newModel [
	^ SWAGameMobModel rabbitCoat: self coatPhenotype
]

{
	#category : #genetics,
	#'squeak_changestamp' : 'MCPServer (jl) 11/17/2026 14:35'
}
SWAGameRabbit >> passCoatAlleleOn: aGame [
	(aGame random next * 100) < self coatMutationChance
		ifTrue: [^ self class coatAlleles atRandom: aGame random].
	^ self coat atRandom: aGame random
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 5/13/2026 15:17'
}
SWAGameRabbit >> species [
	^ #rabbit
]
