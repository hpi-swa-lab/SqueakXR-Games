Class {
	#name : #SWAGameMobTraceGraphTest,
	#superclass : #TestCase,
	#instVars : [
		'graph',
		'mob'
	],
	#category : #'SWAGame-Tests'
}

{
	#category : #support,
	#'squeak_changestamp' : 'MCPServer (jl) 11/13/2026 11:08'
}
SWAGameMobTraceGraphTest >> entryFrom: fromX to: toX [

	^ SWAGameMobEntry new from: (Vector3 x: fromX y: 0 z: 0) to: (Vector3 x: toX y: 0 z: 0); yourself
]

{
	#category : #support,
	#'squeak_changestamp' : 'MCPServer (jl) 11/3/2026 15:09'
}
SWAGameMobTraceGraphTest >> pixelsOf: aColor [

	| form pixel |
	form := (graph instVarNamed: 'source') form.
	pixel := aColor pixelValueForDepth: 32.
	^ (0 to: form width - 1) inject: 0 into: [:sum :x |
		sum + ((0 to: form height - 1) count: [:y | (form pixelValueAt: x @ y) = pixel])]
]

{
	#category : #support,
	#'squeak_changestamp' : 'MCPServer (jl) 11/3/2026 15:09'
}
SWAGameMobTraceGraphTest >> record: t of: anEntry ticked: aBoolean [

	graph recordFrameOf: mob entry: anEntry milliseconds: 10 t: t ticked: aBoolean worldScale: 1.
]

{
	#category : #running,
	#'squeak_changestamp' : 'MCPServer (jl) 11/3/2026 15:09'
}
SWAGameMobTraceGraphTest >> setUp [

	super setUp.
	graph := SWAGameMobTraceGraph new.
	mob := SWAGameRabbit new.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 11/3/2026 15:09'
}
SWAGameMobTraceGraphTest >> testAMobWithoutAnEntryIsNotSampled [

	self record: 0.5 of: nil ticked: false.
	self assert: graph samples isEmpty.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 11/3/2026 15:09'
}
SWAGameMobTraceGraphTest >> testAStepBackIsCounted [

	| entry |
	entry := self entryFrom: 0 to: 1.
	self record: 0.5 of: entry ticked: false.
	self record: 1.0 of: entry ticked: true.
	self record: 0.3 of: entry ticked: false.
	self assert: graph backwardFrames = 1.
	self assert: graph tickCount = 1.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 11/3/2026 15:09'
}
SWAGameMobTraceGraphTest >> testAnotherMobStartsANewTrace [

	self record: 0.5 of: (self entryFrom: 0 to: 1) ticked: false.
	graph recordFrameOf: SWAGameFox new entry: (self entryFrom: 0 to: 1) milliseconds: 10 t: 0.5 ticked: false worldScale: 1.
	self assert: graph samples size = 1.
	self assert: graph mob isFox.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 11/3/2026 15:09'
}
SWAGameMobTraceGraphTest >> testSmoothMotionHasNoBackwardFrames [

	| entry |
	entry := self entryFrom: 0 to: 1.
	#(0.2 0.4 0.6 0.8) do: [:t | self record: t of: entry ticked: false].
	self assert: graph backwardFrames = 0.
	self assert: ((graph samples last at: 4) closeTo: 20).
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 11/3/2026 15:09'
}
SWAGameMobTraceGraphTest >> testTheSeriesAreDrawn [

	| entry |
	entry := self entryFrom: 0 to: 1.
	#(0.2 0.4 0.6 0.8 1.0) do: [:t | self record: t of: entry ticked: t = 1.0].
	graph redraw.
	self assert: (self pixelsOf: graph tColor) > 0.
	self assert: (self pixelsOf: graph drawnColor) > 0.
	self assert: (self pixelsOf: graph tickColor) > 0.
]
