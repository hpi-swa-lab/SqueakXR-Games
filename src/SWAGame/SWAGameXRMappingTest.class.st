"
Characterisation of the cell-to-object-space mapping and of the grass map encoding.

The mapping is written out twice, in SWAGameXR>>worldPosForMob: and in SWAGameVoxelChunks>>writeQuadVerts:..., and when the two drift apart mobs hover slightly off the ground. These tests pin the current numbers so that moving to global coordinates is a deliberate change rather than a silent one.
"
Class {
	#name : #SWAGameXRMappingTest,
	#superclass : #SWAGameTestCase,
	#instVars : [
		'xr'
	],
	#category : #'SWAGame-Tests',
	#'squeak_changestamp' : '<historical>'
}

{
	#category : #helpers,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 15:46'
}
SWAGameXRMappingTest >> mobAtCellX: cx z: cz standingOn: surfaceHeight [
	"Feet on the surface, centred in the column."

	^ SWAGameRabbit new
		positionX: cx + 0.5 y: surfaceHeight z: cz + 0.5;
		yourself
]

{
	#category : #private,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 17:36'
}
SWAGameXRMappingTest >> rayWalkDownOntoCellX: cellX z: cellZ on: anXR [
	"Aim at the centre of a cell, not its corner: Vector3 is single precision, so a
	coordinate landing exactly on a cell boundary floors into the cell before it."

	| centre ray walk |
	centre := anXR objectPosForCellX: cellX + 0.5 y: anXR gridHeight z: cellZ + 0.5.
	ray := SRRay
		origin: (Vector3 x: centre x y: centre y + 1 z: centre z)
		forward: (Vector3 x: 0 y: -1 z: 0).
	walk := SWAGameVoxelRayWalk new setGame: anXR ray: ray.
	walk ifNil: [^ nil].
	walk clipToGrid ifFalse: [^ nil].
	walk prepareStepping.
	^ walk march
]

{
	#category : #running,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 15:46'
}
SWAGameXRMappingTest >> setUp [
	super setUp.
	xr := SWAGameXR new.
]

