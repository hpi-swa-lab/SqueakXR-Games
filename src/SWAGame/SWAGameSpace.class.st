"
The one place that converts a cell coordinate into object space.
"
Class {
	#name : #SWAGameSpace,
	#superclass : #Object,
	#instVars : [
		'worldScale',
		'originX',
		'originZ'
	],
	#category : #'SWAGame-Voxels',
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}

{
	#category : #'instance creation',
	#'squeak_changestamp' : 'MCPServer 10/15/2026 16:07'
}
SWAGameSpace class >> worldScale: aScale originX: anX originZ: aZ [

	^ self new
		worldScale: aScale originX: anX originZ: aZ;
		yourself
]

{
	#category : #converting,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameSpace >> cellXForObjectX: aNumber [
	"Inverse of #vectorForCellX:y:z:."

	^ aNumber / worldScale + originX
]

{
	#category : #converting,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 16:42'
}
SWAGameSpace >> cellZForObjectZ: aNumber [

	^ aNumber / worldScale + originZ
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 16:07'
}
SWAGameSpace >> originX [
	"The cell that sits at the object origin on the x axis."

	^ originX
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 16:08'
}
SWAGameSpace >> originZ [
	"The cell that sits at the object origin on the z axis."

	^ originZ
]

{
	#category : #converting,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 16:08'
}
SWAGameSpace >> vectorForCellX: cellX y: cellY z: cellZ [

	^ Vector3
		x: (cellX - originX) * worldScale
		y: cellY * worldScale
		z: (cellZ - originZ) * worldScale
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 16:07'
}
SWAGameSpace >> worldScale [

	^ worldScale
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameSpace >> worldScale: aScale [
	"Mutated, not replaced: the mesher and the game share this instance."

	worldScale := aScale
]

{
	#category : #initialization,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 16:07'
}
SWAGameSpace >> worldScale: aScale originX: anX originZ: aZ [

	worldScale := aScale.
	originX := anX.
	originZ := aZ.
	^ self
]
