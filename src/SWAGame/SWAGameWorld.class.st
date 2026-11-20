"
The simulation: terrain, mobs and the tick. No rendering, so a test can step a world headless.

Documentation: doc/swagame in the mysqueak repository.
"
Class {
	#name : #SWAGameWorld,
	#superclass : #Object,
	#instVars : [
		'heightMap',
		'gridSize',
		'maxHeight',
		'grassMap',
		'newMobs',
		'riverMap',
		'voxels',
		'speciesIndex',
		'mobCells',
		'eatenCount',
		'starvedCount',
		'random',
		'secondsPerTick',
		'mobChunks',
		'simulationCentre',
		'simulationRadiusChunks',
		'noise',
		'generatedChunks',
		'corpseIndex',
		'config',
		'garden'
	],
	#classVars : [
		'DefaultGrassRegrowthPerSecond'
	],
	#category : #SWAGame,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}

{
	#category : #serialization,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 14:37'
}
SWAGameWorld class >> bytesToText: aByteArray [
	"Deflated, then Base64: a 4096 byte block section of mostly one value comes out
	at a few dozen characters."
	| zip |
	zip := ZLibWriteStream on: (ByteArray new: 256).
	zip nextPutAll: aByteArray; close.
	^ (Base64MimeConverter mimeEncode: zip encodedStream contents readStream) contents
		reject: [:each | each isSeparator]
]

{
	#category : #serialization,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 14:37'
}
SWAGameWorld class >> fromJson: aString [
	| json |
	json := Json readFrom: aString readStream.
	(json at: #format ifAbsent: [nil]) = 'swagame-world'
		ifFalse: [^ self error: 'Not a saved SWAGame world'].
	^ self basicNew restoreFromJson: json
]

{
	#category : #preferences,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:28'
}
SWAGameWorld class >> grassRegrowthPerSecond [
	<preference: 'Grass regrowth per second'
		category: 'SWAGame'
		description: 'Chance per second that a grass tile grows one level. With the rabbit burn rate and eat gain this sets how many rabbits the pasture feeds.'
		type: #Number>
	^ DefaultGrassRegrowthPerSecond ifNil: [0.015]
]

{
	#category : #preferences,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:28'
}
SWAGameWorld class >> grassRegrowthPerSecond: aNumber [
	DefaultGrassRegrowthPerSecond := aNumber.
]

{
	#category : #'instance creation',
	#'squeak_changestamp' : 'MCPServer 5/13/2026 15:31'
}
SWAGameWorld class >> gridSize: gs maxHeight: mh [
	^ self new initializeWithGridSize: gs maxHeight: mh
]

{
	#category : #serialization,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 14:37'
}
SWAGameWorld class >> loadNamed: aName [
	^ self fromJson: (self savedDirectory
		readOnlyFileNamed: aName, '.json'
		do: [:file | file contents])
]

{
	#category : #serialization,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 14:37'
}
SWAGameWorld class >> nextSavedName [
	| names n |
	names := self savedNames asSet.
	n := 1.
	[names includes: 'game-', n printString] whileTrue: [n := n + 1].
	^ 'game-', n printString
]

{
	#category : #serialization,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 14:37'
}
SWAGameWorld class >> savedDirectory [
	"Next to the image, which is the repository, so both desktop images see them."
	^ FileDirectory default directoryNamed: 'swagame-worlds'
]

{
	#category : #serialization,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 14:37'
}
SWAGameWorld class >> savedNames [
	| dir |
	dir := self savedDirectory.
	dir exists ifFalse: [^ #()].
	^ ((dir fileNames select: [:each | each endsWith: '.json'])
		collect: [:each | each allButLast: 5]) asSortedCollection asArray
]

{
	#category : #serialization,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 14:37'
}
SWAGameWorld class >> textToBytes: aString [
	^ (ZLibReadStream on: (Base64MimeConverter mimeDecodeToBytes: aString readStream) contents)
		upToEnd asByteArray
]

{
	#category : #chunks,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameWorld >> activeChunkKeys [


	| centreX centreZ radius |
	radius := simulationRadiusChunks.
	(radius isNil or: [simulationCentre isNil]) ifTrue: [^ self generatedChunks].
	centreX := self chunkXOfKey: simulationCentre.
	centreZ := self chunkZOfKey: simulationCentre.
	^ self generatedChunks select: [:key |
		((self chunkXOfKey: key) - centreX) abs <= radius
			and: [((self chunkZOfKey: key) - centreZ) abs <= radius]]
]

{
	#category : #chunks,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameWorld >> activeMobsDo: aBlock [
	"A frozen mob is neither prey, nor threat, nor obstacle."

	self activeChunkKeys do: [:key |
		(self mobChunks at: key ifAbsent: [nil]) ifNotNil: [:bucket |
			bucket do: [:mob | mob alive ifTrue: [aBlock value: mob]]]]
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 18:36'
}
SWAGameWorld >> addMob: aMob [
	"Joins after the tick."
	aMob ifNotNil: [newMobs add: aMob]
]

{
	#category : #chunks,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 18:36'
}
SWAGameWorld >> addMobNow: aMob [
	"The only way in outside a tick."
	aMob ifNil: [^ nil].
	self configureMob: aMob.
	self placeMobInChunk: aMob.
	^ aMob
]

{
	#category : #configuration,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 18:36'
}
SWAGameWorld >> applyScenario: aScenario [
	"Every value, so the game keeps this tuning when the image defaults change."
	config := Dictionary new.
	aScenario resolvedValues keysAndValuesDo: [:owner :params |
		config at: owner put: params copy].
	self reconfigureMobs.
]

{
	#category : #serialization,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:17'
}
SWAGameWorld >> asJson [
	"Terrain, mobs and this game's own parameters. Height, grass and block bytes
	are deflated, so a 32 cell world is tens of kilobytes rather than megabytes."
	| state json pair |
	state := self capturedState.
	pair := [:key | key ifNil: [nil] ifNotNil: [{SWAGameChunk xOfKey: key. SWAGameChunk zOfKey: key}]].
	json := JsonObject new.
	json
		at: #format put: 'swagame-world';
		at: #version put: 1;
		at: #gridSize put: (state at: #gridSize);
		at: #maxHeight put: (state at: #maxHeight);
		at: #voxelHeight put: (state at: #voxelHeight);
		at: #secondsPerTick put: (state at: #secondsPerTick);
		at: #noise put: (self class bytesToText: (state at: #noise));
		at: #simulationCentre put: (pair value: (state at: #simulationCentre));
		at: #simulationRadiusChunks put: (state at: #simulationRadiusChunks);
		at: #eaten put: (state at: #eaten);
		at: #starved put: (state at: #starved);
		at: #config put: (state at: #config);
		at: #garden put: (state at: #garden);
		at: #chunks put: ((state at: #chunks) collect: [:each |
			JsonObject new
				at: #at put: (pair value: each first);
				at: #heights put: (self class bytesToText: each second);
				at: #grass put: (self class bytesToText: each third);
				yourself]);
		at: #voxels put: ((state at: #voxels) collect: [:each |
			JsonObject new
				at: #at put: (pair value: each first);
				at: #sections put: (each second collect: [:section |
					section ifNotNil: [self class bytesToText: section]]);
				yourself]);
		at: #mobFields put: #('species' 'x' 'y' 'z' 'energy' 'age' 'remains' 'deathTimer' 'coat');
		at: #mobs put: (state at: #mobs).
	^ Json render: json
]

