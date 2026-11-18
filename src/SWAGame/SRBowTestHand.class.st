"
A minimal stand-in for SRHand.
"
Class {
	#name : #SRBowTestHand,
	#superclass : #SRObject,
	#instVars : [
		'body',
		'cursor'
	],
	#category : #'SWAGame-Tests',
	#'squeak_changestamp' : '<historical>'
}

{
	#category : #accessing,
	#'squeak_changestamp' : 'leo-MCPServer 11/18/2026 17:56'
}
SRBowTestHand >> body [

	^ body
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'leo-MCPServer 11/18/2026 17:56'
}
SRBowTestHand >> cursor [

	^ cursor
]

{
	#category : #initialization,
	#'squeak_changestamp' : 'leo-MCPServer 11/18/2026 17:56'
}
SRBowTestHand >> initialize [

	super initialize.
	body := SRObject new.
	cursor := SRObject new
]
