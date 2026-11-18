"
One sample per frame of the selected mob: the interpolation t, the speed it is drawn at and the speed it is simulated at. Frames where the drawn speed goes negative are visible jitter.
"
Class {
	#name : #SWAGameMobTraceGraph,
	#superclass : #SWAGameSlab,
	#instVars : [
		'mob',
		'samples',
		'maxSamples',
		'lastX',
		'lastZ',
		'graphWidth',
		'graphHeight',
		'plane',
		'texture',
		'source',
		'dirty',
		'lastRedraw'
	],
	#category : #SWAGame,
	#'squeak_changestamp' : '<historical>'
}

{
	#category : #colors,
	#'squeak_changestamp' : 'MCPServer (jl) 11/3/2026 15:09'
}
SWAGameMobTraceGraph >> axisColor [

	^ Color gray: 0.6
]

{
	#category : #colors,
	#'squeak_changestamp' : 'MCPServer (jl) 11/3/2026 15:09'
}
SWAGameMobTraceGraph >> backgroundColor [

	^ Color r: 0.08 g: 0.08 b: 0.12
]

{
	#category : #statistics,
	#'squeak_changestamp' : 'MCPServer (jl) 11/3/2026 15:09'
}
SWAGameMobTraceGraph >> backwardFrames [
	"Below a hundredth of a cell per second is rounding, not a step back."

	^ samples count: [:each | (each at: 4) < -0.01]
]

{
	#category : #recording,
	#'squeak_changestamp' : 'MCPServer (jl) 11/3/2026 15:09'
}
SWAGameMobTraceGraph >> clearFor: aMob [

	mob := aMob.
	samples removeAll.
	lastX := lastZ := nil.
	dirty := true.
]

{
	#category : #rendering,
	#'squeak_changestamp' : 'MCPServer (jl) 11/3/2026 15:09'
}
SWAGameMobTraceGraph >> columnFor: framesAgo in: aRectangle [

	^ aRectangle right - (framesAgo * aRectangle width / maxSamples) rounded
]

{
	#category : #'initialize-release',
	#'squeak_changestamp' : 'MCPServer (jl) 11/3/2026 15:09'
}
SWAGameMobTraceGraph >> destroy [

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
	#'squeak_changestamp' : 'MCPServer (jl) 11/3/2026 15:09'
}
SWAGameMobTraceGraph >> drawLegendIn: aRectangle font: aFont on: aCanvas [

	| x stats |
	x := aRectangle left.
	{'t' -> self tColor. 'drawn cells/s' -> self drawnColor. 'simulated cells/s' -> self simulatedColor. 'tick' -> self tickColor} do: [:entry |
		aCanvas fillRectangle: (x @ 8 extent: 16 @ 10) color: entry value.
		aCanvas drawString: entry key at: (x + 22) @ 4 font: aFont color: entry value.
		x := x + 22 + (aFont widthOfString: entry key) + 20].
	stats := (mob ifNil: ['no mob selected'] ifNotNil: [mob species, ' ', mob identityHash printString]),
		'   ticks ', self tickCount printString,
		'   backward frames ', self backwardFrames printString,
		'   frame ms ', (self meanFrameMilliseconds printShowingDecimalPlaces: 1),
		' / max ', (self maxFrameMilliseconds printShowingDecimalPlaces: 1).
	aCanvas drawString: stats at: aRectangle left @ (8 + aFont height) font: aFont color: self labelColor.
]

