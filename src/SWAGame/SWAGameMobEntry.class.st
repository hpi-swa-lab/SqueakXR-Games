"
What SWAGameXR draws of one mob between two ticks. Kept per tick and reused, so the frames in between allocate nothing.
"
Class {
	#name : #SWAGameMobEntry,
	#superclass : #Object,
	#instVars : [
		'mob',
		'from',
		'to',
		'scale',
		'color',
		'wireColor',
		'energyRatio',
		'remains',
		'gait',
		'eating',
		'position'
	],
	#category : #'SWAGame-XR',
	#'squeak_changestamp' : '<historical>'
}

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/13/2026 11:07'
}
SWAGameMobEntry >> color [
	^ color
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/13/2026 11:07'
}
SWAGameMobEntry >> energyRatio [
	^ energyRatio
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/13/2026 11:07'
}
SWAGameMobEntry >> from [
	^ from
]

{
	#category : #initialization,
	#'squeak_changestamp' : 'MCPServer (jl) 11/13/2026 11:13'
}
SWAGameMobEntry >> from: fromPos to: toPos [
	"Copied into vectors of its own: the entry lives for many ticks, the positions handed in do not."
	from ifNil: [from := Vector3 new].
	to ifNil: [to := Vector3 new].
	from setPosition: fromPos.
	to setPosition: toPos.
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/13/2026 11:07'
}
SWAGameMobEntry >> gait [
	^ gait
]

{
	#category : #testing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/13/2026 11:07'
}
SWAGameMobEntry >> isBody [
	^ remains notNil
]

{
	#category : #testing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/13/2026 11:07'
}
SWAGameMobEntry >> isEating [
	^ eating == true
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/13/2026 11:07'
}
SWAGameMobEntry >> mob [
	^ mob
]

{
	#category : #initialization,
	#'squeak_changestamp' : 'MCPServer (jl) 11/13/2026 11:07'
}
SWAGameMobEntry >> mob: aMob [
	mob := aMob.
]

{
	#category : #interpolating,
	#'squeak_changestamp' : 'MCPServer (jl) 11/13/2026 11:13'
}
SWAGameMobEntry >> positionAt: t [
	"The same Vector3 every time, refilled; use it, do not keep it."
	position ifNil: [position := Vector3 new].
	^ position
		x: from x + ((to x - from x) * t)
		y: from y + ((to y - from y) * t)
		z: from z + ((to z - from z) * t)
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/13/2026 11:07'
}
SWAGameMobEntry >> remains [
	"nil for the living."
	^ remains
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/13/2026 11:07'
}
SWAGameMobEntry >> scale [
	^ scale
]

{
	#category : #initialization,
	#'squeak_changestamp' : 'MCPServer (jl) 11/13/2026 11:13'
}
SWAGameMobEntry >> setMob: aMob from: fromPos to: toPos scale: aNumber colors: rlColors gait: aGait remains: remainsOrNil [
	mob := aMob.
	self from: fromPos to: toPos.
	scale := aNumber.
	color := rlColors first.
	wireColor := rlColors second.
	energyRatio := (aMob energy / aMob maxEnergy asFloat) min: 1.0 max: 0.0.
	gait := aGait.
	remains := remainsOrNil.
	eating := aMob isEating.
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/13/2026 11:07'
}
SWAGameMobEntry >> to [
	^ to
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/13/2026 11:07'
}
SWAGameMobEntry >> wireColor [
	^ wireColor
]
