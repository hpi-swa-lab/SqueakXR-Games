"
Every voxel as a single collision geometry.

The hit face travels back through noteVoxelHitX:y:z:face: -- SRHand rebuilds the result object and drops anything hung on it.
"
Class {
	#name : #SWAGameVoxelCollider,
	#superclass : #SRCollisionGeometry,
	#instVars : [
		'game'
	],
	#category : #'SWAGame-XR',
	#'squeak_changestamp' : '<historical>'
}

{
	#category : #drawing,
	#'squeak_changestamp' : 'MCPServer (leo) 11/9/2026 14:49'
}
SWAGameVoxelCollider >> drawGizmoOn: aGizmoPainter colored: aColor [

	^ self
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 7/29/2026 13:33'
}
SWAGameVoxelCollider >> game [
	^ game
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 7/29/2026 13:33'
}
SWAGameVoxelCollider >> game: aSWAGameXR [
	game := aSWAGameXR
]

{
	#category : #collisions,
	#'squeak_changestamp' : 'MCPServer (jl) 10/21/2026 10:10'
}
SWAGameVoxelCollider >> intersectsBoxCenter: aCentre halfExtents: aHalfExtents [
	"The cells the box covers, asked of the voxel store directly. One
	SRCollisionBox per voxel would be millions of objects for the few the player
	can touch."

	| gameWorld a b |
	game ifNil: [^ false].
	gameWorld := game gameWorld ifNil: [^ false].
	"Corner order does not survive the game's rotation: a half turn about y sends
	the low corner to the high cell, and to:do: then iterates nothing at all --
	terrain that silently stops holding the player up. Yaws are snapped to
	quarter turns, so the two transformed corners still bound the cells exactly."
	a := game cellPositionForGlobal: aCentre - aHalfExtents.
	b := game cellPositionForGlobal: aCentre + aHalfExtents.
	(a x min: b x) floor to: (a x max: b x) floor do: [:cx |
		(a y min: b y) floor to: (a y max: b y) floor do: [:cy |
			(a z min: b z) floor to: (a z max: b z) floor do: [:cz |
				(gameWorld isSolidAtX: cx y: cy z: cz) ifTrue: [^ true]]]].
	^ false
]

{
	#category : #collisions,
	#'squeak_changestamp' : 'MCPServer (leo) 11/9/2026 14:47'
}
SWAGameVoxelCollider >> rayIntersection: aRay [
	"Answer an SRRayIntersectionResult for the first solid voxel along aRay.
	 The hit voxel and the face we entered through are handed to the game
	 separately: SRHand rebuilds the result as an SRHandRayIntersectionResult
	 and copies only #object and #point, so anything we hung on the result
	 would be lost before onRaycast: ever saw it."
	| hit gridPoint point |
	hit := self voxelHitForRay: aRay.
	hit ifNil: [^ nil].
	gridPoint := hit at: 5.
	game
		noteVoxelHitX: (hit at: 1)
		y: (hit at: 2)
		z: (hit at: 3)
		face: (hit at: 4).
	point := game
		globalPositionForCellX: gridPoint x
		y: gridPoint y
		z: gridPoint z.
	^ SRIntersectionResult new
		object: self object;
		point: point;
		distance: (point - aRay origin) length
]

{
	#category : #collisions,
	#'squeak_changestamp' : 'MCPServer 7/29/2026 15:30'
}
SWAGameVoxelCollider >> voxelHitForRay: aRay [
	"3D-DDA (Amanatides & Woo). Answer {gx. gy. gz. faceNormal. gridEntryPoint}
	 for the first solid voxel the ray enters, or nil if it misses the terrain.

	 The march itself lives in SWAGameVoxelRayWalk. This method used to contain
	 all of it -- 1552 bytes, 40 temps, 123 lines -- which Cog's ARM64 JIT
	 miscompiled: merely calling it hard-crashed SqueakXR on the Quest with a
	 native SIGSEGV, even with the body reduced to ^ nil. Keep it small.
	 See journal/2026-07-29-arm-jit-voxel-collider-crash.md."
	^ (SWAGameVoxelRayWalk game: game ray: aRay)
		ifNotNil: [:walk | walk findHit]
]