{
	#category : #rendering,
	#'squeak_changestamp' : 'MCPServer (jl) 11/3/2026 15:09'
}
SWAGameMobTraceGraph >> drawLevels: anArray from: low to: high in: aRectangle font: aFont on: aCanvas [

	anArray do: [:value | | y label |
		y := self rowFor: value from: low to: high in: aRectangle.
		aCanvas line: aRectangle left @ y to: aRectangle right @ y width: 1 color: self gridColor.
		label := value printShowingDecimalPlaces: 1.
		aCanvas
			drawString: label
			at: (aRectangle left - 6 - (aFont widthOfString: label)) @ (y - (aFont height // 2))
			font: aFont
			color: self labelColor].
	aCanvas line: aRectangle topLeft to: aRectangle bottomLeft width: 1 color: self axisColor.
]

{
	#category : #rendering,
	#'squeak_changestamp' : 'MCPServer (jl) 11/3/2026 15:09'
}
SWAGameMobTraceGraph >> drawTicksIn: aRectangle on: aCanvas [

	| n |
	n := samples size.
	samples withIndexDo: [:each :i | | x |
		(each at: 3) ifTrue: [
			x := self columnFor: n - i in: aRectangle.
			aCanvas line: x @ aRectangle top to: x @ aRectangle bottom width: 1 color: self tickColor]].
]

{
	#category : #colors,
	#'squeak_changestamp' : 'MCPServer (jl) 11/3/2026 15:09'
}
SWAGameMobTraceGraph >> drawnColor [

	^ Color yellow
]

{
	#category : #rendering,
	#'squeak_changestamp' : 'MCPServer (jl) 11/3/2026 15:09'
}
SWAGameMobTraceGraph >> ensurePlane [

	plane ifNotNil: [^ self].
	plane := SWAGameDisplayPlane new
		position: (Vector3 x: 0 y: 0.16 z: 0);
		scale: (Vector3 x: 10 y: 1 z: 5);
		yourself.
	self addChild: plane.
]

{
	#category : #rendering,
	#'squeak_changestamp' : 'MCPServer (jl) 11/3/2026 15:09'
}
SWAGameMobTraceGraph >> ensureTexture [
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
	#category : #colors,
	#'squeak_changestamp' : 'MCPServer (jl) 11/3/2026 15:09'
}
SWAGameMobTraceGraph >> gridColor [

	^ Color r: 0.2 g: 0.2 b: 0.25
]

{
	#category : #initialize,
	#'squeak_changestamp' : 'MCPServer (jl) 11/3/2026 15:09'
}
SWAGameMobTraceGraph >> initialize [

	super initialize.
	samples := OrderedCollection new.
	maxSamples := 240.
	graphWidth := 600.
	graphHeight := 300.
	dirty := false.
	slabWidth := 10.
	slabHeight := 5.
	slabDepth := 0.3.
]

{
	#category : #rendering,
	#'squeak_changestamp' : 'MCPServer (jl) 11/3/2026 15:09'
}
SWAGameMobTraceGraph >> isRedrawDue [
	"Drawing the Form and uploading it every frame would cost more than the graph is worth at 300 fps."

	^ lastRedraw isNil or: [(Time millisecondsSince: lastRedraw) >= 100]
]

{
	#category : #colors,
	#'squeak_changestamp' : 'MCPServer (jl) 11/3/2026 15:09'
}
SWAGameMobTraceGraph >> labelColor [

	^ Color gray: 0.8
]

{
	#category : #rendering,
	#'squeak_changestamp' : 'MCPServer (jl) 11/3/2026 15:09'
}
SWAGameMobTraceGraph >> labelFont [

	^ (TextStyle named: #BitstreamVeraSans) fontOfPointSize: 9
]

{
	#category : #statistics,
	#'squeak_changestamp' : 'MCPServer (jl) 11/3/2026 15:09'
}
SWAGameMobTraceGraph >> maxFrameMilliseconds [

	^ samples inject: 0.0 into: [:max :each | max max: (each at: 1)]
]

{
	#category : #statistics,
	#'squeak_changestamp' : 'MCPServer (jl) 11/3/2026 15:09'
}
SWAGameMobTraceGraph >> meanFrameMilliseconds [

	samples isEmpty ifTrue: [^ 0.0].
	^ (samples inject: 0.0 into: [:sum :each | sum + (each at: 1)]) / samples size
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/3/2026 15:09'
}
SWAGameMobTraceGraph >> mob [

	^ mob
]

{
	#category : #rendering,
	#'squeak_changestamp' : 'MCPServer (jl) 11/3/2026 15:09'
}
SWAGameMobTraceGraph >> plotBounds [

	^ 48 @ 46 corner: (graphWidth - 24) @ (graphHeight - 34)
]

{
	#category : #rendering,
	#'squeak_changestamp' : 'MCPServer (jl) 11/3/2026 15:09'
}
SWAGameMobTraceGraph >> plotSeries: anIndex from: low to: high in: aRectangle color: aColor on: aCanvas [

	| n |
	n := samples size.
	2 to: n do: [:i |
		aCanvas
			line: (self columnFor: n - i + 1 in: aRectangle) @ (self rowFor: ((samples at: i - 1) at: anIndex) from: low to: high in: aRectangle)
			to: (self columnFor: n - i in: aRectangle) @ (self rowFor: ((samples at: i) at: anIndex) from: low to: high in: aRectangle)
			width: 1
			color: aColor].
]

{
	#category : #recording,
	#'squeak_changestamp' : 'MCPServer (jl) 11/13/2026 11:13'
}
SWAGameMobTraceGraph >> recordFrameOf: aMob entry: anEntry milliseconds: ms t: t ticked: aBoolean worldScale: aScale [
	"The drawn speed is signed along the segment the mob is drawn on, so a step back shows below zero."
	| from to position x z sx sz length dx dz drawnSpeed |
	aMob == mob ifFalse: [self clearFor: aMob].
	anEntry ifNil: [^ self].
	from := anEntry from.
	to := anEntry to.
	sx := to x - from x.
	sz := to z - from z.
	position := anEntry positionAt: t.
	x := position x.
	z := position z.
	drawnSpeed := 0.0.
	(lastX notNil and: [ms > 0]) ifTrue: [
		dx := x - lastX.
		dz := z - lastZ.
		length := ((sx * sx) + (sz * sz)) sqrt.
		drawnSpeed := length > 1.0e-6
			ifTrue: [(dx * sx) + (dz * sz) / length]
			ifFalse: [((dx * dx) + (dz * dz)) sqrt].
		drawnSpeed := drawnSpeed / aScale / (ms / 1000.0)].
	lastX := x.
	lastZ := z.
	samples add: {ms asFloat. t. aBoolean. drawnSpeed. ((aMob vx * aMob vx) + (aMob vz * aMob vz)) sqrt}.
	samples size > maxSamples ifTrue: [samples removeFirst].
	dirty := true.
]

{
	#category : #rendering,
	#'squeak_changestamp' : 'MCPServer (jl) 11/3/2026 15:09'
}
SWAGameMobTraceGraph >> redraw [

	| font plot tPlot speedPlot range |
	font := self labelFont.
	plot := self plotBounds.
	tPlot := self tBoundsIn: plot.
	speedPlot := self speedBoundsIn: plot.
	range := self speedRange.
	self ensureTexture.
	source editDo: [:each | | canvas |
		each fillColor: self backgroundColor.
		canvas := each form getCanvas.
		self drawTicksIn: tPlot on: canvas.
		self drawTicksIn: speedPlot on: canvas.
		self drawLevels: #(0.0 1.0) from: 0.0 to: 1.0 in: tPlot font: font on: canvas.
		self drawLevels: {range key. 0.0. range value} asSet asSortedCollection asArray from: range key to: range value in: speedPlot font: font on: canvas.
		self plotSeries: 2 from: 0.0 to: 1.0 in: tPlot color: self tColor on: canvas.
		self plotSeries: 5 from: range key to: range value in: speedPlot color: self simulatedColor on: canvas.
		self plotSeries: 4 from: range key to: range value in: speedPlot color: self drawnColor on: canvas.
		canvas drawString: 'frames' at: (plot center x - 15) @ (plot bottom + 4) font: font color: self labelColor.
		self drawLegendIn: plot font: font on: canvas].
]

{
	#category : #rendering,
	#'squeak_changestamp' : 'MCPServer (jl) 11/3/2026 15:09'
}
SWAGameMobTraceGraph >> renderOn: aSRRenderer [

	(dirty and: [self isRedrawDue]) ifTrue: [
		self redraw.
		dirty := false.
		lastRedraw := Time millisecondClockValue].
	Raylib rlPushMatrix;
		rlMultMatrixfMatf: self globalTransform transposed.
	self renderSlab.
	Raylib rlPopMatrix.
	self ensurePlane.
]

{
	#category : #rendering,
	#'squeak_changestamp' : 'MCPServer (jl) 11/3/2026 15:09'
}
SWAGameMobTraceGraph >> rowFor: aValue from: low to: high in: aRectangle [

	^ aRectangle bottom - 1 - ((aValue - low) * (aRectangle height - 1) / (high - low)) rounded
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/3/2026 15:09'
}
SWAGameMobTraceGraph >> samples [

	^ samples
]

{
	#category : #colors,
	#'squeak_changestamp' : 'MCPServer (jl) 11/3/2026 15:09'
}
SWAGameMobTraceGraph >> simulatedColor [

	^ Color r: 0.3 g: 0.9 b: 0.3
]

{
	#category : #rendering,
	#'squeak_changestamp' : 'MCPServer (jl) 11/3/2026 15:09'
}
SWAGameMobTraceGraph >> speedBoundsIn: aRectangle [

	^ aRectangle left @ (aRectangle top + (aRectangle height // 3) + 14) corner: aRectangle bottomRight
]

{
	#category : #rendering,
	#'squeak_changestamp' : 'MCPServer (jl) 11/3/2026 15:09'
}
SWAGameMobTraceGraph >> speedRange [
	"Answers low -> high, always spanning zero and at least one cell per second."
	| low high |
	low := 0.0.
	high := 1.0.
	samples do: [:each |
		low := low min: (each at: 4).
		high := (high max: (each at: 4)) max: (each at: 5)].
	^ low -> high
]

{
	#category : #rendering,
	#'squeak_changestamp' : 'MCPServer (jl) 11/3/2026 15:09'
}
SWAGameMobTraceGraph >> tBoundsIn: aRectangle [

	^ aRectangle topLeft corner: aRectangle right @ (aRectangle top + (aRectangle height // 3))
]

{
	#category : #colors,
	#'squeak_changestamp' : 'MCPServer (jl) 11/3/2026 15:09'
}
SWAGameMobTraceGraph >> tColor [

	^ Color cyan
]

{
	#category : #colors,
	#'squeak_changestamp' : 'MCPServer (jl) 11/3/2026 15:09'
}
SWAGameMobTraceGraph >> tickColor [

	^ Color r: 0.3 g: 0.3 b: 0.45
]

{
	#category : #statistics,
	#'squeak_changestamp' : 'MCPServer (jl) 11/3/2026 15:09'
}
SWAGameMobTraceGraph >> tickCount [

	^ samples count: [:each | each at: 3]
]
