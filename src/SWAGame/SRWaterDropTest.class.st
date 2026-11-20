"
Tests SRWaterDrop.
"
Class {
	#name : #SRWaterDropTest,
	#superclass : #TestCase,
	#instVars : [
		'scene',
		'drop'
	],
	#category : #'SWAGame-Tests',
	#'squeak_changestamp' : '<historical>'
}

{
	#category : #running,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:07'
}
SRWaterDropTest >> setUp [

	super setUp.
	scene := SRObject new.
	drop := SRWaterDrop new.
	scene addChild: drop.
	drop globalTranslation: 0 @ 1m @ 0.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:07'
}
SRWaterDropTest >> testGravityPullsTheDropDown [

	drop step: 0.1.
	self assert: (drop velocity - (0 @ -0.981 @ 0)) length < 0.0001.
	self assert: drop globalTranslation y < 1m.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:07'
}
SRWaterDropTest >> testTheDropDisappearsBelowTheFloor [

	drop globalTranslation: 0 @ -1cm @ 0.
	drop step: 0.01.
	self assert: drop parent isNil.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:07'
}
SRWaterDropTest >> testTheDropExpiresAfterItsLifetime [

	drop step: SRWaterDrop lifetime / 2.
	self assert: drop parent == scene.
	drop step: SRWaterDrop lifetime.
	self assert: drop parent isNil.
]
