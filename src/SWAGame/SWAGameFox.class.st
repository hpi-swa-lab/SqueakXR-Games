"
Hunts rabbits, and only while hungry.
"
Class {
	#name : #SWAGameFox,
	#superclass : #SWAGameMob,
	#classVars : [
		'DefaultBurnRate',
		'DefaultDetectionRange',
		'DefaultEatGain',
		'DefaultEatTime',
		'DefaultHuntRadius',
		'DefaultLifespan',
		'DefaultMaxEnergy',
		'DefaultOffspringEnergy',
		'DefaultReproduceChance',
		'DefaultReproduceCost',
		'DefaultReproduceThreshold',
		'DefaultRestTime',
		'DefaultRunSpeed',
		'DefaultStartingEnergy',
		'DefaultTerritoryRadius',
		'DefaultWalkSpeed'
	],
	#category : #SWAGame,
	#'squeak_changestamp' : '<historical>'
}

{
	#category : #preferences,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:13'
}
SWAGameFox class >> burnRate [
	<preference: 'Fox burn rate'
		category: 'SWAGame'
		description: 'Energy spent per second. Chasing is what limits how many foxes the world feeds.'
		type: #Number>
	^ DefaultBurnRate ifNil: [0.8]
]

{
	#category : #preferences,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 14:35'
}
SWAGameFox class >> burnRate: aNumber [
	DefaultBurnRate := aNumber.
	self defaultsChanged.
]

{
	#category : #preferences,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 13:57'
}
SWAGameFox class >> detectionRange [
	<preference: 'Fox detection range'
		category: 'SWAGame'
		description: 'How far fox can sense rabbits to hunt.'
		type: #Number>
	^ DefaultDetectionRange ifNil: [8]
]

{
	#category : #preferences,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 14:35'
}
SWAGameFox class >> detectionRange: aNumber [
	DefaultDetectionRange := aNumber.
	self defaultsChanged.
]

{
	#category : #preferences,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 13:46'
}
SWAGameFox class >> eatGain [
	<preference: 'Fox eat gain'
		category: 'SWAGame'
		description: 'Energy gained from eating a rabbit.'
		type: #Number>
	^ DefaultEatGain ifNil: [35]
]

{
	#category : #preferences,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 14:35'
}
SWAGameFox class >> eatGain: aNumber [
	DefaultEatGain := aNumber.
	self defaultsChanged.
]

{
	#category : #preferences,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:36'
}
SWAGameFox class >> eatTime [
	<preference: 'Fox eat time'
		category: 'SWAGame'
		description: 'Seconds a fox takes to eat a rabbit.'
		type: #Number>
	^ DefaultEatTime ifNil: [8]
]

{
	#category : #preferences,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 14:35'
}
SWAGameFox class >> eatTime: aNumber [
	DefaultEatTime := aNumber.
	self defaultsChanged.
]

{
	#category : #preferences,
	#'squeak_changestamp' : 'MCPServer 5/18/2026 14:13'
}
SWAGameFox class >> huntRadius [
	<preference: 'Fox hunt radius'
		category: 'SWAGame'
		description: 'How close fox must be to kill a rabbit.'
		type: #Number>
	^ DefaultHuntRadius ifNil: [1]
]

{
	#category : #preferences,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 14:35'
}
SWAGameFox class >> huntRadius: aNumber [
	DefaultHuntRadius := aNumber.
	self defaultsChanged.
]

{
	#category : #preferences,
	#'squeak_changestamp' : 'MCPServer (jl) 11/13/2026 10:56'
}
SWAGameFox class >> lifespan [
	<preference: 'Fox lifespan'
		category: 'SWAGame'
		description: 'Seconds. A fox is a child for the first fifth and grows until half of it.'
		type: #Number>
	^ DefaultLifespan ifNil: [600]
]

{
	#category : #preferences,
	#'squeak_changestamp' : 'MCPServer (jl) 11/13/2026 10:56'
}
SWAGameFox class >> lifespan: aNumber [
	DefaultLifespan := aNumber.
	self defaultsChanged.
]

