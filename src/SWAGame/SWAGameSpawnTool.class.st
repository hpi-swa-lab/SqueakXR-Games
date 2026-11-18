"
Puts a mob of one species on the terrain column the hand is pointing at.

The species is the parameter, as the material is for SWAGamePlaceTool, so the two
hands can be armed with a rabbit and a fox at once. This is the tool form of the
button slab's #selectSpecies: plus a terrain click.
"
Class {
	#name : #SWAGameSpawnTool,
	#superclass : #SWAGameTool,
	#instVars : [
		'species'
	],
	#category : #'SWAGame-XR',
	#'squeak_changestamp' : '<historical>'
}

{
	#category : #acting,
	#'squeak_changestamp' : 'MCPServer (jl) 10/21/2026 11:16'
}
SWAGameSpawnTool >> applyAtX: gx y: gy z: gz face: aFaceNormal [
	"The face does not matter: the mob goes on top of the column either way,
	so pointing at a cliff wall still puts it somewhere it can stand."

	game spawn: species atX: gx z: gz.
]

{
	#category : #comparing,
	#'squeak_changestamp' : 'MCPServer (jl) 10/21/2026 11:16'
}
SWAGameSpawnTool >> isSameToolAs: anSRTool [
	"The species is the parameter that makes two spawn tools different tools."

	^ (super isSameToolAs: anSRTool) and: [species == anSRTool species]
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 10/21/2026 11:16'
}
SWAGameSpawnTool >> label [
	^ species asString capitalized
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 10/21/2026 11:16'
}
SWAGameSpawnTool >> previewColor [
	"The mob's own colour, so the cube on the hand is the colour of what it
	will put down."

	| factory |
	game ifNil: [^ super previewColor].
	factory := game gameWorld speciesRegistry at: species ifAbsent: [^ super previewColor].
	^ factory value color
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 10/21/2026 11:16'
}
SWAGameSpawnTool >> species [
	^ species
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 10/21/2026 11:16'
}
SWAGameSpawnTool >> species: aSymbol [
	species := aSymbol.
]
