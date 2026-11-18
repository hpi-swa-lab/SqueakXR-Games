"
A rabbit or a fox, at a continuous position in cells, y up.
"
Class {
	#name : #SWAGameMob,
	#superclass : #Object,
	#instVars : [
		'x',
		'y',
		'z',
		'vx',
		'vy',
		'vz',
		'onGround',
		'alarmed',
		'target',
		'decisionTimer',
		'chunkKey',
		'color',
		'energy',
		'alive',
		'movementStrategy',
		'age',
		'reproduceThreshold',
		'reproduceChance',
		'reproduceCost',
		'offspringEnergy',
		'eatGain',
		'burnRate',
		'huntRadius',
		'maxEnergy',
		'startingEnergy',
		'walkSpeed',
		'runSpeed',
		'restTimer',
		'route',
		'stuckTimer',
		'lastDistance',
		'remains',
		'deathTimer',
		'mealTimer',
		'meal',
		'restTime',
		'eatTime',
		'territoryRadius',
		'petTimer',
		'lifespan'
	],
	#category : #SWAGame,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 18:36'
}

{
	#category : #defaults,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 18:36'
}
SWAGameMob class >> defaultsChanged [
	SWAGameWorld allInstancesDo: [:each | each reconfigureMobs].
]

{
	#category : #defaults,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:36'
}
SWAGameMob class >> eatTime [
	^ 3.0
]

{
	#category : #defaults,
	#'squeak_changestamp' : 'MCPServer (jl) 11/13/2026 10:56'
}
SWAGameMob class >> lifespan [
	^ 300
]

{
	#category : #constants,
	#'squeak_changestamp' : 'MCPServer (leo) 11/5/2026 17:47'
}
SWAGameMob class >> petDuration [

	^ 2
]

{
	#category : #defaults,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:11'
}
SWAGameMob class >> restTime [
	^ 3.0
]

{
	#category : #defaults,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:11'
}
SWAGameMob class >> runSpeed [
	^ 2.0
]

{
	#category : #defaults,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:11'
}
SWAGameMob class >> walkSpeed [
	^ 0.5
]

{
	#category : #behavior,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 18:36'
}
SWAGameMob >> actOn: aGame [
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/13/2026 10:56'
}
SWAGameMob >> age [
	"Seconds alive; a body stops ageing."
	^ age ifNil: [0]
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 14:37'
}
SWAGameMob >> age: anInteger [
	age := anInteger.
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 15:14'
}
SWAGameMob >> alarmed [

	^ alarmed ifNil: [false]
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 18:36'
}
SWAGameMob >> alarmed: aBoolean [
	alarmed := aBoolean.
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 5/13/2026 14:57'
}
SWAGameMob >> alive [
	^ alive
]

{
	#category : #physics,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 18:36'
}
SWAGameMob >> applyPhysicsOn: aGame dt: dt [
	"Substeps: past about a quarter cell per step a mob tunnels into terrain and jams."
	"Fast path for a mob standing still; the block underfoot is still checked."
	| steps h |
	(onGround == true
		and: [vx = 0.0 and: [vz = 0.0 and: [vy = 0.0
		and: [aGame isSolidAtX: x floor y: y floor - 1 z: z floor]]]])
			ifTrue: [^ self].
	steps := (((vx abs max: vz abs) max: vy abs) * dt / 0.25) ceiling max: 1.
	h := dt / steps.
	steps timesRepeat: [self integrateOn: aGame dt: h].
]

{
	#category : #physics,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 18:36'
}
SWAGameMob >> applySeparationOn: aGame [
	"Soft: a hard block wedges mobs in doorways and lets a crowd trap one against a wall."
	| radius radiusSquared pushX pushZ |
	radius := self halfWidth * 2.
	radiusSquared := radius * radius.
	pushX := 0.0.
	pushZ := 0.0.
	aGame mobsNearCellX: self cellX z: self cellZ do: [:other |
		| dx dz squared distance overlap |
		dx := x - other x.
		dz := z - other z.
		squared := (dx * dx) + (dz * dz).
		(squared < radiusSquared and: [other ~~ self]) ifTrue: [
			distance := squared sqrt.
			overlap := (radius - distance) / radius.
			distance > 0.0001
				ifTrue: [
					pushX := pushX + (dx / distance * overlap).
					pushZ := pushZ + (dz / distance * overlap)]
				ifFalse: [
					"Offspring start exactly on the parent: no direction to push along."
					pushX := pushX + (aGame random next - 0.5).
					pushZ := pushZ + (aGame random next - 0.5)]]].
	(pushX = 0.0 and: [pushZ = 0.0]) ifTrue: [^ self].
	vx := vx + (pushX * self pushStrength).
	vz := vz + (pushZ * self pushStrength).
]