{
	#category : #preferences,
	#'squeak_changestamp' : 'MCPServer 5/18/2026 14:13'
}
SWAGameFox class >> maxEnergy [
	<preference: 'Fox max energy'
		category: 'SWAGame'
		description: 'Maximum energy for bar display.'
		type: #Number>
	^ DefaultMaxEnergy ifNil: [200]
]

{
	#category : #preferences,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 14:35'
}
SWAGameFox class >> maxEnergy: aNumber [
	DefaultMaxEnergy := aNumber.
	self defaultsChanged.
]

{
	#category : #preferences,
	#'squeak_changestamp' : 'MCPServer 5/18/2026 14:13'
}
SWAGameFox class >> offspringEnergy [
	<preference: 'Fox offspring energy'
		category: 'SWAGame'
		description: 'Starting energy of newborn foxes.'
		type: #Number>
	^ DefaultOffspringEnergy ifNil: [50]
]

{
	#category : #preferences,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 14:35'
}
SWAGameFox class >> offspringEnergy: aNumber [
	DefaultOffspringEnergy := aNumber.
	self defaultsChanged.
]

{
	#category : #preferences,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:13'
}
SWAGameFox class >> reproduceChance [
	<preference: 'Fox reproduce chance'
		category: 'SWAGame'
		description: 'Percent chance per second to reproduce when above threshold.'
		type: #Number>
	^ DefaultReproduceChance ifNil: [1]
]

{
	#category : #preferences,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 14:35'
}
SWAGameFox class >> reproduceChance: aNumber [
	DefaultReproduceChance := aNumber.
	self defaultsChanged.
]

{
	#category : #preferences,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 13:57'
}
SWAGameFox class >> reproduceCost [
	<preference: 'Fox reproduction cost'
		category: 'SWAGame'
		description: 'Energy cost to the parent when reproducing.'
		type: #Number>
	^ DefaultReproduceCost ifNil: [60]
]

{
	#category : #preferences,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 14:35'
}
SWAGameFox class >> reproduceCost: aNumber [
	DefaultReproduceCost := aNumber.
	self defaultsChanged.
]

{
	#category : #preferences,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 18:36'
}
SWAGameFox class >> reproduceThreshold [
	<preference: 'Fox reproduce threshold'
		category: 'SWAGame'
		description: 'Energy needed before a fox can reproduce.'
		type: #Number>
	"Under where a meal leaves a hungry fox (about 98), or foxes never breed."
	^ DefaultReproduceThreshold ifNil: [90]
]

{
	#category : #preferences,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 14:35'
}
SWAGameFox class >> reproduceThreshold: aNumber [
	DefaultReproduceThreshold := aNumber.
	self defaultsChanged.
]

{
	#category : #preferences,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:12'
}
SWAGameFox class >> restTime [
	<preference: 'Fox rest time'
		category: 'SWAGame'
		description: 'Longest pause, in seconds, after a calm fox arrives somewhere.'
		type: #Number>
	^ DefaultRestTime ifNil: [6]
]

{
	#category : #preferences,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 14:35'
}
SWAGameFox class >> restTime: aNumber [
	DefaultRestTime := aNumber.
	self defaultsChanged.
]

{
	#category : #preferences,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:12'
}
SWAGameFox class >> runSpeed [
	<preference: 'Fox run speed'
		category: 'SWAGame'
		description: 'Cells per second when hunting. Above the rabbit run speed a hunt can actually be won.'
		type: #Number>
	^ DefaultRunSpeed ifNil: [3.0]
]

{
	#category : #preferences,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 14:35'
}
SWAGameFox class >> runSpeed: aNumber [
	DefaultRunSpeed := aNumber.
	self defaultsChanged.
]

{
	#category : #preferences,
	#'squeak_changestamp' : 'MCPServer 5/18/2026 14:13'
}
SWAGameFox class >> startingEnergy [
	<preference: 'Fox starting energy'
		category: 'SWAGame'
		description: 'Energy at birth.'
		type: #Number>
	^ DefaultStartingEnergy ifNil: [150]
]

{
	#category : #preferences,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 14:35'
}
SWAGameFox class >> startingEnergy: aNumber [
	DefaultStartingEnergy := aNumber.
	self defaultsChanged.
]