{
	#category : #terrain,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameWorld >> blockTypeAtX: cx z: cz y: cy [
	"One based in x and z."

	| h ratio |
	h := self heightAtX: cx y: cz.
	cy < (h - 1) ifTrue: [^ SWAGameBlocks idFor: #dirt].
	(self isRiverAt: cx - 1 @ (cz - 1)) ifTrue: [^ SWAGameBlocks idFor: #water].
	ratio := (h - 1) / (maxHeight - 1) asFloat.
	ratio <= 0.2 ifTrue: [^ SWAGameBlocks idFor: #water].
	ratio <= 0.35 ifTrue: [^ SWAGameBlocks idFor: #sand].
	ratio <= 0.7 ifTrue: [^ SWAGameBlocks idFor: #grass].
	ratio <= 0.85 ifTrue: [^ SWAGameBlocks idFor: #rock].
	^ SWAGameBlocks idFor: #snow
]

{
	#category : #serialization,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:17'
}
SWAGameWorld >> capturedState [
	"Copied in one go, unpreempted: the render process ticks the game, and a
	half-ticked world would not load as the one that was saved."
	^ [| state |
		state := Dictionary new.
		state
			at: #gridSize put: gridSize;
			at: #maxHeight put: maxHeight;
			at: #voxelHeight put: (voxels ifNil: [maxHeight + 12] ifNotNil: [voxels height]);
			at: #secondsPerTick put: self secondsPerTick;
			at: #noise put: (self noise permutation first: 256) asByteArray;
			at: #simulationCentre put: simulationCentre;
			at: #simulationRadiusChunks put: simulationRadiusChunks;
			at: #eaten put: (eatenCount ifNil: [0]);
			at: #starved put: (starvedCount ifNil: [0]);
			at: #config put: (self config collect: [:each | each copy]);
			at: #garden put: self garden asArray;
			at: #chunks put: (self generatedChunks asSortedCollection asArray collect: [:key |
				{key. (heightMap at: key) copy. (grassMap at: key) copy}]);
			at: #voxels put: (voxels
				ifNil: [#()]
				ifNotNil: [| columns |
					columns := OrderedCollection new.
					voxels chunksDo: [:key :chunk |
						columns add: {key. chunk sections collect: [:each | each ifNotNil: [each copy]]}].
					columns asArray]);
			at: #mobs put: (Array streamContents: [:stream |
				self mobChunks valuesDo: [:bucket |
					bucket do: [:mob |
						mob isGone ifFalse: [
							stream nextPut: {mob species. mob x. mob y. mob z. mob energy. mob age.
								mob alive ifTrue: [nil] ifFalse: [mob remains].
								mob alive ifTrue: [nil] ifFalse: [mob deathTimer].
								mob coat}]]]]).
		state] valueUnpreemptively
]

{
	#category : #chunks,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameWorld >> cellKeyForX: cellX z: cellZ [
	"Biased: a plain x * n + z borrows from x once z is negative."

	^ cellX * 1048576 + (cellZ + 524288)
]

{
	#category : #chunks,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameWorld >> chunkKeyForX: cellX z: cellZ [
	^ SWAGameChunk keyForCellX: cellX z: cellZ
]

{
	#category : #chunks,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 17:29'
}
SWAGameWorld >> chunkXOfKey: aKey [

	^ SWAGameChunk xOfKey: aKey
]

{
	#category : #chunks,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 17:29'
}
SWAGameWorld >> chunkZOfKey: aKey [

	^ SWAGameChunk zOfKey: aKey
]

{
	#category : #chunks,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:17'
}
SWAGameWorld >> clearTerrain [
	heightMap := Dictionary new.
	grassMap := Dictionary new.
	garden := nil.
	riverMap := nil.
	generatedChunks := Set new.
	self removeAllMobs
]

{
	#category : #statistics,
	#'squeak_changestamp' : 'MCPServer (jl) 11/17/2026 14:35'
}
SWAGameWorld >> coatCensus [
	| census |
	census := Bag new.
	(self mobsOfSpecies: #rabbit) do: [:each | census add: each coatPhenotype].
	^ census
]

{
	#category : #terrain,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameWorld >> columnIndexX: cellX z: cellZ [
	"Zero based."
	^ ((cellX bitAnd: 15) bitShift: 4) + (cellZ bitAnd: 15) + 1
]

{
	#category : #terrain,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameWorld >> columnMapForChunkKey: aKey [
	^ heightMap at: aKey ifAbsent: [nil]
]

{
	#category : #terrain,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 14:34'
}
SWAGameWorld >> compactTerrainMaps [
	"Converts maps from the nested Arrays they used to be."
	{heightMap. grassMap} do: [:map |
		map keys do: [:key |
			| rows bytes |
			rows := map at: key.
			rows isArray ifTrue: [
				bytes := ByteArray new: 256.
				1 to: 16 do: [:ix |
					1 to: 16 do: [:iz |
						bytes at: (ix - 1 bitShift: 4) + iz put: (((rows at: ix) at: iz) min: 255 max: 0)]].
				map at: key put: bytes]]]
]

{
	#category : #configuration,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 18:36'
}
SWAGameWorld >> config [
	"Owner (#rabbit #fox #world) -> selector -> value, only what this game sets itself."
	^ config ifNil: [config := Dictionary new]
]

{
	#category : #configuration,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 14:34'
}
SWAGameWorld >> configureMob: aMob [
	"Parameters only, never energy: a mob placed with an energy of its own, a
	newborn included, keeps it."
	(self parametersOf: aMob species) keysAndValuesDo: [:selector :value |
		aMob perform: selector asMutator with: value].
	^ aMob
]

{
	#category : #mobs,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 18:36'
}
SWAGameWorld >> corpsesDo: aBlock [
	self mobChunks valuesDo: [:bucket |
		bucket do: [:mob | (mob alive not and: [mob isGone not]) ifTrue: [aBlock value: mob]]]
]

{
	#category : #mobs,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:36'
}
SWAGameWorld >> corpsesNear: aPoint radius: r ofSpecies: aSpeciesSymbol [
	"aPoint carries x in x and z in y, like a mob target."
	^ (self corpsesOfSpecies: aSpeciesSymbol) select: [:m |
		| dx dz |
		dx := m x - aPoint x.
		dz := m z - aPoint y.
		m remains > 0 and: [(dx * dx) + (dz * dz) <= (r * r)]]
]

{
	#category : #mobs,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:36'
}
SWAGameWorld >> corpsesOfSpecies: aSpeciesSymbol [
	corpseIndex ifNil: [self rebuildMobIndexes].
	^ corpseIndex at: aSpeciesSymbol ifAbsent: [#()]
]

{
	#category : #configuration,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 14:34'
}
SWAGameWorld >> currentScenario [
	^ SWAGameScenario
		named: 'Current'
		values: (Dictionary newFrom: (SWAGameScenario owners
			collect: [:each | each key -> (self parametersOf: each key)]))
]

{
	#category : #statistics,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 13:53'
}
SWAGameWorld >> deathTally [

	^ { #eaten -> (eatenCount ifNil: [0]). #starved -> (starvedCount ifNil: [0]) }
]

{
	#category : #serialization,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 14:37'
}
SWAGameWorld >> detachedCopy [
	"Through the saved form, so a copy is exactly what loading a save gives: the
	same terrain, mobs and parameters, sharing nothing with this game."
	^ self class fromJson: self asJson
]

{
	#category : #collision,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameWorld >> ensureVoxels [
	"Headless worlds only: SWAGameXR hands in its own grid."

	voxels ifNotNil: [^ voxels].
	voxels := SWAGameChunkedGrid width: gridSize depth: gridSize height: maxHeight + 12.
	0 to: gridSize - 1 do: [:cx |
		0 to: gridSize - 1 do: [:cz |
			| h |
			h := self heightAtX: cx + 1 y: cz + 1.
			0 to: h - 1 do: [:cy |
				voxels at: cx at: cy at: cz put: 1]]].
	^ voxels
]

{
	#category : #terrain,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:17'
}
SWAGameWorld >> garden [

	^ garden ifNil: [garden := SWAGameGarden new]
]

{
	#category : #terrain,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameWorld >> generateChunkAtX: cx z: cz [
	"Idempotent, and independent of the order chunks are generated in."
	| key heights grasses x0 z0 |
	(self isChunkGeneratedX: cx z: cz) ifTrue: [^ false].
	key := SWAGameChunk keyX: cx z: cz.
	x0 := cx * 16.
	z0 := cz * 16.
	heights := ByteArray new: 256 withAll: 1.
	grasses := ByteArray new: 256.
	heightMap at: key put: heights.
	grassMap at: key put: grasses.
	self generatedChunks add: key.
	0 to: 15 do: [:lx |
		0 to: 15 do: [:lz |
			heights
				at: (lx bitShift: 4) + lz + 1
				put: ((self heightForColumnX: x0 + lx + 1 z: z0 + lz + 1) min: 255)]].
	"Grass after the heights, because grassland depends on the elevation."
	0 to: 15 do: [:lx |
		0 to: 15 do: [:lz |
			(self isGrasslandAtX: x0 + lx + 1 z: z0 + lz + 1) ifTrue: [
				grasses at: (lx bitShift: 4) + lz + 1 put: self maxGrass]]].
	^ true
]

{
	#category : #chunks,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 16:49'
}
SWAGameWorld >> generatedChunks [

	^ generatedChunks ifNil: [generatedChunks := Set new]
]

{
	#category : #terrain,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameWorld >> grassAt: aPoint [
	"Zero based, aPoint is x @ z."
	| column |
	column := grassMap at: (self chunkKeyForX: aPoint x z: aPoint y) ifAbsent: [nil].
	column ifNil: [^ 0].
	^ column at: (self columnIndexX: aPoint x z: aPoint y)
]

{
	#category : #terrain,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameWorld >> grassAt: aPoint put: aValue [
	"Zero based, aPoint is x @ z."
	| column |
	column := grassMap at: (self chunkKeyForX: aPoint x z: aPoint y) ifAbsent: [nil].
	column ifNil: [^ aValue].
	^ column at: (self columnIndexX: aPoint x z: aPoint y) put: aValue
]

{
	#category : #terrain,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 18:36'
}
SWAGameWorld >> grassRegrowthPerSecond [
	^ self parameter: #grassRegrowthPerSecond of: #world
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 5/13/2026 15:30'
}
SWAGameWorld >> gridSize [
	^ gridSize
]

{
	#category : #chunks,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 18:36'
}
SWAGameWorld >> harvestDeadAndNewborn [
	self mobChunks valuesDo: [:bucket |
		bucket removeAllSuchThat: [:mob | mob isGone]].
	newMobs do: [:mob |
		self configureMob: mob.
		self placeMobInChunk: mob].
	newMobs := OrderedCollection new.
	self mobChunks keys do: [:key |
		(self mobChunks at: key) isEmpty ifTrue: [self mobChunks removeKey: key]]
]

{
	#category : #terrain,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameWorld >> heightAtX: x y: y [
	"One based; y is the z coordinate. An ungenerated column answers 1."
	| column |
	column := self columnMapForChunkKey: (self chunkKeyForX: x - 1 z: y - 1).
	column ifNil: [^ 1].
	^ column at: (self columnIndexX: x - 1 z: y - 1)
]

{
	#category : #terrain,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameWorld >> heightAtX: x y: y put: aHeight [
	"One based; y is the z coordinate."
	| column |
	column := self columnMapForChunkKey: (self chunkKeyForX: x - 1 z: y - 1).
	column ifNil: [^ aHeight].
	^ column at: (self columnIndexX: x - 1 z: y - 1) put: (aHeight min: 255 max: 0)
]

{
	#category : #terrain,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameWorld >> heightForColumnX: x z: z [
	"A pure function of position: that is what makes chunks join seamlessly."

	| value |
	value := self noise
		octaveNoiseX: x * 0.08
		y: z * 0.08
		octaves: 4
		persistence: 0.5.
	^ ((value + 1) / 2 * maxHeight) rounded max: 1
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 5/13/2026 15:30'
}
SWAGameWorld >> heightMap [
	^ heightMap
]

{
	#category : #initialization,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameWorld >> initializeWithGridSize: gs maxHeight: mh [
	"Chunk by chunk, like a chunk raised later: one generation path."

	gridSize := gs.
	maxHeight := mh.
	self clearTerrain.
	0 to: (gs - 1) // 16 do: [:cx |
		0 to: (gs - 1) // 16 do: [:cz |
			self generateChunkAtX: cx z: cz]].
	self spawnMobs
]

{
	#category : #chunks,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameWorld >> isCellGeneratedX: cellX z: cellZ [
	"An ungenerated chunk is a wall, so a target there is unreachable."

	^ self generatedChunks
		includes: (SWAGameChunk keyForCellX: cellX floor z: cellZ floor)
]

{
	#category : #chunks,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 17:29'
}
SWAGameWorld >> isChunkGeneratedX: cx z: cz [

	^ self generatedChunks includes: (SWAGameChunk keyX: cx z: cz)
]

{
	#category : #terrain,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameWorld >> isGrasslandAtX: x z: z [
	"One based."

	| h ratio |
	h := self heightAtX: x y: z.
	ratio := (h - 1) / (maxHeight - 1) asFloat.
	^ ratio > 0.2 and: [ratio <= 0.7]
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameWorld >> isRiverAt: aPoint [
	"Always false: nothing fills riverMap since generation is per chunk."

	riverMap ifNil: [^ false].
	^ (riverMap at: aPoint x + 1) at: aPoint y + 1
]

{
	#category : #configuration,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 14:34'
}
SWAGameWorld >> isScenarioActive: aScenario [
	| resolved |
	resolved := aScenario resolvedValues.
	^ resolved keys allSatisfy: [:owner |
		(resolved at: owner) associations allSatisfy: [:each |
			((self parameter: each key of: owner) - each value) abs < 1.0e-6]]
]

{
	#category : #collision,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 13:21'
}
SWAGameWorld >> isSolidAtPointX: px y: py z: pz [
	"Continuous cell-space point to the voxel it falls inside."

	^ self isSolidAtX: px floor y: py floor z: pz floor
]

{
	#category : #collision,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameWorld >> isSolidAtX: cx y: cy z: cz [
	"Below the store is solid, above it open, and an ungenerated chunk is a wall."

	voxels ifNil: [^ false].
	cy < 0 ifTrue: [^ true].
	(self isChunkGeneratedX: (cx bitShift: -4) z: (cz bitShift: -4))
		ifFalse: [^ true].
	^ (voxels at: cx at: cy at: cz) > 0
]

{
	#category : #terrain,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 14:53'
}
SWAGameWorld >> maxGrass [

	^ 10
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 5/13/2026 15:30'
}
SWAGameWorld >> maxHeight [
	^ maxHeight
]

{
	#category : #chunks,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameWorld >> migrateMobsBetweenChunks [
	"Collected first: the buckets are being iterated."

	| movers |
	movers := OrderedCollection new.
	self mobChunks keysAndValuesDo: [:key :bucket |
		bucket do: [:mob |
			(self chunkKeyForX: mob cellX z: mob cellZ) = key
				ifFalse: [movers add: mob]]].
	movers do: [:mob |
		(self mobChunks at: mob chunkKey ifAbsent: [nil])
			ifNotNil: [:bucket | bucket remove: mob ifAbsent: []].
		self placeMobInChunk: mob]
]

{
	#category : #chunks,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameWorld >> mobChunks [
	"Chunk key -> mobs: the only storage of mobs."

	^ mobChunks ifNil: [mobChunks := Dictionary new]
]

{
	#category : #chunks,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 16:38'
}
SWAGameWorld >> mobCount [

	| total |
	total := 0.
	self mobsDo: [:each | total := total + 1].
	^ total
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameWorld >> mobs [
	"A snapshot; prefer #mobsDo:."

	| all |
	all := OrderedCollection new.
	self mobsDo: [:each | all add: each].
	^ all
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 16:39'
}
SWAGameWorld >> mobsAt: aPoint ofSpecies: aSpeciesSymbol [
	"Mobs whose column is aPoint, which is a cell rather than a position."

	^ (self mobsOfSpecies: aSpeciesSymbol) select: [:m |
		m alive and: [m cellX = aPoint x and: [m cellZ = aPoint y]]]
]

{
	#category : #chunks,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameWorld >> mobsDo: aBlock [
	self mobChunks valuesDo: [:bucket |
		bucket do: [:mob | mob alive ifTrue: [aBlock value: mob]]]
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 13:42'
}
SWAGameWorld >> mobsNear: aPoint radius: r ofSpecies: aSpeciesSymbol [
	"aPoint carries x in x and z in y, like a mob target."

	^ (self mobsOfSpecies: aSpeciesSymbol) select: [:m |
		| dx dz |
		dx := m x - aPoint x.
		dz := m z - aPoint y.
		m alive and: [(dx * dx) + (dz * dz) <= (r * r)]]
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 17:30'
}
SWAGameWorld >> mobsNearCellX: cx z: cz do: aBlock [
	"The nine columns around a cell, which is as far as a mob can push."

	mobCells ifNil: [^ self].
	cx - 1 to: cx + 1 do: [:gx |
		cz - 1 to: cz + 1 do: [:gz |
			(mobCells at: (self cellKeyForX: gx z: gz) ifAbsent: [nil])
				ifNotNil: [:c | c do: aBlock]]].
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 15:09'
}
SWAGameWorld >> mobsOfSpecies: aSpeciesSymbol [
	speciesIndex ifNil: [self rebuildMobIndexes].
	^ speciesIndex at: aSpeciesSymbol ifAbsent: [#()]
]

{
	#category : #configuration,
	#'squeak_changestamp' : 'MCPServer (jl) 11/17/2026 14:35'
}
SWAGameWorld >> newMobOfSpecies: aSymbol [
	"A spawn: this game's parameters, and its starting energy."
	| mob |
	mob := (self speciesRegistry at: aSymbol) value.
	self configureMob: mob.
	mob energy: (self parameter: #startingEnergy of: aSymbol).
	mob beFounderOn: self.
	^ mob
]

{
	#category : #terrain,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameWorld >> noise [
	"One per world: chunks generated against different instances do not join."

	^ noise ifNil: [noise := SWAPerlinNoise new]
]

{
	#category : #configuration,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 14:34'
}
SWAGameWorld >> parameter: aSelector of: anOwnerKey [
	^ ((self config at: anOwnerKey ifAbsent: [nil])
		ifNotNil: [:params | params at: aSelector ifAbsent: [nil]])
			ifNil: [(SWAGameScenario ownerAt: anOwnerKey) perform: aSelector]
]

{
	#category : #configuration,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 14:34'
}
SWAGameWorld >> parameter: aSelector of: anOwnerKey put: aValue [
	(self config at: anOwnerKey ifAbsentPut: [Dictionary new]) at: aSelector put: aValue.
	self reconfigureMobs.
]

{
	#category : #configuration,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 14:34'
}
SWAGameWorld >> parametersOf: anOwnerKey [
	| owner |
	owner := SWAGameScenario ownerAt: anOwnerKey.
	^ Dictionary newFrom: ((SWAGameScenario parametersOf: owner)
		collect: [:selector | selector -> (self parameter: selector of: anOwnerKey)])
]

{
	#category : #chunks,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 16:20'
}
SWAGameWorld >> placeMobInChunk: aMob [

	| key |
	key := self chunkKeyForX: aMob cellX z: aMob cellZ.
	aMob chunkKey: key.
	(self mobChunks at: key ifAbsentPut: [OrderedCollection new]) add: aMob.
	^ key
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameWorld >> random [
	"Per world: Random is not reentrant, and worlds tick in different processes."

	^ random ifNil: [random := Random new]
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 18:36'
}
SWAGameWorld >> rebuildMobIndexes [
	"Neighbour lookups run several times a second: scanning all mobs per mob makes the tick quadratic."
	speciesIndex ifNil: [speciesIndex := Dictionary new].
	speciesIndex valuesDo: [:each | each removeAll].
	corpseIndex ifNil: [corpseIndex := Dictionary new].
	corpseIndex valuesDo: [:each | each removeAll].
	"Made afresh: emptied in place, it kept every cell a mob had ever stood in."
	mobCells := Dictionary new.
	self activeMobsDo: [:m |
		| index |
		(speciesIndex at: m species ifAbsentPut: [OrderedCollection new]) add: m.
		index := self cellKeyForX: m cellX z: m cellZ.
		(mobCells at: index ifAbsentPut: [OrderedCollection new]) add: m].
	"Bodies are food, not neighbours: indexed by species, but never pushed against."
	self activeChunkKeys do: [:key |
		(self mobChunks at: key ifAbsent: [nil]) ifNotNil: [:bucket |
			bucket do: [:m |
				(m alive not and: [m remains > 0]) ifTrue: [
					(corpseIndex at: m species ifAbsentPut: [OrderedCollection new]) add: m]]]].
]

{
	#category : #configuration,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 14:34'
}
SWAGameWorld >> reconfigureMobs [
	self mobsDo: [:each | self configureMob: each].
	newMobs ifNotNil: [newMobs do: [:each | self configureMob: each]].
]

{
	#category : #terrain,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 18:36'
}
SWAGameWorld >> regrowGrass [
	"The expected number of events per chunk: a roll for all 256 tiles cost more than stepping every mob."
	| expected |
	expected := 256 * self grassRegrowthPerSecond * self secondsPerTick.
	self activeChunkKeys do: [:key |
		| x0 z0 events |
		x0 := (self chunkXOfKey: key) * 16.
		z0 := (self chunkZOfKey: key) * 16.
		events := (expected + self random next) floor.
		events > 0 ifTrue: [
			(grassMap at: key ifAbsent: [nil]) ifNotNil: [:column |
				events timesRepeat: [
					| slot g lx lz |
					slot := (self random next * 256) floor + 1.
					g := column at: slot.
					lx := slot - 1 bitShift: -4.
					lz := slot - 1 bitAnd: 15.
					(g < self maxGrass
						and: [g > 0 or: [self isGrasslandAtX: x0 + lx + 1 z: z0 + lz + 1]])
							ifTrue: [column at: slot put: g + 1]]]]]
]

{
	#category : #chunks,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 16:39'
}
SWAGameWorld >> removeAllMobs [
	newMobs := OrderedCollection new.
	mobChunks := Dictionary new.
]

{
	#category : #serialization,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:17'
}
SWAGameWorld >> restoreFromJson: json [
	| key height |
	key := [:pair | SWAGameChunk keyX: pair first z: pair second].
	gridSize := json at: #gridSize.
	maxHeight := json at: #maxHeight.
	secondsPerTick := json at: #secondsPerTick.
	noise := SWAPerlinNoise basicNew permutation: (self class textToBytes: (json at: #noise)).
	simulationCentre := (json at: #simulationCentre) ifNotNil: [:pair | key value: pair].
	simulationRadiusChunks := json at: #simulationRadiusChunks.
	eatenCount := json at: #eaten.
	starvedCount := json at: #starved.
	config := Dictionary new.
	(json at: #config) keysAndValuesDo: [:owner :params |
		config at: owner asSymbol put: (Dictionary new
			addAll: (params associations collect: [:each | each key asSymbol -> each value]);
			yourself)].
	heightMap := Dictionary new.
	grassMap := Dictionary new.
	garden := SWAGameGarden fromArray: ((json at: #garden) ifNil: [#()]).
	generatedChunks := Set new.
	(json at: #chunks) do: [:each |
		| k |
		k := key value: (each at: #at).
		generatedChunks add: k.
		heightMap at: k put: (self class textToBytes: (each at: #heights)).
		grassMap at: k put: (self class textToBytes: (each at: #grass))].
	height := json at: #voxelHeight.
	voxels := SWAGameChunkedGrid width: gridSize depth: gridSize height: height.
	(json at: #voxels) do: [:each |
		| chunk |
		chunk := SWAGameChunk new initializeHeight: height.
		(each at: #sections) doWithIndex: [:text :i |
			text ifNotNil: [chunk sections at: i put: (self class textToBytes: text)]].
		voxels chunkAtKey: (key value: (each at: #at)) put: chunk].
	newMobs := OrderedCollection new.
	mobChunks := Dictionary new.
	(json at: #mobs) do: [:fields |
		| mob |
		mob := (self speciesRegistry at: fields first asSymbol) value.
		mob positionX: (fields at: 2) y: (fields at: 3) z: (fields at: 4).
		mob energy: (fields at: 5).
		mob age: (fields at: 6).
		"Saves from before coats have eight fields."
		(fields size >= 9 and: [(fields at: 9) notNil]) ifTrue: [
			mob coat: ((fields at: 9) collect: [:each | each asSymbol])].
		self addMobNow: mob.
		(fields at: 7) ifNotNil: [:left | mob lieDeadWith: left after: (fields at: 8)]].
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 5/13/2026 15:31'
}
SWAGameWorld >> riverMap [
	^ riverMap
]

{
	#category : #serialization,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 14:37'
}
SWAGameWorld >> saveAs: aName [
	| dir json |
	json := self asJson.
	dir := self class savedDirectory.
	dir assureExistence.
	dir deleteFileNamed: aName, '.json'.
	dir forceNewFileNamed: aName, '.json' do: [:file | file nextPutAll: json].
	^ aName
]

{
	#category : #simulation,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameWorld >> secondsPerTick [
	"SWAGameXR derives its tick period from this, not the reverse."

	^ secondsPerTick ifNil: [secondsPerTick := 0.05]
]

{
	#category : #simulation,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameWorld >> secondsPerTick: aNumber [
	"Rates are per second, so this changes smoothness and cost, not speed."

	secondsPerTick := aNumber.
]

{
	#category : #chunks,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameWorld >> simulateAroundCellX: cellX z: cellZ [
	simulationCentre := (self chunkKeyForX: cellX asInteger z: cellZ asInteger)
]

{
	#category : #chunks,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameWorld >> simulationRadiusChunks: aNumberOrNil [
	"nil simulates every chunk."

	simulationRadiusChunks := aNumberOrNil
]

{
	#category : #initialization,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 18:36'
}
SWAGameWorld >> spawnMobs [
	| area rabbitCount foxCount |
	self removeAllMobs.
	area := gridSize * gridSize.
	"About ten rabbits to a fox, near where the populations settle; a handful dies out on bad luck."
	rabbitCount := (area * 32 / 4096) ceiling max: 4.
	foxCount := (area * 3 / 4096) ceiling max: 1.
	{#rabbit -> rabbitCount. #fox -> foxCount} do: [:assoc |
		assoc value timesRepeat: [
			| cx cz |
			cx := (0 to: gridSize - 1) atRandom.
			cz := (0 to: gridSize - 1) atRandom.
			self addMobNow: ((self newMobOfSpecies: assoc key)
				positionX: cx + 0.5
					y: (self heightAtX: cx + 1 y: cz + 1)
					z: cz + 0.5;
				yourself)]]
]

{
	#category : #chunks,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameWorld >> spawnMobsInChunkX: cx z: cz [
	| x0 z0 |
	x0 := cx * 16.
	z0 := cz * 16.
	{#rabbit -> 5. #fox -> 1} do: [:assoc |
		assoc value timesRepeat: [
			| x z |
			x := x0 + (0 to: 15) atRandom.
			z := z0 + (0 to: 15) atRandom.
			self addMobNow: ((self newMobOfSpecies: assoc key)
				positionX: x + 0.5
					y: (self heightAtX: x + 1 y: z + 1)
					z: z + 0.5;
				yourself)]]
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 18:36'
}
SWAGameWorld >> speciesRegistry [
	"Add new species here."
	^ Dictionary new
		at: #rabbit put: [SWAGameRabbit new];
		at: #fox put: [SWAGameFox new];
		yourself
]

{
	#category : #chunks,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameWorld >> startFromChunkX: cx z: cz [
	self clearTerrain.
	self generateChunkAtX: cx z: cz.
	self spawnMobsInChunkX: cx z: cz
]

{
	#category : #statistics,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 13:53'
}
SWAGameWorld >> tallyEaten [

	eatenCount := (eatenCount ifNil: [0]) + 1.
]

{
	#category : #statistics,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 13:53'
}
SWAGameWorld >> tallyStarved [

	starvedCount := (starvedCount ifNil: [0]) + 1.
]

{
	#category : #simulation,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameWorld >> tick [
	newMobs ifNil: [newMobs := OrderedCollection new].
	self rebuildMobIndexes.
	self activeChunkKeys do: [:key |
		(self mobChunks at: key ifAbsent: [nil]) ifNotNil: [:bucket |
			bucket copy do: [:mob | mob stepOn: self]]].
	self migrateMobsBetweenChunks.
	self harvestDeadAndNewborn.
	self regrowGrass
]

{
	#category : #configuration,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 14:34'
}
SWAGameWorld >> useImageDefaults [
	config := Dictionary new.
	self reconfigureMobs.
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 13:21'
}
SWAGameWorld >> voxels [

	^ voxels
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 13:21'
}
SWAGameWorld >> voxels: aGrid [

	voxels := aGrid.
]

{
	#category : #terrain,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:17'
}
SWAGameWorld >> water: aCell [
	"Zero based, aCell is x @ z."

	(self garden pourOn: aCell) ifTrue: [
		self grassAt: aCell put: ((self grassAt: aCell) + 1 min: self maxGrass)].
]
