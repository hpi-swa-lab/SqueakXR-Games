"
A point a few cells away, re-rolled when it falls in an ungenerated chunk.
"
Class {
	#name : #SWAGameWanderStrategy,
	#superclass : #SWAGameMoveStrategy,
	#category : #SWAGame,
	#'squeak_changestamp' : '<historical>'
}

{
	#category : #movement,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 18:36'
}
SWAGameWanderStrategy >> nextRouteFor: aMob on: aGame [
	"Random cells, one search each: flooding the neighbourhood first cost ten times as much."
	| nav start |
	nav := SWAGameNavigator on: aGame.
	start := nav nodeFor: aMob.
	6 timesRepeat: [
		| angle dist gx gz |
		angle := aGame random next * 2 * Float pi.
		dist := 2 + (aGame random next * 4).
		gx := (aMob x + (angle cos * dist)) floor.
		gz := (aMob z + (angle sin * dist)) floor.
		(aGame isCellGeneratedX: gx z: gz) ifTrue: [
			(nav routeFrom: start toX: gx z: gz limit: 40) ifNotNil: [:route | ^ route]]].
	^ nil
]
