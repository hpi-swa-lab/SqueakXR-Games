"
2D noise for terrain height.

The permutation is shuffled per instance, so chunks only join if they share one.
"
Class {
	#name : #SWAPerlinNoise,
	#superclass : #Object,
	#instVars : [
		'permutation'
	],
	#category : #SWAGame,
	#'squeak_changestamp' : '<historical>'
}

{
	#category : #private,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAPerlinNoise >> fade: t [
	^ t * t * t * (t * (t * 6 - 15) + 10)
]

{
	#category : #private,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAPerlinNoise >> grad: hash x: x y: y [
	| h |
	h := hash bitAnd: 3.
	h = 0 ifTrue: [^ x + y].
	h = 1 ifTrue: [^ x negated + y].
	h = 2 ifTrue: [^ x - y].
	^ x negated - y
]

{
	#category : #initialization,
	#'squeak_changestamp' : 'MCPServer 5/13/2026 14:36'
}
SWAPerlinNoise >> initialize [
	| p |
	super initialize.
	p := (0 to: 255) asArray shuffled.
	permutation := p , p
]

{
	#category : #private,
	#'squeak_changestamp' : 'MCPServer 5/13/2026 14:36'
}
SWAPerlinNoise >> lerp: t a: a b: b [
	^ a + (t * (b - a))
]

{
	#category : #api,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAPerlinNoise >> noiseX: xFloat y: yFloat [
	"Answers -1 to 1."
	| xi yi xf yf u v aa ab ba bb n1 n2 ix1 ix2 |
	xi := xFloat floor.
	yi := yFloat floor.
	xf := xFloat - xi.
	yf := yFloat - yi.
	xi := xi asInteger bitAnd: 255.
	yi := yi asInteger bitAnd: 255.
	u := self fade: xf.
	v := self fade: yf.
	aa := permutation at: (permutation at: xi + 1) + yi + 1.
	ab := permutation at: (permutation at: xi + 1) + yi + 2.
	ba := permutation at: (permutation at: xi + 2) + yi + 1.
	bb := permutation at: (permutation at: xi + 2) + yi + 2.
	n1 := self lerp: u a: (self grad: aa x: xf y: yf) b: (self grad: ba x: xf - 1 y: yf).
	n2 := self lerp: u a: (self grad: ab x: xf y: yf - 1) b: (self grad: bb x: xf - 1 y: yf - 1).
	^ self lerp: v a: n1 b: n2
]

{
	#category : #api,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAPerlinNoise >> octaveNoiseX: x y: y octaves: octaves persistence: persistence [
	"Fractal Brownian motion."
	| total amplitude frequency maxValue |
	total := 0.0.
	amplitude := 1.0.
	frequency := 1.0.
	maxValue := 0.0.
	1 to: octaves do: [:i |
		total := total + ((self noiseX: x * frequency y: y * frequency) * amplitude).
		maxValue := maxValue + amplitude.
		amplitude := amplitude * persistence.
		frequency := frequency * 2.0].
	^ total / maxValue
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 14:37'
}
SWAPerlinNoise >> permutation [
	^ permutation
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAPerlinNoise >> permutation: aSequence [
	permutation := (aSequence first: 256) asArray , (aSequence first: 256) asArray.
]