{
	#category : #running,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 15:46'
}
SWAGameXRMappingTest >> tearDown [
	"Left alive it would be picked up by SWAGameXR allInstances, which is how
	the live world is found."

	xr ifNotNil: [[xr destroy] on: Error do: [:e | nil]].
	xr := nil.
	super tearDown.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 10/21/2026 11:18'
}
SWAGameXRMappingTest >> testASpawnToolPutsItsOwnSpeciesOnTheColumn [
	"A spawn tool is a place tool with a species instead of a material, so the
	same first-refusal path that digs and places also spawns."

	| gameWorld tool count before mob |
	gameWorld := xr gameWorld.
	xr generateChunkAtX: 0 z: 0.
	tool := SWAGameSpawnTool new game: xr; species: #fox; yourself.
	"Counted by walking the chunks: #mobsOfSpecies: reads an index that only a
	tick rebuilds, so it cannot see a mob spawned between ticks."
	count := [:species |
		| n |
		n := 0.
		gameWorld mobsDo: [:each | each species == species ifTrue: [n := n + 1]].
		n].
	before := count value: #fox.
	tool applyAtX: 5 y: 3 z: 7 face: (Vector3 x: 0 y: 1 z: 0).
	self assert: before + 1 equals: (count value: #fox).
	"Standing on the column, not inside it."
	mob := nil.
	gameWorld mobsDo: [:each |
		(each species == #fox and: [each x = 5.5]) ifTrue: [mob := each]].
	self assert: mob notNil.
	self assert: 7.5 equals: mob z.
	self assert: (gameWorld heightAtX: 6 y: 8) equals: mob y.
	"The species is what tells two spawn tools apart."
	self assert: (tool isSameToolAs: (SWAGameSpawnTool new species: #fox; yourself)).
	self deny: (tool isSameToolAs: (SWAGameSpawnTool new species: #rabbit; yourself)).
	self deny: (tool isSameToolAs: (SWAGameDigTool new)).
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (leo) 11/9/2026 14:37'
}
SWAGameXRMappingTest >> testAToggleRowInAStickyMenuRelabelsItself [
	"A grabbed menu is sticky and stays in the world, so SRMenuItem answers an
	activation with #labelsChanged rather than closing. A row whose label was
	built as a string goes on announcing the state the game was opened in."

	| menu saved rowNamed before |
	saved := SRAvatar continuousLocomotion.
	[menu := SRMenu new sticky: true; yourself.
	xr addSettingItemsTo: menu.
	menu rebuild.
	rowNamed := [:prefix |
		menu children detect: [:each |
			each isMenuItem and: [each label beginsWith: prefix]]].
	before := (rowNamed value: 'Locomotion: ') label.
	(rowNamed value: 'Locomotion: ') activateBy: nil.
	self assert: SRAvatar continuousLocomotion ~= saved.
	menu rebuild.
	self deny: before = (rowNamed value: 'Locomotion: ') label]
		ensure: [SRAvatar continuousLocomotion: saved].
]

{
	#category : #'tests - mapping',
	#'squeak_changestamp' : 'MCPServer 10/15/2026 15:47'
}
SWAGameXRMappingTest >> testCellCentreMapsToColumnCentre [
	"A mob in the middle of a cell must land on the middle of that column, not
	on its corner. Half a cell out is the classic off-by-one-half here."

	| mob pos scale |
	scale := xr worldScale.
	mob := self mobAtCellX: 0 z: 0 standingOn: 4.
	pos := xr worldPosForMob: mob.
	self assert: (pos x - ((0.5 - (xr gridWidth / 2)) * scale)) abs < self tolerance.
	self assert: (pos z - ((0.5 - (xr gridDepth / 2)) * scale)) abs < self tolerance.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer 10/16/2026 09:38'
}
SWAGameXRMappingTest >> testCellPositionFollowsTheRigNotTheHeadOffset [
	"A camera is a child of the avatar, so its own translation is an offset
	inside the rig. Reading #position instead of #globalTranslation left the
	simulation centre parked wherever the avatar started."

	| rig head atOrigin moved |
	rig := SRObject new.
	head := SRObject new.
	rig addChild: head.
	head translation: (Vector3 x: 0 y: 1.8 z: 0).
	atOrigin := xr cellPositionOf: head.
	rig translation: (xr objectPosForCellX: 40 y: 0 z: 40).
	moved := xr cellPositionOf: head.
	self assert: (atOrigin x - (xr gridWidth / 2)) abs < 0.001.
	self assert: (moved x - 40) abs < 0.001.
	self assert: (moved z - 40) abs < 0.001.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer 10/16/2026 09:39'
}
SWAGameXRMappingTest >> testChangingTheScaleReachesTheSharedSpace [
	"#worldScale: used to set the ivar and remesh, but never the space the
	vertices and the mob positions are both read from, so every chunk was
	rebuilt at the old size and nothing moved."

	| before after |
	before := xr objectPosForCellX: 10 y: 0 z: 10.
	xr worldScale: 1.0.
	after := xr objectPosForCellX: 10 y: 0 z: 10.
	self assert: xr space worldScale equals: 1.0.
	self assert: xr voxelChunks space == xr space.
	self assert: (after x - (before x / 0.05)) abs < 0.001.
	self assert: (after z - (before z / 0.05)) abs < 0.001.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'jl-MCPServer 11/25/2026 17:41'
}
SWAGameXRMappingTest >> testClosingDisarmsOnlyTheHandsHoldingItsTools [
	| world avatar other otherTool |
	world := SRWorld new.
	avatar := SRAvatar new.
	world avatar: avatar.
	world addChild: avatar.
	world addChild: xr.
	other := SWAGameXR new.
	[otherTool := SWAGameDigTool new game: other; yourself.
	avatar rightHand basicTool: (SWAGameDigTool new game: xr; yourself).
	avatar leftHand basicTool: otherTool.
	xr close.
	self assert: avatar rightHand tool isNil.
	self assert: avatar leftHand tool == otherTool]
		ensure: [other destroy].
]

{
	#category : #tests,
	#'squeak_changestamp' : 'jl-MCPServer 11/25/2026 17:41'
}
SWAGameXRMappingTest >> testClosingInFirstPersonGivesTheAvatarBack [
	"Closed in walk mode, the player was left with the game's locomotion, standing
	where a 1 m world used to be."
	| world avatar |
	world := SRWorld new.
	avatar := SRAvatar new.
	world avatar: avatar.
	world addChild: avatar.
	world addChild: xr.
	xr instVarNamed: 'walkMode' put: true.
	avatar locomotionEnabled: true.
	avatar translation: 20m @ 0m @ 30m.
	xr close.
	self assert: (avatar instVarNamed: 'locomotionEnabled') isNil.
	self assert: Vector3 zero equals: avatar translation.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'jl-MCPServer 11/25/2026 17:41'
}
SWAGameXRMappingTest >> testClosingRemovesTheGameAndItsPanels [
	"The panels are world children, not children of the game, so removing the
	game alone left them standing in the scene."
	| world panels |
	world := SRWorld new.
	world addChild: xr.
	panels := {
		'popGraph' -> SWAGamePopGraph new.
		'traceGraph' -> SWAGameMobTraceGraph new.
		'mobInspector' -> SRObject new.
		'buttonSlab' -> SRObject new.
		'toolSlab' -> SRObject new}.
	panels do: [:each |
		world addChild: each value.
		xr instVarNamed: each key put: each value].
	xr close.
	self deny: xr isOpen.
	self deny: (world children includes: xr).
	panels do: [:each |
		self deny: each value isOpen description: each key , ' is still in the world'.
		self assert: (xr instVarNamed: each key) isNil description: each key , ' is still held'].
]

{
	#category : #tests,
	#'squeak_changestamp' : 'leo-MCPServer 11/20/2026 19:10'
}
SWAGameXRMappingTest >> testEachHandTargetsItsOwnVoxel [
	"Two hands, two targets. The game kept one #lastVoxelHit slot, which is
	right for the cast that is acting but cannot describe where both hands are
	pointing at once."

	| world avatar left right gameWorld |
	world := SRWorld new.
	avatar := SRAvatar new.
	world addChild: avatar.
	world addChild: xr.
	"A known flat floor four cells deep, as #testTheTerrainIsSolidToTheBoxSweep
	builds: generated terrain leaves #topFilledYAtX:z: nil in this fixture."
	gameWorld := xr gameWorld.
	gameWorld clearTerrain.
	xr generateChunkAtX: 0 z: 0.
	gameWorld voxels clear.
	0 to: 15 do: [:cx |
		0 to: 15 do: [:cz |
			0 to: 3 do: [:cy | gameWorld voxels at: cx at: cy at: cz put: 1]]].
	left := avatar leftHand.
	right := avatar rightHand.

	"A hand pointing at nothing targets nothing."
	xr updateHandTargets.
	self assert: (xr targetVoxelFor: left) isNil.
	"Straight down from above two different columns. Cell coordinates have to go
	through #globalPositionForCellX:y:z: -- at the table worldScale of 0.05 the
	whole 32 cell grid is 1.6 m across, so cell 4 is nowhere near x = 4."
	#(#(4 left) #(9 right)) with: {left. right} do: [:spec :hand |
		| column |
		column := xr globalPositionForCellX: spec first + 0.5 y: 0 z: spec first + 0.5.
		hand globalTransform: (Matrix4x4
			objectLookAt: column
			from: column + (0 @ 40 @ 0)
			up: Vector3 forward)].
	"Bare hands, deliberately: the mark follows the ray, not the tool, so you can
	see where a hand aims before arming it."
	self assert: left tool isNil.
	self assert: right tool isNil.
	xr updateHandTargets.
	self assert: (xr instVarNamed: 'handTargets') notNil.
	self deny: ((xr instVarNamed: 'handTargets') at: left) isNil.
	self deny: ((xr instVarNamed: 'handTargets') at: right) isNil.
	self
		deny: ((xr instVarNamed: 'handTargets') at: left) = ((xr instVarNamed: 'handTargets') at: right)
		description: 'both hands reported the same voxel'.
]

{
	#category : #'tests - mapping',
	#'squeak_changestamp' : 'MCPServer 10/15/2026 15:47'
}
SWAGameXRMappingTest >> testFeetRestOnTheTopOfTheColumn [
	"The render position is the mob's centre, so its feet are half a body below.
	Those feet must sit exactly on the surface it is standing on."

	| mob pos feet surface |
	surface := 7.
	mob := self mobAtCellX: 10 z: 11 standingOn: surface.
	pos := xr worldPosForMob: mob.
	feet := pos y - (mob height / 2 * xr worldScale).
	self assert: (feet - (surface * xr worldScale)) abs < self tolerance.
]

{
	#category : #'tests - grass encoding',
	#'squeak_changestamp' : 'MCPServer 10/15/2026 15:47'
}
SWAGameXRMappingTest >> testGrassIsEncodedInGreenAndAlphaOnly [
	"A Form word reaches the GPU as BGRA, so red and blue swap places. Green and
	alpha are the only channels that survive, and the shader reads exactly those."

	| bare lush notGrassland green alpha red blue |
	green := [:w | (w bitShift: -8) bitAnd: 255].
	alpha := [:w | (w bitShift: -24) bitAnd: 255].
	red := [:w | (w bitShift: -16) bitAnd: 255].
	blue := [:w | w bitAnd: 255].

	notGrassland := xr grassWordForLevel: 0.
	self assert: notGrassland equals: 0 description: 'mask must be fully clear'.

	bare := xr grassWordForLevel: 1.
	self assert: (alpha value: bare) equals: 255.
	self assert: (green value: bare) equals: 0.

	lush := xr grassWordForLevel: xr grassShadeCount.
	self assert: (alpha value: lush) equals: 255.
	self assert: (green value: lush) equals: 255.

	self assert: (red value: lush) equals: 0.
	self assert: (blue value: lush) equals: 0.
]

{
	#category : #'tests - grass encoding',
	#'squeak_changestamp' : 'MCPServer 10/15/2026 15:47'
}
SWAGameXRMappingTest >> testGrassLevelMapsOntoTheShadePalette [
	"Index 1 is bare ground, not absent: 0 is reserved for 'not grassland'."

	| max |
	max := xr gameWorld maxGrass.
	self assert: (xr shadeIndexForGrass: 0) equals: 1.
	self assert: (xr shadeIndexForGrass: max) equals: xr grassShadeCount.
	self assert: (xr grassShadePalette size) equals: xr grassShadeCount.
]

{
	#category : #'tests - grass encoding',
	#'squeak_changestamp' : 'MCPServer 10/15/2026 15:53'
}
SWAGameXRMappingTest >> testGrassTextureSurvivesAnImageSave [
	"Saving the image hibernates Forms, compressing the Bitmap into a ByteArray.
	Storing a pixel word into that raised 'Improper store into indexable object'
	every frame and took terrain rendering down with it."

	| source |
	xr updateGrassTexture.
	source := xr instVarNamed: 'grassSource'.
	source form hibernate.
	self assert: source form bits class equals: ByteArray.
	self shouldnt: [xr updateGrassTexture] raise: Error.
	self assert: source form bits class equals: Bitmap.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'leo-MCPServer 11/25/2026 19:52'
}
SWAGameXRMappingTest >> testHeartsFaceTheAvatarBeingRendered [

	| world first second local |
	self assert: xr viewerPosition isNil.
	world := SRWorld new.
	world addChild: xr.
	self assert: xr viewerPosition isNil.
	first := SRAvatar new translation: 1 @ 0 @ 2; yourself.
	second := SRAvatar new translation: 5 @ 0 @ 5; yourself.
	world addChild: first; addChild: second.
	local := [:avatar | xr globalTransform globalPointToLocal: avatar camera globalTranslation].
	SRRenderingAvatarVariable value: second during: [
		self assert: (local value: second) equals: xr viewerPosition].
	self assert: (local value: first) equals: xr viewerPosition.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'leo-MCPServer 11/25/2026 19:52'
}
SWAGameXRMappingTest >> testLeavingWalkModeReturnsTheActingAvatarToTheOriginAndOthersBehind [

	| world first second |
	world := SRWorld new.
	first := SRAvatar desktop.
	second := SRAvatar xr.
	world addChild: first; addChild: second; addChild: xr.
	first translation: 3 @ 0 @ 3.
	second translation: 4 @ 0 @ 4.
	SRActingAvatarVariable value: second during: [xr exitWalkMode].
	self assert: Vector3 zero equals: second translation.
	self assert: 0m @ 0m @ 2.5m equals: first translation.
	xr exitWalkMode.
	self assert: Vector3 zero equals: first translation.
	self assert: 0m @ 0m @ 2.5m equals: second translation.
]

{
	#category : #'tests - mapping',
	#'squeak_changestamp' : 'MCPServer 10/15/2026 16:08'
}
SWAGameXRMappingTest >> testMesherAndMobsShareOneMapping [
	"The vertex positions and the mob positions have to come from the same
	origin and scale. Comparing the objects, not the numbers, is what makes a
	later divergence impossible rather than merely detectable."

	self assert: xr voxelChunks space == xr space.
	self assert: xr space worldScale equals: xr worldScale.
	self assert: xr space originX equals: xr gridWidth / 2.
	self assert: xr space originZ equals: xr gridDepth / 2.
]

{
	#category : #'tests - mapping',
	#'squeak_changestamp' : 'MCPServer 10/15/2026 15:47'
}
SWAGameXRMappingTest >> testOneCellOfTravelIsOneWorldScale [
	"Scale must apply once. Applying it twice still looks plausible standing
	still and only shows up as drift once something moves."

	| here there |
	here := xr worldPosForMob: (self mobAtCellX: 4 z: 4 standingOn: 4).
	there := xr worldPosForMob: (self mobAtCellX: 5 z: 4 standingOn: 4).
	self assert: ((there x - here x) - xr worldScale) abs < self tolerance.
	self assert: (there z - here z) abs < self tolerance.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 10/21/2026 09:55'
}
SWAGameXRMappingTest >> testPanelFacingIgnoresHeadPitchAndRoll [
	"Two bugs in one place. It used to adopt the camera's whole rotation, so a
	panel opened while looking down hung at that angle; then it used the camera's
	heading, which cannot point a panel standing 45 cm to the side at the player."

	| panelPos |
	panelPos := Vector3 x: 1 y: 1.2 z: 2.
	#( #(5 1.2 2) #(1 1.2 9) #(-3 -4 -1) #(2 9 5) ) do: [:each |
		| target probe normal toTarget |
		target := Vector3 x: each first y: each second z: each third.
		probe := SRObject new.
		probe rotation: (xr facingFrom: panelPos toward: target).
		normal := probe up.
		toTarget := target - panelPos.
		toTarget := (Vector3 x: toTarget x y: 0 z: toTarget z) normalized.
		"Upright whatever the height difference, and square on to the viewer."
		self assert: normal y abs < 0.001.
		self assert: ((normal dot: toTarget) - 1) abs < 0.01.
		"Rows run up the panel rather than across it, and this way up rather than
		the other: the pair of rotations that faces the viewer upside down also
		satisfies every assertion above."
		self assert: probe backward y < -0.999].
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 12:57'
}
SWAGameXRMappingTest >> testPartsOfTheGameBelongToIt [

	| part |
	part := SRObject new.
	xr addChild: (SRObject new addChild: part; yourself).
	self assert: xr equals: part app.
	self assert: xr equals: xr app.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 17:36'
}
SWAGameXRMappingTest >> testPickingReachesChunksAtNegativeCoordinates [
	"The ray walk used to clip to 0..marchExtent, so terrain grown towards
	negative coordinates could be seen but never picked."

	| world |
	world := xr gameWorld.
	world clearTerrain.
	world voxels clear.
	xr generateChunkAtX: -1 z: -1.
	#( #(-1 -1) #(-8 -8) #(-16 -16) #(-16 -1) ) do: [:pair |
		| cellX cellZ hit |
		cellX := pair first.
		cellZ := pair second.
		hit := self rayWalkDownOntoCellX: cellX z: cellZ on: xr.
		self deny: hit isNil.
		self assert: hit first equals: cellX.
		self assert: hit third equals: cellZ.
		self
			assert: hit second
			equals: (world heightAtX: cellX + 1 y: cellZ + 1) - 1].
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 17:36'
}
SWAGameXRMappingTest >> testPickingStopsAtUngeneratedChunks [
	"An ungenerated chunk holds no blocks at all, so a ray through it must miss
	rather than hit the flat floor the chunk markers stand on."

	| world |
	world := xr gameWorld.
	world clearTerrain.
	world voxels clear.
	xr generateChunkAtX: -1 z: -1.
	self deny: (self rayWalkDownOntoCellX: -1 z: -1 on: xr) isNil.
	self assert: (self rayWalkDownOntoCellX: -17 z: -17 on: xr) isNil.
	self assert: (self rayWalkDownOntoCellX: -17 z: -1 on: xr) isNil.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 11/4/2026 10:57'
}
SWAGameXRMappingTest >> testSettingsAreInACuratedSubmenuAndTheToolsStayAtTheTop [
	| menu rows settingsRow sub subRows |
	menu := SRMenu new.
	xr addCustomMenuItemsTo: menu.
	menu rebuild.
	rows := (menu children select: [:each | each isMenuItem]) collect: [:each | each label].
	"First person is the one toggle reached for in play, so it heads the top level."
	self assert: (rows first beginsWith: 'First person: ').
	self assert: 'Settings >' equals: rows second.
	"No other toggle leaks into the top level; the tools are what is left."
	(rows allButFirst: 2) do: [:each |
		self deny: (each includesSubstring: ': ON')
			description: each , ' is a toggle at the top level'].
	self assert: (rows includes: 'Pick Axe').
	settingsRow := menu children detect: [:each |
		each isMenuItem and: [each label = 'Settings >']].
	sub := menu openSubmenuFromItem: settingsRow filledBy: [:each |
		xr addSettingItemsTo: each].
	subRows := (sub children select: [:each | each isMenuItem]) collect: [:each | each label].
	#('Buttons: ' 'Graph: ' 'Terrain tools: '
	  'Chunk bounds: ' 'Locomotion: ') do: [:prefix |
		self
			assert: (subRows anySatisfy: [:each | each beginsWith: prefix])
			description: prefix , ' is missing from Settings'].
	self deny: (subRows anySatisfy: [:each | each beginsWith: 'First person: ']).
	"Every setting keeps the submenu open: you came here to change several."
	(sub children select: [:each | each isMenuItem]) do: [:each |
		self assert: each keepsMenuOpen description: each label , ' closes the menu'].
	"Hitting the row again closes it, rather than stacking a second submenu."
	self assert: (menu openSubmenuFromItem: settingsRow filledBy: [:each | each]) isNil.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'jl-MCPServer 11/25/2026 17:41'
}
SWAGameXRMappingTest >> testTheContextMenuOffersCloseAndItClosesTheMenu [
	| menu row |
	menu := SRMenu new.
	xr addCustomMenuItemsTo: menu.
	menu rebuild.
	row := menu children detect: [:each | each isMenuItem and: [each label = 'Close']] ifNone: [nil].
	self assert: row notNil.
	self deny: row keepsMenuOpen.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 11/3/2026 15:08'
}
SWAGameXRMappingTest >> testTheFrameOfATickDrawsTheLeftoverOfThePeriod [
	"Drawn at the end of the new segment instead, the mobs jumped back a whole step on the next frame."
	| period |
	period := xr instVarNamed: 'tickMillis'.
	xr step: period * 0.9.
	xr step: period * 0.3.
	self assert: ((xr instVarNamed: 'animT') closeTo: 0.2).
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 10/21/2026 11:12'
}
SWAGameXRMappingTest >> testTheGraphIsFedWithTheButtonSlabClosed [
	"The feed used to be called #updateCountLabels and #step: ran it only when
	showButtons was true, so the graph recorded nothing from the day the slabs
	stopped opening by default. Each readout is gated on its own flag now."

	| graph |
	graph := SWAGamePopGraph new.
	xr instVarNamed: 'popGraph' put: graph.
	xr instVarNamed: 'showGraph' put: true.
	xr instVarNamed: 'showButtons' put: false.
	self assert: (graph instVarNamed: 'rabbitHistory') isEmpty.
	"One whole tick, since the simulation only samples on a tick boundary."
	xr step: (xr instVarNamed: 'tickMillis') + 1.
	self deny: (graph instVarNamed: 'rabbitHistory') isEmpty.
	self deny: (graph instVarNamed: 'foxHistory') isEmpty.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 11/18/2026 18:35'
}
SWAGameXRMappingTest >> testTheTerrainIsGroundOnlyInFirstPerson [
	| scene probe gameWorld floor centre half |
	gameWorld := xr gameWorld.
	gameWorld clearTerrain.
	xr generateChunkAtX: 0 z: 0.
	gameWorld voxels clear.
	floor := 4.
	0 to: 15 do: [:cx |
		0 to: 15 do: [:cz |
			0 to: floor - 1 do: [:cy | gameWorld voxels at: cx at: cy at: cz put: 1]]].
	scene := SRObject new.
	probe := SRObject new.
	scene addChild: xr; addChild: probe.
	centre := xr globalPositionForCellX: 8.5 y: floor - 0.5 z: 8.5.
	half := Vector3 x: xr worldScale / 3 y: xr worldScale / 3 z: xr worldScale / 3.
	self deny: xr isSolid.
	self deny: ((SRSceneSolids forObject: probe) solidInBoxCenter: centre halfExtents: half).
	self assert: ((SRRay origin: centre + (0 @ 1 @ 0) forward: (0 @ -1 @ 0)) castNearestSolid: scene) isNil.
	xr instVarNamed: 'walkMode' put: true.
	self assert: xr isSolid.
	self assert: ((SRSceneSolids forObject: probe) solidInBoxCenter: centre halfExtents: half).
	self deny: ((SRRay origin: centre + (0 @ 1 @ 0) forward: (0 @ -1 @ 0)) castNearestSolid: scene) isNil.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (SqueakXR) 10/19/2026 14:53'
}
SWAGameXRMappingTest >> testTheTerrainIsSolidToTheBoxSweep [
	"How the player is stopped by terrain: the collider answers the same box query
	any SRCollisionGeometry does, so SRAvatar needs to know nothing about voxels.
	One SRCollisionBox per voxel would be millions of objects instead."

	| world floor collider half |
	world := xr gameWorld.
	world clearTerrain.
	xr generateChunkAtX: 0 z: 0.
	world voxels clear.
	floor := 4.
	0 to: 15 do: [:cx |
		0 to: 15 do: [:cz |
			0 to: floor - 1 do: [:cy | world voxels at: cx at: cy at: cz put: 1]]].
	collider := xr collisionGeometry.
	"A third of a cell, so the box cannot reach a neighbouring one."
	half := Vector3
		x: xr worldScale / 3
		y: xr worldScale / 3
		z: xr worldScale / 3.
	self assert: (collider
		intersectsBoxCenter: (xr globalPositionForCellX: 8.5 y: floor - 0.5 z: 8.5)
		halfExtents: half).
	self deny: (collider
		intersectsBoxCenter: (xr globalPositionForCellX: 8.5 y: floor + 2.5 z: 8.5)
		halfExtents: half).
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 10/21/2026 10:11'
}
SWAGameXRMappingTest >> testTheTerrainIsSolidToTheBoxSweepWhenTheGameIsTurned [
	"xrMenuSpawn: seats the game at a quarter-turn yaw, and a half turn sends the
	box's low corner to the high cell. Iterating from low to high then visited no
	cells at all and the terrain quietly stopped holding the player up."

	| world floor collider half |
	world := xr gameWorld.
	world clearTerrain.
	xr generateChunkAtX: 0 z: 0.
	world voxels clear.
	floor := 4.
	0 to: 15 do: [:cx |
		0 to: 15 do: [:cz |
			0 to: floor - 1 do: [:cy | world voxels at: cx at: cy at: cz put: 1]]].
	collider := xr collisionGeometry.
	half := Vector3
		x: xr worldScale / 3
		y: xr worldScale / 3
		z: xr worldScale / 3.
	#(0 90 180 270) do: [:yaw |
		xr rotation: (Quaternion angle: yaw axis: Vector3 up).
		self
			assert: (collider
				intersectsBoxCenter: (xr globalPositionForCellX: 8.5 y: floor - 0.5 z: 8.5)
				halfExtents: half)
			description: 'solid cell missed at yaw ' , yaw printString.
		self
			deny: (collider
				intersectsBoxCenter: (xr globalPositionForCellX: 8.5 y: floor + 2.5 z: 8.5)
				halfExtents: half)
			description: 'empty cell reported solid at yaw ' , yaw printString].
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer (jl) 11/13/2026 11:08'
}
SWAGameXRMappingTest >> testTheTraceGraphIsFedFromTheSelectedMob [

	| graph rabbit |
	graph := SWAGameMobTraceGraph new.
	rabbit := SWAGameRabbit new.
	xr instVarNamed: 'traceGraph' put: graph.
	xr instVarNamed: 'selectedMob' put: rabbit.
	(xr instVarNamed: 'mobObjects') add: (SWAGameMobEntry new from: Vector3 zero to: (Vector3 x: 1 y: 0 z: 0); mob: rabbit; yourself).
	xr step: 10.
	xr step: 10.
	self assert: graph samples size = 2.
	self assert: graph mob == rabbit.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer 10/16/2026 13:54'
}
SWAGameXRMappingTest >> testTogglingAfterAPanelWasRemovedByItsHaloReopensIt [
	"The Remove halo item dismisses a panel without passing through the toggles.
	The flag went on saying ON, so the menu label lied and the next toggle only
	cleared the flag -- it took two toggles to see the panel again."

	"A stand-in panel rather than a real slab: building one needs a world, and
	what is under test is the bookkeeping, not the geometry."

	| host panel |
	host := SRObject new.
	panel := SRObject new.
	host addChild: panel.
	xr instVarNamed: 'toolSlab' put: panel.
	xr instVarNamed: 'showTools' put: true.
	self assert: panel isOpen.

	panel remove.
	self deny: panel isOpen.
	xr reconcilePanels.
	self assert: (xr instVarNamed: 'showTools') not.
	self assert: (xr instVarNamed: 'toolSlab') isNil.

	"And the other direction: the flag claiming ON with nothing built."
	xr instVarNamed: 'showButtons' put: true.
	xr instVarNamed: 'buttonSlab' put: nil.
	xr reconcilePanels.
	self assert: (xr instVarNamed: 'showButtons') not.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'leo-MCPServer 11/25/2026 19:51'
}
SWAGameXRMappingTest >> testToolRowsMarkTheHandHoldingThem [
	"Each row arms the hand that reached for it, so the row has to be able to
	say both. SWAGameXR>>tools answers fresh instances, so the row recognises
	what a hand holds by #isSameToolAs: rather than by identity."

	| world avatar menu rowNamed arm |
	world := SRWorld new.
	avatar := SRAvatar new.
	world addChild: avatar.
	world addChild: xr.
	menu := SRMenu new sticky: true; yourself.
	xr addToolItemsTo: menu.
	menu rebuild.
	rowNamed := [:prefix |
		menu children detect: [:each |
			each isMenuItem and: [each label beginsWith: prefix]]].
	arm := [:prefix :hand |
		(rowNamed value: prefix) action value: nil value: hand.
		menu rebuild].

	self assert: 'Bare hand [L] [R]' equals: (rowNamed value: 'Bare hand') label.

	arm value: 'Pick Axe' value: avatar rightHand.
	self assert: 'Pick Axe [R]' equals: (rowNamed value: 'Pick Axe') label.
	self assert: 'Bare hand [L]' equals: (rowNamed value: 'Bare hand') label.

	"The same kind of tool in both hands: one row, two marks."
	arm value: 'Pick Axe' value: avatar leftHand.
	self assert: 'Pick Axe [L] [R]' equals: (rowNamed value: 'Pick Axe') label.

	"A place tool differs from another by its material, not its class."
	arm value: 'Grass' value: avatar leftHand.
	self assert: 'Grass [L]' equals: (rowNamed value: 'Grass') label.
	self assert: 'Pick Axe [R]' equals: (rowNamed value: 'Pick Axe') label.
	self assert: 'Dirt' equals: (rowNamed value: 'Dirt') label.
]

{
	#category : #tests,
	#'squeak_changestamp' : 'MCPServer 10/16/2026 09:41'
}
SWAGameXRMappingTest >> testVoxelHitPointLandsOnTheColumnSurface [
	"The point teleport now lands the avatar on. The collider used to carry its
	own copy of the cell-to-object arithmetic next to SWAGameSpace's."

	| world collider ray result topY |
	world := xr gameWorld.
	world clearTerrain.
	world voxels clear.
	xr generateChunkAtX: 0 z: 0.
	collider := SWAGameVoxelCollider new game: xr; yourself.
	ray := SRRay
		origin: (xr globalPositionForCellX: 8.5 y: xr gridHeight z: 8.5)
		forward: (Vector3 x: 0 y: -1 z: 0).
	result := collider rayIntersection: ray.
	self deny: result isNil.
	topY := (xr globalPositionForCellX: 8.5 y: (world heightAtX: 9 y: 9) z: 8.5) y.
	self assert: (result point y - topY) abs < 0.01.
	self assert: (result point x - (xr globalPositionForCellX: 8.5 y: 0 z: 8.5) x) abs < 0.01.
]

{
	#category : #helpers,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 15:47'
}
SWAGameXRMappingTest >> tolerance [
	"Vector3 holds single precision floats, so roughly seven digits. Demanding
	double precision here fails on correct arithmetic."

	^ 1e-6
]
