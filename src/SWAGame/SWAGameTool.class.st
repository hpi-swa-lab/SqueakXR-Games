"
A terrain tool. Declines any hit that is not the terrain, so panels, chunk markers and menus still answer the trigger while a tool is held.
"
Class {
	#name : #SWAGameTool,
	#superclass : #SRTool,
	#instVars : [
		'game'
	],
	#category : #'SWAGame-XR',
	#'squeak_changestamp' : '<historical>'
}

{
	#category : #acting,
	#'squeak_changestamp' : 'MCPServer (SqueakXR) 10/20/2026 11:00'
}
SWAGameTool >> applyAtX: gx y: gy z: gz face: aFaceNormal [
	^ self subclassResponsibility
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (SqueakXR) 10/20/2026 10:59'
}
SWAGameTool >> game [
	^ game
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (SqueakXR) 10/20/2026 10:59'
}
SWAGameTool >> game: aGame [
	game := aGame.
]

{
	#category : #acting,
	#'squeak_changestamp' : 'MCPServer (SqueakXR) 10/20/2026 11:00'
}
SWAGameTool >> handleRaycast: aHandRayIntersectionResult [
	"The voxel and face come from the DDA that ran in the game's collision
	geometry during this very cast, so they are only valid for our own hit."

	| hit |
	aHandRayIntersectionResult object == game ifFalse: [^ false].
	hit := game lastVoxelHit ifNil: [^ false].
	self
		applyAtX: (hit at: 1)
		y: (hit at: 2)
		z: (hit at: 3)
		face: (hit at: 4).
	^ true
]
