"
Digs out the cube that was hit.
"
Class {
	#name : #SWAGameDigTool,
	#superclass : #SWAGameTool,
	#category : #'SWAGame-XR',
	#'squeak_changestamp' : '<historical>'
}

{
	#category : #acting,
	#'squeak_changestamp' : 'MCPServer (SqueakXR) 10/20/2026 11:00'
}
SWAGameDigTool >> applyAtX: gx y: gy z: gz face: aFaceNormal [

	game digAtX: gx y: gy z: gz.
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (SqueakXR) 10/20/2026 11:00'
}
SWAGameDigTool >> label [
	^ 'Pick Axe'
]

{
	#category : #preview,
	#'squeak_changestamp' : 'MCPServer (SqueakXR) 10/20/2026 13:57'
}
SWAGameDigTool >> previewColor [
	"The pick axe red from the tool slab."

	^ Color r: 0.75 g: 0.2 b: 0.2
]
