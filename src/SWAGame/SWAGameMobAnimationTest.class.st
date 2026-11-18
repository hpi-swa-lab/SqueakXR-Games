Class {
	#name : #SWAGameMobAnimationTest,
	#superclass : #SWAGameTestCase,
	#instVars : [
		'xr'
	],
	#category : #'SWAGame-Tests'
}

{
	#category : #running,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 15:40'
}
SWAGameMobAnimationTest >> entries [
	^ xr instVarNamed: 'mobObjects'
]

{
	#category : #running,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 15:40'
}
SWAGameMobAnimationTest >> setUp [
	super setUp.
	xr := SWAGameXR new.
]

{
	#category : #running,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 15:40'
}
SWAGameMobAnimationTest >> tearDown [
	"Left alive it would be picked up by SWAGameXR allInstances, which is how the live world is found."
	xr ifNotNil: [[xr destroy] on: Error do: [:e | nil]].
	xr := nil.
	super tearDown.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:58'
}
SWAGameMobAnimationTest >> testALostContextReachesTheMobMeshes [
	| mesh |
	mesh := SWAGameMobModel rabbit newMesh.
	mesh instVarNamed: 'internalMesh' put: RlMesh new.
	(xr mobRenderer instVarNamed: 'meshes') at: #rabbit put: mesh.
	xr onCacheInvalidated.
	self assert: (mesh instVarNamed: 'internalMesh') isNil.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 11/13/2026 11:08'
}
SWAGameMobAnimationTest >> testAWalkAdvancesTheStride [
	| mob gait before |
	xr tick.
	mob := (self entries detect: [:entry | entry isBody not]) mob.
	gait := xr mobRenderer gaitFor: mob.
	before := gait phaseAt: 1.
	xr snapshotMobPositions.
	mob positionX: mob x + 0.25 y: mob y z: mob z.
	xr buildMobAnimationData; advanceGaits.
	self assert: (gait phaseAt: 1) > before.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 11/13/2026 11:13'
}
SWAGameMobAnimationTest >> testAnEntryChangesItsOwnVectorsInsteadOfKeepingNewOnes [
	"An entry lives for many ticks; a fresh Vector3 kept per tick would fill the remembered set."
	| fromPos entry |
	fromPos := Vector3 x: 1 y: 2 z: 3.
	entry := SWAGameMobEntry new from: fromPos to: (Vector3 x: 3 y: 2 z: 1); yourself.
	self deny: entry from == fromPos.
	self assert: entry from equals: fromPos.
	self assert: (entry positionAt: 0.5) equals: (Vector3 x: 2 y: 2 z: 2).
	self assert: (entry positionAt: 0.5) == (entry positionAt: 1).
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 11/13/2026 11:08'
}
SWAGameMobAnimationTest >> testEveryEntryCarriesTheGaitOfItsMob [
	xr tick.
	self deny: self entries isEmpty.
	self entries do: [:entry |
		self assert: entry gait identical: (xr mobRenderer gaitFor: entry mob)].
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 11/13/2026 11:08'
}
SWAGameMobAnimationTest >> testGaitsMoveOnlyWhenTheSimulationTicks [
	"#buildMobAnimationData also runs on a spawn, between ticks; a walk counted twice would skip a stride."
	| mob before |
	xr tick.
	mob := (self entries detect: [:entry | entry isBody not]) mob.
	mob positionX: mob x + 0.3 y: mob y z: mob z.
	before := (xr mobRenderer gaitFor: mob) phaseAt: 1.
	xr buildMobAnimationData.
	self assert: ((xr mobRenderer gaitFor: mob) phaseAt: 1) equals: before.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 11/13/2026 11:08'
}
SWAGameMobAnimationTest >> testGaitsOfTheGoneAreDropped [
	| mob |
	xr tick.
	mob := (self entries detect: [:entry | entry isBody not]) mob.
	mob die; consume: 1.0.
	xr buildMobAnimationData.
	self deny: ((xr mobRenderer instVarNamed: 'gaits') includesKey: mob).
]
