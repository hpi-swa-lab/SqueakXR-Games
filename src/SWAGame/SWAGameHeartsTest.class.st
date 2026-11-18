"
Tests SWAGameHearts.
"
Class {
	#name : #SWAGameHeartsTest,
	#superclass : #SWAGameTestCase,
	#category : #'SWAGame-Tests',
	#'squeak_changestamp' : '<historical>'
}

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (leo) 11/5/2026 17:49'
}
SWAGameHeartsTest >> testAHeartRises [

	| heart |
	heart := SWAGameHeart at: (Vector3 x: 0 y: 0 z: 0) cellSize: 5 cm sway: 0.
	heart advance: 0.5.
	self assert: heart position y > 0.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (leo) 11/5/2026 17:49'
}
SWAGameHeartsTest >> testHeartsExpire [

	| hearts |
	hearts := SWAGameHearts new.
	hearts emitAt: (Vector3 x: 0 y: 0 z: 0) cellSize: 5 cm.
	hearts advance: SWAGameHeart lifetime / 2.
	self assert: hearts hearts size equals: 1.
	hearts advance: SWAGameHeart lifetime / 2.
	self assert: hearts hearts isEmpty.
]
