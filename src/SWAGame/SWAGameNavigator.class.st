"
Routes over the voxel terrain as a mob can walk it: up one block by jumping, down at most a few.

A node is a cell a mob can stand in, packed into one SmallInteger so the searches key Dictionaries without allocating.
"
Class {
	#name : #SWAGameNavigator,
	#superclass : #Object,
	#instVars : [
		'game'
	],
	#category : #SWAGame,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 18:36'
}

{
	#category : #'instance creation',
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:24'
}
SWAGameNavigator class >> on: aGame [
	^ self new setGame: aGame
]

{
	#category : #nodes,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:24'
}
SWAGameNavigator >> keyX: x y: y z: z [
	^ ((x + 1048576) bitShift: 30) + ((y + 256) bitShift: 21) + (z + 1048576)
]

{
	#category : #nodes,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:25'
}
SWAGameNavigator >> landingX: x z: z from: y [
	"The feet height in column x z that a mob standing at y beside it reaches, or
	nil. A rise needs headroom over the mob as well, or the jump hits the ceiling."
	| drop |
	(game isSolidAtX: x y: y z: z) ifTrue: [
		^ (game isSolidAtX: x y: y + 1 z: z) ifTrue: [nil] ifFalse: [y + 1]].
	drop := 0.
	[drop <= self maxDrop] whileTrue: [
		(game isSolidAtX: x y: y - drop - 1 z: z) ifTrue: [^ y - drop].
		drop := drop + 1].
	^ nil
]

{
	#category : #limits,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 18:36'
}
SWAGameNavigator >> maxDrop [
	"A mob that drops into a pit it cannot climb out of has nowhere left to go."
	^ 3
]

{
	#category : #nodes,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:24'
}
SWAGameNavigator >> neighboursOf: key do: aBlock [
	"Diagonals only across flat ground: cutting a corner at a step clips the block
	on the corner and stalls the mob against it."
	| x y z headroom flat |
	x := self xOf: key.
	y := self yOf: key.
	z := self zOf: key.
	headroom := (game isSolidAtX: x y: y + 1 z: z) not.
	flat := Array new: 4.
	#(#(1 0) #(-1 0) #(0 1) #(0 -1)) doWithIndex: [:d :i |
		| ny |
		ny := self landingX: x + d first z: z + d last from: y.
		(ny notNil and: [ny <= y or: [headroom]]) ifTrue: [
			flat at: i put: ny = y.
			aBlock value: (self keyX: x + d first y: ny z: z + d last)]].
	#(#(1 1 1 3) #(1 -1 1 4) #(-1 1 2 3) #(-1 -1 2 4)) do: [:d |
		((flat at: d third) == true and: [(flat at: d fourth) == true]) ifTrue: [
			(self landingX: x + d first z: z + d second from: y) = y ifTrue: [
				aBlock value: (self keyX: x + d first y: y z: z + d second)]]]
]

{
	#category : #nodes,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:24'
}
SWAGameNavigator >> nodeFor: aMob [
	"The cell under its feet, falling to the ground first if it is in mid-jump."
	| x y z |
	x := aMob cellX.
	z := aMob cellZ.
	y := (aMob y + 0.01) floor.
	[y > 0 and: [(game isSolidAtX: x y: y - 1 z: z) not]] whileTrue: [y := y - 1].
	^ self keyX: x y: y z: z
]

{
	#category : #nodes,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:24'
}
SWAGameNavigator >> pointOf: key [
	"Where a mob steers to: the centre of the cell, horizontally."
	^ ((self xOf: key) + 0.5) @ ((self zOf: key) + 0.5)
]

{
	#category : #searching,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:26'
}
SWAGameNavigator >> reachFrom: startKey radius: r [
	^ self reachFrom: startKey radius: r unless: [:key | false]
]

{
	#category : #searching,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:26'
}
SWAGameNavigator >> reachFrom: startKey radius: r unless: aBlock [
	"Breadth first within r cells horizontally, never entering a node aBlock
	answers true for. Answers node -> {parent. steps}."
	| reach frontier x0 z0 |
	x0 := self xOf: startKey.
	z0 := self zOf: startKey.
	reach := Dictionary new.
	reach at: startKey put: {nil. 0}.
	frontier := OrderedCollection with: startKey.
	[frontier isEmpty] whileFalse: [
		| key steps |
		key := frontier removeFirst.
		steps := (reach at: key) second + 1.
		self neighboursOf: key do: [:next |
			((reach includesKey: next) not
				and: [((self xOf: next) - x0) abs <= r
				and: [((self zOf: next) - z0) abs <= r
				and: [(aBlock value: next) not]]]) ifTrue: [
					reach at: next put: {key. steps}.
					frontier addLast: next]]].
	^ reach
]

{
	#category : #searching,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:24'
}
SWAGameNavigator >> routeFrom: startKey toX: gx z: gz limit: maxNodes [
	"A* to any standable height of column gx gz. Answers waypoints, or nil when the
	column cannot be reached within maxNodes expansions."
	| open parents cost expanded h |
	h := [:key | ((self xOf: key) - gx) abs max: ((self zOf: key) - gz) abs].
	parents := Dictionary new.
	cost := Dictionary new.
	parents at: startKey put: nil.
	cost at: startKey put: 0.
	open := Heap sortBlock: [:a :b | a first <= b first].
	open add: {h value: startKey. startKey}.
	expanded := 0.
	[open isEmpty or: [expanded >= maxNodes]] whileFalse: [
		| key g |
		key := open removeFirst second.
		((self xOf: key) = gx and: [(self zOf: key) = gz]) ifTrue: [
			| route |
			route := OrderedCollection new.
			[(parents at: key) notNil] whileTrue: [
				route addFirst: (self pointOf: key).
				key := parents at: key].
			^ route].
		expanded := expanded + 1.
		g := (cost at: key) + 1.
		self neighboursOf: key do: [:next |
			g < (cost at: next ifAbsent: [SmallInteger maxVal]) ifTrue: [
				cost at: next put: g.
				parents at: next put: key.
				open add: {g + (h value: next). next}]]].
	^ nil
]

{
	#category : #searching,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:24'
}
SWAGameNavigator >> routeTo: key in: reach [
	"Waypoints from the step after the start to key, or nil if key was not reached."
	| route current |
	(reach includesKey: key) ifFalse: [^ nil].
	route := OrderedCollection new.
	current := key.
	[(reach at: current) first notNil] whileTrue: [
		route addFirst: (self pointOf: current).
		current := (reach at: current) first].
	^ route
]

{
	#category : #initialization,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:24'
}
SWAGameNavigator >> setGame: aGame [
	game := aGame.
]

{
	#category : #nodes,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:24'
}
SWAGameNavigator >> xOf: key [
	^ (key bitShift: -30) - 1048576
]

{
	#category : #nodes,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:24'
}
SWAGameNavigator >> yOf: key [
	^ ((key bitShift: -21) bitAnd: 511) - 256
]

{
	#category : #nodes,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:24'
}
SWAGameNavigator >> zOf: key [
	^ (key bitAnd: 2097151) - 1048576
]
