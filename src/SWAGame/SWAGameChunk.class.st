"
A 16x16 column of the world in 16-cube sections.

A section is allocated on the first solid write into it.
"
Class {
	#name : #SWAGameChunk,
	#superclass : #Object,
	#instVars : [
		'sections'
	],
	#category : #'SWAGame-Voxels',
	#'squeak_changestamp' : '<historical>'
}

{
	#category : #keys,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameChunk class >> keyForCellX: cellX z: cellZ [
	"bitShift: floors negative cells, as // would."

	^ self keyX: (cellX bitShift: -4) z: (cellZ bitShift: -4)
]

{
	#category : #keys,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameChunk class >> keyX: cx z: cz [
	"A SmallInteger, not a Point: this runs per voxel lookup. cz is signed,
	between #minCoordinate and #maxCoordinate."

	^ cx * 65536 + cz
]

{
	#category : #keys,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 17:29'
}
SWAGameChunk class >> maxCoordinate [
	^ 32767
]

{
	#category : #keys,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 17:29'
}
SWAGameChunk class >> minCoordinate [
	^ -32768
]

{
	#category : #constants,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameChunk class >> sectionHeight [
	^ 16
]

{
	#category : #constants,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameChunk class >> size [
	^ 16
]

{
	#category : #keys,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 17:33'
}
SWAGameChunk class >> xOfKey: aKey [
	^ aKey + 32768 // 65536
]

{
	#category : #keys,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 17:33'
}
SWAGameChunk class >> zOfKey: aKey [
	^ (aKey + 32768 \\ 65536) - 32768
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 15:30'
}
SWAGameChunk >> allocatedSectionCount [

	^ sections count: [:each | each notNil]
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameChunk >> atLocalX: lx y: y z: lz [
	"The shifts and masks assume #size and #sectionHeight are 16."

	| sectionIndex section |
	sectionIndex := (y bitShift: -4) + 1.
	(sectionIndex between: 1 and: sections size) ifFalse: [^ 0].
	section := sections at: sectionIndex.
	section ifNil: [^ 0].
	^ section at: ((((y bitAnd: 15) bitShift: 4) + lz bitShift: 4) + lx + 1)
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameChunk >> atLocalX: lx y: y z: lz put: aValue [
	| sectionIndex section |
	sectionIndex := (y bitShift: -4) + 1.
	(sectionIndex between: 1 and: sections size) ifFalse: [^ aValue].
	section := sections at: sectionIndex.
	section ifNil: [
		aValue = 0 ifTrue: [^ aValue].
		section := ByteArray new: self class sectionHeight * 16 * 16.
		sections at: sectionIndex put: section].
	section
		at: ((((y bitAnd: 15) bitShift: 4) + lz bitShift: 4) + lx + 1)
		put: aValue.
	^ aValue
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 16:00'
}
SWAGameChunk >> hasSectionAtY: y [
	"False means nothing solid was ever written into that 16 cube."

	| sectionIndex |
	sectionIndex := (y bitShift: -4) + 1.
	(sectionIndex between: 1 and: sections size) ifFalse: [^ false].
	^ (sections at: sectionIndex) notNil
]

{
	#category : #private,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 15:30'
}
SWAGameChunk >> indexLocalX: lx y: ly z: lz [
	"Within one section, all three coordinates are 0 to 15."

	^ (ly * 16 + lz) * 16 + lx + 1
]

{
	#category : #initialization,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 15:30'
}
SWAGameChunk >> initializeHeight: blockHeight [

	sections := Array new: (blockHeight / self class sectionHeight) ceiling.
	^ self
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 14:37'
}
SWAGameChunk >> sections [
	^ sections
]
