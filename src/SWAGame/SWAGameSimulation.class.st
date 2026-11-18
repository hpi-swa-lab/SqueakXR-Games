"
A game run without rendering, to see where a tuning leads. It starts from a detached copy of a world, the same terrain, mobs and parameters as loading a save would give, so the game it was taken from is not touched and the image preferences are not either.
"
Class {
	#name : #SWAGameSimulation,
	#superclass : #Object,
	#instVars : [
		'name',
		'game',
		'samples',
		'elapsed'
	],
	#classVars : [
		'LastReport',
		'SweepLog'
	],
	#category : #SWAGame,
	#'squeak_changestamp' : '<historical>'
}

{
	#category : #comparing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 18:36'
}
SWAGameSimulation class >> compare: scenarios from: aWorld seconds: seconds [
	"Runs in the caller's process."
	^ scenarios collect: [:each |
		(self of: aWorld scenario: each)
			runFor: seconds every: 30;
			yourself]
]

{
	#category : #comparing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 18:36'
}
SWAGameSimulation class >> compareInBackground: scenarios from: aWorld seconds: seconds [
	"At systemBackgroundPriority: at 30 a run never yields and starves the MCP server and the tools."
	| sims |
	sims := scenarios collect: [:each | self of: aWorld scenario: each].
	LastReport := 'running'.
	^ [
		sims do: [:each |
			each runFor: seconds every: 30.
			Transcript cr; show: (String streamContents: [:s | each printSummaryOn: s])].
		LastReport := self reportOn: sims]
			forkAt: Processor systemBackgroundPriority
			named: 'SWAGame scenario comparison'
]

{
	#category : #comparing,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 14:38'
}
SWAGameSimulation class >> lastReport [
	^ LastReport
]

{
	#category : #'instance creation',
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 14:38'
}
SWAGameSimulation class >> of: aWorld scenario: aScenarioOrNil [
	^ self new setWorld: aWorld scenario: aScenarioOrNil
]

{
	#category : #comparing,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 14:38'
}
SWAGameSimulation class >> reportOn: simulations [
	^ String streamContents: [:stream |
		simulations do: [:each | each printSummaryOn: stream. stream cr]]
]

