"
Tests for mob physics, rates and steering against a flat test world.

The world is built with a known flat floor rather than generated terrain, so a failure means the mob is wrong rather than the landscape happening to differ.
"
Class {
	#name : #SWAGameMobTest,
	#superclass : #SWAGameTestCase,
	#instVars : [
		'world'
	],
	#category : #'SWAGame-Tests',
	#'squeak_changestamp' : '<historical>'
}

{
	#category : #helpers,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 15:40'
}
SWAGameMobTest >> drive: aMob toward: aPoint ticks: count do: aBlock [
	"The target is reasserted every tick because #reconsiderOn: clears it, and a
	mob with no strategy would otherwise stand still and pass movement tests
	without ever moving."

	count timesRepeat: [
		aMob target: aPoint.
		aMob stepOn: world.
		aBlock value]
]

{
	#category : #private,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 17:39'
}
SWAGameMobTest >> generateFlatChunkAtX: cx z: cz [
	"Generated so the chunk is simulated and targets in it are legal, then
	flattened: a mob spawned inside a slope jams against it, which looks exactly
	like a mob that was never stepped."

	| x0 z0 |
	world generateChunkAtX: cx z: cz.
	x0 := cx * 16.
	z0 := cz * 16.
	x0 to: x0 + 15 do: [:x |
		z0 to: z0 + 15 do: [:z |
			0 to: 3 do: [:y | world voxels at: x at: y at: z put: 1]]].
]

{
	#category : #helpers,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 16:35'
}
SWAGameMobTest >> rabbitAtX: x z: z [

	| mob |
	mob := SWAGameRabbit new
		positionX: x y: 4 z: z;
		movementStrategy: nil;
		yourself.
	world addMobNow: mob.
	^ mob
]

{
	#category : #running,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 16:22'
}
SWAGameMobTest >> setUp [
	super setUp.
	world := SWAGameWorld gridSize: 32 maxHeight: 20.
	world ensureVoxels.
	world voxels clear.
	"A flat floor four blocks deep, so the surface is at y = 4."
	0 to: 31 do: [:x |
		0 to: 31 do: [:z |
			0 to: 3 do: [:y | world voxels at: x at: y at: z put: 1]]].
	world removeAllMobs.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:38'
}
SWAGameMobTest >> testACalmMobRestsBeforeSettingOffAgain [
	| mob |
	mob := self rabbitAtX: 8.5 z: 8.5.
	mob movementStrategy: SWAGameWanderStrategy new.
	world grassAt: mob cell put: 0.
	mob restFor: 2.
	30 timesRepeat: [mob stepOn: world].
	self assert: mob target isNil.
	self assert: mob vx equals: 0.0.
	30 timesRepeat: [mob stepOn: world].
	self assert: mob target notNil.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:29'
}
SWAGameMobTest >> testACalmPlanIsKeptWhileWalking [
	"Re-picking four times a second made grazers zigzag on the spot."
	| mob plan |
	mob := self rabbitAtX: 8.5 z: 8.5.
	mob movementStrategy: SWAGameWanderStrategy new.
	mob stepOn: world.
	plan := mob target.
	self assert: plan notNil.
	15 timesRepeat: [mob stepOn: world].
	self assert: mob target equals: plan.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 11/13/2026 10:56'
}
SWAGameMobTest >> testAFoxTakesItsTimeOverAKill [
	| fox rabbit before seconds |
	rabbit := self rabbitAtX: 8.5 z: 8.5.
	rabbit age: rabbit lifespan.
	fox := SWAGameFox new positionX: 8.6 y: 4 z: 8.5; movementStrategy: nil; yourself.
	fox energy: 50.
	world addMobNow: fox.
	world rebuildMobIndexes.
	before := fox energy.
	fox stepOn: world.
	"Stepped directly rather than ticked, so the index is refreshed by hand: a
	stale one still has the rabbit standing there to push against."
	world rebuildMobIndexes.
	self deny: rabbit alive.
	self assert: fox meal == rabbit.
	self assert: fox energy < (before + 1) description: 'the whole meal arrived at once'.
	seconds := [:s | (s / world secondsPerTick) rounded timesRepeat: [fox stepOn: world]].
	seconds value: fox eatTime / 2.
	self assert: (rabbit remains between: 0.4 and: 0.6).
	self assert: fox vx equals: 0.0.
	seconds value: fox eatTime / 2 + 0.2.
	self assert: rabbit remains equals: 0.
	self assert: fox meal isNil.
	self assert: fox energy > (before + fox eatGain - (fox burnRate * (fox eatTime + 1))).
	self assert: rabbit isGone.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:37'
}
SWAGameMobTest >> testAHungryFoxGoesForABody [
	| fox body route |
	body := self rabbitAtX: 14.5 z: 8.5.
	body die.
	fox := SWAGameFox new positionX: 8.5 y: 4 z: 8.5; yourself.
	fox energy: 50.
	world addMobNow: fox.
	world rebuildMobIndexes.
	self assert: (fox movementStrategy alarmsFor: fox on: world).
	route := fox movementStrategy nextRouteFor: fox on: world.
	self assert: route last equals: body x @ body z.
]

