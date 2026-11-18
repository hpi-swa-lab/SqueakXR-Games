"
The ground under the board. Grabbing it moves the whole game.
"
Class {
	#name : #SWAGameBasePlate,
	#superclass : #SRPlane,
	#category : #SWAGame,
	#'squeak_changestamp' : '<historical>'
}

{
	#category : #interaction,
	#'squeak_changestamp' : 'MCPServer 4/22/2026 17:42'
}
SWAGameBasePlate >> grabTarget [

	^ self parent ifNil: [self]
]

{
	#category : #initialization,
	#'squeak_changestamp' : 'MCPServer 4/22/2026 17:43'
}
SWAGameBasePlate >> initialize [

	super initialize.
]