{
	#category : #genetics,
	#'squeak_changestamp' : 'MCPServer (jl) 11/17/2026 14:35'
}
SWAGameMob >> beFounderOn: aGame [
]

{
	#category : #behavior,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 18:36'
}
SWAGameMob >> burnEnergyOn: aGame [
	"burnRate is per second."

	energy := energy - (burnRate * aGame secondsPerTick).
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 5/13/2026 18:28'
}
SWAGameMob >> burnRate [
	^ burnRate
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 5/13/2026 18:28'
}
SWAGameMob >> burnRate: aNumber [
	burnRate := aNumber
]

{
	#category : #behavior,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 18:36'
}
SWAGameMob >> canReproduceOn: aGame [
	^ false
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 18:36'
}
SWAGameMob >> cell [
	^ self cellX @ self cellZ
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 13:22'
}
SWAGameMob >> cellX [

	^ x floor
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 13:22'
}
SWAGameMob >> cellY [

	^ y floor
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 13:22'
}
SWAGameMob >> cellZ [

	^ z floor
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 18:36'
}
SWAGameMob >> chunkKey [
	^ chunkKey
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 16:21'
}
SWAGameMob >> chunkKey: anInteger [

	chunkKey := anInteger
]

{
	#category : #genetics,
	#'squeak_changestamp' : 'MCPServer (jl) 11/17/2026 14:35'
}
SWAGameMob >> coat [
	^ nil
]

{
	#category : #physics,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 18:36'
}
SWAGameMob >> collidesAtX: px y: py z: pz on: aGame [
	"The top edge is pulled in, or a mob on a block boundary collides with the block above."

	| hw x0 x1 y0 y1 z0 z1 |
	hw := self halfWidth.
	x0 := (px - hw) floor.
	x1 := (px + hw) floor.
	y0 := py floor.
	y1 := (py + self height - 0.001) floor.
	z0 := (pz - hw) floor.
	z1 := (pz + hw) floor.
	x0 to: x1 do: [:cx |
		y0 to: y1 do: [:cy |
			z0 to: z1 do: [:cz |
				(aGame isSolidAtX: cx y: cy z: cz) ifTrue: [^ true]]]].
	^ false
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 5/13/2026 14:47'
}
SWAGameMob >> color [
	^ color
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 5/13/2026 14:47'
}
SWAGameMob >> color: aColor [
	color := aColor
]

{
	#category : #behavior,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 18:36'
}
SWAGameMob >> consume: aFraction [
	"Answers what was actually left to take."
	| bite |
	bite := aFraction min: self remains.
	remains := self remains - bite.
	^ bite
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 14:37'
}
SWAGameMob >> deathTimer [
	^ deathTimer
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:36'
}
SWAGameMob >> decayTime [
	"Seconds a body lies before it is gone, eaten or not."
	^ 30.0
]

{
	#category : #behavior,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 13:38'
}
SWAGameMob >> decisionInterval [
	"Seconds between re-reading the strategy."

	^ 0.25
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 14:34'
}
SWAGameMob >> detectionRange [
	^ movementStrategy ifNotNil: [:strategy | strategy detectionRange]
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 14:34'
}
SWAGameMob >> detectionRange: aNumber [
	"Kept by the strategy, which is what does the sensing."
	movementStrategy ifNotNil: [:strategy | strategy detectionRange: aNumber].
]

{
	#category : #behavior,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 18:36'
}
SWAGameMob >> die [
	alive := false.
	remains := 1.0.
	deathTimer := 0.
	vx := 0.0.
	vz := 0.0.
	target := nil.
	route := nil.
	self stopEating.
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 5/13/2026 18:28'
}
SWAGameMob >> eatGain [
	^ eatGain
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 5/13/2026 18:28'
}
SWAGameMob >> eatGain: aNumber [
	eatGain := aNumber
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 14:34'
}
SWAGameMob >> eatTime [
	"Seconds one meal takes. Zero means a single tick, not a division by zero."
	^ (eatTime ifNil: [self class eatTime]) max: 0.05
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 14:34'
}
SWAGameMob >> eatTime: aNumber [
	eatTime := aNumber.
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 5/13/2026 14:57'
}
SWAGameMob >> energy [
	^ energy
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 5/13/2026 14:57'
}
SWAGameMob >> energy: anInteger [
	energy := anInteger
]

