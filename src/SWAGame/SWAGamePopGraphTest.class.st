Class {
	#name : #SWAGamePopGraphTest,
	#superclass : #TestCase,
	#instVars : [
		'graph'
	],
	#category : #'SWAGame-Tests'
}

{
	#category : #private,
	#'squeak_changestamp' : 'MCPServer (MCPServer (MCPServer)) 10/23/2026 11:03'
}
SWAGamePopGraphTest >> pixelsOf: aColor [

	| form pixel |
	form := (graph instVarNamed: 'source') form.
	pixel := aColor pixelValueForDepth: 32.
	^ (0 to: form width - 1) inject: 0 into: [:sum :x |
		sum + ((0 to: form height - 1) count: [:y | (form pixelValueAt: x @ y) = pixel])]
]

{
	#category : #running,
	#'squeak_changestamp' : 'MCPServer (MCPServer (MCPServer)) 10/23/2026 11:03'
}
SWAGamePopGraphTest >> setUp [

	super setUp.
	graph := SWAGamePopGraph new.
	1 to: 50 do: [:i | graph recordRabbits: i foxes: 50 - i].
	graph redraw.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (MCPServer (MCPServer)) 10/23/2026 11:03'
}
SWAGamePopGraphTest >> testBothSeriesAreDrawn [

	self assert: (self pixelsOf: Color white) > 0.
	self assert: (self pixelsOf: (Color r: 0.9 g: 0.5 b: 0.1)) > 0.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 11/3/2026 14:31'
}
SWAGamePopGraphTest >> testTheAxesAreDrawn [

	self assert: (self pixelsOf: graph axisColor) > 0.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (MCPServer (MCPServer)) 10/23/2026 11:03'
}
SWAGamePopGraphTest >> testThePlaneShowsTheTextureThroughTheSwizzlingShader [

	| material |
	material := (graph instVarNamed: 'plane') material.
	self assert: material texture == (graph instVarNamed: 'texture').
	self assert: material shader name equals: #morphicPanel.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 11/3/2026 14:31'
}
SWAGamePopGraphTest >> testTheScaleIsRoundedToTheGridLines [

	self assert: graph maxPop equals: 52.
]
