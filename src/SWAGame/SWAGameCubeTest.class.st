Class {
	#name : #SWAGameCubeTest,
	#superclass : #TestCase,
	#category : #'SWAGame-Tests'
}

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 11/16/2026 11:28'
}
SWAGameCubeTest >> testSWACubesCanBeGrabbed [

	self assert: SWAGameCube new canGrab.
	self assert: SWACube new canGrab.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 11/16/2026 11:37'
}
SWAGameCubeTest >> testSqueezingAtACubeGrabsIt [
	"The ray hits the visible SRCube child first, which used to swallow the grab."

	| world avatar cube hand from |
	world := SRWorld new.
	avatar := SRAvatar new.
	world addChild: avatar.
	cube := SWAGameCube new.
	cube translation: 0 @ 1.4 @ -2.
	world addChild: cube.
	hand := avatar rightHand.
	from := 0.2 @ 1.3 @ 0.
	hand globalTransform: (Matrix4x4
		objectLookAt: from + (cube globalTranslation - from) normalized
		from: from
		up: Vector3 up).
	hand cursor updateActions: nil.
	hand updateFirstIntersection.
	hand inputState updateDesktopTrigger: 0.0 squeeze: 1.0 topButton: false.
	(hand instVarNamed: 'actions') detect: [:action | (action run: hand inputState) not] ifNone: [nil].
	self assert: hand grabbedObject == cube.
]
