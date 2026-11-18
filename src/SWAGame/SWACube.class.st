"
A cube with collision geometry, which SRCube has none of.

Unused: nothing in the image sends it.
"
Class {
	#name : #SWACube,
	#superclass : #SRObject,
	#instVars : [
		'color'
	],
	#category : #SWAGame,
	#'squeak_changestamp' : '<historical>'
}

{
	#category : #collisions,
	#'squeak_changestamp' : 'MCPServer 5/18/2026 18:24'
}
SWACube >> collisionGeometry [
	^ SRCollisionBox new
		center: self globalTranslation;
		halfExtents: self globalScale / 2.0;
		rotation: self globalRotation;
		object: self
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 5/18/2026 18:23'
}
SWACube >> color [
	^ color
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 5/18/2026 18:23'
}
SWACube >> color: aColor [
	color := aColor
]

{
	#category : #initialization,
	#'squeak_changestamp' : 'MCPServer 5/18/2026 18:23'
}
SWACube >> initialize [
	super initialize.
	color := Color red
]

{
	#category : #rendering,
	#'squeak_changestamp' : 'MCPServer 5/18/2026 18:24'
}
SWACube >> renderOn: aSRRenderer [
	aSRRenderer renderCubeTransformed: self globalTransform withColor: color
]

{
	#category : #hierarchy,
	#'squeak_changestamp' : 'MCPServer (jl) 11/16/2026 11:28'
}
SWACube >> wantsGrab [

	^ true
]