{
	#category : #behavior,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 18:36'
}
SWAGameMob >> followRoute: aRoute on: aGame [
	"An empty route counts as arriving, or a boxed-in mob searches every decision.
	A replan towards the same next cell keeps the progress record."
	(aRoute isNil or: [aRoute isEmpty]) ifTrue: [^ self stopOn: aGame].
	aRoute == route ifTrue: [^ self].
	(route notNil and: [route notEmpty and: [route first = aRoute first]])
		ifFalse: [lastDistance := nil].
	route := aRoute asOrderedCollection.
	target := route last.
]

{
	#category : #behavior,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 18:36'
}
SWAGameMob >> gainEnergy: anAmount [
	energy := (energy + anAmount) min: maxEnergy.
]

{
	#category : #physics,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 13:22'
}
SWAGameMob >> gravity [
	"Cells per second squared."

	^ 24.0
]

{
	#category : #physics,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 13:21'
}
SWAGameMob >> halfWidth [
	"Under half a cell, so a mob fits through a one-block gap."

	^ 0.3
]

{
	#category : #testing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 12:31'
}
SWAGameMob >> hasTerritoryOn: aGame [
	self territoryRadius <= 0 ifTrue: [^ true].
	^ (aGame mobsOfSpecies: self species) noneSatisfy: [:other |
		other ~~ self
			and: [other alive
			and: [(other x - x) squared + (other z - z) squared
				< self territoryRadius squared]]]
]

{
	#category : #physics,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 13:21'
}
SWAGameMob >> height [
	"Under one cell, so a mob fits in a one-block-high tunnel."

	^ 0.8
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 5/13/2026 18:28'
}
SWAGameMob >> huntRadius [
	^ huntRadius
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 5/13/2026 18:28'
}
SWAGameMob >> huntRadius: aNumber [
	huntRadius := aNumber
]

{
	#category : #initialization,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 18:36'
}
SWAGameMob >> initialize [
	super initialize.
	self positionX: 0.5 y: 0.0 z: 0.5.
	vx := 0.0.
	vy := 0.0.
	vz := 0.0.
	onGround := false.
	target := nil.
	color := Color red.
	energy := 50.
	alive := true.
	age := 0.
	movementStrategy := nil.
	
	reproduceThreshold := 50.
	reproduceChance := 5.
	reproduceCost := 20.
	offspringEnergy := 25.
	eatGain := 5.
	burnRate := 1.
	huntRadius := 0.
	maxEnergy := 100.
	startingEnergy := 50
]

{
	#category : #physics,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 18:36'
}
SWAGameMob >> integrateOn: aGame dt: dt [
	"onGround is rediscovered every step, so digging out the block below drops the mob."

	| newX newY newZ |
	vy := vy - (self gravity * dt).

	newX := x + (vx * dt).
	(self collidesAtX: newX y: y z: z on: aGame)
		ifTrue: [self tryJump]
		ifFalse: [x := newX].

	newZ := z + (vz * dt).
	(self collidesAtX: x y: y z: newZ on: aGame)
		ifTrue: [self tryJump]
		ifFalse: [z := newZ].

	newY := y + (vy * dt).
	(self collidesAtX: x y: newY z: z on: aGame)
		ifTrue: [
			vy <= 0 ifTrue: [
				y := newY floor + 1.
				onGround := true].
			vy := 0.0]
		ifFalse: [
			y := newY.
			onGround := false].
]

{
	#category : #petting,
	#'squeak_changestamp' : 'MCPServer (leo) 11/5/2026 17:47'
}
SWAGameMob >> isBeingPetted [

	^ petTimer notNil and: [petTimer > 0]
]

{
	#category : #testing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/13/2026 10:56'
}
SWAGameMob >> isChild [
	^ self age < (self lifespan * 0.2)
]

{
	#category : #testing,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:36'
}
SWAGameMob >> isEating [
	^ mealTimer notNil or: [meal notNil]
]

{
	#category : #testing,
	#'squeak_changestamp' : 'MCPServer 5/13/2026 15:17'
}
SWAGameMob >> isFox [
	^ self species = #fox
]

