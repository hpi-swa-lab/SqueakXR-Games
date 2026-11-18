Class {
	#name : #SWAGameMobRendererTest,
	#superclass : #TestCase,
	#instVars : [
		'renderer'
	],
	#category : #'SWAGame-Tests'
}

{
	#category : #running,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 15:40'
}
SWAGameMobRendererTest >> setUp [
	super setUp.
	renderer := SWAGameMobRenderer new.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 15:40'
}
SWAGameMobRendererTest >> testABodyLiesOnItsSide [
	renderer
		rotateYaw: 0.0 lying: true;
		combine: Matrix4x4 identity scale: 1.0 x: 0.0 y: 0.0 z: 0.0.
	self assert: (self transformAt: 2 column: 2) abs < 1.0e-9.
	self assert: (self transformAt: 3 column: 3) equals: 1.0.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 18:07'
}
SWAGameMobRendererTest >> testALostContextDropsTheShader [
	renderer instVarNamed: 'shader' put: SRShader new.
	renderer onCacheInvalidated.
	self assert: (renderer instVarNamed: 'shader') isNil.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:58'
}
SWAGameMobRendererTest >> testAMeshOfALostContextIsUploadedAgain [
	| mesh |
	mesh := self uploadedMesh.
	renderer onCacheInvalidated.
	self assert: (mesh instVarNamed: 'internalMesh') isNil.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:58'
}
SWAGameMobRendererTest >> testARetiredMeshOfALostContextIsNeverUnloaded [
	"Its id belongs to the dead context, and may name something else in the new one."
	self uploadedMesh.
	renderer forgetModels.
	renderer onCacheInvalidated.
	self assert: (renderer instVarNamed: 'retired') isNil.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 15:40'
}
SWAGameMobRendererTest >> testTheGameTransformAppliesOnTop [
	| game |
	game := Matrix4x4 identity copy.
	game a14: 10.0.
	renderer
		rotateYaw: 0.0 lying: false;
		combine: game scale: 1.0 x: 1.0 y: 0.0 z: 0.0.
	self assert: (self transformAt: 1 column: 4) equals: 11.0.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 15:40'
}
SWAGameMobRendererTest >> testTheModelOriginLandsOnThePosition [
	renderer
		rotateYaw: 0.0 lying: false;
		combine: Matrix4x4 identity scale: 2.0 x: 1.0 y: 2.0 z: 3.0.
	self assert: (self transformAt: 1 column: 1) equals: 2.0.
	self assert: (self transformAt: 2 column: 2) equals: 2.0.
	self assert: (self transformAt: 3 column: 3) equals: 2.0.
	self assert: (self transformAt: 1 column: 4) equals: 1.0.
	self assert: (self transformAt: 2 column: 4) equals: 2.0.
	self assert: (self transformAt: 3 column: 4) equals: 3.0.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 15:40'
}
SWAGameMobRendererTest >> testYawTurnsTheSnoutTowardTheHeading [
	"The model looks along +z; a yaw of a quarter turn, as SWAGameMobGait answers for heading +x, must turn it to +x."
	renderer
		rotateYaw: Float pi / 2 lying: false;
		combine: Matrix4x4 identity scale: 1.0 x: 0.0 y: 0.0 z: 0.0.
	self assert: ((self transformAt: 1 column: 3) - 1.0) abs < 1.0e-9.
	self assert: (self transformAt: 3 column: 3) abs < 1.0e-9.
]

{
	#category : #running,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 15:40'
}
SWAGameMobRendererTest >> transformAt: row column: column [
	^ (renderer instVarNamed: 'transform') at: row - 1 * 4 + column
]

{
	#category : #running,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:58'
}
SWAGameMobRendererTest >> uploadedMesh [
	"Stands in for a mesh the render loop has uploaded."
	| mesh |
	mesh := SWAGameMobModel rabbit newMesh.
	mesh instVarNamed: 'internalMesh' put: RlMesh new.
	(renderer instVarNamed: 'meshes') at: #rabbit put: mesh.
	^ mesh
]
