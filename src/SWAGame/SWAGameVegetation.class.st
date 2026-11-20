"
Draws the grass and flowers of a SWAGameGarden on top of their columns.
"
Class {
	#name : #SWAGameVegetation,
	#superclass : #Object,
	#instVars : [
		'rlPosition',
		'rlGrassColor',
		'rlStemColor',
		'rlPetalColors'
	],
	#category : #'SWAGame-XR',
	#'squeak_changestamp' : '<historical>'
}

{
	#category : #growth,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:16'
}
SWAGameVegetation class >> bladeHeightAt: aStage [

	^ 0.1 + (0.06 * aStage)
]

{
	#category : #constants,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:16'
}
SWAGameVegetation class >> bladeWidth [

	^ 0.05
]

{
	#category : #growth,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:16'
}
SWAGameVegetation class >> bladesAt: aStage [

	^ aStage + 1 min: self maxBlades
]

{
	#category : #growth,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:16'
}
SWAGameVegetation class >> flowersAt: aStage [

	^ aStage - SWAGameGarden flowerStage + 1 max: 0
]

{
	#category : #constants,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:16'
}
SWAGameVegetation class >> grassColor [

	^ Color r: 0.3 g: 0.75 b: 0.25
]

{
	#category : #constants,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:16'
}
SWAGameVegetation class >> headSize [

	^ 0.12
]

{
	#category : #constants,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:16'
}
SWAGameVegetation class >> maxBlades [

	^ 3
]

{
	#category : #constants,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:16'
}
SWAGameVegetation class >> petalColors [

	^ {
		Color r: 1.0 g: 0.85 b: 0.2.
		Color r: 0.95 g: 0.35 b: 0.55.
		Color r: 0.6 g: 0.45 b: 0.95.
		Color white}
]

{
	#category : #constants,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:16'
}
SWAGameVegetation class >> spots [
	"Offsets from the column centre in cells, as x @ z."

	^ {
		-0.25 @ -0.2. 0.2 @ -0.28. 0.05 @ 0.22. -0.3 @ 0.25.
		0.28 @ 0.12. -0.05 @ -0.02. 0.15 @ -0.08. -0.15 @ 0.05}
]

{
	#category : #constants,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:16'
}
SWAGameVegetation class >> stemColor [

	^ Color r: 0.2 g: 0.5 b: 0.2
]

{
	#category : #constants,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:16'
}
SWAGameVegetation class >> stemHeight [

	^ 0.32
]

{
	#category : #constants,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:16'
}
SWAGameVegetation class >> stemWidth [

	^ 0.04
]

{
	#category : #rendering,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:16'
}
SWAGameVegetation >> drawAt: aSpot y: aNumber width: aWidth height: aHeight color: anRlColor [

	rlPosition x: aSpot x; y: aNumber; z: aSpot y.
	Raylib drawCubePosition: rlPosition width: aWidth height: aHeight length: aWidth color: anRlColor.
]

{
	#category : #rendering,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:16'
}
SWAGameVegetation >> ensureRlScratch [

	rlPosition ifNil: [rlPosition := RlVector3 new].
	rlGrassColor ifNil: [rlGrassColor := self rlColorFor: self class grassColor].
	rlStemColor ifNil: [rlStemColor := self rlColorFor: self class stemColor].
	rlPetalColors ifNil: [rlPetalColors := self class petalColors collect: [:each | self rlColorFor: each]].
]

{
	#category : #rendering,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:16'
}
SWAGameVegetation >> renderBladeAt: aSpot stage: aStage [

	| height |
	height := self class bladeHeightAt: aStage.
	self drawAt: aSpot y: height / 2 width: self class bladeWidth height: height color: rlGrassColor.
]

{
	#category : #rendering,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:16'
}
SWAGameVegetation >> renderFlowerAt: aSpot petals: anRlColor [

	| stem head |
	stem := self class stemHeight.
	head := self class headSize.
	self drawAt: aSpot y: stem / 2 width: self class stemWidth height: stem color: rlStemColor.
	self drawAt: aSpot y: stem + (head / 2) width: head height: head color: anRlColor.
]

{
	#category : #rendering,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:16'
}
SWAGameVegetation >> renderGarden: aGarden of: aGame [

	aGarden isEmpty ifTrue: [^ self].
	self ensureRlScratch.
	aGarden plantsDo: [:cell :stage |
		self
			renderStage: stage
			of: cell
			at: (aGame vegetationBaseFor: cell)
			scale: aGame worldScale].
]

{
	#category : #rendering,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:19'
}
SWAGameVegetation >> renderStage: aStage of: aCell at: aVector3 scale: aNumber [

	| seed |
	seed := self seedFor: aCell.
	Raylib
		rlPushMatrix;
		rlTranslatefX: aVector3 x y: aVector3 y z: aVector3 z;
		rlScalefX: aNumber asFloat y: aNumber asFloat z: aNumber asFloat.
	1 to: (self class bladesAt: aStage) do: [:index |
		self renderBladeAt: (self spot: index seed: seed) stage: aStage].
	1 to: (self class flowersAt: aStage) do: [:index |
		self
			renderFlowerAt: (self spot: index + self class maxBlades seed: seed)
			petals: (rlPetalColors atWrap: seed + index)].
	Raylib rlPopMatrix.
]

{
	#category : #rendering,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:16'
}
SWAGameVegetation >> rlColorFor: aColor [

	^ SRRaylibRenderer fill: RlColor new withColor: aColor
]

{
	#category : #layout,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:16'
}
SWAGameVegetation >> seedFor: aCell [

	^ (aCell x * 7) + (aCell y * 13)
]

{
	#category : #layout,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:16'
}
SWAGameVegetation >> spot: anIndex seed: aSeed [

	^ self class spots atWrap: aSeed + anIndex
]
