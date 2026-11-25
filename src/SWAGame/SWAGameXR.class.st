"
The game as an object in the XR scene: owns a SWAGameWorld and draws it.

Documentation: doc/swagame in the mysqueak repository.
"
Class {
	#name : #SWAGameXR,
	#superclass : #SRObject,
	#instVars : [
		'gridHandle',
		'gridWidth',
		'gridDepth',
		'gridHeight',
		'groundPlane',
		'worldScale',
		'world',
		'mobObjects',
		'tickElapsed',
		'animT',
		'tickMillis',
		'mobSnapshots',
		'rabbitLabel',
		'foxLabel',
		'paused',
		'pauseLabel',
		'selectedMobLabel',
		'showBars',
		'barsLabel',
		'selectedSpecies',
		'rabbitBtn',
		'foxBtn',
		'selectedMob',
		'mobInspector',
		'popGraph',
		'buttonSlab',
		'voxelChunks',
		'chunkRebuildBudget',
		'voxelMeshMaterial',
		'voxelMeshSRShader',
		'lineThickness',
		'showButtons',
		'showGraph',
		'toolSlab',
		'selectedTool',
		'toolButtons',
		'showTools',
		'voxelCollider',
		'lastVoxelHit',
		'rlMobPos',
		'rlBarPos',
		'rlScratchColor',
		'rlEnergyBackColor',
		'rlHighlightColor',
		'rlAgeYoungColor',
		'rlAgeOldColor',
		'rlVoxelTransform',
		'voxelThicknessBuffer',
		'rlMobColors',
		'grassShadePalette',
		'grassShadeApplied',
		'grassTexture',
		'grassSource',
		'voxelWorldScaleBuffer',
		'voxelGridExtentBuffer',
		'showChunkBounds',
		'rlChunkPos',
		'rlChunkColor',
		'space',
		'chunkMarkers',
		'walkMode',
		'handTargets',
		'rlTargetPos',
		'mobRenderer',
		'traceGraph',
		'petSound',
		'hearts',
		'petSoundMob',
		'vegetation'
	],
	#classVars : [
		'AnimalModels',
		'BlockOutlines',
		'BlockTextures',
		'SimulationRadiusChunks'
	],
	#category : #'SWAGame-XR',
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}

{
	#category : #avatars,
	#'squeak_changestamp' : 'leo-MCPServer 11/25/2026 19:52'
}
SWAGameXR class >> actingAvatarIn: aWorld [

	aWorld ifNil: [^ nil].
	^ aWorld actingAvatar ifNil: [self firstAvatarIn: aWorld]
]

{
	#category : #preferences,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 16:32'
}
SWAGameXR class >> animalModels [
	<preference: 'Animal models'
		category: 'SWAGame'
		description: 'Draw rabbits and foxes as animated blocky animals. Off, each is a coloured cube.'
		type: #Boolean>
	^ AnimalModels ifNil: [true]
]

{
	#category : #preferences,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 16:32'
}
SWAGameXR class >> animalModels: aBoolean [
	AnimalModels := aBoolean.
]

{
	#category : #preferences,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 16:32'
}
SWAGameXR class >> blockOutlines [
	<preference: 'Block outlines'
		category: 'SWAGame'
		description: 'Draw a line round every face of every block, the 3D grid. Off, the block patterns show the edges on their own.'
		type: #Boolean>
	^ BlockOutlines ifNil: [false]
]

{
	#category : #preferences,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 16:32'
}
SWAGameXR class >> blockOutlines: aBoolean [
	BlockOutlines := aBoolean.
]

{
	#category : #preferences,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 16:32'
}
SWAGameXR class >> blockTextures [
	<preference: 'Block textures'
		category: 'SWAGame'
		description: 'Give grass, dirt, sand, rock, snow and water their pixel pattern. Off, every block is its plain colour.'
		type: #Boolean>
	^ BlockTextures ifNil: [true]
]

{
	#category : #preferences,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 16:32'
}
SWAGameXR class >> blockTextures: aBoolean [
	BlockTextures := aBoolean.
]

{
	#category : #'instance creation',
	#'squeak_changestamp' : 'MCPServer 4/22/2026 15:24'
}
SWAGameXR class >> boardGameScale [
	"Create a board game scaled world (0.1x)"
	^self newWithScale: 0.1
]

{
	#category : #'terrain editing',
	#'squeak_changestamp' : 'MCPServer 7/29/2026 13:14'
}
SWAGameXR class >> colorForMaterial: aSymbol [
	"Answer the cube color for a terrain material symbol, or magenta if unknown."
	^ (self terrainMaterials
		detect: [:each | each first == aSymbol]
		ifNone: [^ Color magenta]) third
]

{
	#category : #avatars,
	#'squeak_changestamp' : 'leo-MCPServer 11/25/2026 19:52'
}
SWAGameXR class >> firstAvatarIn: aWorld [
	"The fallback when SWAGame has no acting or rendering avatar to go by."

	aWorld ifNil: [^ nil].
	aWorld avatarsDo: [:each | ^ each].
	^ nil
]

