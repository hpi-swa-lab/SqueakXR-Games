"
Emits and draws the hearts of petted mobs.
"
Class {
	#name : #SWAGameHearts,
	#superclass : #Object,
	#instVars : [
		'hearts',
		'pixels',
		'rlPosition',
		'rlColor'
	],
	#category : #'SWAGame-XR',
	#'squeak_changestamp' : '<historical>'
}

{
	#category : #constants,
	#'squeak_changestamp' : 'MCPServer (leo) 11/5/2026 17:48'
}
SWAGameHearts class >> color [

	^ Color r: 1.0 g: 0.3 b: 0.45
]

{
	#category : #constants,
	#'squeak_changestamp' : 'MCPServer (leo) 11/5/2026 17:48'
}
SWAGameHearts class >> emitInterval [

	^ 0.3
]

{
	#category : #constants,
	#'squeak_changestamp' : 'MCPServer (leo) 11/5/2026 17:48'
}
SWAGameHearts class >> pattern [

	^ #(
		'.XX.XX.'
		'XXXXXXX'
		'XXXXXXX'
		'.XXXXX.'
		'..XXX..'
		'...X...')
]

{
	#category : #constants,
	#'squeak_changestamp' : 'MCPServer (leo) 11/5/2026 17:48'
}
SWAGameHearts class >> pixelCells [

	^ 0.07
]

{
	#category : #constants,
	#'squeak_changestamp' : 'MCPServer (leo) 11/5/2026 17:48'
}
SWAGameHearts class >> pixelOffsets [

	| rows |
	rows := self pattern.
	^ Array streamContents: [:stream |
		rows withIndexDo: [:row :rowIndex |
			row withIndexDo: [:pixel :column |
				pixel = $X ifTrue: [
					stream nextPut: (column - (row size + 1 / 2)) asFloat @ (rows size - rowIndex) asFloat]]]]
]

{
	#category : #emitting,
	#'squeak_changestamp' : 'MCPServer (leo) 11/5/2026 17:48'
}
SWAGameHearts >> advance: seconds [

	hearts do: [:heart | heart advance: seconds].
	hearts removeAllSuchThat: [:heart | heart isExpired].
]

{
	#category : #emitting,
	#'squeak_changestamp' : 'MCPServer (leo) 11/5/2026 17:48'
}
SWAGameHearts >> emitAt: aVector3 cellSize: aNumber [

	hearts add: (SWAGameHeart
		at: aVector3
		cellSize: aNumber
		sway: Float twoPi * ThreadSafeRandom value next).
]

{
	#category : #emitting,
	#'squeak_changestamp' : 'MCPServer (leo) 11/5/2026 17:48'
}
SWAGameHearts >> emitAt: aVector3 cellSize: aNumber over: seconds [

	ThreadSafeRandom value next < (seconds / self class emitInterval)
		ifTrue: [self emitAt: aVector3 cellSize: aNumber].
]

{
	#category : #rendering,
	#'squeak_changestamp' : 'MCPServer (leo) 11/5/2026 17:48'
}
SWAGameHearts >> ensureRlScratch [

	rlPosition ifNil: [rlPosition := RlVector3 new].
	rlColor ifNil: [rlColor := SRRaylibRenderer fill: RlColor new withColor: self class color].
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (leo) 11/5/2026 17:48'
}
SWAGameHearts >> hearts [

	^ hearts
]

{
	#category : #initialization,
	#'squeak_changestamp' : 'MCPServer (leo) 11/5/2026 17:48'
}
SWAGameHearts >> initialize [

	super initialize.
	hearts := OrderedCollection new.
	pixels := self class pixelOffsets.
]

{
	#category : #rendering,
	#'squeak_changestamp' : 'MCPServer (leo) 11/5/2026 17:48'
}
SWAGameHearts >> renderFacing: aViewerPositionOrNil [

	hearts isEmpty ifTrue: [^ self].
	self ensureRlScratch.
	hearts do: [:heart | self renderHeart: heart facing: aViewerPositionOrNil].
]

{
	#category : #rendering,
	#'squeak_changestamp' : 'MCPServer (leo) 11/5/2026 17:48'
}
SWAGameHearts >> renderHeart: aHeart facing: aViewerPositionOrNil [

	| position pixelSize |
	position := aHeart position.
	pixelSize := aHeart scale * self class pixelCells.
	Raylib
		rlPushMatrix;
		rlTranslatefX: position x y: position y z: position z;
		rlRotatefAngle: (self yawFrom: position toward: aViewerPositionOrNil) x: 0.0 y: 1.0 z: 0.0;
		rlScalefX: pixelSize y: pixelSize z: pixelSize.
	pixels do: [:pixel |
		rlPosition x: pixel x; y: pixel y; z: 0.0.
		Raylib drawCubePosition: rlPosition width: 1.0 height: 1.0 length: 1.0 color: rlColor].
	Raylib rlPopMatrix.
]

{
	#category : #rendering,
	#'squeak_changestamp' : 'MCPServer (leo) 11/5/2026 17:48'
}
SWAGameHearts >> yawFrom: aPosition toward: aViewerPositionOrNil [

	| delta |
	aViewerPositionOrNil ifNil: [^ 0.0].
	delta := aViewerPositionOrNil - aPosition.
	^ (delta x arcTan: delta z) radiansToDegrees
]