{
	#category : #'tests - chunks',
	#'squeak_changestamp' : 'MCPServer 10/15/2026 16:35'
}
SWAGameMobTest >> testAMobAddedAtRuntimeIsSimulated [
	"Mobs placed by clicking the terrain were added to the flat list only, so the
	tick walked the chunks and never stepped them: they stood still forever."

	| mob |
	mob := SWAGameRabbit new positionX: 8.5 y: 4 z: 8.5; yourself.
	world addMobNow: mob.
	10 timesRepeat: [world tick].
	self assert: mob age > 0 description: 'never stepped'.
	self assert: ((world mobChunks at: mob chunkKey ifAbsent: [OrderedCollection new])
		includes: mob).
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 11/13/2026 11:04'
}
SWAGameMobTest >> testAMobGrowsUntilHalfItsLifespan [
	| rabbit |
	rabbit := self rabbitAtX: 8.5 z: 8.5.
	rabbit lifespan: 100.
	self assert: (rabbit weight closeTo: 0.1).
	rabbit age: 25.
	self assert: (rabbit weight closeTo: 0.55).
	rabbit age: 80.
	self assert: rabbit weight equals: 1.0.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 11/13/2026 10:56'
}
SWAGameMobTest >> testAMobIsAChildForTheFirstFifthOfItsLifespan [
	| rabbit |
	rabbit := self rabbitAtX: 8.5 z: 8.5.
	rabbit lifespan: 100.
	self assert: rabbit isChild.
	rabbit age: 19.9.
	self assert: rabbit isChild.
	rabbit age: 20.
	self deny: rabbit isChild.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (leo) 11/5/2026 17:49'
}
SWAGameMobTest >> testAPettedRabbitStandsStill [

	| mob before |
	mob := self rabbitAtX: 8.5 z: 8.5.
	mob movementStrategy: SWAGameWanderStrategy new.
	mob stepOn: world.
	mob pet.
	before := mob x @ mob z.
	5 timesRepeat: [mob stepOn: world].
	self assert: mob x @ mob z equals: before.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:37'
}
SWAGameMobTest >> testARabbitTakesItsTimeOverGrass [
	| rabbit before |
	rabbit := self rabbitAtX: 8.5 z: 8.5.
	world grassAt: rabbit cell put: world maxGrass.
	rabbit energy: 20.
	before := rabbit energy.
	rabbit stepOn: world.
	self assert: rabbit isEating.
	(rabbit eatTime / 2 / world secondsPerTick) rounded timesRepeat: [rabbit stepOn: world].
	self assert: (world grassAt: rabbit cell) > 0.
	self assert: rabbit energy > before.
	self assert: rabbit energy < (before + rabbit eatGain - 1).
	(rabbit eatTime / 2 / world secondsPerTick) rounded + 2 timesRepeat: [rabbit stepOn: world].
	self deny: rabbit isEating.
	self assert: (world grassAt: rabbit cell) equals: 0.
	self assert: rabbit energy > (before + rabbit eatGain - (rabbit burnRate * (rabbit eatTime + 1))).
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (leo) 11/3/2026 18:16'
}
SWAGameMobTest >> testAShotOverTheBodyMisses [

	| mob |
	mob := self rabbitAtX: 8.5 z: 8.5.
	self deny: (mob isHitFrom: (Vector3 x: 5 y: 6 z: 8.5) to: (Vector3 x: 12 y: 6 z: 8.5))
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (leo) 11/3/2026 18:16'
}
SWAGameMobTest >> testAShotStoppingShortOfTheBodyMisses [

	| mob |
	mob := self rabbitAtX: 8.5 z: 8.5.
	self deny: (mob isHitFrom: (Vector3 x: 5 y: 4.4 z: 8.5) to: (Vector3 x: 8 y: 4.4 z: 8.5))
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (leo) 11/3/2026 18:16'
}
SWAGameMobTest >> testAShotThroughTheBodyHits [

	| mob |
	mob := self rabbitAtX: 8.5 z: 8.5.
	self assert: (mob isHitFrom: (Vector3 x: 5 y: 4.4 z: 8.5) to: (Vector3 x: 12 y: 4.4 z: 8.5))
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:37'
}
SWAGameMobTest >> testAThreatInterruptsAMeal [
	| rabbit fox |
	rabbit := SWAGameRabbit new positionX: 16.5 y: 4 z: 16.5; yourself.
	world addMobNow: rabbit.
	world grassAt: rabbit cell put: world maxGrass.
	rabbit energy: 20.
	rabbit restFor: 10.
	3 timesRepeat: [rabbit stepOn: world].
	self assert: rabbit isEating.
	fox := SWAGameFox new positionX: 13.5 y: 4 z: 16.5; yourself.
	world addMobNow: fox.
	world rebuildMobIndexes.
	6 timesRepeat: [rabbit stepOn: world].
	self assert: rabbit alarmed.
	self deny: rabbit isEating.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:29'
}
SWAGameMobTest >> testAThreatInterruptsARest [
	| rabbit fox |
	rabbit := SWAGameRabbit new positionX: 16.5 y: 4 z: 16.5; yourself.
	world addMobNow: rabbit.
	rabbit restFor: 10.
	fox := SWAGameFox new positionX: 13.5 y: 4 z: 16.5; yourself.
	world addMobNow: fox.
	world rebuildMobIndexes.
	rabbit stepOn: world.
	self assert: rabbit alarmed.
	self assert: rabbit target notNil.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 11/13/2026 11:04'
}
SWAGameMobTest >> testAYoungRabbitIsASmallerAndShorterMeal [
	| fox rabbit before |
	rabbit := self rabbitAtX: 8.5 z: 8.5.
	rabbit age: 0.
	fox := SWAGameFox new positionX: 8.6 y: 4 z: 8.5; movementStrategy: nil; yourself.
	fox energy: 50.
	world addMobNow: fox.
	fox burnRate: 0.
	world rebuildMobIndexes.
	before := fox energy.
	fox stepOn: world.
	world rebuildMobIndexes.
	self assert: fox meal == rabbit.
	(fox eatTime * rabbit weight / world secondsPerTick) rounded + 1 timesRepeat: [fox stepOn: world].
	self assert: rabbit remains equals: 0.
	self assert: fox meal isNil.
	self assert: (fox energy - before closeTo: fox eatGain * 0.1).
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 11/13/2026 10:56'
}
SWAGameMobTest >> testAgeIsCountedInSeconds [
	| rabbit |
	rabbit := self rabbitAtX: 8.5 z: 8.5.
	20 timesRepeat: [world tick].
	self assert: (rabbit age closeTo: 20 * world secondsPerTick).
]