{
	#category : #testing,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:36'
}
SWAGameMob >> isGone [
	^ alive not and: [self remains <= 0 or: [(deathTimer ifNil: [0]) >= self decayTime]]
]

{
	#category : #behavior,
	#'squeak_changestamp' : 'MCPServer (leo) 11/3/2026 18:16'
}
SWAGameMob >> isHitFrom: startCell to: endCell [

	| hw entry exit |
	hw := self halfWidth.
	entry := 0.
	exit := 1.
	{{startCell x. endCell x. x - hw. x + hw}.
	{startCell y. endCell y. y. y + self height}.
	{startCell z. endCell z. z - hw. z + hw}} do: [:slab | | from delta t0 t1 |
		from := slab first.
		delta := slab second - from.
		delta = 0
			ifTrue: [(from between: slab third and: slab fourth) ifFalse: [^ false]]
			ifFalse: [
				t0 := slab third - from / delta.
				t1 := slab fourth - from / delta.
				entry := entry max: (t0 min: t1).
				exit := exit min: (t0 max: t1)]].
	^ entry <= exit
]

{
	#category : #testing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 18:36'
}
SWAGameMob >> isHungry [
	"Only the hunt strategy asks; grazers always eat."

	^ true
]

{
	#category : #testing,
	#'squeak_changestamp' : 'MCPServer 5/13/2026 15:16'
}
SWAGameMob >> isRabbit [
	^ self species = #rabbit
]

{
	#category : #behavior,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 18:36'
}
SWAGameMob >> isStuckAt: aDistance on: aGame [
	"Progress, not position: a mob jumping at a wall it cannot climb never gets closer."
	(lastDistance isNil or: [aDistance < (lastDistance - 0.1)]) ifTrue: [
		lastDistance := aDistance.
		stuckTimer := 0.
		^ false].
	stuckTimer := (stuckTimer ifNil: [0]) + aGame secondsPerTick.
	^ stuckTimer > self patience
]

{
	#category : #physics,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 13:22'
}
SWAGameMob >> jumpSpeed [
	"Clears one block: jumpSpeed squared over twice gravity is just above 1."

	^ 7.0
]

{
	#category : #behavior,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 18:36'
}
SWAGameMob >> lieDeadWith: aRemains after: seconds [
	self die.
	remains := aRemains.
	deathTimer := seconds.
]

{
	#category : #behavior,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:36'
}
SWAGameMob >> lieOn: aGame [
	"Still falls: a mob killed in mid-jump would otherwise hang in the air."
	deathTimer := (deathTimer ifNil: [0]) + aGame secondsPerTick.
	vx := 0.0.
	vz := 0.0.
	self applyPhysicsOn: aGame dt: aGame secondsPerTick.
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/13/2026 10:56'
}
SWAGameMob >> lifespan [
	"Seconds. Nothing dies of old age; it sets how long a mob is a child and grows."
	^ lifespan ifNil: [self class lifespan]
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/13/2026 10:56'
}
SWAGameMob >> lifespan: aNumber [
	lifespan := aNumber.
]

{
	#category : #behavior,
	#'squeak_changestamp' : 'MCPServer (jl) 11/17/2026 14:35'
}
SWAGameMob >> makeOffspringOn: aGame [
	^ nil
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 5/13/2026 18:28'
}
SWAGameMob >> maxEnergy [
	^ maxEnergy ifNil: [100]
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 5/13/2026 18:28'
}
SWAGameMob >> maxEnergy: aNumber [
	maxEnergy := aNumber
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:36'
}
SWAGameMob >> meal [
	^ meal
]

{
	#category : #rendering,
	#'squeak_changestamp' : 'MCPServer (jl) 11/17/2026 14:35'
}
SWAGameMob >> modelKey [
	"Mobs that look alike share a model and a mesh."
	^ self species
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:12'
}
SWAGameMob >> moveSpeed [
	^ self alarmed
		ifTrue: [self runSpeed]
		ifFalse: [self walkSpeed]
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 5/13/2026 14:57'
}
SWAGameMob >> movementStrategy [
	^ movementStrategy
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 18:36'
}
SWAGameMob >> movementStrategy: aStrategy [
	movementStrategy := aStrategy
]

