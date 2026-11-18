"
An SRPlane with no collision geometry, so a ray passes through it.
"
Class {
	#name : #SWAGameDisplayPlane,
	#superclass : #SRPlane,
	#category : #SWAGame,
	#'squeak_changestamp' : '<historical>'
}

{
	#category : #collisions,
	#'squeak_changestamp' : 'MCPServer 5/18/2026 17:54'
}
SWAGameDisplayPlane >> collisionGeometry [
	^ nil
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 5/18/2026 18:15'
}
SWAGameDisplayPlane >> mesh [
	"Handle case where world is not yet available."
	self world ifNil: [^ self class mesh].
	^ super mesh
]
