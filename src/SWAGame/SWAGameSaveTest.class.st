Class {
	#name : #SWAGameSaveTest,
	#superclass : #SWAGameTestCase,
	#instVars : [
		'world'
	],
	#category : #'SWAGame-Tests'
}

{
	#category : #support,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 14:38'
}
SWAGameSaveTest >> mobRecordsOf: aWorld [
	| records |
	records := OrderedCollection new.
	aWorld mobChunks valuesDo: [:bucket |
		bucket do: [:mob |
			records add: {mob species. mob x. mob y. mob z. mob energy. mob age. mob alive. mob remains. mob walkSpeed}]].
	^ (records asSortedCollection: [:a :b | a second <= b second]) asArray
]

{
	#category : #running,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 14:38'
}
SWAGameSaveTest >> setUp [
	super setUp.
	world := SWAGameWorld gridSize: 32 maxHeight: 20.
	world ensureVoxels.
	world parameter: #walkSpeed of: #rabbit put: 1.25.
	world tallyEaten.
	(world mobs detect: [:each | each isRabbit]) lieDeadWith: 0.5 after: 3.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:19'
}
SWAGameSaveTest >> testAGardenIsSaved [

	| loaded |
	SWAGameGarden dropsPerStage timesRepeat: [world water: 3 @ 4].
	loaded := SWAGameWorld fromJson: world asJson.
	self assert: (loaded garden stageAt: 3 @ 4) equals: 1.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 14:38'
}
SWAGameSaveTest >> testALoadedWorldGrowsAsTheOriginalWould [
	"The noise is saved with it, so a chunk raised after loading joins up."
	| loaded |
	loaded := world detachedCopy.
	world generateChunkAtX: 2 z: 0.
	loaded generateChunkAtX: 2 z: 0.
	self
		assert: ((loaded instVarNamed: 'heightMap') at: (SWAGameChunk keyX: 2 z: 0))
		equals: ((world instVarNamed: 'heightMap') at: (SWAGameChunk keyX: 2 z: 0)).
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 14:38'
}
SWAGameSaveTest >> testASavedWorldLoadsAsItWas [
	| loaded |
	loaded := SWAGameWorld fromJson: world asJson.
	self assert: loaded generatedChunks equals: world generatedChunks.
	world generatedChunks do: [:key |
		self assert: ((loaded instVarNamed: 'heightMap') at: key) equals: ((world instVarNamed: 'heightMap') at: key).
		self assert: ((loaded instVarNamed: 'grassMap') at: key) equals: ((world instVarNamed: 'grassMap') at: key)].
	world voxels chunksDo: [:key :chunk |
		| other |
		other := nil.
		loaded voxels chunksDo: [:k :c | k = key ifTrue: [other := c]].
		self assert: other sections equals: chunk sections].
	self assert: (self mobRecordsOf: loaded) equals: (self mobRecordsOf: world).
	self assert: (loaded parameter: #walkSpeed of: #rabbit) equals: 1.25.
	self assert: loaded config equals: world config.
	self assert: loaded noise permutation equals: world noise permutation.
	self assert: (loaded instVarNamed: 'eatenCount') equals: 1.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 14:38'
}
SWAGameSaveTest >> testASimulationLeavesItsGameAndTheImageAlone [
	| before simulation |
	before := self mobRecordsOf: world.
	simulation := SWAGameSimulation of: world scenario: SWAGameScenario documentary.
	simulation runFor: 5 every: 1.
	self assert: (self mobRecordsOf: world) equals: before.
	self assert: (world parameter: #walkSpeed of: #rabbit) equals: 1.25.
	self assert: SWAGameRabbit walkSpeed equals: 0.6.
	self assert: (simulation game parameter: #walkSpeed of: #rabbit) equals: 0.35.
	self assert: simulation samples size equals: 6.
	self assert: simulation elapsed > 4.9.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 14:39'
}
SWAGameSaveTest >> testTheSavedFormIsCompact [
	"18 KB of block, height and grass bytes, which as JSON numbers would be about
	40 KB. Deflated they come to under 3 KB."
	self assert: world asJson size < 8000.
]