{
	#category : #'tests - physics',
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:13'
}
SWAGameMobTest >> testCannotLeaveTheWorld [
	"Walking off the edge gave a negative cell index, which crashed the grass
	map with a subscript of zero."

	| mob |
	mob := self rabbitAtX: 1.0 z: 1.0.
	mob runSpeed: 20.
	mob alarmed: true.
	self drive: mob toward: -50 @ -50 ticks: 300 do: [
		self assert: mob cellX >= 0.
		self assert: mob cellZ >= 0.
		self assert: mob cellX < 32.
		self assert: mob cellZ < 32].
	self assert: mob x < 1.0 description: 'mob never pressed against the edge'.
]

{
	#category : #'tests - chunks',
	#'squeak_changestamp' : 'MCPServer 10/15/2026 16:43'
}
SWAGameMobTest >> testChunksBeyondTheSimulationRadiusFreeze [
	"The point of chunking the simulation: a mob far from the player is not
	stepped at all, so it neither ages nor moves nor costs anything."

	| near far |
	near := self rabbitAtX: 2.5 z: 2.5.
	far := self rabbitAtX: 29.5 z: 29.5.
	self deny: near chunkKey = far chunkKey
		description: 'both mobs landed in one chunk, nothing is being tested'.
	world simulationRadiusChunks: 0.
	world simulateAroundCellX: 2 z: 2.
	20 timesRepeat: [world tick].
	self assert: near age > 0 description: 'the nearby mob should be simulated'.
	self assert: far age equals: 0.
	"Lifting the limit brings it back to life."
	world simulationRadiusChunks: nil.
	20 timesRepeat: [world tick].
	self assert: far age > 0
]

