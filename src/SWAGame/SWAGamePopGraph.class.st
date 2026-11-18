"
Rabbit and fox counts over time, drawn into a texture on a slab.
"
Class {
	#name : #SWAGamePopGraph,
	#superclass : #SWAGameSlab,
	#instVars : [
		'rabbitHistory',
		'foxHistory',
		'maxSamples',
		'graphWidth',
		'graphHeight',
		'plane',
		'texture',
		'source',
		'dirty'
	],
	#category : #SWAGame,
	#'squeak_changestamp' : '<historical>'
}

{
	#category : #rendering,
	#'squeak_changestamp' : 'MCPServer (jl) 11/3/2026 14:31'
}
SWAGamePopGraph >> axisColor [

	^ Color gray: 0.6
]

{
	#category : #rendering,
	#'squeak_changestamp' : 'MCPServer (jl) 11/3/2026 14:31'
}
SWAGamePopGraph >> columnFor: ticksAgo in: aRectangle [

	^ aRectangle right - (ticksAgo * aRectangle width / maxSamples) rounded
]

{
	#category : #rendering,
	#'squeak_changestamp' : 'MCPServer (jl) 11/3/2026 14:31'
}
SWAGamePopGraph >> currentCount: aSeries [

	^ aSeries isEmpty ifTrue: [0] ifFalse: [aSeries last]
]

{
	#category : #initialization,
	#'squeak_changestamp' : 'MCPServer (MCPServer) 10/23/2026 12:28'
}
SWAGamePopGraph >> destroy [

	| oldTexture |
	oldTexture := texture.
	oldTexture ifNotNil: [
		self world ifNotNil: [:aWorld | aWorld addDeferredFrameMessage: [oldTexture unload]]].
	plane ifNotNil: [plane remove. plane := nil].
	texture := nil.
	source := nil.
]

{
	#category : #rendering,
	#'squeak_changestamp' : 'MCPServer (jl) 11/3/2026 14:31'
}
SWAGamePopGraph >> drawLegendIn: aRectangle font: aFont on: aCanvas [

	| x |
	x := aRectangle left + 20.
	{'Rabbits: ', (self currentCount: rabbitHistory) printString -> self rabbitColor.
	'Foxes: ', (self currentCount: foxHistory) printString -> self foxColor} do: [:entry |
		aCanvas fillRectangle: (x @ 8 extent: 16 @ 10) color: entry value.
		aCanvas drawString: entry key at: (x + 22) @ 4 font: aFont color: entry value.
		x := x + 22 + (aFont widthOfString: entry key) + 24].
]

