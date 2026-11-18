"
Away from the nearest threat, scored over seven directions: running straight away cornered prey against a wall.
"
Class {
	#name : #SWAGameFleeStrategy,
	#superclass : #SWAGameMoveStrategy,
	#instVars : [
		'threatSpecies',
		'detectionRange',
		'calmStrategy'
	],
	#category : #SWAGame,
	#'squeak_changestamp' : '<historical>'
}

{
	#category : #movement,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:26'
}
SWAGameFleeStrategy >> alarmsFor: aMob on: aGame [
	^ (self nearestThreatTo: aMob on: aGame) notNil
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 18:36'
}
SWAGameFleeStrategy >> calmStrategy [
	^ calmStrategy ifNil: [calmStrategy := SWAGameWanderStrategy new]
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 13:35'
}
SWAGameFleeStrategy >> calmStrategy: aStrategy [

	calmStrategy := aStrategy.
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 5/13/2026 18:29'
}
SWAGameFleeStrategy >> detectionRange [
	^ detectionRange ifNil: [8]
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 5/13/2026 18:29'
}
SWAGameFleeStrategy >> detectionRange: aNumber [
	detectionRange := aNumber
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 18:36'
}
SWAGameFleeStrategy >> fleeRadius [
	"The search grows with its square, for every alarmed prey."
	^ self detectionRange min: 5
]

{
	#category : #movement,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:26'
}
SWAGameFleeStrategy >> nearestThreatTo: aMob on: aGame [
	| nearest nearDist |
	nearest := nil.
	nearDist := self detectionRange squared.
	(aGame mobsOfSpecies: threatSpecies) do: [:t |
		| tx tz d |
		t alive ifTrue: [
			tx := t x - aMob x.
			tz := t z - aMob z.
			d := (tx * tx) + (tz * tz).
			d < nearDist ifTrue: [nearest := t. nearDist := d]]].
	^ nearest
]

{
	#category : #movement,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 18:41'
}
SWAGameFleeStrategy >> nextRouteFor: aMob on: aGame [
	"Never through the cells next to the threat. A route that still leads away is kept:
	replanning a whole herd every decision was the largest cost per tick."
	| threat nav start reach best bestScore |
	threat := self nearestThreatTo: aMob on: aGame.
	aMob alarmed: threat notNil.
	threat ifNil: [^ self calmStrategy nextRouteFor: aMob on: aGame].
	(self route: aMob route stillLeadsAwayFrom: threat for: aMob) ifTrue: [^ aMob route].
	nav := SWAGameNavigator on: aGame.
	start := nav nodeFor: aMob.
	reach := nav reachFrom: start radius: self fleeRadius unless: [:key |
		| p |
		p := nav pointOf: key.
		(p x - threat x) squared + (p y - threat z) squared < 4].
	best := nil.
	bestScore := -1.
	reach keysDo: [:key |
		| p score |
		p := nav pointOf: key.
		score := (p x - threat x) squared + (p y - threat z) squared.
		score > bestScore ifTrue: [
			bestScore := score.
			best := key]].
	^ nav routeTo: best in: reach
]

{
	#category : #movement,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:27'
}
SWAGameFleeStrategy >> route: aRoute stillLeadsAwayFrom: aThreat for: aMob [
	"The next waypoint has to be no closer to the threat than the mob is, and the
	end of the route well clear of it."
	| here next goal |
	(aRoute isNil or: [aRoute isEmpty]) ifTrue: [^ false].
	here := (aMob x - aThreat x) squared + (aMob z - aThreat z) squared.
	next := (aRoute first x - aThreat x) squared + (aRoute first y - aThreat z) squared.
	goal := (aRoute last x - aThreat x) squared + (aRoute last y - aThreat z) squared.
	^ next >= here and: [goal > (here + 4)]
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 5/13/2026 15:19'
}
SWAGameFleeStrategy >> threatSpecies: aSymbol [
	threatSpecies := aSymbol
]