{
	#category : #preferences,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 12:31'
}
SWAGameFox class >> territoryRadius [
	<preference: 'Fox territory radius'
		category: 'SWAGame'
		description: 'A fox only breeds with no other fox within this many cells. What keeps the foxes from outgrowing their prey; 0 turns it off.'
		type: #Number>
	^ DefaultTerritoryRadius ifNil: [6]
]

{
	#category : #preferences,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 12:31'
}
SWAGameFox class >> territoryRadius: aNumber [
	DefaultTerritoryRadius := aNumber.
	self defaultsChanged.
]

{
	#category : #preferences,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:12'
}
SWAGameFox class >> walkSpeed [
	<preference: 'Fox walk speed'
		category: 'SWAGame'
		description: 'Cells per second when calm.'
		type: #Number>
	^ DefaultWalkSpeed ifNil: [0.7]
]

{
	#category : #preferences,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 14:35'
}
SWAGameFox class >> walkSpeed: aNumber [
	DefaultWalkSpeed := aNumber.
	self defaultsChanged.
]

{
	#category : #behavior,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 18:36'
}
SWAGameFox >> actOn: aGame [
	| reach |
	meal ifNotNil: [^ self feedOn: aGame].
	self isHungry ifFalse: [^ self].
	"Continuous positions never match exactly, so touching is the least reach."
	reach := huntRadius max: 0.7.
	(aGame corpsesNear: x @ z radius: reach ofSpecies: #rabbit) ifNotEmpty: [:bodies |
		^ meal := bodies first].
	(aGame mobsNear: x @ z radius: reach ofSpecies: #rabbit) do: [:rabbit |
		rabbit alive ifTrue: [
			rabbit die.
			aGame tallyEaten.
			^ meal := rabbit]]
]

{
	#category : #behavior,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 12:31'
}
SWAGameFox >> canReproduceOn: aGame [
	"reproduceChance is percent per second. Territory last: it scans the foxes,
	and the dice usually say no first."
	^ energy > reproduceThreshold
		and: [aGame random next < (reproduceChance / 100.0 * aGame secondsPerTick)
		and: [self hasTerritoryOn: aGame]]
]

{
	#category : #behavior,
	#'squeak_changestamp' : 'MCPServer (jl) 11/13/2026 11:03'
}
SWAGameFox >> feedOn: aGame [
	"A smaller body is a shorter meal: energy arrives at the same rate either way."
	| duration |
	meal isGone ifTrue: [^ meal := nil].
	duration := self eatTime * meal weight max: aGame secondsPerTick.
	self gainEnergy: eatGain * meal weight * (meal consume: aGame secondsPerTick / duration).
	meal remains <= 0 ifTrue: [meal := nil].
]

{
	#category : #initialization,
	#'squeak_changestamp' : 'MCPServer (jl) 11/13/2026 10:55'
}
SWAGameFox >> initialize [
	super initialize.
	color := Color orange.
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
	huntRadius := self class huntRadius.
	territoryRadius := self class territoryRadius.
	movementStrategy := SWAGameHuntStrategy new
		preySpecies: #rabbit;
		detectionRange: self class detectionRange;
		yourself
]

{
	#category : #testing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 18:36'
}
SWAGameFox >> isHungry [
	"A sated fox does not hunt, or the prey is wiped out."


	^ energy < (maxEnergy * 0.35)
]

{
	#category : #behavior,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 18:36'
}
SWAGameFox >> makeOffspring [
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
SWAGameFox >> makeOffspringOn: aGame [
	energy := energy - reproduceCost.
	^ self class new
		positionX: x y: y z: z;
		energy: offspringEnergy;
		yourself
]

{
	#category : #behavior,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 18:36'
}
SWAGameFox >> restAfterArrivingOn: aGame [
	"A hungry fox keeps ranging, or it starves without ever seeing a rabbit."
	^ self isHungry
		ifTrue: [0]
		ifFalse: [super restAfterArrivingOn: aGame]
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 5/13/2026 15:17'
}
SWAGameFox >> species [
	^ #fox
]