{
	#category : #comparing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 18:36'
}
SWAGameSimulation class >> sweep: scenarios sizes: sizes replicates: n seconds: seconds [
	"Forked below the tools; the log grows a line per run."
	SweepLog := WriteStream on: String new.
	^ [
		sizes do: [:size |
			scenarios do: [:scenario |
				n timesRepeat: [
					| world sim start |
					start := Time millisecondClockValue.
					world := SWAGameWorld gridSize: size maxHeight: 20.
					world ensureVoxels.
					sim := self of: world scenario: scenario.
					sim runFor: seconds every: 30.
					SweepLog
						print: size; tab; nextPutAll: scenario name; tab.
					sim printRowOn: SweepLog.
					SweepLog
						tab; print: (Time millisecondClockValue - start) // 1000; nextPut: $s; lf]]].
		SweepLog nextPutAll: 'DONE'; lf]
			forkAt: Processor systemBackgroundPriority
			named: 'SWAGame sweep'
]

{
	#category : #comparing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 12:06'
}
SWAGameSimulation class >> sweepLog [
	^ SweepLog ifNil: [''] ifNotNil: [:log | log contents]
]

{
	#category : #reporting,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 12:06'
}
SWAGameSimulation >> countsOf: anIndex from: aFraction [
	"The populations from aFraction of the run onwards, past the transient."
	^ (samples allButFirst: (samples size * aFraction) floor) collect: [:each | each at: anIndex]
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 14:38'
}
SWAGameSimulation >> elapsed [
	"Simulated seconds."
	^ elapsed
]

{
	#category : #reporting,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 14:38'
}
SWAGameSimulation >> extinctionOf: aSpeciesIndex [
	"Simulated seconds at which a species was first seen at zero, or nil."
	^ (samples detect: [:each | (each at: aSpeciesIndex) = 0] ifNone: [^ nil]) first
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 14:38'
}
SWAGameSimulation >> game [
	^ game
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 14:38'
}
SWAGameSimulation >> name [
	^ name
]

{
	#category : #reporting,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 12:06'
}
SWAGameSimulation >> printRowOn: aStream [
	| rabbits foxes |
	rabbits := self countsOf: 2 from: 0.5.
	foxes := self countsOf: 3 from: 0.5.
	aStream
		nextPutAll: self verdict; tab;
		nextPutAll: 'r '; print: rabbits min; nextPut: $-; print: rabbits max;
		nextPutAll: ' cv '; print: ((self variationOf: 2) roundTo: 0.01); tab;
		nextPutAll: 'f '; print: foxes min; nextPut: $-; print: foxes max;
		nextPutAll: ' cv '; print: ((self variationOf: 3) roundTo: 0.01).
	(self extinctionOf: 2) ifNotNil: [:t | aStream nextPutAll: ' r-gone '; print: t rounded].
	(self extinctionOf: 3) ifNotNil: [:t | aStream nextPutAll: ' f-gone '; print: t rounded].
]

{
	#category : #reporting,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 14:38'
}
SWAGameSimulation >> printSpecies: anIndex named: aString on: aStream [
	| counts |
	counts := samples collect: [:each | each at: anIndex].
	aStream
		nextPutAll: aString; space;
		print: counts min; nextPut: $-; print: counts max;
		nextPutAll: ' end '; print: counts last.
	(self extinctionOf: anIndex) ifNotNil: [:t |
		aStream nextPutAll: ' (gone at '; print: t rounded; nextPutAll: ' s)'].
]

{
	#category : #reporting,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 14:38'
}
SWAGameSimulation >> printSummaryOn: aStream [
	aStream nextPutAll: name; tab.
	self printSpecies: 2 named: 'rabbits' on: aStream.
	aStream tab.
	self printSpecies: 3 named: 'foxes' on: aStream.
]

{
	#category : #reporting,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 14:38'
}
SWAGameSimulation >> printTimelineOn: aStream [
	samples do: [:each |
		aStream print: each first rounded; nextPutAll: ' s'; tab;
			print: each second; tab; print: each third; tab; print: each fourth; cr]
]

{
	#category : #running,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 14:38'
}
SWAGameSimulation >> runFor: seconds every: sampleSeconds [
	"Simulated time, at the game's own tick period, so it plays out as it would on
	screen, only as fast as the machine allows."
	| ticksPerSample ticks |
	ticksPerSample := (sampleSeconds / game secondsPerTick) rounded max: 1.
	ticks := (seconds / game secondsPerTick) rounded.
	samples isEmpty ifTrue: [self sample].
	1 to: ticks do: [:i |
		game tick.
		elapsed := elapsed + game secondsPerTick.
		i \\ ticksPerSample = 0 ifTrue: [self sample]].
]

{
	#category : #running,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 14:38'
}
SWAGameSimulation >> sample [
	| rabbits foxes bodies |
	rabbits := 0.
	foxes := 0.
	bodies := 0.
	game mobsDo: [:each |
		each isRabbit ifTrue: [rabbits := rabbits + 1].
		each isFox ifTrue: [foxes := foxes + 1]].
	game corpsesDo: [:each | bodies := bodies + 1].
	samples add: {elapsed. rabbits. foxes. bodies}.
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 14:38'
}
SWAGameSimulation >> samples [
	"{seconds. rabbits. foxes. bodies}"
	^ samples
]

{
	#category : #initialization,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 14:38'
}
SWAGameSimulation >> setWorld: aWorld scenario: aScenarioOrNil [
	game := aWorld detachedCopy.
	aScenarioOrNil
		ifNil: [name := 'As it is']
		ifNotNil: [
			name := aScenarioOrNil name.
			game applyScenario: aScenarioOrNil].
	samples := OrderedCollection new.
	elapsed := 0.
]

{
	#category : #reporting,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 12:06'
}
SWAGameSimulation >> variationOf: anIndex [
	"Coefficient of variation over the second half: how far the population swings
	around its own mean."
	| counts mean |
	counts := self countsOf: anIndex from: 0.5.
	mean := (counts inject: 0 into: [:a :b | a + b]) / counts size.
	mean = 0 ifTrue: [^ 0].
	^ ((counts inject: 0 into: [:a :b | a + (b - mean) squared]) / counts size) sqrt / mean
]

{
	#category : #reporting,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 12:06'
}
SWAGameSimulation >> verdict [
	"#collapse: the rabbits died, so the foxes follow. #foxesDied: the rabbits are
	left to the pasture. Otherwise #steady or #cycling, by how far both swing."
	(self extinctionOf: 2) ifNotNil: [^ #collapse].
	(self extinctionOf: 3) ifNotNil: [^ #foxesDied].
	^ ((self variationOf: 2) < 0.3 and: [(self variationOf: 3) < 0.35])
		ifTrue: [#steady]
		ifFalse: [#cycling]
]
