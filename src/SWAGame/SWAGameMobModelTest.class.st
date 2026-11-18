Class {
	#name : #SWAGameMobModelTest,
	#superclass : #TestCase,
	#category : #'SWAGame-Tests'
}

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 15:40'
}
SWAGameMobModelTest >> testAHopReachesForwardAndPushesBack [
	| pose |
	pose := ByteArray new: 16.
	SWAGameMobModel rabbit writePose: pose phase: Float pi / 2 swing: 0.5 eating: false time: 0.
	self assert: (pose floatAt: 1) < 0.
	self assert: (pose floatAt: 5) > 0.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 15:40'
}
SWAGameMobModelTest >> testAnEatingAnimalLowersItsHead [
	| pose |
	pose := ByteArray new: 16.
	SWAGameMobModel rabbit writePose: pose phase: 0 swing: 0 eating: true time: 0.
	self assert: (pose floatAt: 9) > 0.3.
	SWAGameMobModel rabbit writePose: pose phase: 0 swing: 0 eating: false time: 0.
	self assert: (pose floatAt: 9) equals: 0.0.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 15:40'
}
SWAGameMobModelTest >> testEveryVertexCarriesItsLimbAndPivot [
	| model source |
	model := SWAGameMobModel new.
	model part: #legsB pivot: #(3 -2) box: #(0 0 0 1 1 1) color: Color white.
	source := model meshSource.
	1 to: source elementCount do: [:i |
		self assert: (source colors at: i * 4) equals: 2 * 32.
		self assert: (source texcoords at: i * 2 - 1) equals: 3.0.
		self assert: (source texcoords at: i * 2) equals: -2.0].
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 15:40'
}
SWAGameMobModelTest >> testFacesBetweenGroupsAreKept [
	"A swinging leg uncovers the side of the body it was touching."
	| model |
	model := SWAGameMobModel new.
	model
		part: #body box: #(0 0 0 1 1 1) color: Color white;
		part: #legsA pivot: #(1 0) box: #(1 0 0 2 1 1) color: Color white.
	self assert: model faceCount equals: 12.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 15:40'
}
SWAGameMobModelTest >> testFacesInsideAGroupAreCulled [
	| model |
	model := SWAGameMobModel new.
	model part: #body box: #(0 0 0 2 1 1) color: Color white.
	self assert: model faceCount equals: 10.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 15:40'
}
SWAGameMobModelTest >> testFacesWindCounterClockwiseFromOutside [
	"Backface culling drops a face wound the other way, and the animal shows its inside."
	SWAGameMobModel faceTable do: [:face |
		| n c |
		n := face first.
		c := face second collect: [:corner | Vector3 x: corner first y: corner second z: corner third].
		self assert: ((c second - c first) cross: (c third - c first)) equals: (Vector3 x: n first y: n second z: n third).
		self assert: ((c third - c first) cross: (c fourth - c first)) equals: (Vector3 x: n first y: n second z: n third)].
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 15:40'
}
SWAGameMobModelTest >> testSpeciesFitSixteenBitIndices [
	#(#rabbit #fox) do: [:species |
		| source |
		source := (SWAGameMobModel forSpecies: species) meshSource.
		self assert: source elementCount < 65536.
		self assert: (source indices inject: 0 into: [:a :b | a max: b]) equals: source elementCount - 1]
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 15:40'
}
SWAGameMobModelTest >> testSpeciesStandOnTheGround [
	"The renderer puts the model origin at the feet."
	#(#rabbit #fox) do: [:species |
		| lowest |
		lowest := nil.
		(SWAGameMobModel forSpecies: species) facesDo: [:group :xyz :face :color |
			lowest := lowest ifNil: [xyz second] ifNotNil: [lowest min: xyz second]].
		self assert: lowest equals: 0]
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 15:40'
}
SWAGameMobModelTest >> testTrotSwingsTheDiagonalPairsAgainstEachOther [
	| pose |
	pose := ByteArray new: 16.
	SWAGameMobModel fox writePose: pose phase: Float pi / 2 swing: 0.5 eating: false time: 0.
	self assert: ((pose floatAt: 1) + (pose floatAt: 5)) abs < 1.0e-6.
	self assert: (pose floatAt: 1) > 0.4.
]
