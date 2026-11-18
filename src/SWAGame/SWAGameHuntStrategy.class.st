"
Towards the nearest prey, wandering when none is in range.
"
Class {
	#name : #SWAGameHuntStrategy,
	#superclass : #SWAGameMoveStrategy,
	#instVars : [
		'preySpecies',
		'detectionRange'
	],
	#category : #SWAGame,
	#'squeak_changestamp' : '<historical>'
}

{
	#category : #movement,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:36'
}
SWAGameHuntStrategy >> alarmsFor: aMob on: aGame [
	^ aMob isEating not
		and: [aMob isHungry
		and: [(self preyNear: aMob on: aGame) notEmpty]]
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 5/13/2026 18:29'
}
SWAGameHuntStrategy >> detectionRange [
	^ detectionRange ifNil: [20]
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 5/13/2026 18:29'
}
SWAGameHuntStrategy >> detectionRange: aNumber [
	detectionRange := aNumber
]

{
	#category : #movement,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 18:36'
}
SWAGameHuntStrategy >> nextRouteFor: aMob on: aGame [
	"Only the nearest two are tried: each is a search, four times a second."
	| nav start prey |
	aMob isHungry ifTrue: [
		nav := SWAGameNavigator on: aGame.
		start := nav nodeFor: aMob.
		prey := self preyNear: aMob on: aGame.
		(prey first: (prey size min: 2)) do: [:each |
			(nav routeFrom: start toX: each cellX z: each cellZ limit: 250) ifNotNil: [:route |
				aMob alarmed: true.
				^ route
					addLast: each x @ each z;
					yourself]]].
	aMob alarmed: false.
	^ SWAGameWanderStrategy new nextRouteFor: aMob on: aGame
]

{
	#category : #movement,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:36'
}
SWAGameHuntStrategy >> preyNear: aMob on: aGame [
	"Nearest first, within detection range. A body counts: it is the same meal
	without the chase."
	| range |
	range := self detectionRange squared.
	^ (((aGame mobsOfSpecies: preySpecies), (aGame corpsesOfSpecies: preySpecies)) select: [:p |
		(p alive or: [p remains > 0])
			and: [(p x - aMob x) squared + (p z - aMob z) squared < range]])
				asSortedCollection: [:a :b |
					(a x - aMob x) squared + (a z - aMob z) squared
						<= ((b x - aMob x) squared + (b z - aMob z) squared)]
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 5/13/2026 15:18'
}
SWAGameHuntStrategy >> preySpecies: aSymbol [
	preySpecies := aSymbol
]