{
	#category : #'instance creation',
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameXR class >> newWithScale: aScale [
	^self new worldScale: aScale; yourself
]

{
	#category : #constants,
	#'squeak_changestamp' : 'MCPServer (leo) 11/5/2026 17:49'
}
SWAGameXR class >> petReach [

	^ 0.6
]

{
	#category : #constants,
	#'squeak_changestamp' : 'MCPServer (leo) 11/5/2026 17:49'
}
SWAGameXR class >> petSoundPath [

	^ 'C:\Users\leona\Downloads\575759__code_box__rabbit-bop.ogg'
]

{
	#category : #preferences,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 16:42'
}
SWAGameXR class >> simulationRadiusChunks [
	<preference: 'Simulation radius (chunks)'
		category: 'SWAGame'
		description: 'How many 16 cell chunks around the player keep ticking. 0 means no limit, which is what a world only two chunks across wants.'
		type: #Number>
	^ SimulationRadiusChunks ifNil: [0]
]

{
	#category : #preferences,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 16:42'
}
SWAGameXR class >> simulationRadiusChunks: aNumber [

	SimulationRadiusChunks := aNumber
]

{
	#category : #'xr menu',
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameXR class >> spawnDistance [
	^ self startCells * self tableWorldScale / 2 + 70 cm
]

{
	#category : #'xr menu',
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 16:38'
}
SWAGameXR class >> startCells [
	^ self startChunks * SWAGameChunk size
]

{
	#category : #'xr menu',
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameXR class >> startChunks [
	^ 3
]

{
	#category : #'shader sources',
	#'squeak_changestamp' : 'MCPServer (leo) 11/3/2026 12:03'
}
SWAGameXR class >> swagameTerrain [
	<shaderSource: #swagameTerrain>
	"The terrain: a 16-pixel pattern per block type, grass tinted on upward faces, and an outline per face.

	The vertex colour alpha is the block type id (SWAGameBlocks class>>rgbaFor:), so the
	pattern needs no texture and no extra vertex attribute.

	Grass level arrives as a grid-sized texture rather than as vertex colour,
	because grass changes a few hundred times a second and baking it into the
	mesh leaves every chunk permanently dirty.

	The grass map is sampled from the object-space position, which inverts the
	mapping in SWAGameVoxelChunks>>writeQuadVerts:...: a vertex sits at
	(cell + corner - gridExtent/2) * worldScale.

	Green and alpha carry level and grassland mask, because an SRTextureSource
	is BGRA and only those two channels survive the red/blue swap unchanged."
	^ {
		#uniforms -> #(lineThickness worldScale gridExtent grassMap blockTextures).
		#vert -> '
#version 450

layout(location = 0) in vec3 vertexPosition;
layout(location = 1) in vec2 vertexTexCoord;
layout(location = 2) in vec3 vertexNormal;
layout(location = 3) in vec4 vertexColor;

layout(location = 0) uniform mat4 mvp;
layout(location = 1) uniform mat4 matNormal;
layout(location = 7) uniform mat4 matModel;

layout(location = 0) out vec2 fragTexCoord;
layout(location = 1) out vec4 fragColor;
layout(location = 2) out vec3 fragNormal;
layout(location = 3) out vec3 fragObjPos;
layout(location = 4) out vec3 fragObjNormal;
layout(location = 5) out vec3 fragPosition;

void main()
{
    fragTexCoord = vertexTexCoord;
    fragColor = vertexColor;
    fragNormal = normalize(vec3(matNormal*vec4(vertexNormal, 0.0)));
    fragObjPos = vertexPosition;
    fragObjNormal = vertexNormal;
    fragPosition = vec3(matModel*vec4(vertexPosition, 1.0));

    gl_Position = mvp*vec4(vertexPosition, 1.0);
}
'.
		#frag -> ('
#version 450
', (SRLight glslLightingFrom: 8), '
layout(location = 0) in vec2 fragTexCoord;
layout(location = 1) in vec4 fragColor;
layout(location = 2) in vec3 fragNormal;
layout(location = 3) in vec3 fragObjPos;
layout(location = 4) in vec3 fragObjNormal;
layout(location = 5) in vec3 fragPosition;

layout(location = 2) uniform vec4 colDiffuse;
layout(location = 3) uniform float lineThickness;
layout(location = 4) uniform float worldScale;
layout(location = 5) uniform vec2 gridExtent;
layout(location = 6) uniform float blockTextures;
layout(binding = 1) uniform sampler2D grassMap;

layout(location = 0) out vec4 finalColor;

uint hash(ivec3 v)
{
    uint h = uint(v.x) * 1597334677u ^ uint(v.y) * 3812015801u ^ uint(v.z) * 2798796415u;
    h ^= h >> 15;
    h *= 2246822519u;
    h ^= h >> 13;
    h *= 3266489917u;
    h ^= h >> 16;
    return h;
}

float rnd(ivec3 v)
{
    return float(hash(v) & 65535u) / 65535.0;
}

// Ids as in SWAGameBlocks class>>types: grass, dirt, sand, rock, snow, water.
vec3 blockPattern(int type, vec3 base, ivec3 texel, float row, bool top, bool bottom, float cellY)
{
    vec3 dirt = vec3(0.45, 0.32, 0.2);
    float r = rnd(texel);
    if (type == 1) {
        if (top) return base * (0.82 + 0.3 * r);
        // Grass hangs over the side by two to four pixels, per column.
        float h = 2.0 + floor(rnd(ivec3(texel.x, int(cellY) * 7 + 31, texel.z)) * 3.0);
        if (!bottom && row >= 16.0 - h) return base * (0.8 + 0.3 * r);
        return dirt * (0.8 + 0.35 * r);
    }
    if (type == 2) {
        if (r < 0.05) return base * 0.6;
        return base * (0.78 + 0.35 * r);
    }
    if (type == 3) {
        if (r > 0.94) return base * 1.12;
        if (r < 0.06) return base * 0.8;
        return base * (0.88 + 0.14 * r);
    }
    if (type == 4) {
        if (r < 0.04) return base * 0.5;
        float blotch = rnd((texel >> 1) + ivec3(17));
        return base * (0.72 + 0.22 * blotch + 0.12 * r);
    }
    if (type == 5) return base * (0.94 + 0.06 * r);
    if (type == 6) {
        float streak = rnd(ivec3(texel.x >> 2, texel.y, texel.z));
        return base * (0.85 + 0.2 * streak + 0.05 * r);
    }
    return base;
}

void main()
{
    vec3 n = normalize(fragNormal);
    vec3 on = fragObjNormal;
    vec4 baseColor = colDiffuse * vec4(fragColor.rgb, 1.0);
    int type = int(fragColor.a * 255.0 + 0.5);

    // Cell space, inverting SWAGameVoxelChunks>>writeQuadVerts:...; half a pixel
    // inside the face, so the pixel belongs to this block and not its neighbour.
    vec3 p = fragObjPos / worldScale + vec3(gridExtent.x * 0.5, 0.0, gridExtent.y * 0.5);
    vec3 cell = floor(p - on * 0.5);
    vec3 local = p - cell;
    ivec3 texel = ivec3(floor((p - on * (0.5 / 16.0)) * 16.0));
    bool top = on.y > 0.5;
    bool bottom = on.y < -0.5;

    vec3 patterned = blockPattern(type, baseColor.rgb, texel, floor(local.y * 16.0), top, bottom, cell.y);
    // Once a block pixel is smaller than a screen pixel the pattern only shimmers,
    // as on the table, so it fades to its average there. Derived from p, not from
    // local: local jumps at block borders, which would flatten every face edge.
    float footprint = 16.0 * max(length(dFdx(p)), length(dFdy(p)));
    float detail = (1.0 - smoothstep(0.7, 1.5, footprint)) * blockTextures;
    vec3 plain = (type == 1 && !top) ? mix(vec3(0.45, 0.32, 0.2), baseColor.rgb, 0.25) : baseColor.rgb * 0.95;
    baseColor.rgb = mix(plain, patterned, detail);

    // Grass only on upward faces, faded in so a chamfered normal does not pop.
    float topness = smoothstep(0.75, 0.95, n.y);
    if (topness > 0.0) {
        // Sampled at the texel centre: the grass map is bilinear, and sampling
        // the continuous position bleeds a cell into its neighbours, which puts
        // pasture colour on the water and rock next to it.
        vec2 cell = floor(fragObjPos.xz / worldScale + gridExtent * 0.5);
        vec4 g = textureLod(grassMap, (cell + 0.5) / gridExtent, 0.0);
        // Grazed ground fades towards bare earth and grows back to the terrain
        // colour itself, so the height palette survives instead of being
        // replaced by a flat grey.
        vec3 earth = vec3(0.42, 0.35, 0.26);
        vec3 grazed = mix(earth, baseColor.rgb, 0.25);
        baseColor.rgb = mix(baseColor.rgb, mix(grazed, baseColor.rgb, g.g), topness * g.a);
    }

    vec3 lit = baseColor.rgb * diffuseLighting(fragPosition, n);

    // Distance to the nearest face border, expressed in pixels.
    vec2 fw = max(fwidth(fragTexCoord), vec2(1e-6));
    vec2 d = min(fragTexCoord, vec2(1.0) - fragTexCoord) / fw;
    float px = min(d.x, d.y);

    float halfW = lineThickness * 0.5;
    float edge = 1.0 - smoothstep(halfW - 0.5, halfW + 0.5, px);
    edge *= step(0.001, lineThickness);

    finalColor = vec4(mix(lit, lit * 0.5, edge), 1.0);
}
')
	} as: Dictionary
]

{
	#category : #preferences,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameXR class >> tableWorldScale [
	^ 5 cm
]

{
	#category : #'terrain editing',
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameXR class >> terrainMaterials [
	"#(symbol label color), in tool row order."
	^ {
		{#grass. 'Grass'. Color r: 0.25 g: 0.7 b: 0.25}.
		{#dirt. 'Dirt'. Color r: 0.45 g: 0.32 b: 0.2}.
		{#sand. 'Sand'. Color r: 0.86 g: 0.78 b: 0.45}.
		{#rock. 'Rock'. Color r: 0.5 g: 0.5 b: 0.55}.
		{#snow. 'Snow'. Color r: 0.95 g: 0.96 b: 1.0}.
		{#water. 'Water'. Color r: 0.15 g: 0.35 b: 0.85}}
]

{
	#category : #avatars,
	#'squeak_changestamp' : 'leo-MCPServer 11/25/2026 19:52'
}
SWAGameXR class >> viewingAvatarIn: aWorld [

	^ SRRenderingAvatarVariable value ifNil: [self firstAvatarIn: aWorld]
]

{
	#category : #'xr menu',
	#'squeak_changestamp' : 'leo-MCPServer 11/25/2026 19:52'
}
SWAGameXR class >> xrMenuSpawn: aMenu [
	<xrMenu: #(world games) label: 'SWAGame' priority: 250>
	"On the floor ahead of the viewer: the game's origin is at ground level."
	| xrWorld camera forward ahead game yaw |
	xrWorld := aMenu world.
	camera := (self actingAvatarIn: xrWorld) ifNil: [^ nil] ifNotNil: [:avatar | avatar camera].
	forward := camera globalTransform localDirToGlobal: Vector3 forward.
	"Flatten to the horizontal plane, so looking down does not pull the game in."
	forward := Vector3 x: forward x y: 0 z: forward z.
	forward isZero ifTrue: [forward := Vector3 forward].
	ahead := camera globalTranslation + (forward normalized * self spawnDistance).
	"Quarter turns keep the grid square to the room; the half turn because
	the game's +z runs away from the viewer."
	yaw := 180 + (((forward x arcTan: forward z) radiansToDegrees / 90) rounded * 90).
	game := self new
		position: (Vector3 x: ahead x y: 0 z: ahead z);
		rotation: (Quaternion angle: yaw axis: Vector3 up);
		yourself.
	xrWorld addChild: game.
	game generateWorld.
	^ game
]

{
	#category : #avatars,
	#'squeak_changestamp' : 'leo-MCPServer 11/25/2026 19:52'
}
SWAGameXR >> actingAvatar [

	^ self class actingAvatarIn: self world
]

{
	#category : #menus,
	#'squeak_changestamp' : 'jl 11/4/2026 10:50'
}
SWAGameXR >> addCustomMenuItemsTo: aMenu [
	"The settings are curated into one submenu rather than listed here: the top
	level is what you reach for in play, and eight toggles pushed the tools off
	the bottom of it."
	"Reconciles the flags, not the labels: a panel removed by its halo leaves the
	flag claiming it is open, and the next toggle would only clear the flag."
	self reconcilePanels.
	aMenu addItem: ['First person: ', ((walkMode ifNil: [false]) ifTrue: ['ON'] ifFalse: ['off'])]
		action: [self toggleWalkMode] keepOpen: true.
	aMenu addSubmenuItemFor: #settings filledBy: [:sub | self addSettingItemsTo: sub].
	aMenu addSubmenuItemFor: #scenarios filledBy: [:sub | self addScenarioItemsTo: sub].
	aMenu addSubmenuItemFor: #game filledBy: [:sub | self addGameItemsTo: sub].
	aMenu
		addItem: 'Spawn gun'
		action: [:item :hand | self spawnGunFor: hand]
		keepOpen: false.
	self addToolItemsTo: aMenu
]

{
	#category : #menus,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 14:37'
}
SWAGameXR >> addGameItemsTo: aMenu [
	"Saved games are JSON in swagame-worlds next to the image: terrain, mobs and
	this game's own parameters."
	| saved |
	aMenu
		addItem: [saved ifNil: ['Save game'] ifNotNil: ['Saved as ', saved]]
		action: [saved := world saveAs: SWAGameWorld nextSavedName]
		keepOpen: true.
	SWAGameWorld savedNames do: [:each |
		aMenu
			addItem: 'Load ', each
			action: [self adoptWorld: (SWAGameWorld loadNamed: each)]
			keepOpen: false].
]

{
	#category : #menus,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 14:36'
}
SWAGameXR >> addScenarioItemsTo: aMenu [
	"Applies to this game only; the image preferences stay the defaults for games
	that set nothing. Rows are filled when the submenu opens, so a scenario saved
	from here shows up as a row the next time; until then the save row names it."
	| saved |
	SWAGameScenario all do: [:each |
		aMenu
			addItem: [each name, ((world isScenarioActive: each) ifTrue: [' [active]'] ifFalse: [''])]
			action: [world applyScenario: each]
			keepOpen: true].
	aMenu
		addItem: ['Image defaults', (world config isEmpty ifTrue: [' [active]'] ifFalse: [''])]
		action: [world useImageDefaults]
		keepOpen: true.
	aMenu
		addItem: [saved
			ifNil: ['Save current']
			ifNotNil: ['Saved as ', saved name]]
		action: [
			saved := world currentScenario
				name: SWAGameScenario nextSavedName;
				save;
				yourself]
		keepOpen: true.
]

{
	#category : #menus,
	#'squeak_changestamp' : 'MCPServer (jl) 11/4/2026 10:55'
}
SWAGameXR >> addSettingItemsTo: aMenu [
	"Every row is a toggle, so every row keeps the menu open and names the state
	it is in. The labels are blocks: the menu stays in front of the player while
	the settings change under it."

	aMenu addItem: ['Buttons: ', (showButtons ifTrue: ['ON'] ifFalse: ['off'])]
		action: [
			self toggleButtons.
			"Opened from the menu, so it opens where the menu is -- which is where
			the hand put it. Otherwise it appears beside the board, which in walk
			mode is 16 m away."
			showButtons ifTrue: [self placePanel: buttonSlab besideMenu: aMenu]]
		keepOpen: true.
	aMenu addItem: ['Graph: ', (showGraph ifTrue: ['ON'] ifFalse: ['off'])]
		action: [
			self toggleGraph.
			showGraph ifTrue: [self placePanel: popGraph besideMenu: aMenu]]
		keepOpen: true.
	aMenu addItem: ['Mob trace: ', (traceGraph ifNil: ['off'] ifNotNil: ['ON'])]
		action: [
			self toggleTraceGraph.
			traceGraph ifNotNil: [self placePanel: traceGraph besideMenu: aMenu]]
		keepOpen: true.
	aMenu addItem: ['Terrain tools: ', ((showTools ifNil: [false]) ifTrue: ['ON'] ifFalse: ['off'])]
		action: [
			self toggleTools.
			(showTools ifNil: [false]) ifTrue: [self placePanel: toolSlab besideMenu: aMenu]]
		keepOpen: true.
	aMenu addItem: ['Energy bars: ', ((showBars ifNil: [false]) ifTrue: ['ON'] ifFalse: ['off'])]
		action: [self toggleBars] keepOpen: true.
	aMenu addItem: ['Simulation: ', ((paused ifNil: [false]) ifTrue: ['paused'] ifFalse: ['running'])]
		action: [self togglePause] keepOpen: true.
	aMenu addItem: ['Chunk bounds: ', ((showChunkBounds ifNil: [false]) ifTrue: ['ON'] ifFalse: ['off'])]
		action: [self toggleChunkBounds] keepOpen: true.
	"Preferences, so global like the locomotion row below: every game shows them."
	aMenu addItem: ['Block outlines: ', (self class blockOutlines ifTrue: ['ON'] ifFalse: ['off'])]
		action: [self class blockOutlines: self class blockOutlines not] keepOpen: true.
	aMenu addItem: ['Block textures: ', (self class blockTextures ifTrue: ['ON'] ifFalse: ['off'])]
		action: [self class blockTextures: self class blockTextures not] keepOpen: true.
	aMenu addItem: ['Animal models: ', (self class animalModels ifTrue: ['ON'] ifFalse: ['off'])]
		action: [self class animalModels: self class animalModels not] keepOpen: true.
	"Both states are a mode rather than on and off, so the row names the one in
	force. The preference is global, not the game's: SRAvatar reads it."
	aMenu addItem: ['Locomotion: ', (SRAvatar continuousLocomotion
		ifTrue: ['continuous'] ifFalse: ['teleport'])]
		action: [SRAvatar continuousLocomotion: SRAvatar continuousLocomotion not]
		keepOpen: true.
]

{
	#category : #tools,
	#'squeak_changestamp' : 'MCPServer (jl) 10/21/2026 11:06'
}
SWAGameXR >> addToolItemsTo: aMenu [
	"Rows stay open so both hands can be armed from one menu, and each arms the
	hand that reached for it."

	aMenu
		addItem: ['Bare hand' , (self handMarkerFor: nil)]
		action: [:item :hand | hand ifNotNil: [hand tool: nil]]
		keepOpen: true.
	self tools do: [:each |
		aMenu
			addItem: [each label , (self handMarkerFor: each)]
			action: [:item :hand | hand ifNotNil: [hand tool: each]]
			keepOpen: true].
]

{
	#category : #game,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameXR >> adoptWorld: aWorld [
	"Swapped between frames, so the renderer never draws half of each game."
	| swap |
	swap := [
		world := aWorld.
		gridHandle := aWorld ensureVoxels.
		gridWidth := aWorld gridSize.
		gridDepth := aWorld gridSize.
		gridHeight := gridHandle height.
		space := nil.
		voxelChunks
			setGrid: gridHandle
			width: gridWidth height: gridHeight depth: gridDepth
			worldScale: worldScale.
		voxelChunks space: self space.
		grassTexture ifNotNil: [:texture | texture unload].
		grassSource := nil.
		grassTexture := nil.
		grassShadeApplied := nil.
		mobSnapshots := Dictionary new.
		mobObjects := OrderedCollection new.
		selectedMob := nil.
		mobInspector ifNotNil: [mobInspector mob: nil].
		lastVoxelHit := nil.
		voxelChunks markAllDirty.
		self refreshChunkMarkers.
		self buildMobAnimationData.
		self samplePopulations].
	self world
		ifNil: [swap value]
		ifNotNil: [:scene | scene addDeferredFrameMessage: swap]
]

{
	#category : #mobs,
	#'squeak_changestamp' : 'MCPServer (jl) 11/13/2026 11:08'
}
SWAGameXR >> advanceGaits [
	| seconds |
	seconds := tickMillis / 1000.0.
	mobObjects do: [:entry |
		entry isBody ifFalse: [
			self mobRenderer
				noteTickOf: entry mob
				from: entry from
				to: entry to
				worldScale: worldScale
				seconds: seconds]].
]

{
	#category : #simulation,
	#'squeak_changestamp' : 'MCPServer (jl) 11/10/2026 19:40'
}
SWAGameXR >> aimDistanceFrom: startPoint to: endPoint [
	"Mobs are not in the collision scene, so a ray cast passes through them."

	^ (self mobHitFrom: startPoint to: endPoint) ifNotNil: [:mob |
		((self globalTransform localPointToGlobal: (self worldPosForMob: mob)) - startPoint)
			dot: (endPoint - startPoint) normalized]
]

{
	#category : #'terrain editing',
	#'squeak_changestamp' : 'MCPServer (SqueakXR) 10/20/2026 10:59'
}
SWAGameXR >> applyToolAtX: gx y: gy z: gz face: aFaceNormal [
	"Run the active terrain tool on the voxel (gx, gy, gz) that was clicked.
	 The pick axe digs that very cube out; every other tool places a cube of
	 that material in the empty cell on the side that was clicked."
	selectedTool == #pickaxe
		ifTrue: [self digAtX: gx y: gy z: gz]
		ifFalse: [self placeAtX: gx y: gy z: gz face: aFaceNormal material: selectedTool]
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'jl-MCPServer 11/20/2026 14:09'
}
SWAGameXR >> avatarsDo: aBlock [
	"#world, not #currentXRWorld, see #handMarkerFor:."
	self world ifNotNil: [:w | w avatarsDo: aBlock].
]

{
	#category : #panels,
	#'squeak_changestamp' : 'leo-MCPServer 11/25/2026 19:48'
}
SWAGameXR >> bringPanelsToHand: aHand [
	"Walk mode has no table to stand the panels beside, so they come to the
	player the way the context menu does: the avatar's own placement, so they
	land where the hands are already calibrated for, and the camera's viewing
	direction, so a slab is read face on rather than edge on.

	The two slabs are offset sideways from each other, otherwise they occupy the
	same spot."

	| avatar |
	avatar := aHand avatar.
	avatar ifNil: [^ self].
	self
		placePanelsAt: (avatar menuPlacementPositionForHand: aHand)
		facing: avatar camera
]

{
	#category : #mobs,
	#'squeak_changestamp' : 'MCPServer (jl) 11/13/2026 11:08'
}
SWAGameXR >> buildMobAnimationData [
	"Reused across ticks: fresh entries held by the old game fill the remembered set."
	| mobScale count fill |
	mobObjects ifNil: [mobObjects := OrderedCollection new].
	mobScale := worldScale * 0.5.
	count := 0.
	fill := [:mob :remainsOrNil |
		| entry toPos |
		count := count + 1.
		count > mobObjects size ifTrue: [mobObjects add: SWAGameMobEntry new].
		entry := mobObjects at: count.
		toPos := self worldPosForMob: mob.
		entry
			setMob: mob
			from: (mobSnapshots at: mob ifAbsent: [toPos])
			to: toPos
			scale: mobScale
			colors: (self rlColorsForMobColor: mob color)
			gait: (self mobRenderer gaitFor: mob)
			remains: remainsOrNil.
		remainsOrNil ifNotNil: [entry gait settle]].
	world mobsDo: [:mob | fill value: mob value: nil].
	world corpsesDo: [:mob | fill value: mob value: mob remains].
	[mobObjects size > count] whileTrue: [mobObjects removeLast].
	self mobRenderer pruneGaitsBeyond: count.
]

{
	#category : #watering,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:18'
}
SWAGameXR >> canGrowAtX: gx y: gy z: gz [

	^ (self topFilledYAtX: gx z: gz) = gy
		and: [(gridHandle at: gx at: gy at: gz) ~= (SWAGameBlocks idFor: #water)]
]

{
	#category : #'world generation',
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameXR >> candidateChunkKeys [
	| found |
	found := Set new.
	world generatedChunks do: [:key |
		| cx cz |
		cx := world chunkXOfKey: key.
		cz := world chunkZOfKey: key.
		{cx - 1 @ cz. cx + 1 @ cz. cx @ (cz - 1). cx @ (cz + 1)} do: [:each |
			(world isChunkGeneratedX: each x z: each y)
				ifFalse: [found add: each]]].
	^ found
]

{
	#category : #mapping,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameXR >> cellPositionForGlobal: aVector3 [
	"Inverse of #globalPositionForCellX:y:z:."

	| local |
	local := self globalTransform globalPointToLocal: aVector3.
	^ Vector3
		x: (self space cellXForObjectX: local x)
		y: local y / self space worldScale
		z: (self space cellZForObjectZ: local z)
]

{
	#category : #mapping,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameXR >> cellPositionOf: anSRObject [
	"Global: cameras and hands are children of the avatar rig."

	^ self cellPositionForGlobal: anSRObject globalTranslation
]

{
	#category : #'world generation',
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameXR >> chunkMarkerSize [
	"Capped at what a standing player can reach."

	^ (worldScale * 6) min: 120 cm
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameXR >> chunkRebuildBudget [
	^ chunkRebuildBudget ifNil: [chunkRebuildBudget := 2]
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 7/30/2026 10:10'
}
SWAGameXR >> chunkRebuildBudget: anInteger [
	chunkRebuildBudget := anInteger max: 1
]

{
	#category : #rendering,
	#'squeak_changestamp' : 'MCPServer 7/29/2026 18:06'
}
SWAGameXR >> collisionGeometry [
	"One collider for the whole voxel world. This used to be nil, with a per-column
	 SWAGameTerrainTile carrying an SRCollisionBox for click detection -- which
	 meant gridWidth*gridDepth boxes tested per ray and, worse, only ever the top
	 block of a column: you could not click the wall of a hole you had just dug.
	 The DDA collider is both cheaper (O(ray length), not O(voxels)) and exact on
	 all six faces of every voxel."
	^ voxelCollider ifNil: [
		voxelCollider := SWAGameVoxelCollider new
			game: self;
			object: self;
			yourself]
]

{
	#category : #initialization,
	#'squeak_changestamp' : 'MCPServer (jl) 11/4/2026 10:55'
}
SWAGameXR >> createButtonSlab [
	"Create the species/pause/bars/config/graph button slab as a world child.
	 Was extracted out of the old createUI together with createInspector so each
	 piece can be toggled independently from the debug menu."
	| halfWidth btnSize textScale rowZ spacing 
	  rabbitBtnLabel foxBtnLabel pauseBtn barsBtn configBtn graphBtn totalRows |
	
	Transcript cr; show: 'SWAGameXR: building button slab'.
	halfWidth := gridWidth / 2 * worldScale.
	btnSize := self panelScale * 2.
	textScale := self panelScale * 1.0.
	spacing := btnSize * 2.5.
	totalRows := 6.
	
	buttonSlab := SWAGameSlab new
		slabWidth: (btnSize * 11) height: (spacing * (totalRows + 0.5));
		slabDepth: 0.02;
		yourself.
	self world addChild: buttonSlab.
	self placeNewPanel: buttonSlab atSide: 1 z: spacing * 1.5.
	
	"--- Row 1: Rabbit select ---"
	rowZ := spacing * -2.5.
	rabbitBtn := SWAGameButton new
		color: Color white;
		action: [self selectSpecies: #rabbit];
		position: (Vector3 x: (btnSize * -3.5) y: 0.02 z: rowZ);
		scale: (Vector3 one * btnSize);
		yourself.
	buttonSlab addChild: rabbitBtn.
	
	rabbitBtnLabel := SRTextField new
		text: 'Rabbit';
		color: Color white;
		position: (Vector3 x: (btnSize * -2.3) y: 0.02 z: rowZ);
		scale: (Vector3 one * textScale);
		yourself.
	buttonSlab addChild: rabbitBtnLabel.
	
	rabbitLabel := SRTextField new
		text: 'Rabbits: 0';
		color: Color white;
		position: (Vector3 x: (btnSize * 2.5) y: 0.02 z: rowZ);
		scale: (Vector3 one * textScale);
		yourself.
	buttonSlab addChild: rabbitLabel.
	
	"--- Row 2: Fox select ---"
	rowZ := spacing * -1.5.
	foxBtn := SWAGameButton new
		color: (Color r: 0.9 g: 0.5 b: 0.1);
		action: [self selectSpecies: #fox];
		position: (Vector3 x: (btnSize * -3.5) y: 0.02 z: rowZ);
		scale: (Vector3 one * btnSize);
		yourself.
	buttonSlab addChild: foxBtn.
	
	foxBtnLabel := SRTextField new
		text: 'Fox';
		color: (Color r: 0.9 g: 0.5 b: 0.1);
		position: (Vector3 x: (btnSize * -2.3) y: 0.02 z: rowZ);
		scale: (Vector3 one * textScale);
		yourself.
	buttonSlab addChild: foxBtnLabel.
	
	foxLabel := SRTextField new
		text: 'Foxes: 0';
		color: (Color r: 0.9 g: 0.5 b: 0.1);
		position: (Vector3 x: (btnSize * 2.5) y: 0.02 z: rowZ);
		scale: (Vector3 one * textScale);
		yourself.
	buttonSlab addChild: foxLabel.
	
	"--- Row 3: Pause/Continue ---"
	rowZ := spacing * -0.5.
	pauseBtn := SWAGameButton new
		color: (Color r: 0.3 g: 0.6 b: 0.9);
		action: [self togglePause];
		position: (Vector3 x: (btnSize * -3.5) y: 0.02 z: rowZ);
		scale: (Vector3 one * btnSize);
		yourself.
	buttonSlab addChild: pauseBtn.
	
	pauseLabel := SRTextField new
		text: 'Pause';
		color: (Color r: 0.3 g: 0.6 b: 0.9);
		position: (Vector3 x: (btnSize * -2.3) y: 0.02 z: rowZ);
		scale: (Vector3 one * textScale);
		yourself.
	buttonSlab addChild: pauseLabel.
	
	"--- Row 4: Bars toggle ---"
	rowZ := spacing * 0.5.
	barsBtn := SWAGameButton new
		color: (Color r: 0.2 g: 0.7 b: 0.3);
		action: [self toggleBars];
		position: (Vector3 x: (btnSize * -3.5) y: 0.02 z: rowZ);
		scale: (Vector3 one * btnSize);
		yourself.
	buttonSlab addChild: barsBtn.
	
	barsLabel := SRTextField new
		text: (showBars ifTrue: ['Bars: ON'] ifFalse: ['Bars: OFF']);
		color: (Color r: 0.2 g: 0.7 b: 0.3);
		position: (Vector3 x: (btnSize * -2.3) y: 0.02 z: rowZ);
		scale: (Vector3 one * textScale);
		yourself.
	buttonSlab addChild: barsLabel.
	
	"--- Row 5: Config ---"
	rowZ := spacing * 1.5.
	configBtn := SWAGameButton new
		color: (Color r: 0.7 g: 0.7 b: 0.2);
		action: [self openConfig];
		position: (Vector3 x: (btnSize * -3.5) y: 0.02 z: rowZ);
		scale: (Vector3 one * btnSize);
		yourself.
	buttonSlab addChild: configBtn.
	
	buttonSlab addChild: (SRTextField new
		text: 'Config';
		color: (Color r: 0.7 g: 0.7 b: 0.2);
		position: (Vector3 x: (btnSize * -2.3) y: 0.02 z: rowZ);
		scale: (Vector3 one * textScale);
		yourself).
	
	"--- Row 6: Graph toggle ---"
	rowZ := spacing * 2.5.
	graphBtn := SWAGameButton new
		color: (Color r: 0.6 g: 0.3 b: 0.7);
		action: [self toggleGraph];
		position: (Vector3 x: (btnSize * -3.5) y: 0.02 z: rowZ);
		scale: (Vector3 one * btnSize);
		yourself.
	buttonSlab addChild: graphBtn.
	
	buttonSlab addChild: (SRTextField new
		text: 'Graph';
		color: (Color r: 0.6 g: 0.3 b: 0.7);
		position: (Vector3 x: (btnSize * -2.3) y: 0.02 z: rowZ);
		scale: (Vector3 one * textScale);
		yourself).
	
	self samplePopulations.
	self lockPanelChildrenOf: buttonSlab.
	Transcript cr; show: 'SWAGameXR: button slab READY'
]

{
	#category : #initialization,
	#'squeak_changestamp' : 'MCPServer 7/29/2026 18:06'
}
SWAGameXR >> createGroundPlane [
	"Create a visual base plate at y=0, centered at origin. Grabbing it moves the whole game."
	groundPlane := SWAGameBasePlate new
		scale: (Vector3 x: gridWidth * worldScale y: 1 z: gridDepth * worldScale);
		position: (Vector3 x: 0 y: 0 z: 0).
	groundPlane grabTarget: self.
	self addChild: groundPlane.
]

{
	#category : #initialization,
	#'squeak_changestamp' : 'MCPServer 10/14/2026 12:57'
}
SWAGameXR >> createInspector [
	"Add the mob inspector slab as a world child."
	| halfWidth btnSize inspectorScale inspectorPos |
	halfWidth := gridWidth / 2 * worldScale.
	btnSize := worldScale * 2.
	inspectorScale := worldScale * 1.5.
	inspectorPos := self globalTransform localPointToGlobal: 
		(Vector3 x: halfWidth + (btnSize * 1.5) y: worldScale * 12 z: (btnSize * 2.5) * 5).
	mobInspector := SWAGameMobInspector new
		position: inspectorPos;
		rotation: self globalRotation;
		scale: (Vector3 one * inspectorScale);
		yourself.
	self world addChild: mobInspector
]

{
	#category : #initialization,
	#'squeak_changestamp' : 'MCPServer 10/16/2026 13:26'
}
SWAGameXR >> createToolSlab [
	"Create the terrain-editing slab: one button per terrain material plus the
	 pick axe. Mirrors createButtonSlab but sits on the opposite (-x) side of
	 the grid. Selecting a material makes world clicks add a cube on the
	 clicked face; selecting the pick axe makes them dig the clicked cube out."
	| halfWidth btnSize textScale spacing materials totalRows rowZ rowFor |

	Transcript cr; show: 'SWAGameXR: building tool slab'.
	halfWidth := gridWidth / 2 * worldScale.
	btnSize := self panelScale * 2.
	textScale := self panelScale * 1.0.
	spacing := btnSize * 2.5.
	materials := self class terrainMaterials.
	totalRows := materials size + 2.	"+ title row + pick axe row"
	rowFor := [:i | spacing * (i - ((totalRows + 1) / 2.0))].

	toolButtons := Dictionary new.
	toolSlab := SWAGameSlab new
		slabWidth: (btnSize * 11) height: (spacing * (totalRows + 0.5));
		slabDepth: 0.02;
		yourself.
	self world addChild: toolSlab.
	self placeNewPanel: toolSlab atSide: -1 z: 0.

	"--- Row 1: title ---"
	toolSlab addChild: (SRTextField new
		text: 'Terrain Tools';
		color: Color white;
		position: (Vector3 x: (btnSize * -3.5) y: 0.02 z: (rowFor value: 1));
		scale: (Vector3 one * textScale);
		yourself).

	"--- Rows 2..n: one per material ---"
	materials doWithIndex: [:spec :i |
		| sym label matColor btn |
		sym := spec first.
		label := spec second.
		matColor := spec third.
		rowZ := rowFor value: i + 1.
		btn := SWAGameButton new
			color: matColor;
			action: [self selectTool: sym];
			position: (Vector3 x: (btnSize * -3.5) y: 0.02 z: rowZ);
			scale: (Vector3 one * btnSize);
			yourself.
		toolSlab addChild: btn.
		toolButtons at: sym put: btn.
		toolSlab addChild: (SRTextField new
			text: label;
			color: matColor;
			position: (Vector3 x: (btnSize * -2.3) y: 0.02 z: rowZ);
			scale: (Vector3 one * textScale);
			yourself)].

	"--- Last row: pick axe ---"
	rowZ := rowFor value: totalRows.
	toolButtons at: #pickaxe put: (SWAGameButton new
		color: (Color r: 0.75 g: 0.2 b: 0.2);
		action: [self selectTool: #pickaxe];
		position: (Vector3 x: (btnSize * -3.5) y: 0.02 z: rowZ);
		scale: (Vector3 one * btnSize);
		yourself).
	toolSlab addChild: (toolButtons at: #pickaxe).
	toolSlab addChild: (SRTextField new
		text: 'Pick Axe';
		color: (Color r: 0.95 g: 0.4 b: 0.4);
		position: (Vector3 x: (btnSize * -2.3) y: 0.02 z: rowZ);
		scale: (Vector3 one * textScale);
		yourself).

	self updateToolButtonSelection.
	self lockPanelChildrenOf: toolSlab.
	Transcript cr; show: 'SWAGameXR: tool slab READY'
]

{
	#category : #initialization,
	#'squeak_changestamp' : 'MCPServer 7/29/2026 18:06'
}
SWAGameXR >> createUI [
	"Legacy entry point: create the button slab + the inspector. The two are now
	 controlled by separate per-feature toggles. This is kept for callers that
	 want the historical 'everything' behaviour."
	self createButtonSlab.
	self createInspector
]

{
	#category : #initialization,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameXR >> destroy [
	self finalize.
	self remove
]

{
	#category : #'terrain editing',
	#'squeak_changestamp' : 'MCPServer (SqueakXR) 10/20/2026 10:59'
}
SWAGameXR >> digAtX: gx y: gy z: gz [

	| y |
	y := gy ifNil: [self topFilledYAtX: gx z: gz].
	y ifNil: [^ self].
	(self removeBoxAt: gx @ y @ gz)
		ifTrue: [self syncHeightMapForColumnX: gx z: gz].
]

{
	#category : #'debug toggles',
	#'squeak_changestamp' : 'MCPServer 10/16/2026 13:52'
}
SWAGameXR >> disableButtons [
	"Also runs when the flag is already false but a slab is still held: that is a
	panel dismissed with the Remove halo item, and its labels still need nilling."
	(showButtons or: [buttonSlab notNil]) ifFalse: [^ self].
	showButtons := false.
	buttonSlab ifNotNil: [buttonSlab remove. buttonSlab := nil].
	rabbitBtn := nil. foxBtn := nil.
	rabbitLabel := nil. foxLabel := nil.
	pauseLabel := nil. barsLabel := nil.
	selectedMobLabel := nil.
	Transcript cr; show: 'SWAGameXR: buttons DISABLED'
]

{
	#category : #'debug toggles',
	#'squeak_changestamp' : 'MCPServer 7/29/2026 18:06'
}
SWAGameXR >> disableGraph [
	showGraph ifFalse: [^ self].
	self toggleGraph "clears showGraph"
]

{
	#category : #'debug toggles',
	#'squeak_changestamp' : 'MCPServer 10/16/2026 13:52'
}
SWAGameXR >> disableTools [
	"See #disableButtons: also runs for a slab dismissed with the Remove halo."
	((showTools ifNil: [false]) or: [toolSlab notNil]) ifFalse: [^ self].
	showTools := false.
	self selectTool: nil.
	toolSlab ifNotNil: [toolSlab remove. toolSlab := nil].
	toolButtons := nil.
	Transcript cr; show: 'SWAGameXR: tools DISABLED'
]

{
	#category : #simulation,
	#'squeak_changestamp' : 'MCPServer (jl) 11/3/2026 18:51'
}
SWAGameXR >> distanceFrom: aPoint toSegmentFrom: start to: end [

	| path lengthSq t |
	path := end - start.
	lengthSq := path dot: path.
	t := lengthSq = 0
		ifTrue: [0]
		ifFalse: [((((aPoint - start) dot: path) / lengthSq) max: 0) min: 1].
	^ ((start + (path * t)) - aPoint) length
]

{
	#category : #'walk mode',
	#'squeak_changestamp' : 'MCPServer 10/16/2026 12:44'
}
SWAGameXR >> dragTo: aMatrix4x4 [
	"The world is scenery, at any scale: standing in it, dragging it moves the
	ground from under you, and on the table it is knocked askew by every grab
	aimed at a block. Refused here rather than by making the game ungrabbable,
	because grabbing is also how a hand selects the object whose context menu
	opens."
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 16:32'
}
SWAGameXR >> effectiveLineThickness [
	"0 switches the outline off in the shader."
	^ self class blockOutlines
		ifTrue: [self lineThickness]
		ifFalse: [0.0]
]

{
	#category : #'debug toggles',
	#'squeak_changestamp' : 'MCPServer 10/16/2026 13:53'
}
SWAGameXR >> enableButtons [
	"See #enableTools: the panel, not the flag."
	(buttonSlab notNil and: [buttonSlab isOpen]) ifTrue: [^ self].
	showButtons := true.
	self createButtonSlab.
	Transcript cr; show: 'SWAGameXR: buttons ENABLED'
]

{
	#category : #'debug toggles',
	#'squeak_changestamp' : 'MCPServer 7/29/2026 18:06'
}
SWAGameXR >> enableGraph [
	showGraph ifTrue: [^ self].
	self toggleGraph "sets showGraph"
]

{
	#category : #'debug toggles',
	#'squeak_changestamp' : 'MCPServer 10/16/2026 13:53'
}
SWAGameXR >> enableTools [
	"Guarded on the panel, not the flag: #initialize sets the flag long before
	#createUI builds anything, so guarding on it refused to ever build the slab."
	(toolSlab notNil and: [toolSlab isOpen]) ifTrue: [^ self].
	showTools := true.
	self createToolSlab.
	Transcript cr; show: 'SWAGameXR: tools ENABLED'
]

{
	#category : #'grass shading',
	#'squeak_changestamp' : 'MCPServer (MCPServer) 10/23/2026 10:25'
}
SWAGameXR >> ensureGrassTexture [

	grassSource ifNil: [
		grassSource := SRTextureSourceForm width: world gridSize height: world gridSize].
	grassTexture ifNil: [
		grassTexture := SRTexture withSource: grassSource].
	^ grassTexture
]

{
	#category : #'raylib scratch',
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameXR >> ensureRlScratch [
	"Owned and refilled: allocating an RlColor or RlVector3 costs ~1 KB, refilling ~5 B."

	"One guard per field, for instances that ran an older version of this method."

	rlMobPos ifNil: [rlMobPos := RlVector3 new].
	rlBarPos ifNil: [rlBarPos := RlVector3 new].
	rlChunkPos ifNil: [rlChunkPos := RlVector3 new].
	rlTargetPos ifNil: [rlTargetPos := RlVector3 new].
	rlScratchColor ifNil: [rlScratchColor := RlColor new].
	rlEnergyBackColor ifNil: [
		rlEnergyBackColor := SRRaylibRenderer fill: RlColor new withColor: (Color r: 0.3 g: 0.0 b: 0.0)].
	rlHighlightColor ifNil: [
		rlHighlightColor := SRRaylibRenderer fill: RlColor new withColor: Color yellow].
	rlChunkColor ifNil: [
		rlChunkColor := SRRaylibRenderer fill: RlColor new withColor: Color red].
	rlAgeYoungColor ifNil: [
		rlAgeYoungColor := SRRaylibRenderer fill: RlColor new withColor: (Color r: 0.5 g: 0.8 b: 1.0)].
	rlAgeOldColor ifNil: [
		rlAgeOldColor := SRRaylibRenderer fill: RlColor new withColor: (Color r: 0.2 g: 0.4 b: 0.9)].
	rlVoxelTransform ifNil: [rlVoxelTransform := RlMatrix new].
	voxelThicknessBuffer ifNil: [voxelThicknessBuffer := ByteArray new: 4].
	voxelWorldScaleBuffer ifNil: [voxelWorldScaleBuffer := ByteArray new: 4].
	voxelGridExtentBuffer ifNil: [voxelGridExtentBuffer := ByteArray new: 8].
]

{
	#category : #rendering,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 16:29'
}
SWAGameXR >> ensureVoxelMeshMaterial [
	"On the Quest the transpiled GLSL must already be in the ShaderCache: glslang and spirv-cross are not available on the headset."
	self currentXRWorld ifNil: [^ self].
	(SRShader hasCachedShader: #swagameTerrain) ifFalse: [
		SRShader canTranspile
			ifTrue: [SRShader transpileShaderNamed: #swagameTerrain]
			ifFalse: [
				Transcript cr; show: '** swagameTerrain not in ShaderCache and no transpiler available **'.
				voxelMeshMaterial ifNil: [voxelMeshMaterial := SRMaterial new].
				^ self]].

	voxelMeshSRShader ifNil: [voxelMeshSRShader := SRShader swagameTerrain].
	voxelMeshSRShader internalShader id > 0 ifFalse: [
		Transcript cr; show: '** swagameTerrain failed to compile **'.
		voxelMeshSRShader := nil.
		voxelMeshMaterial ifNil: [voxelMeshMaterial := SRMaterial new].
		^ self].

	(voxelMeshMaterial isNil or: [voxelMeshMaterial shader ~~ voxelMeshSRShader]) ifTrue: [
		voxelMeshMaterial := SRMaterial new.
		voxelMeshMaterial shader: voxelMeshSRShader].
]

{
	#category : #'walk mode',
	#'squeak_changestamp' : 'leo-MCPServer 11/25/2026 19:52'
}
SWAGameXR >> enterWalkMode [
	"One block is one metre and the player stands in it. Scale and locomotion are
	one switch: metre-sized blocks seen from a flying camera, or walking around a
	5 cm world, are both nonsense."
	walkMode := true.
	self worldScale: 1.0.
	self avatarsDo: [:each |
		self placeOnSurface: each.
		"The walking itself belongs to the avatar: the terrain only has to be
		solid, which SWAGameVoxelCollider already answers for."
		each locomotionEnabled: true].
	"There is no table to stand the panels beside any more, and they were
	sized for the board edge 16 m away."
	self actingAvatar ifNotNil: [:avatar | self bringPanelsToHand: avatar rightHand].
]

{
	#category : #'walk mode',
	#'squeak_changestamp' : 'leo-MCPServer 11/25/2026 19:52'
}
SWAGameXR >> exitWalkMode [
	"Back to the table. The avatars return to the rig origin, since a player left
	standing where a 1 m world used to be is 20 times too far away to see it.
	A second player stands 2.5 m back, where SRSimpleAvatarMovementEmulator starts one."
	| first |
	walkMode := false.
	self worldScale: self class tableWorldScale.
	self repositionPanelsAtTable.
	first := self actingAvatar.
	self avatarsDo: [:each |
		each useDefaultLocomotion.
		each translation: (each == first
			ifTrue: [Vector3 zero]
			ifFalse: [0m @ 0m @ 2.5m])].
]

{
	#category : #panels,
	#'squeak_changestamp' : 'MCPServer 10/16/2026 13:48'
}
SWAGameXR >> facingFrom: aPosition toward: aTarget [
	"Stand a panel up and turn it to face a point.

	Two parts. The yaw turns it toward the viewer -- toward, not merely adopting
	the viewer's heading, because a panel placed 45 cm to the side is 44 degrees
	off if it only copies where the head points. The quarter turn about x stands
	the tray up: a slab's face is its +y, so without it the panel lies flat and
	looks at the sky.

	Horizontal only, so the panel never inherits head pitch or roll."

	| direction |
	direction := aTarget - aPosition.
	direction := Vector3 x: direction x y: 0 z: direction z.
	direction length < 0.001 ifTrue: [^ Quaternion identity].
	direction := direction normalized.
	"The quarter turn is +90 and the yaw is taken from the reversed direction:
	the other pair that faces the viewer stands the panel on its head, because
	the rows are laid out along the slab's local z and that maps to world down."
	^ (Quaternion axis: (Vector3 x: 1 y: 0 z: 0) angle: 90)
		* (Quaternion
			radiansAngle: (direction x arcTan: direction z)
			axis: Vector3 up)
]

{
	#category : #'world generation',
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameXR >> fillChunkVoxelsAtX: cx z: cz [
	| x0 z0 |
	x0 := cx * 16.
	z0 := cz * 16.
	x0 to: x0 + 15 do: [:x |
		z0 to: z0 + 15 do: [:z |
			| h |
			h := world heightAtX: x + 1 y: z + 1.
			0 to: (h - 1 min: gridHeight - 1) do: [:y |
				gridHandle
					at: x at: y at: z
					put: (world blockTypeAtX: x + 1 z: z + 1 y: y)]]].
	self voxelChunks markAllDirty
]

{
	#category : #initialization,
	#'squeak_changestamp' : 'MCPServer 7/29/2026 18:06'
}
SWAGameXR >> finalize [
	"Clean up resources when object is garbage collected.
	Note: No C resources to clean up anymore - pure Smalltalk!"
	gridHandle := nil.
	super finalize.
]

{
	#category : #simulation,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 16:39'
}
SWAGameXR >> findMobNear: gx z: gz maxDist: maxDist [
	"Find the closest living mob within maxDist grid cells of gx,gz."
	| closestMob closestDist maxDistSq |
	closestMob := nil.
	closestDist := Float infinity.
	maxDistSq := maxDist squared.
	
	world mobsDo: [:m |
		| dist |
		dist := (m x - gx) squared + (m z - gz) squared.
		(dist < closestDist and: [dist <= maxDistSq]) ifTrue: [
			closestDist := dist.
			closestMob := m]].
	^ closestMob
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 7/29/2026 18:06'
}
SWAGameXR >> gameWorld [
	^ world
]

{
	#category : #'world generation',
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameXR >> generateChunkAtX: cx z: cz [
	(world generateChunkAtX: cx z: cz) ifFalse: [^ false].
	self fillChunkVoxelsAtX: cx z: cz.
	world spawnMobsInChunkX: cx z: cz.
	self refreshChunkMarkers.
	^ true
]

{
	#category : #'world generation',
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameXR >> generateLevel [
	| gs totalCubes |

	Transcript cr; show: 'SWAGameXR: Generating terrain data...'.

	gridHandle clear.
	gs := world gridSize.

	totalCubes := 0.
	0 to: gs - 1 do: [:x |
		0 to: gs - 1 do: [:z |
			| h |
			h := world heightAtX: x + 1 y: z + 1.
			0 to: h - 1 do: [:y |
				gridHandle
					at: x at: y at: z
					put: (world blockTypeAtX: x + 1 z: z + 1 y: y).
				totalCubes := totalCubes + 1]]].
	

	self voxelChunks markAllDirty.
	self refreshChunkMarkers.

	Transcript cr; show: 'Terrain: ', totalCubes printString, ' cubes.'
]

{
	#category : #'world generation',
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameXR >> generateWorld [
	self generateLevel.
	self updateMobVisuals.
	showButtons ifTrue: [self createButtonSlab].
	(showTools ifNil: [false]) ifTrue: [self createToolSlab]
]

{
	#category : #mapping,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameXR >> globalPositionForCellX: cellX y: cellY z: cellZ [
	^ self globalTransform
		localPointToGlobal: (self objectPosForCellX: cellX y: cellY z: cellZ)
]

{
	#category : #'grass shading',
	#'squeak_changestamp' : 'MCPServer 10/15/2026 14:54'
}
SWAGameXR >> grassShadeCount [
	"Few steps on purpose. Every distinct Color is a permanent entry in the chunk
	colour cache, and every change rebuilds a chunk mesh."

	^ 6
]

{
	#category : #'grass shading',
	#'squeak_changestamp' : 'MCPServer 10/15/2026 14:54'
}
SWAGameXR >> grassShadePalette [
	"Bare gray through to lush green. Shared instances, see grassShadeCount."

	^ grassShadePalette ifNil: [
		grassShadePalette := (0 to: self grassShadeCount - 1) collect: [:i |
			| t |
			t := i / (self grassShadeCount - 1).
			Color
				r: 0.5 - (0.35 * t)
				g: 0.5 + (0.15 * t)
				b: 0.5 - (0.32 * t)]]
]

{
	#category : #'grass shading',
	#'squeak_changestamp' : 'MCPServer 10/15/2026 15:02'
}
SWAGameXR >> grassWordForLevel: aLevel [
	"A Form word is ARGB, which reaches the GPU as BGRA. Level goes in green and
	the grassland mask in alpha, the two channels the red/blue swap leaves alone.
	Level 0 means not grassland at all, so the shader tints nothing there."

	| g |
	aLevel = 0 ifTrue: [^ 0].
	g := (aLevel - 1) * 255 // (self grassShadeCount - 1).
	^ (255 bitShift: 24) + (g bitShift: 8)
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 7/29/2026 18:06'
}
SWAGameXR >> gridDepth [
	^ gridDepth
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 7/29/2026 18:06'
}
SWAGameXR >> gridHandle [
	"The SWAGameGrid holding the solid/empty bits of the voxel world."
	^ gridHandle
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 7/29/2026 18:06'
}
SWAGameXR >> gridHeight [
	^ gridHeight
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 7/29/2026 18:06'
}
SWAGameXR >> gridWidth [
	^ gridWidth
]

{
	#category : #menus,
	#'squeak_changestamp' : 'MCPServer (jl) 10/21/2026 11:06'
}
SWAGameXR >> hand: aHand holds: aToolOrNil [
	"nil is the bare hand, which is a row like any other."

	| held |
	aHand ifNil: [^ false].
	held := aHand tool.
	aToolOrNil ifNil: [^ held isNil].
	^ held notNil and: [held isSameToolAs: aToolOrNil]
]

{
	#category : #menus,
	#'squeak_changestamp' : 'leo-MCPServer 11/25/2026 19:52'
}
SWAGameXR >> handMarkerFor: aToolOrNil [
	"Which hands are holding this, for a tool row's label. Both can be, since a
	tool is an object and each hand gets its own instance."

	"#world, not #currentXRWorld: the latter is SRWorld current, so a game in any
	other scene would report the hands of whichever world happens to be running."
	| avatar marks |
	avatar := self actingAvatar ifNil: [^ ''].
	marks := WriteStream on: String new.
	{'L' -> avatar leftHand. 'R' -> avatar rightHand} do: [:each |
		(self hand: each value holds: aToolOrNil)
			ifTrue: [marks nextPutAll: ' [' , each key , ']']].
	^ marks contents
]

{
	#category : #petting,
	#'squeak_changestamp' : 'jl-MCPServer 11/20/2026 14:09'
}
SWAGameXR >> handTouchPoints [

	| points |
	points := OrderedCollection new.
	self avatarsDo: [:each |
		each hands do: [:hand |
			hand ifNotNil: [
				points add: (self globalTransform globalPointToLocal: hand globalTranslation)]]].
	^ points
]

{
	#category : #petting,
	#'squeak_changestamp' : 'MCPServer (leo) 11/5/2026 17:49'
}
SWAGameXR >> heartOriginFor: aMob [

	^ (self worldPosForMob: aMob) + (0 @ (worldScale * 0.5) @ 0)
]

{
	#category : #petting,
	#'squeak_changestamp' : 'MCPServer (leo) 11/5/2026 17:49'
}
SWAGameXR >> hearts [

	^ hearts ifNil: [hearts := SWAGameHearts new]
]

{
	#category : #simulation,
	#'squeak_changestamp' : 'MCPServer (jl) 11/10/2026 19:40'
}
SWAGameXR >> hitByBulletFrom: startPoint to: endPoint [

	^ (self mobHitFrom: startPoint to: endPoint)
		ifNil: [false]
		ifNotNil: [:mob |
			mob die.
			true]
]

{
	#category : #initialization,
	#'squeak_changestamp' : 'MCPServer (jl) 11/4/2026 10:55'
}
SWAGameXR >> initialize [
	super initialize.
	
	gridWidth := self class startCells.
	gridDepth := self class startCells.
	gridHeight := 32.
	worldScale := self class tableWorldScale.
	tickElapsed := 0.0.
	"The world owns the tick period: mob physics integrates against it."
	tickMillis := SWAGameWorld new secondsPerTick * 1000.0.
	animT := 1.0.
	paused := false.
	showBars := false.
	
	showButtons := false.
	showGraph := false.
	showTools := false.
	selectedTool := nil.
	
	world := SWAGameWorld gridSize: gridWidth maxHeight: 20.
	
	gridHandle := SWAGameChunkedGrid width: gridWidth depth: gridDepth height: gridHeight.
	world voxels: gridHandle.
	mobObjects := OrderedCollection new.
	mobSnapshots := Dictionary new.
	
	voxelChunks := SWAGameVoxelChunks
		grid: gridHandle
		width: gridWidth height: gridHeight depth: gridDepth
		worldScale: worldScale.
	voxelChunks space: self space.
	chunkRebuildBudget := 2.
	voxelMeshMaterial := nil.
	
	self createGroundPlane.
	
	Transcript cr; show: 'SWAGameXR initialized ', gridWidth printString, 'x', gridDepth printString, ' (no panels)'
]

{
	#category : #simulation,
	#'squeak_changestamp' : 'MCPServer 7/29/2026 18:06'
}
SWAGameXR >> inspectMob: aMob [
	"Select a mob for inspection. Toggle off if clicking same mob.
	 Lazily creates the inspector on first selection so startup stays cheap."
	
	"Toggle off if same mob"
	(selectedMob notNil and: [selectedMob == aMob]) ifTrue: [
		selectedMob := nil.
		mobInspector ifNotNil: [mobInspector mob: nil].
		^ self].
	
	mobInspector ifNil: [self createInspector].
	selectedMob := aMob.
	mobInspector ifNotNil: [mobInspector mob: aMob]
]

{
	#category : #testing,
	#'squeak_changestamp' : 'MCPServer (SqueakXR) 10/20/2026 10:43'
}
SWAGameXR >> isApp [
	^ true
]

{
	#category : #testing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/18/2026 18:35'
}
SWAGameXR >> isSolid [
	"On the table the board is a model at 5 cm a block, not ground: the holodeck's
	walking and teleport would otherwise climb onto it and stop at its edges."
	^ walkMode == true
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (SqueakXR) 10/20/2026 11:00'
}
SWAGameXR >> lastVoxelHit [
	^ lastVoxelHit
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 7/29/2026 18:06'
}
SWAGameXR >> lineThickness [
	"Edge thickness in pixels (mode #mesh only). Default 2.0."
	^ lineThickness ifNil: [2.0]
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 7/29/2026 18:06'
}
SWAGameXR >> lineThickness: aFloat [
	"Set the cube outline thickness in pixels for mode #mesh. <= 0 disables the outline.
	 Pure uniform change -- no mesh rebuild, takes effect on the next frame."
	lineThickness := aFloat asFloat.
	Transcript cr; show: 'lineThickness -> ', lineThickness printString
]

{
	#category : #panels,
	#'squeak_changestamp' : 'MCPServer 10/16/2026 12:51'
}
SWAGameXR >> lockPanelChildrenOf: aSlab [
	"A grab aimed at a button carries the whole panel, rather than pulling the
	button off it and leaving it floating. The slab itself stays grabbable, which
	is how a panel is repositioned by hand."

	aSlab ifNil: [^ self].
	aSlab children do: [:each | each grabTarget: aSlab]
]

{
	#category : #picking,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameXR >> marchBounds [
	"{xLo. xHi. zLo. zHi} in cells, upper bounds exclusive."

	| size xLo xHi zLo zHi |
	size := SWAGameChunk size.
	xLo := 0.
	xHi := gridWidth.
	zLo := 0.
	zHi := gridDepth.
	world generatedChunks do: [:key |
		| cx cz |
		cx := world chunkXOfKey: key.
		cz := world chunkZOfKey: key.
		xLo := xLo min: cx * size.
		xHi := xHi max: cx + 1 * size.
		zLo := zLo min: cz * size.
		zHi := zHi max: cz + 1 * size].
	^ {xLo. xHi. zLo. zHi}
]

{
	#category : #simulation,
	#'squeak_changestamp' : 'MCPServer (jl) 11/13/2026 11:08'
}
SWAGameXR >> mob: aMob isHitFrom: start to: end [
	"start and end are game-local. Inverts the transform of SWAGameMobRenderer>>drawEntry:t:transform:worldScale:material:time:, so the test sees the mesh where this frame draws it."

	| t toPos fromPos position model gait scale yaw c s toModel |
	t := animT ifNil: [1.0].
	toPos := self worldPosForMob: aMob.
	fromPos := mobSnapshots ifNil: [toPos] ifNotNil: [:snapshots | snapshots at: aMob ifAbsent: [toPos]].
	position := fromPos + ((toPos - fromPos) * t).
	self class animalModels ifFalse: [
		^ (self distanceFrom: position toSegmentFrom: start to: end)
			<= (worldScale * 0.25 * (aMob isChild ifTrue: [0.6] ifFalse: [1]))].
	model := self mobRenderer modelFor: aMob.
	gait := self mobRenderer gaitFor: aMob.
	scale := worldScale / 16.0 * model pixelScale.
	aMob isChild ifTrue: [scale := scale * 0.6].
	position := position - (0 @ (aMob height / 2 * worldScale) @ 0)
		+ (0 @ ((model bobAt: (gait phaseAt: t) swing: (gait swingAt: t)) * scale) @ 0).
	yaw := gait yawAt: t.
	c := yaw cos.
	s := yaw sin.
	toModel := [:point | | d |
		d := point - position.
		Vector3
			x: (c * d x) - (s * d z) / scale
			y: d y / scale
			z: (s * d x) + (c * d z) / scale].
	^ model intersectsSegmentFrom: (toModel value: start) to: (toModel value: end)
]

{
	#category : #petting,
	#'squeak_changestamp' : 'MCPServer (leo) 11/5/2026 17:49'
}
SWAGameXR >> mob: aMob isTouchedAt: aPoint [

	^ ((self worldPosForMob: aMob) - aPoint) length <= (worldScale * self class petReach)
]

{
	#category : #petting,
	#'squeak_changestamp' : 'MCPServer (leo) 11/5/2026 17:58'
}
SWAGameXR >> mob: aMob isTouchedAtAny: touchPoints [

	^ touchPoints anySatisfy: [:point | self mob: aMob isTouchedAt: point]
]

{
	#category : #simulation,
	#'squeak_changestamp' : 'MCPServer (jl) 11/10/2026 19:40'
}
SWAGameXR >> mobHitFrom: startPoint to: endPoint [
	"The segment, not the end point: at 500 m/s a bullet travels further per frame than a mob is wide.
	The cull is generous because the mesh is drawn between the tick's two positions."

	| from to |
	world ifNil: [^ nil].
	from := self globalTransform globalPointToLocal: startPoint.
	to := self globalTransform globalPointToLocal: endPoint.
	world mobsDo: [:mob |
		((self distanceFrom: (self worldPosForMob: mob) toSegmentFrom: from to: to) <= (worldScale * 2)
			and: [self mob: mob isHitFrom: from to: to])
				ifTrue: [^ mob]].
	^ nil
]

{
	#category : #rendering,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 15:27'
}
SWAGameXR >> mobRenderer [
	^ mobRenderer ifNil: [mobRenderer := SWAGameMobRenderer new]
]

{
	#category : #'terrain editing',
	#'squeak_changestamp' : 'MCPServer 7/29/2026 18:06'
}
SWAGameXR >> neighbourOf: gridCoord onFace: aFaceNormal [
	"The integer grid coordinate of the cell touching gridCoord across the given
	 face. A nil normal means the top face, which is the sane default."
	| n |
	n := aFaceNormal ifNil: [Vector3 x: 0 y: 1 z: 0].
	^ (gridCoord x + n x rounded)
		@ (gridCoord y + n y rounded)
		@ (gridCoord z + n z rounded)
]

{
	#category : #events,
	#'squeak_changestamp' : 'MCPServer 7/29/2026 18:06'
}
SWAGameXR >> noteVoxelHitX: gx y: gy z: gz face: aFaceNormal [
	"Called by SWAGameVoxelCollider while a ray is being cast, before the world
	 decides which object was nearest. Remembered so a following onRaycast: knows
	 which voxel and which face the ray actually hit."
	lastVoxelHit := Array with: gx with: gy with: gz with: aFaceNormal
]

{
	#category : #simulation,
	#'squeak_changestamp' : 'MCPServer 10/15/2026 16:08'
}
SWAGameXR >> objectPosForCellX: cellX y: cellY z: cellZ [
	^ self space vectorForCellX: cellX y: cellY z: cellZ
]

{
	#category : #events,
	#'squeak_changestamp' : 'MCPServer (jl) 11/10/2026 19:22'
}
SWAGameXR >> onButtonPress: aButtonEvent [
	"Clicks come as button events from the hand's cursor, no longer as #onRaycast:."

	| voxel |
	aButtonEvent button == #trigger ifFalse: [^ self].
	voxel := (self targetVoxelFor: aButtonEvent hand) ifNil: [^ self].
	aButtonEvent hand tool
		ifNil: [
			self
				onTerrainClickX: (voxel at: 1)
				y: (voxel at: 2)
				z: (voxel at: 3)
				face: (voxel at: 4)]
		ifNotNil: [:tool |
			tool
				applyAtX: (voxel at: 1)
				y: (voxel at: 2)
				z: (voxel at: 3)
				face: (voxel at: 4)].
]

{
	#category : #simulation,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:58'
}
SWAGameXR >> onCacheInvalidated [

	voxelMeshMaterial ifNotNil: #onCacheInvalidated.
	voxelChunks ifNotNil: #onCacheInvalidated.
	grassTexture ifNotNil: #onCacheInvalidated.
	mobRenderer ifNotNil: #onCacheInvalidated.
]

{
	#category : #events,
	#'squeak_changestamp' : 'MCPServer 7/29/2026 18:06'
}
SWAGameXR >> onRaycast: aSRRayIntersectionResult [
	"The terrain itself was hit. The voxel and face come from the DDA that just
	 ran in our collision geometry."
	super onRaycast: aSRRayIntersectionResult.
	lastVoxelHit ifNil: [^ self].
	self
		onTerrainClickX: (lastVoxelHit at: 1)
		y: (lastVoxelHit at: 2)
		z: (lastVoxelHit at: 3)
		face: (lastVoxelHit at: 4)
]

{
	#category : #events,
	#'squeak_changestamp' : 'MCPServer 7/29/2026 18:06'
}
SWAGameXR >> onTerrainClickX: gx y: gy z: gz face: aFaceNormal [
	"A terrain collision tile was clicked. When a terrain tool is active this is
	 an edit (build on the clicked face / dig the clicked cube); otherwise fall
	 back to the historical mob inspect/spawn behaviour."
	selectedTool ifNotNil: [
		^ self applyToolAtX: gx y: gy z: gz face: aFaceNormal].
	^ self onTerrainClickX: gx z: gz
]

{
	#category : #events,
	#'squeak_changestamp' : 'MCPServer (jl) 10/21/2026 11:16'
}
SWAGameXR >> onTerrainClickX: gx z: gz [
	"Called when a terrain tile is clicked. Inspect if clicking directly on a mob, otherwise spawn."
	| clickedMob |
	
	"Mobs no longer sit at integer cells, so an exact match would never hit."
	clickedMob := self findMobNear: gx + 0.5 z: gz + 0.5 maxDist: 0.7.
	clickedMob ifNotNil: [
		self inspectMob: clickedMob.
		^ self].
	
	"Spawn mode (no mob on this tile)"
	selectedSpecies ifNotNil: [
		self spawn: selectedSpecies atX: gx z: gz.
		^ self]
]

{
	#category : #simulation,
	#'squeak_changestamp' : 'MCPServer 7/29/2026 18:06'
}
SWAGameXR >> openConfig [
	SWAGameConfigPanel open
]

{
	#category : #panels,
	#'squeak_changestamp' : 'MCPServer 10/16/2026 13:26'
}
SWAGameXR >> panelAnchorAtSide: aSign z: aZ [
	"Beside the board, +x or -x. The distance out to the edge is in world units
	because the board changes size; the offset beyond the edge is in panel units
	because the panels do not."

	| halfWidth btnSize |
	halfWidth := gridWidth / 2 * worldScale.
	btnSize := self panelScale * 2.
	"The height is a height for a person, not a multiple of the world scale: it
	read 60 cm at table scale and 12 m once a block was a metre."
	^ self globalTransform localPointToGlobal: (Vector3
		x: (halfWidth + (btnSize * 5)) * aSign
		y: 60 cm
		z: aZ)
]

{
	#category : #panels,
	#'squeak_changestamp' : 'MCPServer 10/16/2026 10:26'
}
SWAGameXR >> panelScale [
	"Panel geometry is a size in metres for a human hand, not a property of the
	terrain: a 2 cm unit gives 4 cm buttons. Deliberately the old table scale, so
	that scaling the world leaves the panels alone instead of growing 2 m
	buttons."

	^ self class tableWorldScale
]

{
	#category : #petting,
	#'squeak_changestamp' : 'MCPServer (jl) 11/10/2026 18:17'
}
SWAGameXR >> pet: aMob [

	petSoundMob ifNil: [
		petSoundMob := aMob.
		self petSound ifNotNil: [:sound |
			sound
				translation: (self worldPosForMob: aMob);
				play]].
	aMob pet.
]

{
	#category : #petting,
	#'squeak_changestamp' : 'MCPServer (leo) 11/5/2026 17:58'
}
SWAGameXR >> petRabbitsOver: seconds [

	| touchPoints |
	world ifNil: [^ self].
	touchPoints := self handTouchPoints.
	self stopPetSoundUnlessTouchedAt: touchPoints.
	world mobsDo: [:mob |
		mob isRabbit ifTrue: [self updatePetting: mob touchedAt: touchPoints over: seconds]].
	self hearts advance: seconds.
]

{
	#category : #petting,
	#'squeak_changestamp' : 'MCPServer (jl) 11/10/2026 18:17'
}
SWAGameXR >> petSound [

	^ petSound ifNil: [
		(FileDirectory default fileExists: self class petSoundPath) ifFalse: [
			Transcript showln: 'Pet sound not found: ', self class petSoundPath.
			^ nil].
		petSound := SRAudioPlayer new filepath: self class petSoundPath.
		self addChild: petSound.
		petSound]
]

{
	#category : #'terrain editing',
	#'squeak_changestamp' : 'MCPServer (SqueakXR) 10/20/2026 10:59'
}
SWAGameXR >> placeAtX: gx y: gy z: gz face: aFaceNormal material: aSymbol [
	"The block lands in the empty cell on the side that was clicked, not in the
	cell that was hit."

	| y target |
	y := gy ifNil: [self topFilledYAtX: gx z: gz].
	y ifNil: [^ self].
	target := self neighbourOf: gx @ y @ gz onFace: aFaceNormal.
	(gridHandle isValidX: target x y: target y z: target z) ifFalse: [^ self].
	(gridHandle at: target x at: target y at: target z) = SWAGameBlocks air
		ifFalse: [^ self].
	(self placeBoxAt: target type: (SWAGameBlocks idFor: aSymbol))
		ifTrue: [self syncHeightMapForColumnX: target x z: target z].
]

{
	#category : #'box management',
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameXR >> placeBoxAt: gridCoord type: aBlockTypeId [
	(gridHandle isValidX: gridCoord x y: gridCoord y z: gridCoord z) ifFalse: [^ false].
	gridHandle at: gridCoord x at: gridCoord y at: gridCoord z put: aBlockTypeId.
	self voxelChunks markDirtyAt: gridCoord.
	^ true
]

{
	#category : #panels,
	#'squeak_changestamp' : 'leo-MCPServer 11/25/2026 19:52'
}
SWAGameXR >> placeNewPanel: aSlab atSide: aSign z: aZ [
	"Where a panel goes when it is switched on. Standing in the world there is no
	board to stand it beside -- the edge is 16 m away -- so it arrives in front of
	the player instead.

	Decided here, at creation, rather than in the menu item: the panels are also
	toggled from the Morphic config window and from code, and those paths must
	not leave a slab 16 m up in the air."

	| camera forward right flat |
	aSlab ifNil: [^ self].
	walkMode == true ifFalse: [
		^ aSlab
			position: (self panelAnchorAtSide: aSign z: aZ);
			rotation: self globalRotation].
	camera := self actingAvatar ifNil: [^ self] ifNotNil: [:avatar | avatar camera].
	flat := [:v |
		| h |
		h := Vector3 x: v x y: 0 z: v z.
		h length < 0.001 ifTrue: [Vector3 x: 0 y: 0 z: -1] ifFalse: [h normalized]].
	forward := flat value: camera forward.
	right := flat value: camera right.
	self
		placePanel: aSlab
		at: camera globalTranslation
			+ (forward * 60 cm)
			+ (right * (aSign * 45 cm))
			- (Vector3 up * 20 cm)
]

{
	#category : #'walk mode',
	#'squeak_changestamp' : 'jl-MCPServer 11/20/2026 14:09'
}
SWAGameXR >> placeOnSurface: anAvatar [
	"Stand the player on the column under them, or on the middle of a generated
	chunk when they are over terrain that does not exist yet."
	| cell cellX cellZ top |
	"The head: the player stands under it, and it is metres from the rig origin
	once they have walked about the play space."
	cell := self cellPositionOf: anAvatar camera.
	cellX := cell x floor.
	cellZ := cell z floor.
	(world isCellGeneratedX: cellX z: cellZ) ifFalse: [
		| key |
		key := world generatedChunks detect: [:each | true] ifNone: [^ self].
		cellX := (world chunkXOfKey: key) * SWAGameChunk size + 8.
		cellZ := (world chunkZOfKey: key) * SWAGameChunk size + 8].
	top := world heightAtX: cellX + 1 y: cellZ + 1.
	"The avatar notices the rig moving and stands its own body under the head."
	anAvatar teleportTo: (self
		globalPositionForCellX: cellX + 0.5
		y: top
		z: cellZ + 0.5)
]

{
	#category : #panels,
	#'squeak_changestamp' : 'leo-MCPServer 11/25/2026 19:52'
}
SWAGameXR >> placePanel: aSlab at: aPosition [

	self actingAvatar ifNotNil: [:avatar |
		self placePanel: aSlab at: aPosition facing: avatar camera]
]

{
	#category : #panels,
	#'squeak_changestamp' : 'leo-MCPServer 11/25/2026 19:48'
}
SWAGameXR >> placePanel: aSlab at: aPosition facing: aCamera [
	"Face on to the player. Read the position from the menu that opened the
	panel: SRMenuItem runs the action before closeCascade, so the menu is still
	standing where the hand put it."

	aSlab ifNil: [^ self].
	"Local position and rotation rather than #setTransformAt:facingCamera:. That
	writes a whole look-at matrix, which drops the panel's scale and is undone
	again as soon as the global transform is recomputed from the stale local one.
	Panels are children of the world, so local is global here."
	aSlab
		position: aPosition;
		rotation: (self facingFrom: aPosition toward: aCamera globalTranslation)
]

{
	#category : #panels,
	#'squeak_changestamp' : 'MCPServer 10/16/2026 13:51'
}
SWAGameXR >> placePanel: aSlab besideMenu: aMenu [
	"Side by side with the menu that opened it: the menu is already standing
	where the hand put it, so its position and its right vector are the whole
	answer. Only the facing is computed, because a slab is a flat tray and would
	otherwise lie face up."

	aSlab ifNil: [^ self].
	self
		placePanel: aSlab
		at: aMenu globalTranslation + (aMenu right * (self panelScale * 10))
]

{
	#category : #panels,
	#'squeak_changestamp' : 'leo-MCPServer 11/25/2026 19:48'
}
SWAGameXR >> placePanelsAt: aPosition facing: aCamera [
	"Face on to the player, and offset sideways from each other, otherwise the
	two slabs occupy the same spot."

	{buttonSlab -> 1. toolSlab -> -1} do: [:each |
		self
			placePanel: each key
			at: aPosition + (aCamera right * (each value * self panelScale * 12))
			facing: aCamera]
]

{
	#category : #panels,
	#'squeak_changestamp' : 'MCPServer (jl) 11/3/2026 15:09'
}
SWAGameXR >> reconcilePanels [
	"A panel can be dismissed with the Remove halo item, which never passes
	through the toggles: the flag went on claiming the panel was open, so the
	menu label read ON and the next toggle only cleared the flag instead of
	bringing the panel back."

	(buttonSlab notNil and: [buttonSlab isOpen not])
		ifTrue: [self disableButtons].
	(toolSlab notNil and: [toolSlab isOpen not])
		ifTrue: [self disableTools].
	(popGraph notNil and: [popGraph isOpen not])
		ifTrue: [self toggleGraph].
	(traceGraph notNil and: [traceGraph isOpen not])
		ifTrue: [self toggleTraceGraph].
	"And the other direction: #initialize claims the panels are on before
	#createUI has built any of them."
	buttonSlab ifNil: [showButtons := false].
	toolSlab ifNil: [showTools := false].
	popGraph ifNil: [showGraph := false].
	(mobInspector notNil and: [mobInspector isOpen not])
		ifTrue: [mobInspector := nil. selectedMob := nil]
]

{
	#category : #simulation,
	#'squeak_changestamp' : 'MCPServer (jl) 11/13/2026 11:08'
}
SWAGameXR >> recordTraceFrame: milliseconds ticked: aBoolean [
	| entry |
	selectedMob ifNil: [^ self].
	entry := mobObjects detect: [:each | each mob == selectedMob] ifNone: [nil].
	traceGraph
		recordFrameOf: selectedMob
		entry: entry
		milliseconds: milliseconds
		t: animT
		ticked: aBoolean
		worldScale: worldScale.
]

{
	#category : #'world generation',
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameXR >> refreshChunkMarkers [
	chunkMarkers ifNotNil: [chunkMarkers do: [:each | each remove]].
	chunkMarkers := OrderedCollection new.
	self candidateChunkKeys do: [:coord |
		| marker centre |
		centre := self
			objectPosForCellX: coord x * 16 + 8
			y: 1
			z: coord y * 16 + 8.
		marker := SWAGameButton new
			label: 'Generate';
			color: (Color r: 0.9 g: 0.8 b: 0.2);
			action: [self generateChunkAtX: coord x z: coord y];
			yourself.
		marker position: centre.
		"Grabbing a marker grabs the game, whose context menu then opens."
		marker grabTarget: self.
		marker scale: (Vector3 one * self chunkMarkerSize).
		self addChild: marker.
		chunkMarkers add: marker]
]

{
	#category : #simulation,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 15:27'
}
SWAGameXR >> releaseGpuResources [
	"Deferred, since a removal can come from a menu and GL belongs to the render process. Both upload again if the game is added back."
	| chunks texture mobs |
	chunks := voxelChunks.
	mobs := mobRenderer.
	texture := grassTexture.
	self world ifNotNil: [:aWorld |
		aWorld addDeferredFrameMessage: [
			chunks ifNotNil: [chunks unloadAllMeshes].
			mobs ifNotNil: [mobs unloadMeshes].
			texture ifNotNil: [texture unload]]].
]

{
	#category : #initialization,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameXR >> remove [
	"The context menu's Remove comes here, not through #destroy."
	self removePanels.
	self releaseGpuResources.
	super remove.
]

{
	#category : #'box management',
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameXR >> removeBoxAt: gridCoord [
	(gridHandle at: gridCoord x at: gridCoord y at: gridCoord z) = SWAGameBlocks air
		ifTrue: [^ false].

	gridHandle at: gridCoord x at: gridCoord y at: gridCoord z put: SWAGameBlocks air.
	self voxelChunks markDirtyAt: gridCoord.
	Transcript cr; show: 'Removed box at ', gridCoord printString.
	^ true
]

{
	#category : #initialization,
	#'squeak_changestamp' : 'MCPServer (jl) 11/3/2026 15:09'
}
SWAGameXR >> removePanels [
	"The slabs, the inspector and the graph are world children rather than children
	of the game, so nothing unparents them when the game goes."
	popGraph ifNotNil: [popGraph destroy. popGraph remove. popGraph := nil].
	traceGraph ifNotNil: [traceGraph destroy. traceGraph remove. traceGraph := nil].
	mobInspector ifNotNil: [mobInspector remove. mobInspector := nil].
	buttonSlab ifNotNil: [buttonSlab remove. buttonSlab := nil].
	toolSlab ifNotNil: [toolSlab remove. toolSlab := nil].
]

{
	#category : #rendering,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameXR >> renderChunkBoundsOn: aSRRenderer [
	| size |
	size := self voxelChunks chunkSize.
	0 to: gridWidth - 1 // size do: [:cx |
		0 to: gridHeight - 1 // size do: [:cy |
			0 to: gridDepth - 1 // size do: [:cz |
				| centre |
				centre := self
					objectPosForCellX: cx * size + (size / 2)
					y: cy * size + (size / 2)
					z: cz * size + (size / 2).
				rlChunkPos x: centre x; y: centre y; z: centre z.
				Raylib
					drawCubeWiresPosition: rlChunkPos
					width: size * worldScale
					height: size * worldScale
					length: size * worldScale
					color: rlChunkColor]]]
]

{
	#category : #rendering,
	#'squeak_changestamp' : 'MCPServer (jl) 10/21/2026 12:40'
}
SWAGameXR >> renderHandTargetsOn: aSRRenderer [
	"A wire box round the voxel each hand is pointing at, in that hand's own
	colour rather than its tool's: the tool is already shown by the preview cube
	on the hand, and white tools -- a rabbit is Color white -- were
	indistinguishable from no colour at all.

	Oversized a little, or it z-fights with the block's own faces. Caller has
	pushed the game's transform, so these are local positions."

	| size |
	handTargets ifNil: [^ self].
	size := worldScale * 1.04.
	handTargets keysAndValuesDo: [:hand :hit |
		hit ifNotNil: [
			| centre colour |
			centre := self
				objectPosForCellX: (hit at: 1) + 0.5
				y: (hit at: 2) + 0.5
				z: (hit at: 3) + 0.5.
			rlTargetPos x: centre x; y: centre y; z: centre z.
			colour := hand rayColor.
			Raylib
				drawCubeWiresPosition: rlTargetPos
				width: size
				height: size
				length: size
				color: (self
					rlScratchColorRed: colour red
					green: colour green
					blue: colour blue)]].
]

{
	#category : #petting,
	#'squeak_changestamp' : 'MCPServer (leo) 11/5/2026 17:49'
}
SWAGameXR >> renderHeartsOn: aSRRenderer [

	hearts ifNotNil: [hearts renderFacing: self viewerPosition].
]

{
	#category : #rendering,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:18'
}
SWAGameXR >> renderOn: aSRRenderer [
	"Raylib structs are refilled, never built: see #ensureRlScratch."
	| t barW barH barOffset ageBarMaxH bars mob position
	  eRatio mobScale hlSize energyW ageH bodyW bodyH meshes |

	"drawMesh replaces the current matrix, so the terrain goes before our push."
	self renderTerrainMeshOn: aSRRenderer.

	(showChunkBounds ifNil: [false]) ifTrue: [
		self ensureRlScratch.
		Raylib rlPushMatrix; rlMultMatrixfMatf: self globalTransform transposed.
		self renderChunkBoundsOn: aSRRenderer.
		Raylib rlPopMatrix].

	self ensureRlScratch.
	t := animT ifNil: [1.0].
	bars := showBars ifNil: [false].

	barW := worldScale * 0.8.
	barH := worldScale * 0.12.
	barOffset := worldScale * 0.8.
	ageBarMaxH := worldScale * 0.6.

	meshes := self class animalModels and: [
		self mobRenderer
			renderEntries: mobObjects t: t transform: self globalTransform
			worldScale: worldScale on: aSRRenderer].

	Raylib rlPushMatrix;
		rlMultMatrixfMatf: self globalTransform transposed.

	self renderHandTargetsOn: aSRRenderer.
	self renderHeartsOn: aSRRenderer.
	self renderVegetationOn: aSRRenderer.

	mobObjects do: [:entry |
		mob := entry mob.
		mobScale := mob isChild
			ifTrue: [entry scale * 0.6]
			ifFalse: [entry scale].
		position := entry positionAt: t.
		rlMobPos setPosition: position.
		entry isBody
			ifTrue: [
				bodyW := mobScale * (0.4 + (0.6 * entry remains)).
				bodyH := mobScale * 0.3.
				rlMobPos y: position y - (mobScale - bodyH / 2).
				meshes ifFalse: [Raylib
					drawCubePosition: rlMobPos
					width: bodyW * 1.4 height: bodyH length: bodyW
					color: entry wireColor]]
			ifFalse: [
			meshes ifFalse: [Raylib
				drawCubePosition: rlMobPos
					width: mobScale height: mobScale length: mobScale
					color: entry color;
				drawCubeWiresPosition: rlMobPos
					width: mobScale height: mobScale length: mobScale
					color: entry wireColor].

			mob == selectedMob ifTrue: [
				hlSize := mobScale * 1.4.
				Raylib
					drawCubeWiresPosition: rlMobPos
						width: hlSize height: hlSize length: hlSize
						color: rlHighlightColor].

			bars ifTrue: [
				"Fill and back sit side by side: overlapping coplanar cubes z-fight."
				eRatio := entry energyRatio.
				energyW := barW * eRatio.
				energyW < barW ifTrue: [
					rlBarPos x: position x + (energyW / 2); y: position y + barOffset; z: position z.
					Raylib
						drawCubePosition: rlBarPos
							width: barW - energyW height: barH length: barH
							color: rlEnergyBackColor].
				energyW > 0 ifTrue: [
					rlBarPos x: position x - (barW - energyW / 2); y: position y + barOffset; z: position z.
					Raylib
						drawCubePosition: rlBarPos
							width: energyW height: barH length: barH
							color: (eRatio > 0.5
								ifTrue: [self rlScratchColorRed: (1.0 - eRatio) * 2 green: 1.0 blue: 0.0]
								ifFalse: [self rlScratchColorRed: 1.0 green: eRatio * 2 blue: 0.0])].

				ageH := (mob age / mob lifespan min: 1.0) * ageBarMaxH max: (barH * 0.5).
				rlBarPos x: position x + (mobScale * 0.8); y: position y - (mobScale / 2) + (ageH / 2); z: position z.
				Raylib
					drawCubePosition: rlBarPos
						width: barH height: ageH length: barH
						color: (mob isChild ifTrue: [rlAgeYoungColor] ifFalse: [rlAgeOldColor])]]].

	Raylib rlPopMatrix
]

{
	#category : #rendering,
	#'squeak_changestamp' : 'MCPServer (leo) 11/3/2026 12:21'
}
SWAGameXR >> renderTerrainMeshOn: aSRRenderer [
	"Remeshing is budgeted per frame: small jobs fit a frame's slack, one big remesh does not."
	| rlMaterial chunks |
	chunks := self voxelChunks.
	chunks rebuildUpTo: self chunkRebuildBudget.
	self ensureVoxelMeshMaterial.
	voxelMeshMaterial ifNil: [^ self].
	rlMaterial := voxelMeshMaterial internalMaterialFor: aSRRenderer.
	self ensureRlScratch.
	self updateGrassTexture.
	self setVoxelUniforms.
	voxelMeshMaterial shader ifNotNil: [:shader | aSRRenderer applyLightingTo: shader].
	SRRaylibRenderer fill: rlVoxelTransform withMatrix4x4: self globalTransform.
	chunks meshesDo: [:mesh |
		Raylib drawMesh: mesh internalMesh material: rlMaterial transform: rlVoxelTransform]
]

{
	#category : #rendering,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:18'
}
SWAGameXR >> renderVegetationOn: aSRRenderer [

	self vegetation renderGarden: world garden of: self.
]

{
	#category : #panels,
	#'squeak_changestamp' : 'MCPServer 10/16/2026 10:26'
}
SWAGameXR >> repositionPanelsAtTable [
	"The slabs are world children, so they follow neither the game's transform
	nor its scale on their own."

	| spacing |
	spacing := self panelScale * 2 * 2.5.
	buttonSlab ifNotNil: [
		buttonSlab
			position: (self panelAnchorAtSide: 1 z: spacing * 1.5);
			rotation: self globalRotation].
	toolSlab ifNotNil: [
		toolSlab
			position: (self panelAnchorAtSide: -1 z: 0);
			rotation: self globalRotation]
]

{
	#category : #'world generation',
	#'squeak_changestamp' : 'MCPServer (MCPServer) 10/23/2026 12:28'
}
SWAGameXR >> resizeToGrid: cells height: blockHeight [
	"Rebuild the world at a different size. Everything that carries a dimension
	has to be renewed together: the simulation, the voxel store, the mesh chunks,
	the mapping and the grass map are all sized from these two numbers."

	gridWidth := cells.
	gridDepth := cells.
	gridHeight := blockHeight.
	space := nil.

	world := SWAGameWorld gridSize: cells maxHeight: (blockHeight * 2 // 3).
	gridHandle := SWAGameChunkedGrid width: cells depth: cells height: blockHeight.
	world voxels: gridHandle.

	voxelChunks
		setGrid: gridHandle
		width: gridWidth height: gridHeight depth: gridDepth
		worldScale: worldScale.
	voxelChunks space: self space.

	"Sized from the grid, so they cannot be reused across a resize."
	grassTexture ifNotNil: [:texture |
		self world ifNotNil: [:aWorld | aWorld addDeferredFrameMessage: [texture unload]]].
	grassSource := nil.
	grassTexture := nil.
	grassShadeApplied := nil.
	mobSnapshots := Dictionary new.
	mobObjects := OrderedCollection new.

	self generateLevel.
	^ self
]

{
	#category : #'raylib scratch',
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameXR >> rlColorsForMobColor: aColor [
	"A flat Array scanned linearly: an ifAbsent: block here costs ~224 B per call."

	| index |
	rlMobColors ifNil: [rlMobColors := Array new: 0].
	index := 1.
	[index < rlMobColors size] whileTrue: [
		(rlMobColors at: index) = aColor ifTrue: [^ rlMobColors at: index + 1].
		index := index + 2].
	rlMobColors := rlMobColors,
		(Array
			with: aColor
			with: (Array
				with: (SRRaylibRenderer fill: RlColor new withColor: aColor)
				with: (SRRaylibRenderer fill: RlColor new withColor: aColor muchDarker))).
	^ rlMobColors at: rlMobColors size
]

{
	#category : #'raylib scratch',
	#'squeak_changestamp' : 'MCPServer 10/12/2026 17:54'
}
SWAGameXR >> rlScratchColorRed: r green: g blue: b [
	^ rlScratchColor
		r: (r * 255) asInteger;
		g: (g * 255) asInteger;
		b: (b * 255) asInteger;
		a: 255;
		yourself
]

{
	#category : #simulation,
	#'squeak_changestamp' : 'MCPServer (jl) 10/21/2026 11:11'
}
SWAGameXR >> samplePopulations [
	"One scan for both readouts. Each is gated on its own flag: this was called
	#updateCountLabels and #step: therefore ran it only when the button slab was
	open, so the graph recorded nothing from the day the slabs stopped opening
	by default."

	| rabbits foxes |
	world ifNil: [^ self].
	rabbits := (world mobsOfSpecies: #rabbit) size.
	foxes := (world mobsOfSpecies: #fox) size.
	rabbitLabel ifNotNil: [rabbitLabel text: 'Rabbits: ', rabbits printString].
	foxLabel ifNotNil: [foxLabel text: 'Foxes: ', foxes printString].
	popGraph ifNotNil: [popGraph recordRabbits: rabbits foxes: foxes].
]

{
	#category : #simulation,
	#'squeak_changestamp' : 'MCPServer 7/29/2026 18:06'
}
SWAGameXR >> selectSpecies: aSymbolOrNil [
	"Select a species for placement, or nil to deselect.
	Clicking the same species again deselects."
	selectedSpecies = aSymbolOrNil
		ifTrue: [
			selectedSpecies := nil.
			rabbitBtn ifNotNil: [rabbitBtn selected: false].
			foxBtn ifNotNil: [foxBtn selected: false]]
		ifFalse: [
			selectedSpecies := aSymbolOrNil.
			selectedSpecies ifNotNil: [self selectTool: nil].
			rabbitBtn ifNotNil: [rabbitBtn selected: selectedSpecies = #rabbit].
			foxBtn ifNotNil: [foxBtn selected: selectedSpecies = #fox]]
]

{
	#category : #'terrain editing',
	#'squeak_changestamp' : 'MCPServer 7/29/2026 18:06'
}
SWAGameXR >> selectTool: aSymbolOrNil [
	"Select a terrain material (build) or #pickaxe (dig), nil to deselect.
	 Clicking the active tool again deselects it. Editing and mob spawning are
	 mutually exclusive, so picking a tool clears the species selection."
	selectedTool = aSymbolOrNil
		ifTrue: [selectedTool := nil]
		ifFalse: [
			selectedTool := aSymbolOrNil.
			selectedTool ifNotNil: [self selectSpecies: nil]].
	self updateToolButtonSelection
]

{
	#category : #'terrain editing',
	#'squeak_changestamp' : 'MCPServer 7/29/2026 18:06'
}
SWAGameXR >> selectedTool [
	"The active terrain tool: a material symbol, #pickaxe, or nil."
	^ selectedTool
]

{
	#category : #'grass shading',
	#'squeak_changestamp' : 'MCPServer (MCPServer) 10/23/2026 10:25'
}
SWAGameXR >> setGrassUniformsOn: rawShader [
	"The shader recovers a cell from the object-space position using these two,
	so they must match SWAGameVoxelChunks>>writeQuadVerts:...
	SHADER_UNIFORM_FLOAT = 0, SHADER_UNIFORM_VEC2 = 1."

	| scaleLoc extentLoc mapLoc |
	scaleLoc := voxelMeshSRShader uniformLocAt: #worldScale.
	scaleLoc >= 0 ifTrue: [
		voxelWorldScaleBuffer floatAt: 1 put: worldScale asFloat.
		Raylib setShaderValueShader: rawShader
			locIndex: scaleLoc value: voxelWorldScaleBuffer uniformType: 0].

	extentLoc := voxelMeshSRShader uniformLocAt: #gridExtent.
	extentLoc >= 0 ifTrue: [
		voxelGridExtentBuffer floatAt: 1 put: gridWidth asFloat.
		voxelGridExtentBuffer floatAt: 5 put: gridDepth asFloat.
		Raylib setShaderValueShader: rawShader
			locIndex: extentLoc value: voxelGridExtentBuffer uniformType: 1].

	mapLoc := voxelMeshSRShader uniformLocAt: #grassMap.
	mapLoc >= 0 ifTrue: [
		Raylib setShaderValueTextureShader: rawShader
			locIndex: mapLoc texture: self ensureGrassTexture internalTexture]
]

{
	#category : #rendering,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 16:32'
}
SWAGameXR >> setShaderFloat: aFloat at: aLocation on: rawShader [
	"One buffer serves every float uniform: SetShaderValue copies it into GL at once.
	SHADER_UNIFORM_FLOAT = 0."
	voxelThicknessBuffer floatAt: 1 put: aFloat asFloat.
	Raylib setShaderValueShader: rawShader locIndex: aLocation value: voxelThicknessBuffer uniformType: 0.
]

{
	#category : #rendering,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 16:32'
}
SWAGameXR >> setVoxelUniforms [
	"Per-frame uniforms of the terrain shader. The outline width comes from fwidth()
	in the shader, so no viewport size is needed and stereo is right per eye.
	mvp / matNormal / colDiffuse are set by raylib''s DrawMesh."
	| raw loc |
	voxelMeshSRShader ifNil: [^ self].
	raw := voxelMeshSRShader internalShader.
	raw ifNil: [^ self].
	self ensureRlScratch.
	loc := voxelMeshSRShader uniformLocAt: #lineThickness.
	loc >= 0 ifTrue: [self setShaderFloat: self effectiveLineThickness at: loc on: raw].
	loc := voxelMeshSRShader uniformLocAt: #blockTextures.
	loc >= 0 ifTrue: [
		self
			setShaderFloat: (self class blockTextures ifTrue: [1.0] ifFalse: [0.0])
			at: loc
			on: raw].
	self setGrassUniformsOn: raw
]

{
	#category : #'grass shading',
	#'squeak_changestamp' : 'MCPServer 10/15/2026 14:54'
}
SWAGameXR >> shadeIndexForGrass: aLevel [

	^ (aLevel * (self grassShadeCount - 1) / world maxGrass) rounded + 1
]

{
	#category : #mobs,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameXR >> snapshotMobPositions [
	"Keyed by mob, not index: deaths shift the entries."

	mobSnapshots ifNil: [mobSnapshots := Dictionary new].
	mobSnapshots removeAll.
	world mobsDo: [:mob |
		mobSnapshots at: mob put: (self worldPosForMob: mob)]
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameXR >> space [
	^ space ifNil: [
		space := SWAGameSpace
			worldScale: worldScale
			originX: gridWidth / 2
			originZ: gridDepth / 2]
]

{
	#category : #simulation,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 14:35'
}
SWAGameXR >> spawn: aSpeciesSymbol atX: gx z: gz [
	"On top of the column rather than at the cell that was hit: a mob dropped
	into a hillside would start inside solid ground. #heightAtX:y: is one based."
	world ifNil: [^ self].
	(world speciesRegistry includesKey: aSpeciesSymbol) ifFalse: [^ self].
	world addMobNow: ((world newMobOfSpecies: aSpeciesSymbol)
		positionX: gx + 0.5 y: (world heightAtX: gx + 1 y: gz + 1) z: gz + 0.5;
		yourself).
	self samplePopulations.
	self buildMobAnimationData.
]

{
	#category : #tools,
	#'squeak_changestamp' : 'leo-MCPServer 11/25/2026 19:52'
}
SWAGameXR >> spawnGunFor: aHand [

	| avatar camera position gun |
	avatar := aHand
		ifNil: [self actingAvatar]
		ifNotNil: [aHand avatar].
	avatar ifNil: [^ self].
	camera := avatar camera.
	position := aHand
		ifNil: [camera globalTranslation + (camera forward * 45cm)]
		ifNotNil: [avatar menuPlacementPositionForHand: aHand].
	gun := SRGun new.
	self world addChild: gun.
	gun globalTransform: (Matrix4x4
		objectLookAt: position + camera forward
		from: position
		up: Vector3 up).
]

{
	#category : #simulation,
	#'squeak_changestamp' : 'MCPServer (jl) 10/29/2026 14:35'
}
SWAGameXR >> spawnMob: speciesSymbol [
	"Spawn a mob of the given species at a random position, with this game's parameters."
	| gs cx cz |
	gs := world gridSize.
	cx := (0 to: gs - 1) atRandom.
	cz := (0 to: gs - 1) atRandom.
	world addMobNow: ((world newMobOfSpecies: speciesSymbol)
		positionX: cx + 0.5 y: (world heightAtX: cx + 1 y: cz + 1) z: cz + 0.5;
		yourself).
	self samplePopulations
]

{
	#category : #simulation,
	#'squeak_changestamp' : 'MCPServer (jl) 10/21/2026 11:17'
}
SWAGameXR >> spawnableSpecies [
	"Sorted, so the tool rows do not reorder themselves between menus: the
	registry is a Dictionary."

	^ world
		ifNil: [#()]
		ifNotNil: [:each | each speciesRegistry keys asSortedCollection asArray]
]

{
	#category : #'world generation',
	#'squeak_changestamp' : 'MCPServer 10/15/2026 16:50'
}
SWAGameXR >> startFromSingleChunk [
	"Reset to one generated chunk with markers on its empty neighbours. The
	terrain grows by clicking them."

	world startFromChunkX: 0 z: 0.
	gridHandle clear.
	self fillChunkVoxelsAtX: 0 z: 0.
	grassShadeApplied := nil.
	self updateMobVisuals.
	self refreshChunkMarkers.
	^ world generatedChunks size
]

{
	#category : #simulation,
	#'squeak_changestamp' : 'MCPServer (leo) 11/9/2026 15:03'
}
SWAGameXR >> step: deltaTime [
	| ticked milliseconds |
	super step: deltaTime.
	self updateHandTargets.
	paused ifTrue: [^ self].
	self petRabbitsOver: deltaTime asFloat.
	
	"Float, not the Fraction deltaTime arrives as: animT is read per mob per frame."
	milliseconds := deltaTime asFloat * 1000.
	tickElapsed := (tickElapsed ifNil: [0.0]) + milliseconds.
	ticked := tickElapsed >= tickMillis.
	ticked ifTrue: [
		"A frame longer than one period would otherwise queue up ticks to catch up on."
		tickElapsed := (tickElapsed - tickMillis) min: tickMillis.
		world ifNotNil: [
			self updateSimulationCentre.
			self snapshotMobPositions.
			world tick.
			self buildMobAnimationData.
			self advanceGaits.
			(showButtons or: [showGraph]) ifTrue: [self samplePopulations].
			
			selectedMob ifNotNil: [
				selectedMob alive
					ifTrue: [mobInspector ifNotNil: [mobInspector update]]
					ifFalse: [
						selectedMob := nil.
						mobInspector ifNotNil: [mobInspector mob: nil]]]]].
	
	"After the tick, or its frame draws the new segment at the end and the next frame steps back."
	animT := (tickElapsed / tickMillis) min: 1.0.
	traceGraph ifNotNil: [self recordTraceFrame: milliseconds ticked: ticked].
]

{
	#category : #petting,
	#'squeak_changestamp' : 'MCPServer (jl) 11/10/2026 18:17'
}
SWAGameXR >> stopPetSoundUnlessTouchedAt: touchPoints [

	petSoundMob ifNil: [^ self].
	(petSoundMob alive and: [self mob: petSoundMob isTouchedAtAny: touchPoints]) ifTrue: [^ self].
	petSound ifNotNil: [:sound | sound stop].
	petSoundMob := nil.
]

{
	#category : #'terrain editing',
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:18'
}
SWAGameXR >> syncHeightMapForColumnX: gx z: gz [
	| x z top height |
	x := gx rounded.
	z := gz rounded.
	((x between: 0 and: gridWidth - 1) and: [z between: 0 and: gridDepth - 1])
		ifFalse: [^ self].
	top := self topFilledYAtX: x z: z.
	height := top ifNil: [0] ifNotNil: [top + 1].
	height = (world heightAtX: x + 1 y: z + 1) ifFalse: [world garden clearAt: x @ z].
	world heightAtX: x + 1 y: z + 1 put: height
]

{
	#category : #tools,
	#'squeak_changestamp' : 'MCPServer (jl) 10/21/2026 12:39'
}
SWAGameXR >> targetVoxelFor: aHand [
	"The voxel this hand is pointing at, or nil. Not gated on holding a tool:
	targeting is a property of the ray, and showing it for a bare hand is how
	you find out where a hand is aiming before arming it.

	Cast the whole scene rather than just the terrain collider: a menu in the
	way means a tool would decline, so the mark has to go out at that moment."

	| result |
	result := aHand rayForward castNearest: self world.
	^ (result notNil and: [result object == self])
		ifTrue: [lastVoxelHit]
]

{
	#category : #simulation,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameXR >> tick [
	"One tick now, regardless of the frame clock."
	self snapshotMobPositions.
	world tick.
	self buildMobAnimationData.
	self advanceGaits.
	animT := 0.0.
	tickElapsed := 0.0
]

{
	#category : #simulation,
	#'squeak_changestamp' : 'MCPServer 7/29/2026 18:06'
}
SWAGameXR >> toggleBars [
	"Toggle visibility of energy/age bars on mobs."
	showBars := showBars not.
	barsLabel ifNotNil: [
		showBars
			ifTrue: [barsLabel text: 'Bars: ON']
			ifFalse: [barsLabel text: 'Bars: OFF']]
]

{
	#category : #'debug toggles',
	#'squeak_changestamp' : 'MCPServer 10/16/2026 13:53'
}
SWAGameXR >> toggleButtons [
	self reconcilePanels.
	showButtons
		ifTrue: [self disableButtons]
		ifFalse: [self enableButtons]
]

{
	#category : #'debug toggles',
	#'squeak_changestamp' : 'MCPServer 10/15/2026 16:01'
}
SWAGameXR >> toggleChunkBounds [
	showChunkBounds := (showChunkBounds ifNil: [false]) not.
	^ showChunkBounds
]

{
	#category : #simulation,
	#'squeak_changestamp' : 'MCPServer 10/16/2026 13:26'
}
SWAGameXR >> toggleGraph [
	"Toggle the population graph world child. Also updates the showGraph flag."
	| spacing graphPos |
	popGraph ifNotNil: [
		popGraph destroy.
		popGraph remove.
		popGraph := nil.
		showGraph := false.
		^ self].
	
	"Panel sizes are in metres for a human, not multiples of the world scale: at
	1 m per block the graph was 3 m tall and stood 16 m away."
	spacing := self panelScale * 2 * 2.5.
	popGraph := SWAGamePopGraph new
		scale: (Vector3 one * (self panelScale * 3));
		yourself.
	self world addChild: popGraph.
	self placeNewPanel: popGraph atSide: 1 z: spacing * 6.
	showGraph := true
]

{
	#category : #simulation,
	#'squeak_changestamp' : 'MCPServer 7/29/2026 18:06'
}
SWAGameXR >> togglePause [
	"Toggle simulation pause state and update the pause button label."
	paused := paused not.
	pauseLabel ifNotNil: [
		paused
			ifTrue: [pauseLabel text: 'Continue']
			ifFalse: [pauseLabel text: 'Pause']]
]

{
	#category : #'debug toggles',
	#'squeak_changestamp' : 'MCPServer 10/16/2026 13:53'
}
SWAGameXR >> toggleTools [
	self reconcilePanels.
	(showTools ifNil: [false])
		ifTrue: [self disableTools]
		ifFalse: [self enableTools]
]

{
	#category : #simulation,
	#'squeak_changestamp' : 'MCPServer (jl) 11/3/2026 15:09'
}
SWAGameXR >> toggleTraceGraph [

	| spacing |
	traceGraph ifNotNil: [
		traceGraph destroy.
		traceGraph remove.
		traceGraph := nil.
		^ self].
	spacing := self panelScale * 2 * 2.5.
	traceGraph := SWAGameMobTraceGraph new
		scale: (Vector3 one * (self panelScale * 3));
		yourself.
	self world addChild: traceGraph.
	self placeNewPanel: traceGraph atSide: -1 z: spacing * 6.
]

{
	#category : #'walk mode',
	#'squeak_changestamp' : 'MCPServer 10/16/2026 09:49'
}
SWAGameXR >> toggleWalkMode [
	walkMode == true
		ifTrue: [self exitWalkMode]
		ifFalse: [self enterWalkMode]
]

{
	#category : #tools,
	#'squeak_changestamp' : 'MCPServer (jl) 10/21/2026 11:17'
}
SWAGameXR >> tools [
	"A fresh set each time: a tool carries its own parameters, so two hands must
	not share one instance."

	^ (OrderedCollection with: (SWAGameDigTool new game: self; yourself))
		addAll: (self class terrainMaterials collect: [:spec |
			SWAGamePlaceTool new game: self; material: spec first; yourself]);
		addAll: (self spawnableSpecies collect: [:each |
			SWAGameSpawnTool new game: self; species: each; yourself]);
		yourself
]

{
	#category : #'terrain editing',
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameXR >> topFilledYAtX: gx z: gz [
	"nil for an empty column."
	gridHeight - 1 to: 0 by: -1 do: [:y |
		(gridHandle at: gx at: y at: gz) ~= SWAGameBlocks air ifTrue: [^ y]].
	^ nil
]

{
	#category : #'grass shading',
	#'squeak_changestamp' : 'MCPServer (MCPServer) 10/23/2026 10:25'
}
SWAGameXR >> updateGrassTexture [
	"Written straight into the Form words: a canvas fill composites, and this is
	data rather than paint. Only changed columns are touched, and the upload is
	skipped entirely when nothing moved a shade."

	| gs bits changed |
	self ensureGrassTexture.
	gs := world gridSize.
	"Through the source, so a Form hibernated by an image save is expanded back
	into a Bitmap before anything stores a word into it."
	bits := grassSource bits.
	grassShadeApplied ifNil: [grassShadeApplied := Array new: gs * gs withAll: -1].
	changed := 0.
	0 to: gs - 1 do: [:cx |
		0 to: gs - 1 do: [:cz |
			| level slot |
			"Rivers lie inside the grass elevation band, so they need excluding
			explicitly or the water surface gets tinted like pasture."
			level := ((world isGrasslandAtX: cx + 1 z: cz + 1)
				and: [(world isRiverAt: cx @ cz) not])
					ifTrue: [self shadeIndexForGrass: (world grassAt: cx @ cz)]
					ifFalse: [0].
			slot := cz * gs + cx + 1.
			(grassShadeApplied at: slot) = level ifFalse: [
				grassShadeApplied at: slot put: level.
				bits at: slot put: (self grassWordForLevel: level).
				changed := changed + 1]]].
	changed > 0 ifTrue: [grassSource notifyTextureChanged].
	^ changed
]

{
	#category : #tools,
	#'squeak_changestamp' : 'jl-MCPServer 11/20/2026 14:09'
}
SWAGameXR >> updateHandTargets [
	"Per frame, not per tick: the highlight has to follow the hand even while
	the simulation is paused. The slot is written nil rather than removed, so
	the dictionary is allocated once instead of every frame."
	handTargets ifNil: [handTargets := IdentityDictionary new].
	self avatarsDo: [:each |
		each hands do: [:hand |
			handTargets at: hand put: (self targetVoxelFor: hand)]].
]

{
	#category : #simulation,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameXR >> updateMobVisuals [
	mobSnapshots := Dictionary new.
	self buildMobAnimationData
]

{
	#category : #petting,
	#'squeak_changestamp' : 'MCPServer (leo) 11/5/2026 17:58'
}
SWAGameXR >> updatePetting: aRabbit touchedAt: touchPoints over: seconds [

	(self mob: aRabbit isTouchedAtAny: touchPoints) ifTrue: [self pet: aRabbit].
	aRabbit isBeingPetted ifTrue: [
		self hearts
			emitAt: (self heartOriginFor: aRabbit)
			cellSize: worldScale
			over: seconds].
]

{
	#category : #simulation,
	#'squeak_changestamp' : 'leo-MCPServer 11/25/2026 19:52'
}
SWAGameXR >> updateSimulationCentre [
	| radius camera local |
	radius := self class simulationRadiusChunks.
	world simulationRadiusChunks: (radius > 0 ifTrue: [radius] ifFalse: [nil]).
	radius > 0 ifFalse: [^ self].
	camera := self actingAvatar ifNil: [^ self] ifNotNil: [:avatar | avatar camera].
	local := self cellPositionOf: camera.
	world simulateAroundCellX: local x z: local z
]

{
	#category : #'terrain editing',
	#'squeak_changestamp' : 'MCPServer 7/29/2026 18:06'
}
SWAGameXR >> updateToolButtonSelection [
	"Highlight the button of the active tool (yellow wireframe), unhighlight the rest."
	toolButtons ifNil: [^ self].
	toolButtons keysAndValuesDo: [:sym :btn |
		btn selected: sym == selectedTool]
]

{
	#category : #rendering,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:18'
}
SWAGameXR >> vegetation [

	^ vegetation ifNil: [vegetation := SWAGameVegetation new]
]

{
	#category : #watering,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:18'
}
SWAGameXR >> vegetationBaseFor: aCell [

	^ self
		objectPosForCellX: aCell x + 0.5
		y: (world heightAtX: aCell x + 1 y: aCell y + 1)
		z: aCell y + 0.5
]

{
	#category : #petting,
	#'squeak_changestamp' : 'leo-MCPServer 11/25/2026 19:52'
}
SWAGameXR >> viewerPosition [

	^ self viewingAvatar ifNotNil: [:avatar |
		self globalTransform globalPointToLocal: avatar camera globalTranslation]
]

{
	#category : #avatars,
	#'squeak_changestamp' : 'leo-MCPServer 11/25/2026 19:52'
}
SWAGameXR >> viewingAvatar [

	^ self class viewingAvatarIn: self world
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameXR >> voxelChunks [
	^ voxelChunks ifNil: [
		voxelChunks := SWAGameVoxelChunks
			grid: gridHandle
			width: gridWidth height: gridHeight depth: gridDepth
			worldScale: worldScale]
]

{
	#category : #watering,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:18'
}
SWAGameXR >> voxelHitFrom: start to: end [

	| hit entry |
	hit := (SWAGameVoxelRayWalk game: self ray: (SRRay origin: start forward: (end - start) normalized))
		ifNil: [^ nil]
		ifNotNil: [:walk | walk findHit].
	hit ifNil: [^ nil].
	entry := hit at: 5.
	^ ((self globalPositionForCellX: entry x y: entry y z: entry z) - start) length <= (end - start) length
		ifTrue: [hit]
]

{
	#category : #watering,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:18'
}
SWAGameXR >> waterAtX: gx y: gy z: gz [

	(self canGrowAtX: gx y: gy z: gz) ifTrue: [world water: gx @ gz].
]

{
	#category : #watering,
	#'squeak_changestamp' : 'leo-MCPServer 11/19/2026 14:18'
}
SWAGameXR >> wateredFrom: start to: end [

	| hit |
	world ifNil: [^ false].
	hit := (self voxelHitFrom: start to: end) ifNil: [^ false].
	self waterAtX: (hit at: 1) y: (hit at: 2) z: (hit at: 3).
	^ true
]

{
	#category : #simulation,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameXR >> worldPosForMob: mob [
	^ self
		objectPosForCellX: mob x
		y: mob y + (mob height / 2)
		z: mob z
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer 7/29/2026 18:06'
}
SWAGameXR >> worldScale [
	^worldScale
]

{
	#category : #accessing,
	#'squeak_changestamp' : 'MCPServer (jl) 11/2/2026 17:32'
}
SWAGameXR >> worldScale: aNumber [
	"The space is told, not replaced: the mesher shares it."
	worldScale = aNumber ifTrue: [^ self].
	worldScale := aNumber.
	self space worldScale: aNumber.
	voxelChunks ifNotNil: [voxelChunks worldScale: aNumber; markAllDirty].
	self refreshChunkMarkers.
	walkMode == true ifFalse: [self repositionPanelsAtTable]
]
