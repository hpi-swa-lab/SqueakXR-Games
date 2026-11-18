Class {
	#name : #SWAGameLookTest,
	#superclass : #SWAGameTestCase,
	#instVars : [
		'xr'
	],
	#category : #'SWAGame-Tests'
}

{
	#category : #running,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 16:33'
}
SWAGameLookTest >> setUp [
	super setUp.
	xr := SWAGameXR new.
]

{
	#category : #running,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 16:33'
}
SWAGameLookTest >> tearDown [
	"Left alive it would be picked up by SWAGameXR allInstances, which is how the live world is found."
	xr ifNotNil: [[xr destroy] on: Error do: [:e | nil]].
	xr := nil.
	super tearDown.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 16:33'
}
SWAGameLookTest >> testOutlinesOffMeansAZeroWidthLine [
	"The shader draws no outline at width 0; lineThickness itself keeps its value for when they come back."
	self assert: xr effectiveLineThickness equals: 0.0.
	SWAGameXR blockOutlines: true.
	self assert: xr effectiveLineThickness equals: xr lineThickness.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 16:33'
}
SWAGameLookTest >> testTexturesAndAnimalsAreOnAndOutlinesOffByDefault [
	self deny: SWAGameXR blockOutlines.
	self assert: SWAGameXR blockTextures.
	self assert: SWAGameXR animalModels.
]
