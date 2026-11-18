"
Morphic sliders for the species preferences, for tuning without the headset.
"
Class {
	#name : #SWAGameConfigPanel,
	#superclass : #Model,
	#instVars : [
		'species',
		'sliders',
		'valueLabels'
	],
	#category : #SWAGame,
	#'squeak_changestamp' : '<historical>'
}

{
	#category : #opening,
	#'squeak_changestamp' : 'MCPServer 5/18/2026 15:41'
}
SWAGameConfigPanel class >> open [
	"SWAGameConfigPanel open"
	^ self new open
]

{
	#category : #specs,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 12:31'
}
SWAGameConfigPanel class >> prefSpecsFor: aSpeciesClass [
	"Return an array of {label. getter. min. max. quantum} for each preference."
	| specs |
	specs := OrderedCollection new.
	specs add: {'Walk Speed'. #walkSpeed. 0.1. 5. 0.05}.
	specs add: {'Run Speed'. #runSpeed. 0.5. 10. 0.1}.
	specs add: {'Rest Time'. #restTime. 0. 20. 0.5}.
	specs add: {'Eat Time'. #eatTime. 0. 30. 0.5}.
	specs add: {'Max Energy'. #maxEnergy. 10. 500. 5}.
	specs add: {'Starting Energy'. #startingEnergy. 5. 300. 5}.
	specs add: {'Burn Rate'. #burnRate. 0.1. 10. 0.1}.
	specs add: {'Reproduce Threshold'. #reproduceThreshold. 10. 400. 5}.
	specs add: {'Reproduce Chance'. #reproduceChance. 0.1. 20. 0.1}.
	specs add: {'Reproduce Cost'. #reproduceCost. 5. 200. 5}.
	specs add: {'Offspring Energy'. #offspringEnergy. 5. 200. 5}.
	specs add: {'Eat Gain'. #eatGain. 1. 100. 1}.
	(aSpeciesClass includesSelector: #huntRadius) ifTrue: [
		specs add: {'Hunt Radius'. #huntRadius. 0. 20. 1}].
	(aSpeciesClass class includesSelector: #territoryRadius) ifTrue: [
		specs add: {'Territory Radius'. #territoryRadius. 0. 20. 1}].
	(aSpeciesClass class includesSelector: #detectionRange) ifTrue: [
		specs add: {'Detection Range'. #detectionRange. 1. 30. 1}].
	^ specs
]

{
	#category : #scenarios,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:16'
}
SWAGameConfigPanel >> browseScenarios [
	SWAGameScenario directory assureExistence.
	FileList openOn: SWAGameScenario directory.
]

{
	#category : #building,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:16'
}
SWAGameConfigPanel >> buildPanel [
	| panel |
	panel := Morph new
		color: Color transparent;
		layoutPolicy: TableLayout new;
		listDirection: #topToBottom;
		cellInset: 2;
		layoutInset: 5;
		hResizing: #spaceFill;
		vResizing: #spaceFill;
		yourself.
	panel addMorphBack: (SimpleButtonMorph new
		label: 'Scenarios...';
		target: self;
		actionSelector: #scenarioMenu;
		yourself).
	species do: [:sp |
		panel addMorphBack: (self buildSectionFor: sp)].
	^ panel
]

{
	#category : #building,
	#'squeak_changestamp' : 'MCPServer 5/18/2026 15:56'
}
SWAGameConfigPanel >> buildSectionFor: aSpeciesClass [
	| section header specs |
	section := Morph new
		color: Color transparent;
		layoutPolicy: TableLayout new;
		listDirection: #topToBottom;
		cellInset: 2;
		layoutInset: 4;
		hResizing: #spaceFill;
		vResizing: #shrinkWrap;
		yourself.
	header := StringMorph new
		contents: aSpeciesClass name;
		font: (StrikeFont familyName: 'Bitmap DejaVu Sans' pointSize: 24);
		emphasis: TextEmphasis bold emphasisCode;
		yourself.
	section addMorphBack: header.
	specs := self class prefSpecsFor: aSpeciesClass.
	specs do: [:spec |
		section addMorphBack: (self buildSliderRow: spec for: aSpeciesClass)].
	^ section
]

{
	#category : #building,
	#'squeak_changestamp' : 'MCPServer 5/18/2026 16:14'
}
SWAGameConfigPanel >> buildSliderRow: spec for: aSpeciesClass [
	"spec is {label. getter. min. max. quantum}"
	| row slider inputField getter min max quantum currentValue key labelMorph labelBox txtSel accSel |
	getter := spec second.
	min := spec third.
	max := spec fourth.
	quantum := spec fifth.
	currentValue := aSpeciesClass perform: getter.
	key := aSpeciesClass name, '-', getter.
	txtSel := ('txt_', aSpeciesClass name, '_', getter) asSymbol.
	accSel := ('acc_', aSpeciesClass name, '_', getter, ':') asSymbol.

	row := Morph new
		color: Color transparent;
		layoutPolicy: TableLayout new;
		listDirection: #leftToRight;
		cellInset: 6;
		hResizing: #spaceFill;
		vResizing: #rigid;
		height: 50;
		yourself.

	"Label in fixed-size box"
	labelMorph := StringMorph new contents: spec first.
	labelBox := Morph new
		color: Color transparent;
		hResizing: #rigid;
		vResizing: #spaceFill;
		width: 260;
		yourself.
	labelBox addMorph: labelMorph.
	row addMorphBack: labelBox.

	"Slider"
	slider := Slider new
		minimumValue: min;
		maximumValue: max;
		quantum: quantum;
		orientation: #horizontal;
		extent: 300@30;
		hResizing: #rigid;
		vResizing: #rigid;
		color: Color veryLightGray;
		yourself.
	sliders at: key put: slider.
	slider value: currentValue.
	slider on: self getValue: (self getterFor: key) setValue: (self setterFor: key).
	row addMorphBack: slider.

	"Editable number field"
	inputField := PluggableTextMorph
		on: self text: txtSel accept: accSel
		readSelection: nil menu: nil.
	inputField
		acceptOnCR: true;
		hideScrollBarsIndefinitely;
		minimumHeight: 0;
		hResizing: #rigid;
		vResizing: #rigid;
		height: 30;
		width: 100.
	row addMorphBack: inputField.

	^ row
]

{
	#category : #private,
	#'squeak_changestamp' : 'MCPServer 5/18/2026 16:02'
}
SWAGameConfigPanel >> doesNotUnderstand: aMessage [
	"Route slider and text field messages to the appropriate species class.
	 Slider getter: get_ClassName_prefName
	 Slider setter: set_ClassName_prefName:
	 Text getter:   txt_ClassName_prefName
	 Text setter:   acc_ClassName_prefName:"
	| sel body parts className prefName speciesClass |
	sel := aMessage selector.
	
	"Slider getter"
	(sel beginsWith: 'get_') ifTrue: [
		body := sel allButFirst: 4.
		parts := body findTokens: '_'.
		className := parts first.
		prefName := parts second.
		speciesClass := Smalltalk at: className asSymbol.
		^ speciesClass perform: prefName asSymbol].
	
	"Slider setter"
	(sel beginsWith: 'set_') ifTrue: [
		| key getterSel newVal |
		body := (sel allButFirst: 4) allButLast: 1.
		parts := body findTokens: '_'.
		className := parts first.
		prefName := parts second.
		newVal := aMessage arguments first.
		speciesClass := Smalltalk at: className asSymbol.
		speciesClass perform: (prefName, ':') asSymbol with: newVal.
		key := className, '-', prefName.
		getterSel := ('get_', className, '_', prefName) asSymbol.
		self changed: getterSel.
		self changed: ('txt_', className, '_', prefName) asSymbol.
		^ self].
	
	"Text field getter - return current value as string"
	(sel beginsWith: 'txt_') ifTrue: [
		body := sel allButFirst: 4.
		parts := body findTokens: '_'.
		className := parts first.
		prefName := parts second.
		speciesClass := Smalltalk at: className asSymbol.
		^ (speciesClass perform: prefName asSymbol) printString].
	
	"Text field accept - parse number from text, update slider and species"
	(sel beginsWith: 'acc_') ifTrue: [
		| key newVal text |
		body := (sel allButFirst: 4) allButLast: 1.
		parts := body findTokens: '_'.
		className := parts first.
		prefName := parts second.
		text := aMessage arguments first asString withBlanksTrimmed.
		newVal := [Number readFrom: text] on: Error do: [:e | nil].
		newVal ifNil: [^ false].
		speciesClass := Smalltalk at: className asSymbol.
		speciesClass perform: (prefName, ':') asSymbol with: newVal.
		key := className, '-', prefName.
		self changed: ('get_', className, '_', prefName) asSymbol.
		self changed: ('txt_', className, '_', prefName) asSymbol.
		^ true].
	
	^ super doesNotUnderstand: aMessage
]

{
	#category : #private,
	#'squeak_changestamp' : 'MCPServer 5/18/2026 15:42'
}
SWAGameConfigPanel >> getterFor: key [
	"key is 'ClassName-prefName', return #get_ClassName_prefName"
	^ ('get_', (key copyReplaceAll: '-' with: '_')) asSymbol
]

{
	#category : #initialization,
	#'squeak_changestamp' : 'MCPServer 5/18/2026 15:41'
}
SWAGameConfigPanel >> initialize [
	super initialize.
	species := {SWAGameFox. SWAGameRabbit}.
	sliders := Dictionary new.
	valueLabels := Dictionary new
]

{
	#category : #opening,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 14:48'
}
SWAGameConfigPanel >> open [
	| window scrollPane panel |
	window := SystemWindow labelled: 'SWAGame image defaults'.
	window model: self.
	panel := self buildPanel
		vResizing: #shrinkWrap;
		yourself.
	scrollPane := ScrollPane new
		showScrollBarsOnlyWhenNeeded;
		yourself.
	scrollPane scroller addMorph: panel.
	window addMorph: scrollPane fullFrame: (LayoutFrame fractions: (0@0 corner: 1@1)).
	window openInWorld.
	window extent: 800@1200.
	^ window
]

{
	#category : #updating,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:16'
}
SWAGameConfigPanel >> refresh [
	"After a scenario switch, which sets the preferences behind the sliders' back."
	sliders keysDo: [:key |
		self changed: (self getterFor: key).
		self changed: ('txt_', (key copyReplaceAll: '-' with: '_')) asSymbol].
]

{
	#category : #scenarios,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:16'
}
SWAGameConfigPanel >> saveScenario [
	| name |
	name := UIManager default request: 'Scenario name' initialAnswer: SWAGameScenario nextSavedName.
	name isEmptyOrNil ifTrue: [^ self].
	SWAGameScenario saveCurrentAs: name.
]

{
	#category : #scenarios,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 13:16'
}
SWAGameConfigPanel >> scenarioMenu [
	| menu |
	menu := MenuMorph new defaultTarget: self.
	SWAGameScenario all do: [:each |
		menu
			add: (each isActive ifTrue: ['<on>'] ifFalse: ['<off>']), each name
			target: each
			selector: #apply].
	menu addLine.
	menu add: 'Save current as...' target: self selector: #saveScenario.
	menu add: 'Open scenarios folder' target: self selector: #browseScenarios.
	menu popUpInWorld
]

{
	#category : #private,
	#'squeak_changestamp' : 'MCPServer 5/18/2026 15:42'
}
SWAGameConfigPanel >> setterFor: key [
	"key is 'ClassName-prefName', return #set_ClassName_prefName:"
	^ ('set_', (key copyReplaceAll: '-' with: '_'), ':') asSymbol
]
