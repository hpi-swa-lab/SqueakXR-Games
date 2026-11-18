"
Heads for the richest grass nearby, or a herbivore only eats what it walks over. Scores are jittered, or every rabbit in earshot picks the same cell.
"
Class {
	#name : #SWAGameGrazeStrategy,
	#superclass : #SWAGameMoveStrategy,
	#instVars : [
		'searchRadius'
	],
	#category : #SWAGame,
	#'squeak_changestamp' : '<historical>'
}

{
	#category : #movement,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 18:36'
}
SWAGameGrazeStrategy >> nextRouteFor: aMob on: aGame [
	"By path length, so grass on a ledge does not draw the herd to the foot of the cliff."
	| nav reach best bestScore |
	nav := SWAGameNavigator on: aGame.
	reach := nav reachFrom: (nav nodeFor: aMob) radius: self searchRadius.
	best := nil.
	bestScore := 0.
	reach keysAndValuesDo: [:key :entry |
		| grass score |
		grass := aGame grassAt: (nav xOf: key) @ (nav zOf: key).
		grass > 0 ifTrue: [
			score := grass / (1 + entry second) * (0.5 + aGame random next).
			score > bestScore ifTrue: [
				bestScore := score.
				best := key]]].
	best ifNil: [^ SWAGameWanderStrategy new nextRouteFor: aMob on: aGame].
	^ nav routeTo: best in: reach
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 13:38'
}
SWAGameGrazeStrategy >> searchRadius [

	"Scanned every decision, so the area costs time: keep it small."

	^ searchRadius ifNil: [4]
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 13:35'
}
SWAGameGrazeStrategy >> searchRadius: aNumber [

	searchRadius := aNumber.
]
