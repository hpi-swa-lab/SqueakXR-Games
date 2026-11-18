"
Tests for the chunked voxel storage, including the coordinate types it is actually called with: raycast hits arrive as Floats.
"
Class {
	#name : #SWAGameChunkedGridTest,
	#superclass : #SWAGameTestCase,
	#instVars : [
		'grid'
	],
	#category : #'SWAGame-Tests',
	#'squeak_changestamp' : '<historical>'
}

{
	#category : #running,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 15:36'
}
SWAGameChunkedGridTest >> setUp [
	super setUp.
	grid := SWAGameChunkedGrid width: 32 depth: 32 height: 32.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 17:34'
}
SWAGameChunkedGridTest >> testCellToChunkMappingFloorsForNegativeCells [
	"Cell -1 belongs to chunk -1, not chunk 0. Truncation towards zero would put
	the sixteen cells either side of the origin in the same chunk."

	#( #(-33 -3) #(-32 -2) #(-17 -2) #(-16 -1) #(-1 -1) #(0 0) #(15 0) #(16 1) )
		do: [:pair |
			| cell chunk key |
			cell := pair first.
			chunk := pair second.
			key := SWAGameChunk keyForCellX: cell z: cell.
			self assert: (SWAGameChunk xOfKey: key) equals: chunk.
			self assert: (SWAGameChunk zOfKey: key) equals: chunk].
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 17:34'
}
SWAGameChunkedGridTest >> testChunkKeysAreUniqueAcrossTheSignedRange [
	"Two chunks sharing a key is silent data loss: one overwrites the other's
	column. The decoder has to read cz back out of the same signed window the
	encoder packed it into."

	| keys |
	keys := Set new.
	SWAGameChunk minCoordinate to: SWAGameChunk maxCoordinate by: 337 do: [:cx |
		SWAGameChunk minCoordinate to: SWAGameChunk maxCoordinate by: 337 do: [:cz |
			| key |
			key := SWAGameChunk keyX: cx z: cz.
			self deny: (keys includes: key).
			keys add: key.
			self assert: (SWAGameChunk xOfKey: key) equals: cx.
			self assert: (SWAGameChunk zOfKey: key) equals: cz]].
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 15:36'
}
SWAGameChunkedGridTest >> testClearEmptiesTheWorld [

	0 to: 31 do: [:x | grid at: x at: 1 at: x put: 1].
	self deny: (grid stats detect: [:a | a key == #chunks]) value = 0.
	grid clear.
	self assert: (grid stats detect: [:a | a key == #chunks]) value equals: 0.
	0 to: 31 do: [:x | self assert: (grid at: x at: 1 at: x) equals: 0].
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 15:36'
}
SWAGameChunkedGridTest >> testEmptySpaceCostsNothing [
	"The reason for sectioning a column: air allocates no storage, and writing
	air into untouched space must not start allocating any."

	self assert: (grid stats detect: [:a | a key == #sections]) value equals: 0.
	grid at: 0 at: 0 at: 0 put: 0.
	self assert: (grid stats detect: [:a | a key == #sections]) value equals: 0.
	grid at: 0 at: 0 at: 0 put: 1.
	self assert: (grid stats detect: [:a | a key == #sections]) value equals: 1.
	"A second section of the same column, not a second chunk."
	grid at: 0 at: 20 at: 0 put: 1.
	self assert: (grid stats detect: [:a | a key == #chunks]) value equals: 1.
	self assert: (grid stats detect: [:a | a key == #sections]) value equals: 2.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 15:36'
}
SWAGameChunkedGridTest >> testFloatCoordinatesArePlacedInTheSameCellAsIntegers [
	"A block placed from a raycast hit arrives as Floats. Shifting one raises
	doesNotUnderstand, which took block placing down in the live world."

	grid at: 5.7 at: 3.2 at: 9.9 put: 1.
	self assert: (grid at: 5 at: 3 at: 9) equals: 1.
	self assert: (grid at: 5.1 at: 3.9 at: 9.0) equals: 1.
	self assert: (grid at: 6 at: 3 at: 9) equals: 0.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 15:37'
}
SWAGameChunkedGridTest >> testOcclusionNeedsAllSixNeighbours [

	| centre |
	centre := 8.
	self deny: (grid isOccludedX: centre y: centre z: centre).
	grid at: centre - 1 at: centre at: centre put: 1.
	grid at: centre + 1 at: centre at: centre put: 1.
	grid at: centre at: centre - 1 at: centre put: 1.
	grid at: centre at: centre + 1 at: centre put: 1.
	grid at: centre at: centre at: centre - 1 put: 1.
	self deny: (grid isOccludedX: centre y: centre z: centre).
	grid at: centre at: centre at: centre + 1 put: 1.
	self assert: (grid isOccludedX: centre y: centre z: centre).
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 17:34'
}
SWAGameChunkedGridTest >> testOutOfBoundsReadsAnswerAirAndWritesAreIgnored [
	"Height is the only limit left in either direction. Horizontally the store
	creates chunks on demand, so a far cell is valid rather than out of bounds:
	that is what lets the world grow."

	#( #(0 -1 0) #(0 32 0) #(-5 -1 -5) #(7 100 7) )
		do: [:c |
			| x y z |
			x := c at: 1. y := c at: 2. z := c at: 3.
			self assert: (grid at: x at: y at: z) equals: 0.
			grid at: x at: y at: z put: 1.
			self assert: (grid at: x at: y at: z) equals: 0].
	self assert: (grid stats detect: [:a | a key == #chunks]) value equals: 0.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 15:36'
}
SWAGameChunkedGridTest >> testReadsBackEveryCellItWrote [
	"Walks the whole volume so an addressing error anywhere shows up, rather
	than only on the cells a sample happens to pick."

	| expected |
	expected := Dictionary new.
	0 to: 31 do: [:x |
		0 to: 31 do: [:y |
			0 to: 31 do: [:z |
				| v |
				v := (x + (y * 3) + (z * 7)) \\ 5.
				grid at: x at: y at: z put: v.
				v = 0 ifFalse: [expected at: { x. y. z } put: v]]]].
	0 to: 31 do: [:x |
		0 to: 31 do: [:y |
			0 to: 31 do: [:z |
				self
					assert: (grid at: x at: y at: z)
					equals: (expected at: { x. y. z } ifAbsent: [0])]]].
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 15:36'
}
SWAGameChunkedGridTest >> testSupportAndPlacementRules [

	self assert: (grid hasSupportAt: 4 @ 0 @ 4).
	self deny: (grid hasSupportAt: 4 @ 5 @ 4).
	grid at: 4 at: 4 at: 4 put: 1.
	self assert: (grid hasSupportAt: 4 @ 5 @ 4).
	self assert: (grid canPlaceAt: 4 @ 5 @ 4).
	self deny: (grid canPlaceAt: 4 @ 4 @ 4) description: 'cell is occupied'.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 17:34'
}
SWAGameChunkedGridTest >> testTheWorldHasNoEdgeTowardsNegativeCoordinates [
	"Growth used to be +x/+z only, because the key arithmetic clamped cells at
	zero and silently filed a negative cell in chunk 0."

	grid at: -1 at: 3 at: -1 put: 1.
	grid at: -17 at: 3 at: -17 put: 2.
	self assert: (grid at: -1 at: 3 at: -1) equals: 1.
	self assert: (grid at: -17 at: 3 at: -17) equals: 2.
	self assert: (grid at: 0 at: 3 at: 0) equals: 0.
	self assert: (grid stats detect: [:a | a key == #chunks]) value equals: 2.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 16:57'
}
SWAGameChunkedGridTest >> testTheWorldHasNoHorizontalEdge [
	"Writing far outside the original extent creates the chunk, which is how the
	world grows when a border chunk is generated."

	grid at: 500 at: 3 at: 900 put: 1.
	self assert: (grid at: 500 at: 3 at: 900) equals: 1.
	self assert: (grid at: 501 at: 3 at: 900) equals: 0.
	self assert: (grid stats detect: [:a | a key == #chunks]) value equals: 1.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 15:36'
}
SWAGameChunkedGridTest >> testWritesOnChunkBoundariesStayInTheirOwnChunk [
	"15 and 16 are either side of a chunk border, 31 is the far edge."

	#(15 16 31) do: [:x |
		#(15 16 31) do: [:z |
			grid at: x at: 15 at: z put: 2.
			grid at: x at: 16 at: z put: 3]].
	#(15 16 31) do: [:x |
		#(15 16 31) do: [:z |
			self assert: (grid at: x at: 15 at: z) equals: 2.
			self assert: (grid at: x at: 16 at: z) equals: 3]].
	self assert: (grid at: 14 at: 15 at: 14) equals: 0.
	self assert: (grid at: 17 at: 17 at: 17) equals: 0.
]