{
	#category : #'tests - chunks',
	#'squeak_changestamp' : 'MCPServer 10/15/2026 16:50'
}
SWAGameMobTest >> testChunksGeneratedSeparatelyStillJoinUp [
	"Two chunks raised at different times must meet without a step at the seam.
	They do because a column's height depends only on where it is, so both
	sides of the border compute the same answer."

	| w |
	w := SWAGameWorld gridSize: 32 maxHeight: 20.
	w startFromChunkX: 0 z: 0.
	w generateChunkAtX: 1 z: 0.
	"Only the two generated chunks: x 1 to 32 across both, z 1 to 16 deep."
	1 to: 16 do: [:z |
		1 to: 32 do: [:x |
			self
				assert: (w heightAtX: x y: z)
				equals: (w heightForColumnX: x z: z)
				description: 'column ' , x printString , ',' , z printString]].
	"The seam itself: columns 16 and 17 are in different chunks."
	self assert: ((w heightAtX: 16 y: 9) - (w heightAtX: 17 y: 9)) abs <= 3
		description: 'cliff at the chunk border'
]

{
	#category : #'tests - physics',
	#'squeak_changestamp' : 'MCPServer 10/15/2026 15:40'
}
SWAGameMobTest >> testClimbsAOneBlockStep [
	"Walking into a wall is what triggers the jump, so a one block rise needs no
	separate step-up case."

	| mob |
	16 to: 31 do: [:x |
		0 to: 31 do: [:z | world voxels at: x at: 4 at: z put: 1]].
	mob := self rabbitAtX: 14.5 z: 8.5.
	self drive: mob toward: 20 @ 8.5 ticks: 200 do: [].
	self assert: mob x > 16 description: 'did not get over the step'.
	self assert: mob y equals: 5.
]

{
	#category : #'tests - chunks',
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:13'
}
SWAGameMobTest >> testCrossingAChunkBorderMovesTheMobBetweenBuckets [
	"Chunks are 16 wide, so walking from 14 to past 16 changes owner."

	| mob startKey |
	mob := self rabbitAtX: 14.5 z: 8.5.
	startKey := mob chunkKey.
	mob runSpeed: 20.
	mob alarmed: true.
	self tickWorldDriving: mob toward: 25 @ 8.5 ticks: 120.
	self assert: mob cellX > 16 description: 'never reached the next chunk'.
	self deny: mob chunkKey = startKey.
	self assert: mob chunkKey equals: (world chunkKeyForX: mob cellX z: mob cellZ).
	self deny: ((world mobChunks at: startKey ifAbsent: [OrderedCollection new]) includes: mob).
	self assert: ((world mobChunks at: mob chunkKey) includes: mob).
]

