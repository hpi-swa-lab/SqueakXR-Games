"
Where a mob heads next. Interchangeable at runtime, and species are named by symbol so that no strategy mentions a mob class.
"
Class {
	#name : #SWAGameMoveStrategy,
	#superclass : #Object,
	#category : #SWAGame,
	#'squeak_changestamp' : '<historical>'
}

{
	#category : #movement,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:26'
}
SWAGameMoveStrategy >> alarmsFor: aMob on: aGame [
	"Asked every decision, so it has to be cheap. True replans every decision and
	runs; false lets a calm mob finish what it was doing."
	^ false
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 14:34'
}
SWAGameMoveStrategy >> detectionRange [
	^ nil
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 18:36'
}
SWAGameMoveStrategy >> detectionRange: aNumber [
	"Strategies that sense nothing accept it too: the preference reaches every mob."
]

{
	#category : #movement,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:26'
}
SWAGameMoveStrategy >> nextRouteFor: aMob on: aGame [
	"Waypoints to walk through, as Points of x and z; empty or nil to stay put."
	self subclassResponsibility
]
