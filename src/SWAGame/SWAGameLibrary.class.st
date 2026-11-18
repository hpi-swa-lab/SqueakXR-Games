"
FFI wrapper for libswagame.so, from the counter demo. The ecosystem simulation does not use it.
"
Class {
	#name : #SWAGameLibrary,
	#superclass : #ExternalLibrary,
	#category : #SWAGame,
	#'squeak_changestamp' : '<historical>'
}

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 4/21/2026 17:47'
}
SWAGameLibrary class >> moduleName [
	"Return the platform-specific module name"
	^ self unixModuleName
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 4/21/2026 17:46'
}
SWAGameLibrary class >> unixModuleName [
	^ '/home/jens/lively4/squeak/libswagame.so'
]

{
	#category : #api,
	#'squeak_changestamp' : 'jl 4/21/2026 15:33'
}
SWAGameLibrary >> counter [
	<cdecl: long 'counter' (void) module: '/home/jens/lively4/squeak/libswagame.so'>
	^ self externalCallFailed 
	
]

{
	#category : #api,
	#'squeak_changestamp' : 'jl 4/21/2026 15:33'
}
SWAGameLibrary >> foo [
	<cdecl: long 'foo' (void) module: '/home/jens/lively4/squeak/libswagame.so'>
	^ self externalCallFailed 
]

{
	#category : #api,
	#'squeak_changestamp' : 'MCPServer 4/21/2026 17:57'
}
SWAGameLibrary >> getCount [
	<cdecl: long 'getCount' (void) module: 'libswagame'>
	^self externalCallFailed
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 4/21/2026 12:25'
}
SWAGameLibrary >> macModuleName [
	^ '/home/jens/lively4/squeak/libswagame.so'
]

{
	#category : #'initialize-release',
	#'squeak_changestamp' : 'MCPServer 4/21/2026 17:42'
}
SWAGameLibrary >> primitiveUnloadModule: aString [
	<primitive: 571>
	self primitiveFailed
]

{
	#category : #'initialize-release',
	#'squeak_changestamp' : 'MCPServer 10/15/2026 13:18'
}
SWAGameLibrary >> safeReload [
	"A process inside the library across the unload takes the VM down, so every
	caller has to be stopped first. Nothing steps it since the Morphic game went."

	self unload.
	self forceLoading.
]

{
	#category : #'initialize-release',
	#'squeak_changestamp' : 'MCPServer 10/15/2026 13:18'
}
SWAGameLibrary >> safeReloadWithState [
	"A process inside the library across the unload takes the VM down, so every
	caller has to be stopped first. Nothing steps it since the Morphic game went."

	| savedCount |
	savedCount := self getCount.
	self unload.
	self forceLoading.
	self setCount: savedCount.
	Transcript show: 'Hot-reloaded with state: ', savedCount printString; cr
]

{
	#category : #api,
	#'squeak_changestamp' : 'MCPServer 4/21/2026 17:57'
}
SWAGameLibrary >> setCount: newCount [
	<cdecl: void 'setCount' (long) module: 'libswagame'>
	^self externalCallFailed
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 4/21/2026 12:25'
}
SWAGameLibrary >> unixModuleName [
	^ '/home/jens/lively4/squeak/libswagame.so'
]

{
	#category : #'initialize-release',
	#'squeak_changestamp' : 'MCPServer 4/21/2026 17:42'
}
SWAGameLibrary >> unload [
	self primitiveUnloadModule: self name
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 4/21/2026 12:25'
}
SWAGameLibrary >> win32ModuleName [
	^ '/home/jens/lively4/squeak/libswagame.so'
]