{
	#category : #'tests - chunks',
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:38'
}
SWAGameMobTest >> testDeadMobsLeaveTheirChunk [
	"A body lies where it fell until it decays, as food; it is neither counted
	nor hunted as a living mob, and it does leave in the end."
	| mob key |
	mob := self rabbitAtX: 8.5 z: 8.5.
	key := mob chunkKey.
	"Starve it properly: with grass under it the tick feeds it instead."
	world grassAt: mob cell put: 0.
	mob energy: 0.
	world tick.
	world rebuildMobIndexes.
	self deny: mob alive.
	self assert: ((world mobChunks at: key) includes: mob).
	self deny: (world mobs includes: mob).
	self deny: ((world mobsOfSpecies: #rabbit) includes: mob).
	(mob decayTime / world secondsPerTick) ceiling + 1 timesRepeat: [world tick].
	self deny: ((world mobChunks at: key ifAbsent: [OrderedCollection new]) includes: mob).
]

{
	#category : #'tests - rates',
	#'squeak_changestamp' : 'MCPServer 10/15/2026 15:39'
}
SWAGameMobTest >> testEachWorldHasItsOwnRandomStream [
	"A shared Random was corrupted by two worlds ticked from different
	processes, which crashed the live render loop."

	| other |
	other := SWAGameWorld gridSize: 32 maxHeight: 20.
	self deny: world random == other random.
]

{
	#category : #'tests - rates',
	#'squeak_changestamp' : 'MCPServer 10/15/2026 15:39'
}
SWAGameMobTest >> testEnergyBurnIsPerSecondNotPerTick [
	"Halving the tick period must not double the metabolism. When these rates
	were per tick, raising the simulation rate starved the whole world."

	| burnOver |
	burnOver := [:period |
		| w mob |
		w := SWAGameWorld gridSize: 32 maxHeight: 20.
		w ensureVoxels.
		w secondsPerTick: period.
		mob := SWAGameRabbit new positionX: 8.5 y: 30 z: 8.5; yourself.
		mob burnRate: 2.
		mob energy: 100.
		(2.0 / period) rounded timesRepeat: [mob burnEnergyOn: w].
		100 - mob energy].
	self assert: ((burnOver value: 0.05) - 4) abs < 0.001.
	self assert: ((burnOver value: 0.025) - 4) abs < 0.001.
	self assert: ((burnOver value: 0.1) - 4) abs < 0.001.
]

{
	#category : #'tests - rates',
	#'squeak_changestamp' : 'MCPServer 10/15/2026 15:39'
}
SWAGameMobTest >> testEnergyIsCappedAtMaxEnergy [
	"Uncapped, one good meal funded a whole run of offspring, and the energy bar
	divides by maxEnergy so it drew past the end."

	| mob |
	mob := SWAGameRabbit new.
	mob maxEnergy: 80.
	mob energy: 70.
	mob gainEnergy: 50.
	self assert: mob energy equals: 80.
]

{
	#category : #'tests - physics',
	#'squeak_changestamp' : 'MCPServer 10/15/2026 15:39'
}
SWAGameMobTest >> testFallsOntoTheSurfaceAndStaysThere [

	| mob |
	mob := self rabbitAtX: 8.5 z: 8.5.
	mob positionX: 8.5 y: 12 z: 8.5.
	40 timesRepeat: [mob stepOn: world].
	self assert: mob y equals: 4.
	self assert: mob onGround.
	20 timesRepeat: [mob stepOn: world].
	self assert: mob y equals: 4 description: 'must not sink or jitter once landed'.
]

{
	#category : #'tests - steering',
	#'squeak_changestamp' : 'MCPServer 10/15/2026 16:35'
}
SWAGameMobTest >> testFleeingMovesAwayFromTheFoxAndRaisesTheAlarm [

	| rabbit fox before after |
	rabbit := self rabbitAtX: 16.5 z: 16.5.
	rabbit movementStrategy: (SWAGameFleeStrategy new
		threatSpecies: #fox;
		detectionRange: 10;
		yourself).
	fox := SWAGameFox new positionX: 13.5 y: 4 z: 16.5; yourself.
	world addMobNow: fox.
	world rebuildMobIndexes.
	before := ((rabbit x - fox x) squared + (rabbit z - fox z) squared) sqrt.
	30 timesRepeat: [rabbit stepOn: world].
	after := ((rabbit x - fox x) squared + (rabbit z - fox z) squared) sqrt.
	self assert: rabbit alarmed.
	self assert: after > before description: 'rabbit did not increase its distance'.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:26'
}
SWAGameMobTest >> testFleeingRunsWithinTheGrownChunk [
	"Flee candidates were clamped to gridSize, which both pulled prey out in a
	grown chunk back towards the original area and made every candidate score the
	same once clamped."

	| rabbit fox target |
	world clearTerrain.
	world voxels clear.
	self generateFlatChunkAtX: 2 z: 0.
	rabbit := SWAGameRabbit new positionX: 40.5 y: 4 z: 8.5.
	fox := SWAGameFox new positionX: 36.5 y: 4 z: 8.5.
	world addMobNow: rabbit.
	world addMobNow: fox.
	target := (rabbit movementStrategy nextRouteFor: rabbit on: world) last.
	self assert: rabbit alarmed.
	self assert: target x >= 32.
	self assert: (target x - fox x) abs > (rabbit x - fox x) abs.
]

{
	#category : #'tests - steering',
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:13'
}
SWAGameMobTest >> testGrazingIsSlowerThanFleeing [
	"A rabbit should only sprint when something is chasing it."
	| mob |
	mob := self rabbitAtX: 8.5 z: 8.5.
	mob alarmed: false.
	self assert: mob walkSpeed < mob runSpeed.
	self assert: mob moveSpeed equals: mob walkSpeed.
	mob alarmed: true.
	self assert: mob moveSpeed equals: mob runSpeed.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:26'
}
SWAGameMobTest >> testGrazingSearchesTheChunkItIsInNotTheOriginalExtent [
	"The grass search was bounded by gridSize, so a grazer out in a grown chunk
	found no candidate at all and fell through to wandering."

	| mob strategy |
	world clearTerrain.
	world voxels clear.
	self generateFlatChunkAtX: 2 z: 0.
	32 to: 47 do: [:gx |
		0 to: 15 do: [:gz | world grassAt: gx @ gz put: 0]].
	world grassAt: 44 @ 8 put: world maxGrass.
	mob := SWAGameRabbit new positionX: 40.5 y: 4 z: 8.5.
	world addMobNow: mob.
	strategy := SWAGameGrazeStrategy new.
	strategy searchRadius: 8.
	"One grassy cell, so the jitter cannot change which one wins."
	self assert: (strategy nextRouteFor: mob on: world) last equals: 44.5 @ 8.5.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:28'
}
SWAGameMobTest >> testMobsInANegativeChunkAreOwnedAndSimulatedThere [
	"The chunk key used to clamp cells at zero, which filed every mob west or
	north of the origin in chunk 0 and left it standing still out there."

	| mob start |
	world clearTerrain.
	world voxels clear.
	self generateFlatChunkAtX: -1 z: -1.
	"Wandering, because a grazer may start on its meal and rest there."
	mob := SWAGameRabbit new positionX: -8.5 y: 4 z: -8.5; movementStrategy: SWAGameWanderStrategy new; yourself.
	world addMobNow: mob.
	self assert: (world chunkXOfKey: mob chunkKey) equals: -1.
	self assert: (world chunkZOfKey: mob chunkKey) equals: -1.
	world simulateAroundCellX: -8 z: -8.
	start := mob x @ mob z.
	40 timesRepeat: [world tick].
	self deny: start = (mob x @ mob z).
	self assert: (world voxels at: mob x at: mob y at: mob z) equals: 0.
]

{
	#category : #'tests - physics',
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:13'
}
SWAGameMobTest >> testNeverEndsUpInsideSolidGround [
	"Tunnelling through the floor is the failure mode a bigger speed causes, so
	the check runs every tick rather than only at the end."

	| mob |
	mob := self rabbitAtX: 8.5 z: 8.5.
	mob runSpeed: 50.
	mob alarmed: true.
	self drive: mob toward: 30 @ 30 ticks: 200 do: [
		self deny: (world isSolidAtX: mob cellX y: mob cellY z: mob cellZ)
			description: 'mob is inside a block'].
	self assert: mob x > 20 description: 'mob never moved, so nothing was tested'.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (leo) 11/5/2026 17:49'
}
SWAGameMobTest >> testPettingWearsOff [

	| mob |
	mob := self rabbitAtX: 8.5 z: 8.5.
	mob pet.
	self assert: mob isBeingPetted.
	(SWAGameMob petDuration / world secondsPerTick) rounded + 1 timesRepeat: [mob stepOn: world].
	self deny: mob isBeingPetted.
]

{
	#category : #'tests - steering',
	#'squeak_changestamp' : 'MCPServer 10/15/2026 15:40'
}
SWAGameMobTest >> testSeparationPushesOverlappingMobsApart [
	"Offspring start exactly on the parent, so zero distance must still resolve."

	| a b |
	a := self rabbitAtX: 8.5 z: 8.5.
	b := self rabbitAtX: 8.5 z: 8.5.
	40 timesRepeat: [
		world rebuildMobIndexes.
		a stepOn: world.
		b stepOn: world].
	self assert: (((a x - b x) squared + (a z - b z) squared) sqrt) > (a halfWidth)
		description: 'mobs stayed on top of each other'.
]

{
	#category : #'tests - rates',
	#'squeak_changestamp' : 'MCPServer 10/15/2026 15:39'
}
SWAGameMobTest >> testSpeciesHaveIndependentBurnRates [
	"These shared one class variable on SWAGameMob, so setting the fox silently
	overwrote the rabbit and per-species metabolism never worked."

	| rabbitBefore foxBefore |
	rabbitBefore := SWAGameRabbit burnRate.
	foxBefore := SWAGameFox burnRate.
	[SWAGameRabbit burnRate: 1.
	SWAGameFox burnRate: 9.
	self assert: SWAGameRabbit burnRate equals: 1.
	self assert: SWAGameFox burnRate equals: 9]
		ensure: [
			SWAGameRabbit burnRate: rabbitBefore.
			SWAGameFox burnRate: foxBefore].
]

{
	#category : #'tests - chunks',
	#'squeak_changestamp' : 'MCPServer 10/15/2026 16:22'
}
SWAGameMobTest >> testTheTwoViewsOfTheMobsAgree [
	"The renderer walks the flat list and the simulation walks the buckets, so a
	mob present in one and missing from the other is a ghost or an invisible."

	| sum |
	1 to: 6 do: [:i | self rabbitAtX: 2.5 + (i * 4) z: 6.5].
	200 timesRepeat: [world tick].
	sum := 0.
	world mobChunks valuesDo: [:bucket | sum := sum + bucket size].
	self assert: sum equals: world mobs size.
	world mobs do: [:mob |
		self assert: mob chunkKey equals: (world chunkKeyForX: mob cellX z: mob cellZ).
		self assert: ((world mobChunks at: mob chunkKey) includes: mob)].
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:26'
}
SWAGameMobTest >> testWanderingStaysInTheGrownChunkItIsIn [
	"Wander targets were clamped to gridSize, so a mob out in a grown chunk was
	permanently steered back towards the first one."

	| mob target |
	world clearTerrain.
	world voxels clear.
	self generateFlatChunkAtX: 2 z: 0.
	self generateFlatChunkAtX: -1 z: 0.
	mob := SWAGameRabbit new positionX: 40.5 y: 4 z: 8.5.
	world addMobNow: mob.
	10 timesRepeat: [
		target := (SWAGameWanderStrategy new nextRouteFor: mob on: world) last.
		self assert: target x >= 32.
		self assert: (target x - mob x) abs <= 6].
	mob := SWAGameRabbit new positionX: -8.5 y: 4 z: 8.5.
	world addMobNow: mob.
	10 timesRepeat: [
		target := (SWAGameWanderStrategy new nextRouteFor: mob on: world) last.
		self assert: target x < 0.
		self assert: (target x - mob x) abs <= 6].
]

{
	#category : #helpers,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 16:23'
}
SWAGameMobTest >> tickWorldDriving: aMob toward: aPoint ticks: count [
	"Through the world, not the mob: chunk migration happens in the tick, so
	stepping the mob alone never reassigns it."

	count timesRepeat: [
		aMob target: aPoint.
		world tick]
]