{
	#category : #rendering,
	#'squeak_changestamp' : 'MCPServer (jl) 11/17/2026 14:35'
}
SWAGameMob >> newModel [
	^ SWAGameMobModel forSpecies: self species
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 5/13/2026 18:28'
}
SWAGameMob >> offspringEnergy [
	^ offspringEnergy
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 5/13/2026 18:28'
}
SWAGameMob >> offspringEnergy: aNumber [
	offspringEnergy := aNumber
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 13:26'
}
SWAGameMob >> onGround [

	^ onGround
]

{
	#category : #behavior,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:26'
}
SWAGameMob >> patience [
	"Seconds without getting closer before a mob gives up on a waypoint."
	^ 1.5
]

{
	#category : #petting,
	#'squeak_changestamp' : 'MCPServer (leo) 11/5/2026 17:47'
}
SWAGameMob >> pet [

	petTimer := self class petDuration.
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 13:22'
}
SWAGameMob >> positionX: aNumber y: anotherNumber z: aThirdNumber [

	x := aNumber.
	y := anotherNumber.
	z := aThirdNumber.
]

{
	#category : #physics,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 18:36'
}
SWAGameMob >> pushStrength [
	"Cells per second at full overlap; below walking speed, so a shove does not override the heading."
	^ self walkSpeed * 0.8
]

{
	#category : #behavior,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 18:36'
}
SWAGameMob >> reconsiderOn: aGame [
	"On a timer, not on arrival, so prey notices a threat mid-journey.
	A calm mob keeps its plan: re-picking a jittered grazing spot made herds zigzag."
	| wasAlarmed next |
	restTimer := (restTimer ifNil: [0]) - aGame secondsPerTick.
	decisionTimer := (decisionTimer ifNil: [0]) - aGame secondsPerTick.
	decisionTimer > 0 ifTrue: [^ self].
	decisionTimer := self decisionInterval.
	movementStrategy ifNil: [^ self].
	wasAlarmed := self alarmed.
	(movementStrategy alarmsFor: self on: aGame) ifTrue: [
		next := movementStrategy nextRouteFor: self on: aGame.
		self alarmed ifTrue: [
			self stopEating.
			^ self followRoute: next on: aGame]].
	self alarmed: false.
	wasAlarmed ifTrue: [^ self stopOn: aGame].
	self isEating ifTrue: [^ self].
	(target isNil and: [restTimer <= 0]) ifTrue: [
		self followRoute: (movementStrategy nextRouteFor: self on: aGame) on: aGame].
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:36'
}
SWAGameMob >> remains [
	"How much of the body is left to eat, from 1 at death down to 0."
	^ remains ifNil: [0]
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 5/13/2026 18:28'
}
SWAGameMob >> reproduceChance [
	^ reproduceChance
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 5/13/2026 18:28'
}
SWAGameMob >> reproduceChance: aNumber [
	reproduceChance := aNumber
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 5/13/2026 18:28'
}
SWAGameMob >> reproduceCost [
	^ reproduceCost
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 5/13/2026 18:28'
}
SWAGameMob >> reproduceCost: aNumber [
	reproduceCost := aNumber
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 5/13/2026 18:27'
}
SWAGameMob >> reproduceThreshold [
	^ reproduceThreshold
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 5/13/2026 18:27'
}
SWAGameMob >> reproduceThreshold: aNumber [
	reproduceThreshold := aNumber
]

{
	#category : #behavior,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 12:36'
}
SWAGameMob >> restAfterArrivingOn: aGame [
	^ aGame random next * self restTime
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:26'
}
SWAGameMob >> restFor: seconds [
	restTimer := seconds.
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 14:34'
}
SWAGameMob >> restTime [
	"The longest pause, in seconds, after a calm mob arrives somewhere."
	^ restTime ifNil: [self class restTime]
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 14:34'
}
SWAGameMob >> restTime: aNumber [
	restTime := aNumber.
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:26'
}
SWAGameMob >> route [
	^ route
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 18:36'
}
SWAGameMob >> runSpeed [
	"Cells per second."
	^ runSpeed ifNil: [runSpeed := self class runSpeed]
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:11'
}
SWAGameMob >> runSpeed: aNumber [
	runSpeed := aNumber.
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 18:36'
}
SWAGameMob >> species [
	^ #mob
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 5/13/2026 18:28'
}
SWAGameMob >> startingEnergy [
	^ startingEnergy
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 5/13/2026 18:29'
}
SWAGameMob >> startingEnergy: aNumber [
	startingEnergy := aNumber
]