{
	#category : #rendering,
	#'squeak_changestamp' : 'MCPServer (jl) 11/3/2026 14:31'
}
SWAGamePopGraph >> drawXAxisIn: aRectangle font: aFont on: aCanvas [

	| title |
	aCanvas line: aRectangle bottomLeft to: aRectangle bottomRight width: 1 color: self axisColor.
	0 to: 4 do: [:i | | ticksAgo x label |
		ticksAgo := maxSamples * (4 - i) // 4.
		x := self columnFor: ticksAgo in: aRectangle.
		aCanvas line: x @ aRectangle bottom to: x @ (aRectangle bottom + 4) width: 1 color: self axisColor.
		label := ticksAgo = 0 ifTrue: ['now'] ifFalse: [ticksAgo negated printString].
		aCanvas
			drawString: label
			at: (x - ((aFont widthOfString: label) // 2)) @ (aRectangle bottom + 4)
			font: aFont
			color: self labelColor].
	title := 'ticks'.
	aCanvas
		drawString: title
		at: (aRectangle center x - ((aFont widthOfString: title) // 2)) @ (aRectangle bottom + 4 + aFont height)
		font: aFont
		color: self labelColor.
]

{
	#category : #rendering,
	#'squeak_changestamp' : 'MCPServer (jl) 11/3/2026 14:31'
}
SWAGamePopGraph >> drawYAxisIn: aRectangle maxPop: maxPop font: aFont on: aCanvas [

	0 to: 4 do: [:i | | count y label |
		count := maxPop * i // 4.
		y := self rowFor: count maxPop: maxPop in: aRectangle.
		aCanvas line: aRectangle left @ y to: aRectangle right @ y width: 1 color: self gridColor.
		label := count printString.
		aCanvas
			drawString: label
			at: (aRectangle left - 6 - (aFont widthOfString: label)) @ (y - (aFont height // 2))
			font: aFont
			color: self labelColor].
	aCanvas line: aRectangle topLeft to: aRectangle bottomLeft width: 1 color: self axisColor.
	aCanvas drawString: 'mobs' at: 4 @ 4 font: aFont color: self labelColor.
]

{
	#category : #initialization,
	#'squeak_changestamp' : 'MCPServer 5/18/2026 18:14'
}
SWAGamePopGraph >> ensurePlane [
	"Create the display plane sized to match the slab. Uses SWAGameDisplayPlane (no collision)."
	plane ifNotNil: [^ self].
	plane := SWAGameDisplayPlane new
		position: (Vector3 x: 0 y: 0.16 z: 0);
		scale: (Vector3 x: 10 y: 1 z: 5);
		yourself.
	self addChild: plane
]

{
	#category : #rendering,
	#'squeak_changestamp' : 'MCPServer (MCPServer (MCPServer)) 10/23/2026 11:02'
}
SWAGamePopGraph >> ensureTexture [
	"Forms are BGRA, which the morphicPanel shader swizzles back."
	source ifNotNil: [^ self].
	source := SRTextureSourceForm width: graphWidth height: graphHeight.
	texture := SRTexture withSource: source.
	self ensurePlane.
	plane material
		shader: SRShader morphicPanel;
		texture: texture.
]

{
	#category : #rendering,
	#'squeak_changestamp' : 'MCPServer (jl) 11/3/2026 14:31'
}
SWAGamePopGraph >> foxColor [

	^ Color r: 0.9 g: 0.5 b: 0.1
]

{
	#category : #rendering,
	#'squeak_changestamp' : 'MCPServer (jl) 11/3/2026 14:31'
}
SWAGamePopGraph >> gridColor [

	^ Color r: 0.2 g: 0.2 b: 0.25
]

{
	#category : #initialization,
	#'squeak_changestamp' : 'MCPServer (jl) 11/3/2026 14:31'
}
SWAGamePopGraph >> initialize [

	super initialize.
	rabbitHistory := OrderedCollection new.
	foxHistory := OrderedCollection new.
	maxSamples := 200.
	graphWidth := 600.
	graphHeight := 300.
	dirty := false.
	slabWidth := 10.
	slabHeight := 5.
	slabDepth := 0.3.
]

{
	#category : #rendering,
	#'squeak_changestamp' : 'MCPServer (jl) 11/3/2026 14:31'
}
SWAGamePopGraph >> labelColor [

	^ Color gray: 0.8
]

{
	#category : #rendering,
	#'squeak_changestamp' : 'MCPServer (jl) 11/3/2026 14:31'
}
SWAGamePopGraph >> labelFont [

	^ (TextStyle named: #BitstreamVeraSans) fontOfPointSize: 9
]

{
	#category : #rendering,
	#'squeak_changestamp' : 'MCPServer (jl) 11/3/2026 14:31'
}
SWAGamePopGraph >> maxPop [
	"Rounded up to a multiple of four so the four grid lines get whole numbers."

	| maxPop |
	maxPop := 10.
	rabbitHistory do: [:v | maxPop := maxPop max: v].
	foxHistory do: [:v | maxPop := maxPop max: v].
	^ (maxPop / 4) ceiling * 4
]

{
	#category : #events,
	#'squeak_changestamp' : 'MCPServer 5/18/2026 18:00'
}
SWAGamePopGraph >> onRaycast: aSRRayIntersectionResult [
	"Allow grabbing the graph slab."
	super onRaycast: aSRRayIntersectionResult
]

{
	#category : #rendering,
	#'squeak_changestamp' : 'MCPServer (jl) 11/3/2026 14:31'
}
SWAGamePopGraph >> plotBounds [
	"Margins leave room for the axis labels on the left and bottom and the legend on top."

	^ 48 @ 34 corner: (graphWidth - 24) @ (graphHeight - 46)
]

{
	#category : #rendering,
	#'squeak_changestamp' : 'MCPServer (jl) 11/3/2026 14:31'
}
SWAGamePopGraph >> plotSeries: aSeries color: aColor maxPop: maxPop in: aRectangle on: aCanvas [

	| n |
	n := aSeries size.
	2 to: n do: [:i |
		aCanvas
			line: (self columnFor: n - i + 1 in: aRectangle) @ (self rowFor: (aSeries at: i - 1) maxPop: maxPop in: aRectangle)
			to: (self columnFor: n - i in: aRectangle) @ (self rowFor: (aSeries at: i) maxPop: maxPop in: aRectangle)
			width: 2
			color: aColor].
]

{
	#category : #rendering,
	#'squeak_changestamp' : 'MCPServer (jl) 11/3/2026 14:31'
}
SWAGamePopGraph >> rabbitColor [

	^ Color white
]

{
	#category : #updating,
	#'squeak_changestamp' : 'MCPServer 5/18/2026 17:42'
}
SWAGamePopGraph >> recordRabbits: rabbitCount foxes: foxCount [
	rabbitHistory add: rabbitCount.
	foxHistory add: foxCount.
	rabbitHistory size > maxSamples ifTrue: [rabbitHistory removeFirst].
	foxHistory size > maxSamples ifTrue: [foxHistory removeFirst].
	dirty := true
]

{
	#category : #rendering,
	#'squeak_changestamp' : 'MCPServer (jl) 11/3/2026 14:31'
}
SWAGamePopGraph >> redraw [

	| maxPop plot font |
	maxPop := self maxPop.
	plot := self plotBounds.
	font := self labelFont.
	self ensureTexture.
	source editDo: [:each | | canvas |
		each fillColor: (Color r: 0.08 g: 0.08 b: 0.12).
		canvas := each form getCanvas.
		self drawYAxisIn: plot maxPop: maxPop font: font on: canvas.
		self drawXAxisIn: plot font: font on: canvas.
		self plotSeries: rabbitHistory color: self rabbitColor maxPop: maxPop in: plot on: canvas.
		self plotSeries: foxHistory color: self foxColor maxPop: maxPop in: plot on: canvas.
		self drawLegendIn: plot font: font on: canvas].
]

{
	#category : #rendering,
	#'squeak_changestamp' : 'MCPServer (MCPServer (MCPServer)) 10/23/2026 11:02'
}
SWAGamePopGraph >> renderOn: aSRRenderer [

	dirty ifTrue: [
		self redraw.
		dirty := false].
	Raylib rlPushMatrix;
		rlMultMatrixfMatf: self globalTransform transposed.
	self renderSlab.
	Raylib rlPopMatrix.
	self ensurePlane.
]

{
	#category : #rendering,
	#'squeak_changestamp' : 'MCPServer (jl) 11/3/2026 14:31'
}
SWAGamePopGraph >> rowFor: aCount maxPop: maxPop in: aRectangle [

	^ aRectangle bottom - 1 - (aCount * (aRectangle height - 1) / maxPop) rounded
]
