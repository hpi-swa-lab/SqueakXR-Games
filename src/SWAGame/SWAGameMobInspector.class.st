"
The selected mob's properties on a slab.
"
Class {
	#name : #SWAGameMobInspector,
	#superclass : #SWAGameSlab,
	#instVars : [
		'mob',
		'propertyLabels',
		'textScale',
		'rowSpacing',
		'panelHeight',
		'panelWidth'
	],
	#category : #SWAGame,
	#'squeak_changestamp' : '<historical>'
}

{
	#category : #specs,
	#'squeak_changestamp' : 'MCPServer (jl) 11/17/2026 14:35'
}
SWAGameMobInspector class >> propertySelectors [
	"Properties to display in the inspector."
	^ #(
		species
		coatDescription
		energy
		maxEnergy
		age
		lifespan
		weight
		walkSpeed
		runSpeed
		eatTime
		startingEnergy
		burnRate
		reproduceThreshold
		reproduceChance
		reproduceCost
		offspringEnergy
		eatGain
		huntRadius
	)
]

{
	#category : #building,
	#'squeak_changestamp' : 'MCPServer 5/18/2026 18:46'
}
SWAGameMobInspector >> addLabel: aString atRow: rowOffset color: aColor [
	"Add a text label at the given row offset (along Z axis), slightly above the slab."
	| label |
	label := SRTextField new
		text: aString;
		color: aColor;
		position: (Vector3 x: panelWidth / -2 + 0.3 y: 0.2 z: rowOffset);
		scale: (Vector3 one * textScale);
		yourself.
	self addChild: label.
	propertyLabels add: label.
	^ label
]

{
	#category : #initialization,
	#'squeak_changestamp' : 'MCPServer 5/18/2026 18:34'
}
SWAGameMobInspector >> initialize [
	super initialize.
	propertyLabels := OrderedCollection new.
	textScale := 0.6.
	rowSpacing := 0.8.
	panelHeight := 0.
	panelWidth := 12.0.
	slabWidth := panelWidth.
	slabHeight := 0.
	slabDepth := 0.3
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 5/18/2026 16:28'
}
SWAGameMobInspector >> mob [
	^ mob
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 5/18/2026 16:28'
}
SWAGameMobInspector >> mob: aMob [
	mob := aMob.
	self rebuild
]

{
	#category : #events,
	#'squeak_changestamp' : 'MCPServer 5/18/2026 16:37'
}
SWAGameMobInspector >> onRaycast: aSRRayIntersectionResult [
	"Allow grabbing and moving the inspector panel."
	super onRaycast: aSRRayIntersectionResult
]

{
	#category : #building,
	#'squeak_changestamp' : 'MCPServer (jl) 11/17/2026 14:35'
}
SWAGameMobInspector >> rebuild [
	"Remove old labels, create fresh rows for current mob."
	| props rowZ headerColor valueColor totalHeight |
	
	"Remove old children"
	propertyLabels do: [:lbl | lbl remove].
	propertyLabels := OrderedCollection new.
	
	mob ifNil: [
		slabWidth := panelWidth. slabHeight := 0.
		^ self].
	
	props := self class propertySelectors select: [:sel | mob respondsTo: sel].
	headerColor := mob color.
	valueColor := Color white.
	
	"Calculate total height first"
	totalHeight := (props size + 1) * rowSpacing + (rowSpacing * 0.3) + rowSpacing.
	panelHeight := totalHeight.
	slabWidth := panelWidth.
	slabHeight := panelHeight.
	
	"Start from top of slab"
	rowZ := panelHeight / -2 + (rowSpacing * 0.5).
	
	"Title row"
	self addLabel: (mob species asString capitalized, ' Inspector')
		atRow: rowZ color: headerColor.
	rowZ := rowZ + rowSpacing.
	
	"Separator"
	rowZ := rowZ + (rowSpacing * 0.3).
	
	"Property rows"
	props do: [:sel |
		| val text |
		val := [mob perform: sel] on: Error do: [:e | '?'].
		text := sel asString, ': ', val printString.
		self addLabel: text atRow: rowZ color: valueColor.
		rowZ := rowZ + rowSpacing]
]

{
	#category : #rendering,
	#'squeak_changestamp' : 'MCPServer 5/18/2026 18:34'
}
SWAGameMobInspector >> renderOn: aSRRenderer [
	panelHeight = 0 ifTrue: [^ self].
	Raylib rlPushMatrix;
		rlMultMatrixfMatf: self globalTransform transposed.
	self renderSlab.
	Raylib rlPopMatrix
]

{
	#category : #updating,
	#'squeak_changestamp' : 'MCPServer 5/18/2026 16:28'
}
SWAGameMobInspector >> update [
	"Refresh property values without full rebuild."
	| props idx |
	mob ifNil: [^ self].
	mob alive ifFalse: [^ self].
	
	props := self class propertySelectors.
	idx := 2. "Skip title label"
	props do: [:sel |
		| val text label |
		val := [mob perform: sel] on: Error do: [:e | '?'].
		text := sel asString, ': ', val printString.
		idx <= propertyLabels size ifTrue: [
			label := propertyLabels at: idx.
			label text: text].
		idx := idx + 1]
]
