"
Superclass for the SWAGame tests, so they run against the defaults in the code rather than the live tuning.

Species parameters are class variables behind <preference:> pragmas, and the getters fall back to a literal when the variable is nil. A test that reads them is really testing whatever was last set in the config panel: tuning the rabbit detection range from 6 to 2 made a flee test fail without a line of code changing.
"
Class {
	#name : #SWAGameTestCase,
	#superclass : #TestCase,
	#instVars : [
		'savedPreferences'
	],
	#category : #'SWAGame-Tests',
	#'squeak_changestamp' : '<historical>'
}

{
	#category : #preferences,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:28'
}
SWAGameTestCase >> preferenceHolders [
	"Class, and the class variables of it that back a preference. Named rather
	than discovered, because not every class variable is a preference:
	SWAGameBlocks>>RgbaCache is a memo and clearing it proves nothing."

	^ { SWAGameRabbit. SWAGameFox. SWAGameWorld. SWAGameXR. SRAvatar }
]

{
	#category : #preferences,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 16:33'
}
SWAGameTestCase >> preferenceVariablesOf: aClass [
	"A preference is a class variable whose getter falls back to a literal when
	it is nil, so nil is the documented 'use the default' value."

	^ aClass classVarNames select: [:each |
		(each beginsWith: 'Default')
			or: [#(#SimulationRadiusChunks #ContinuousLocomotion #SmoothTurn
				#SnapTurnAngle #SmoothTurnSpeed #TeleportBlink #WalkSpeed
				#BlockOutlines #BlockTextures #AnimalModels)
					includes: each]]
]

{
	#category : #running,
	#'squeak_changestamp' : 'MCPServer 10/19/2026 11:22'
}
SWAGameTestCase >> setUp [
	super setUp.
	savedPreferences := Dictionary new.
	self preferenceHolders do: [:holder |
		(self preferenceVariablesOf: holder) do: [:name |
			savedPreferences
				at: holder -> name
				put: (holder classPool at: name ifAbsent: [nil]).
			holder classPool at: name put: nil]].
]

{
	#category : #running,
	#'squeak_changestamp' : 'MCPServer 10/19/2026 11:22'
}
SWAGameTestCase >> tearDown [
	"Restored even when a test fails, so running the tests never retunes the
	running game."

	savedPreferences ifNotNil: [
		savedPreferences keysAndValuesDo: [:key :value |
			key key classPool at: key value put: value]].
	savedPreferences := nil.
	super tearDown
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 10/21/2026 10:41'
}
SWAGameTestCase >> testPreferencesAreTheCodeDefaults [
	"Guards the isolation itself, and runs in every subclass, so a setUp that
	forgets to call super is caught here rather than by a flee test failing a
	fortnight after someone retuned the rabbits."

	self assert: (SWAGameRabbit classPool at: #DefaultDetectionRange) isNil.
	self assert: SWAGameRabbit detectionRange equals: 6.
	"SqueakXR's are reached too: walking reads the locomotion style."
	self assert: (SRAvatar classPool at: #ContinuousLocomotion) isNil.
	self assert: SRAvatar locomotionStyle equals: #teleport.
]
