"
Places a block of one material. The material is the tool's parameter, so the two hands can hold this tool set to two different blocks.
"
Class {
	#name : #SWAGamePlaceTool,
	#superclass : #SWAGameTool,
	#instVars : [
		'material'
	],
	#category : #'SWAGame-XR',
	#'squeak_changestamp' : '<historical>'
}

{
	#category : #acting,
	#'squeak_changestamp' : 'MCPServer (SqueakXR) 10/20/2026 11:00'
}
SWAGamePlaceTool >> applyAtX: gx y: gy z: gz face: aFaceNormal [

	game placeAtX: gx y: gy z: gz face: aFaceNormal material: material.
]

{
	#category : #comparing,
	#'squeak_changestamp' : 'MCPServer (jl) 10/21/2026 11:05'
}
SWAGamePlaceTool >> isSameToolAs: anSRTool [
	"The material is the parameter that makes two place tools different tools."

	^ (super isSameToolAs: anSRTool) and: [material == anSRTool material]
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (SqueakXR) 10/20/2026 13:57'
}
SWAGamePlaceTool >> label [
	^ self spec
		ifNil: [material asString]
		ifNotNil: [:each | each second]
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (SqueakXR) 10/20/2026 11:00'
}
SWAGamePlaceTool >> material [
	^ material
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (SqueakXR) 10/20/2026 11:00'
}
SWAGamePlaceTool >> material: aSymbol [
	material := aSymbol.
]

{
	#category : #preview,
	#'squeak_changestamp' : 'MCPServer (SqueakXR) 10/20/2026 13:57'
}
SWAGamePlaceTool >> previewColor [
	"The slab's colour for the same material, so the hand and the panel agree."

	^ self spec
		ifNil: [super previewColor]
		ifNotNil: [:each | each third]
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (SqueakXR) 10/20/2026 13:57'
}
SWAGamePlaceTool >> spec [
	^ SWAGameXR terrainMaterials
		detect: [:each | each first == material]
		ifNone: [nil]
]
