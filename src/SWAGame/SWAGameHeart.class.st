"
A heart rising from a petted mob.
"
Class {
	#name : #SWAGameHeart,
	#superclass : #Object,
	#instVars : [
		'origin',
		'cellSize',
		'sway',
		'age'
	],
	#category : #'SWAGame-XR',
	#'squeak_changestamp' : '<historical>'
}

{
	#category : #'instance creation',
	#'squeak_changestamp' : 'MCPServer (leo) 11/5/2026 17:47'
}
SWAGameHeart class >> at: aVector3 cellSize: aNumber sway: phase [

	^ self new setOrigin: aVector3 cellSize: aNumber sway: phase
]

{
	#category : #constants,
	#'squeak_changestamp' : 'MCPServer (leo) 11/5/2026 17:47'
}
SWAGameHeart class >> lifetime [

	^ 1.5
]

{
	#category : #constants,
	#'squeak_changestamp' : 'MCPServer (leo) 11/5/2026 17:47'
}
SWAGameHeart class >> riseSpeed [

	^ 1.2
]

{
	#category : #constants,
	#'squeak_changestamp' : 'MCPServer (leo) 11/5/2026 17:47'
}
SWAGameHeart class >> swayWidth [

	^ 0.1
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (leo) 11/5/2026 17:47'
}
SWAGameHeart >> advance: seconds [

	age := age + seconds.
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (leo) 11/5/2026 17:47'
}
SWAGameHeart >> isExpired [

	^ age >= self class lifetime
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (leo) 11/5/2026 17:47'
}
SWAGameHeart >> position [

	^ origin + (((sway + (age * 4)) sin * self class swayWidth * cellSize) @ (age * self class riseSpeed * cellSize) @ 0)
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (leo) 11/5/2026 17:47'
}
SWAGameHeart >> progress [

	^ age / self class lifetime
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (leo) 11/5/2026 17:47'
}
SWAGameHeart >> scale [

	^ ((self progress * 6 min: (1 - self progress) * 1.5) min: 1) * cellSize
]

{
	#category : #initialization,
	#'squeak_changestamp' : 'MCPServer (leo) 11/5/2026 17:47'
}
SWAGameHeart >> setOrigin: aVector3 cellSize: aNumber sway: phase [

	origin := aVector3.
	cellSize := aNumber.
	sway := phase.
	age := 0.
]