{
	#category : #behavior,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:26'
}
SWAGameMob >> steerTowardTargetOn: aGame [
	| waypoint dx dz dist |
	target ifNil: [vx := 0.0. vz := 0.0. ^ self].
	waypoint := (route isNil or: [route isEmpty])
		ifTrue: [target]
		ifFalse: [route first].
	dx := waypoint x - x.
	dz := waypoint y - z.
	dist := ((dx * dx) + (dz * dz)) sqrt.
	dist < 0.25 ifTrue: [
		(route notNil and: [route size > 1]) ifFalse: [^ self stopOn: aGame].
		route removeFirst.
		lastDistance := nil.
		^ self steerTowardTargetOn: aGame].
	(self isStuckAt: dist on: aGame) ifTrue: [^ self stopOn: aGame].
	vx := dx / dist * self moveSpeed.
	vz := dz / dist * self moveSpeed.
]

{
	#category : #behavior,
	#'squeak_changestamp' : 'MCPServer (jl) 11/17/2026 14:35'
}
SWAGameMob >> stepOn: aGame [
	alive ifFalse: [^ self lieOn: aGame].
	
	age := (age ifNil: [0]) + aGame secondsPerTick.
	self burnEnergyOn: aGame.
	self reconsiderOn: aGame.
	self wearOffPettingOn: aGame.
	(self isEating or: [self isBeingPetted])
		ifTrue: [vx := 0.0. vz := 0.0]
		ifFalse: [self steerTowardTargetOn: aGame].
	self applySeparationOn: aGame.
	self applyPhysicsOn: aGame dt: aGame secondsPerTick.
	self actOn: aGame.
	
	energy <= 0 ifTrue: [
		aGame tallyStarved.
		self die].
	
	(alive and: [self canReproduceOn: aGame]) ifTrue: [
		aGame addMob: (self makeOffspringOn: aGame)]
]

{
	#category : #behavior,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:36'
}
SWAGameMob >> stopEating [
	mealTimer := nil.
	meal := nil.
]

{
	#category : #behavior,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 18:42'
}
SWAGameMob >> stopOn: aGame [
	"Without a pause after arriving the animals are in constant motion."
	target := nil.
	route := nil.
	lastDistance := nil.
	vx := 0.0.
	vz := 0.0.
	self restFor: (self restAfterArrivingOn: aGame).
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 13:09'
}
SWAGameMob >> target [

	^ target
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 18:36'
}
SWAGameMob >> target: aPoint [
	"aPoint is x @ z, walked to in a straight line; strategies hand over a route."
	target := aPoint.
	route := nil.
	lastDistance := nil.
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 12:31'
}
SWAGameMob >> territoryRadius [
	"Cells around a mob that have to be free of its own species before it breeds;
	0 for none."
	^ territoryRadius ifNil: [0]
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 12:31'
}
SWAGameMob >> territoryRadius: aNumber [
	territoryRadius := aNumber.
]

{
	#category : #physics,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 13:23'
}
SWAGameMob >> tryJump [
	"Walking into a wall is what makes a mob climb, so a one-block rise needs no
	separate step-up case."

	onGround ifFalse: [^ self].
	vy := self jumpSpeed.
	onGround := false.
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 13:27'
}
SWAGameMob >> vx [

	^ vx
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 13:27'
}
SWAGameMob >> vy [

	^ vy
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 13:27'
}
SWAGameMob >> vz [

	^ vz
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 18:36'
}
SWAGameMob >> walkSpeed [
	"Cells per second."
	^ walkSpeed ifNil: [walkSpeed := self class walkSpeed]
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:11'
}
SWAGameMob >> walkSpeed: aNumber [
	walkSpeed := aNumber.
]

{
	#category : #petting,
	#'squeak_changestamp' : 'MCPServer (leo) 11/5/2026 17:47'
}
SWAGameMob >> wearOffPettingOn: aGame [

	petTimer ifNotNil: [petTimer := petTimer - aGame secondsPerTick].
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/13/2026 11:04'
}
SWAGameMob >> weight [
	"From a tenth at birth to 1, full grown at half the lifespan."
	^ 0.1 + (0.9 * ((self age / (self lifespan / 2)) min: 1.0))
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 13:22'
}
SWAGameMob >> x [
	^ x
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 13:22'
}
SWAGameMob >> y [
	^ y
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 13:22'
}
SWAGameMob >> z [

	^ z
]
