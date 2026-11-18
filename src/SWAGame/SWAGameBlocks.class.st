"
The block type ids a voxel can hold, and their colours. Id 0 is air.
"
Class {
	#name : #SWAGameBlocks,
	#superclass : #Object,
	#classVars : [
		'RgbaCache'
	],
	#category : #'SWAGame-Voxels',
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}

{
	#category : #constants,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 16:14'
}
SWAGameBlocks class >> air [

	^ 0
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 16:15'
}
SWAGameBlocks class >> colorFor: anId [

	| all |
	all := self types.
	(anId between: 1 and: all size) ifFalse: [^ Color magenta].
	^ (all at: anId) second
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 16:15'
}
SWAGameBlocks class >> idFor: aSymbol [

	self types doWithIndex: [:each :index |
		each first == aSymbol ifTrue: [^ index]].
	^ self air
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 16:15'
}
SWAGameBlocks class >> resetCache [

	RgbaCache := nil
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameBlocks class >> rgbaFor: anId [
	"Must not allocate: the mesher asks once per face. Alpha is the type id, not opacity."

	RgbaCache ifNil: [
		RgbaCache := (1 to: self types size) collect: [:id |
			| c |
			c := self colorFor: id.
			Array
				with: (c red * 255) asInteger
				with: (c green * 255) asInteger
				with: (c blue * 255) asInteger
				with: id]].
	(anId between: 1 and: RgbaCache size) ifFalse: [^ #(255 0 255 0)].
	^ RgbaCache at: anId
]

{
	#category : #constants,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameBlocks class >> types [
	"Ids start at 1; air is 0."

	^ {
		{#grass. Color r: 0.25 g: 0.7 b: 0.25}.
		{#dirt. Color r: 0.45 g: 0.32 b: 0.2}.
		{#sand. Color r: 0.86 g: 0.78 b: 0.45}.
		{#rock. Color r: 0.5 g: 0.5 b: 0.55}.
		{#snow. Color r: 0.95 g: 0.96 b: 1.0}.
		{#water. Color r: 0.15 g: 0.35 b: 0.85}}
]
