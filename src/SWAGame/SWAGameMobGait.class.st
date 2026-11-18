"
Heading, stride phase and leg swing of one mob, each kept at the last two simulation ticks so the renderer can interpolate between them per frame.
"
Class {
	#name : #SWAGameMobGait,
	#superclass : #Object,
	#instVars : [
		'yawFrom',
		'yawTo',
		'phaseFrom',
		'phaseTo',
		'swingFrom',
		'swingTo'
	],
	#category : #'SWAGame-XR',
	#'squeak_changestamp' : '<historical>'
}

{
	#category : #stepping,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 15:26'
}
SWAGameMobGait >> advance: cells in: seconds headingX: vx z: vz stride: strideCells [
	"One simulation tick: cells walked horizontally in seconds, while heading along vx vz."
	| speed target |
	yawFrom := yawTo.
	phaseFrom := phaseTo.
	swingFrom := swingTo.
	(vx * vx) + (vz * vz) > 0.0025 ifTrue: [
		target := vx arcTan: vz.
		[target - yawFrom > Float pi] whileTrue: [target := target - Float twoPi].
		[yawFrom - target > Float pi] whileTrue: [target := target + Float twoPi].
		yawTo := yawFrom + ((target - yawFrom) * 0.5)].
	phaseTo := phaseFrom + (cells / strideCells * Float twoPi).
	speed := cells / seconds.
	target := speed < 0.05
		ifTrue: [0.0]
		ifFalse: [0.45 + (0.12 * speed) min: 0.9].
	swingTo := swingFrom + ((target - swingFrom) * 0.5).
	self wrap.
]

{
	#category : #initialization,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 15:26'
}
SWAGameMobGait >> initialize [
	super initialize.
	yawFrom := yawTo := 0.0.
	phaseFrom := phaseTo := 0.0.
	swingFrom := swingTo := 0.0.
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 15:26'
}
SWAGameMobGait >> phaseAt: t [
	^ phaseFrom + ((phaseTo - phaseFrom) * t)
]

{
	#category : #stepping,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 15:26'
}
SWAGameMobGait >> settle [
	"A body stops where it fell. Without this it would keep turning between the last two ticks of its life."
	yawFrom := yawTo.
	phaseFrom := phaseTo.
	swingFrom := swingTo := 0.0.
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 15:26'
}
SWAGameMobGait >> swingAt: t [
	^ swingFrom + ((swingTo - swingFrom) * t)
]

{
	#category : #stepping,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 15:26'
}
SWAGameMobGait >> wrap [
	"Keeps the angles small; both ends move by whole turns, so the interpolation between them is unchanged."
	| turns |
	phaseFrom > 1000.0 ifTrue: [
		turns := (phaseFrom / Float twoPi) floor * Float twoPi.
		phaseFrom := phaseFrom - turns.
		phaseTo := phaseTo - turns].
	yawFrom abs > Float twoPi ifTrue: [
		turns := (yawFrom / Float twoPi) truncated * Float twoPi.
		yawFrom := yawFrom - turns.
		yawTo := yawTo - turns].
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 15:26'
}
SWAGameMobGait >> yawAt: t [
	^ yawFrom + ((yawTo - yawFrom) * t)
]
