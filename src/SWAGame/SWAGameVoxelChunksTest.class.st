Class {
	#name : #SWAGameVoxelChunksTest,
	#superclass : #SWAGameTestCase,
	#instVars : [
		'xr',
		'chunks'
	],
	#category : #'SWAGame-Tests'
}

{
	#category : #private,
	#'squeak_changestamp' : 'MCPServer (MCPServer) 10/23/2026 12:29'
}
SWAGameVoxelChunksTest >> meshes [

	| meshes |
	meshes := IdentitySet new.
	chunks meshesDo: [:each | meshes add: each].
	^ meshes
]

{
	#category : #running,
	#'squeak_changestamp' : 'MCPServer (MCPServer) 10/23/2026 12:29'
}
SWAGameVoxelChunksTest >> setUp [

	super setUp.
	xr := SWAGameXR new.
	xr generateLevel.
	chunks := xr voxelChunks.
	chunks rebuildAllDirty.
]

{
	#category : #running,
	#'squeak_changestamp' : 'MCPServer (MCPServer) 10/23/2026 12:29'
}
SWAGameVoxelChunksTest >> tearDown [

	xr ifNotNil: [[xr destroy] on: Error do: [:e | nil]].
	xr := nil.
	super tearDown.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (MCPServer) 10/23/2026 12:29'
}
SWAGameVoxelChunksTest >> testARebuildUnloadsTheMeshItReplaces [

	| old |
	old := self uploadedMesh.
	chunks markAllDirty.
	chunks rebuildAllDirty.
	self deny: (self meshes includes: old).
	self assert: (old instVarNamed: 'internalMesh') isNil.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (MCPServer) 10/23/2026 12:29'
}
SWAGameVoxelChunksTest >> testAResetUnloadsOnlyAtTheNextRebuild [
	"A reset can come from a menu; the unload waits for the render process."
	| old |
	old := self uploadedMesh.
	chunks resetChunks.
	self assert: (old instVarNamed: 'internalMesh') notNil.
	chunks rebuildUpTo: 0.
	self assert: (old instVarNamed: 'internalMesh') isNil.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (MCPServer) 10/23/2026 12:29'
}
SWAGameVoxelChunksTest >> testARetiredMeshOfALostContextIsNeverUnloaded [
	"Its id belongs to the dead context, and may name something else in the new one."
	| old |
	old := self uploadedMesh.
	chunks resetChunks.
	chunks onCacheInvalidated.
	chunks rebuildUpTo: 0.
	self assert: (old instVarNamed: 'internalMesh') notNil.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 15:59'
}
SWAGameVoxelChunksTest >> testTheBlockTypeTravelsInAlpha [
	"The terrain shader picks its pattern by it; an alpha of 255 would draw everything as plain colour."
	SWAGameBlocks types doWithIndex: [:type :id |
		self assert: (SWAGameBlocks rgbaFor: id) fourth equals: id].
]

{
	#category : #private,
	#'squeak_changestamp' : 'MCPServer (MCPServer) 10/23/2026 12:29'
}
SWAGameVoxelChunksTest >> uploadedMesh [
	"Stands in for a mesh the render loop has uploaded."
	| mesh |
	chunks meshesDo: [:each | mesh := each].
	mesh instVarNamed: 'internalMesh' put: RlMesh new.
	^ mesh
]
