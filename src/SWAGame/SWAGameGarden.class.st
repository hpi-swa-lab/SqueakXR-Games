"
Water poured on terrain columns, and the vegetation it has grown there. Cells are x @ z, zero based.
"
Class {
	#name : #SWAGameGarden,
	#superclass : #Object,
	#instVars : [
		'water'
	],
	#category : #SWAGame,
	#'squeak_changestamp' : '<historical>'
}

{
	#category : #constants,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:16'
}
SWAGameGarden class >> dropsPerStage [

	^ 12
]

{
	#category : #constants,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:16'
}
SWAGameGarden class >> flowerStage [

	^ 3
]

{
	#category : #'instance creation',
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:16'
}
SWAGameGarden class >> fromArray: anArray [

	^ self new
		restoreFrom: anArray;
		yourself
]

{
	#category : #constants,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:16'
}
SWAGameGarden class >> maxStage [

	^ 4
]

{
	#category : #constants,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:16'
}
SWAGameGarden class >> maxWater [

	^ self dropsPerStage * self maxStage
]

{
	#category : #growth,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:16'
}
SWAGameGarden class >> stageFor: anAmount [

	^ anAmount // self dropsPerStage
]

{
	#category : #serialization,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:16'
}
SWAGameGarden >> asArray [

	^ water associations asArray collect: [:each | {each key x. each key y. each value}]
]

{
	#category : #watering,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:16'
}
SWAGameGarden >> clearAt: aCell [

	water removeKey: aCell ifAbsent: [].
]

{
	#category : #initialization,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:16'
}
SWAGameGarden >> initialize [

	super initialize.
	water := Dictionary new.
]

{
	#category : #testing,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:16'
}
SWAGameGarden >> isEmpty [

	^ water isEmpty
]

{
	#category : #enumerating,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:16'
}
SWAGameGarden >> plantsDo: aBlock [

	water keysAndValuesDo: [:cell :amount |
		| stage |
		stage := self class stageFor: amount.
		stage > 0 ifTrue: [aBlock value: cell value: stage]].
]

{
	#category : #watering,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:16'
}
SWAGameGarden >> pourOn: aCell [

	| before |
	before := self stageAt: aCell.
	water at: aCell put: ((self waterAt: aCell) + 1 min: self class maxWater).
	^ (self stageAt: aCell) > before
]

{
	#category : #serialization,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:16'
}
SWAGameGarden >> restoreFrom: anArray [

	anArray do: [:each | water at: each first @ each second put: each third].
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:16'
}
SWAGameGarden >> stageAt: aCell [

	^ self class stageFor: (self waterAt: aCell)
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:16'
}
SWAGameGarden >> waterAt: aCell [

	^ water at: aCell ifAbsent: [0]
]
