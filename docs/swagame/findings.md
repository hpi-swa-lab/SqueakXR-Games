# 15 Findings: Dead Code, Dead Features, Polish

[Deck](index.md) | [1 Architecture](architecture.md) | [2 Terrain](terrain.md) | [3 Chunks](chunks.md) | [4 Rendering](rendering.md) | [5 Picking](picking.md) | [6 Editing](editing.md) | [7 Mobs](mobs.md) | [8 Behaviour](behaviour.md) | [9 Ecosystem](ecosystem.md) | [10 Mob Rendering](mob-rendering.md) | [11 First Person](first-person.md) | [12 Panels](panels.md) | [13 Save and Load](save-load.md) | [14 Tests](tests.md) | **15 Findings**

A working list, collected during the documentation pass of 2026-11-02 and
checked against the running WSL image. Nothing here has been removed yet. The
list grows as more topics get their page. Topics 4 to 6 and 10 to 14 got
their pages on 2026-11-03 (15.7.7); their methods were read for the pages but
not yet scanned for dead code or given the comment pass.

## 15.1 How the dead code was found

```smalltalk
"Methods of the package without a sender anywhere (tests excluded, pragma methods excluded)."
(PackageInfo named: 'SWAGame') classes reject: [:c | c inheritsFrom: TestCase] ...
	SystemNavigation default allCallsOn: sel

"Instance variables that only one or two methods touch."
c whichSelectorsAccess: ivarName
```

False positives: preference setters (`SWAGameFox class>>walkSpeed:` and
friends) are reached through `perform: selector asMutator` from scenarios and
the config panel, and some methods are workspace entry points
(`SWAGameSimulation class>>compare:...`, `SWAGameMobRenderer>>forgetModels`,
`SWAGameVoxelChunks>>rebuildAllDirty`, `SWAGameXR>>startFromSingleChunk`).

## 15.2 Dead classes

| class | evidence | note |
|---|---|---|
| `SWACube` | no references, no instances | from before terrain was meshed |
| `SWAGameCube` | no references, no instances | same |
| `SWAGameLibrary` | no references, no instances | the FFI bridge to `libswagame.so`. The game is pure Smalltalk now; see also *Outside the image* below |

## 15.3 Dead features

- **Rivers.** `riverMap`, `isRiverAt:`, `riverMap` accessor, and the checks in
  `SWAGameWorld>>blockTypeAtX:z:y:`, `SWAGameRabbit>>canEnter:on:` (itself
  unsent) and `SWAGameXR>>updateGrassTexture`. Nothing fills the map since
  generation became per chunk. Either per-chunk water, or remove.
- **Board-game scale.** `SWAGameXR class>>boardGameScale` (0.1) and
  `newWithScale:` predate `tableWorldScale` (0.05) and walk mode; unsent.
- **The FFI-era lifecycle.** `SWAGameXR>>finalize` only nils `gridHandle`
  ("No C resources to clean up anymore"), and `destroy` is `finalize` plus
  `remove`.
- **Two ways to edit terrain and place mobs.** Hand tools (`SWAGameDigTool`,
  `SWAGamePlaceTool`, `SWAGameSpawnTool`, the app menu) and the older slabs
  (`createToolSlab` with `selectedTool` symbols and `#pickaxe`,
  `createButtonSlab` with `selectSpecies:`, both routed through
  `onTerrainClickX:y:z:face:`). Both still work and are reachable from the
  settings menu. Decide whether the slabs stay; if not, a large part of
  `SWAGameXR` goes with them (see the method sizes below).
- **The grass shade palette.** `grassShadePalette` and its `grassShadeCount`
  rationale ("every distinct Color is a permanent entry in the chunk colour
  cache") belong to the vertex-colour era; production code no longer uses the
  palette, only a test does.

## 15.4 Dead methods (no senders outside tests)

| class | methods |
|---|---|
| `SWAGameXR` | `createUI`, `enableGraph`, `disableGraph`, `spawnMob:`, `selectedTool`, `resizeToGrid:height:`, `colorForMaterial:` (class), `boardGameScale` (class) |
| `SWAGameWorld` | `compactTerrainMaps` (a one-time migration), `isSolidAtPointX:y:z:`, `mobsAt:ofSpecies:`, `riverMap`, `heightMap`, `deathTally`, `mobCount` (handy in a workspace) |
| `SWAGameChunk` | `indexLocalX:y:z:` |
| `SWAGameChunkedGrid` | `canPlaceAt:`, `hasSupportAt:`, `isOccludedX:y:z:`: board-game rules, now only exercised by `SWAGameChunkedGridTest` |
| `SWAGameVoxelChunks` | `chunkSize:`, `hasDirtyChunks` |
| `SWAGameMob` | `vy` |
| `SWAGameRabbit` | `canEnter:on:` |
| `SWAGameSlab` | `slabWidth`, `slabDepth` |
| `SWAGameScenario` | `valueOf:for:`, `saveCurrent` (class) |
| `SWAGameMobModel` | `gait` |
| `SWAGameLibrary` | `macModuleName`, `win32ModuleName`, `safeReload`, `safeReloadWithState` |

## 15.5 Dead state (written, never read)

- `SWAGameChunkedGrid>>#width`, `#depth`: the grid has no horizontal extent.
- `SWAGameXR>>#groundPlane`: only assigned; the plate lives on as a child.
- `SWAGameXR>>#selectedMobLabel`: only ever set to nil.
- `SWAGameButton>>#label`: set, never read. The chunk markers say
  `label: 'Generate'`, and nobody sees it.
- `SWAGameConfigPanel>>#valueLabels`: only initialised.

## 15.6 Remaining fixed-size bounds

The October rewrite removed five places where `gridSize`/`gridWidth` doubled as
a world limit. These remain; each stops a feature at the original 48 x 48 area:

| where | effect beyond the original area |
|---|---|
| `SWAGameXR>>updateGrassTexture` | the grass map texture is `gridSize` squared: grown chunks get no grazing tint |
| `SWAGameXR>>syncHeightMapForColumnX:z:` | returns early outside `gridWidth`: digging or building in a grown chunk leaves the height map stale, so grass and spawn heights disagree with the blocks |
| `SWAGameXR>>renderChunkBoundsOn:` | wire boxes only over the original area |
| `SWAGameXR>>generateLevel` | regenerates voxels for the original area only (a second copy of `fillChunkVoxelsAtX:z:`) |
| `SWAGameXR>>spawnMob:` | random position within `gridSize` (unsent anyway) |
| `SWAGameWorld>>ensureVoxels` | headless worlds raise blocks for the original area only |
| `SWAGameXR>>panelAnchorAtSide:z:` | the panels stand beside the original board; once the world has grown towards `-x`, the tool slab floats over terrain |

And one at a larger scale: **the mesher's chunk key** (`keyForChunkX:y:z:`,
`(cx * 1024 + cy) * 1024 + cz`) decodes `cz` from -512 to 511, while storage
keys allow -32768 to 32767 chunks. Beyond 512 chunks (8192 cells) mesh keys
collide. Out of reach today, but two key schemes for the same chunks is one
too many.

## 15.7 Polish

### 15.7.1 Size of `SWAGameXR`

64 instance variables (42 in July,
after a cleanup from 51), 149 methods. It mixes frame stepping, raw Raylib
drawing, the terrain shader and its uniforms, grass texture upload, picking,
two tool systems, three panels, walk mode, menus and persistence hooks.
Natural seams: a terrain renderer (mesh material, uniforms, grass texture), a
panel controller (slabs, graph, inspector, `reconcilePanels`), and the mob
render entries.

### 15.7.2 Methods near the Cog ARM64 JIT size limit

A large method once crashed the
Quest at *compile* time (journal 2026-07-29, threshold around 1000 bytes of
compiled method). Today: `createButtonSlab` 1380 bytes,
`SWAGameConfigPanel>>buildSliderRow:for:` 746, `createToolSlab` 713,
`SWAGameMobModel class>>rabbit` 682, `>>fox` 614.

### 15.7.3 Mob render entries

~~Mob render entries are 11-slot Arrays~~ Fixed 2026-11-13: they are
`SWAGameMobEntry` instances, still reused across ticks. Reading them by name
also shrank `renderOn:` to 333 bytes.

### 15.7.4 Duplication

- `SWAGameXR class>>terrainMaterials` repeats `SWAGameBlocks class>>types`
  (same six colours, plus a label).
- `generateLevel` and `fillChunkVoxelsAtX:z:` both fill voxels from heights.
- The `SWAGameSpace` for a grid is constructed in `SWAGameXR>>space` and again
  as a fallback in `SWAGameVoxelChunks>>space`; `SWAGameXR>>voxelChunks` has a
  lazy branch that would create a mesher *without* the shared space (dead
  today, since `initialize` always sets it).
- `SWAGameVoxelChunks>>writeQuadVerts:...` inlines the arithmetic of
  `SWAGameSpace>>vectorForCellX:y:z:` (reading the parameters from the shared
  space, so it cannot drift in scale or origin, but the formula exists twice).

### 15.7.5 Mobs and the simulation

- ~~**`age` counts ticks**~~ Fixed 2026-11-13: `age` is in seconds and
  measured against a `lifespan` preference (childhood, growth, meal size; see
  [Mobs](mobs.md)). Still open: no dying of old age, and games saved before
  the change load with their tick counts read as seconds, so every mob in them
  comes back full grown.
- **A fresh `SWAGameWorld` has no voxel store.** `isSolidAtX:y:z:` then answers
  false everywhere, so the mobs that `initialize` spawns fall for ever until
  someone calls `ensureVoxels`. `SWAGameXR` and the sweeps do; a test or a
  workspace easily does not.
- **Four integer key packings** for coordinates: `SWAGameChunk class>>keyX:z:`
  (chunks), `SWAGameVoxelChunks>>keyForChunkX:y:z:` (mesh chunks),
  `SWAGameWorld>>cellKeyForX:z:` (mob index) and `SWAGameNavigator>>keyX:y:z:`
  (route nodes), each with its own bias and range.
- **Initial mob parameters are written three times**: `SWAGameMob>>initialize`
  (generic values), the species' `initialize` (the same list again, from the
  class preferences), then `SWAGameWorld>>configureMob:` (the game's values).
  The first two lists are copies of each other.
- The strategies carry their own `detectionRange` fallbacks (flee 8, hunt 20),
  which differ from the preferences and only matter for a strategy built
  outside a species.
- `Rabbit max energy` and `Fox max energy` are described as "Maximum energy
  for bar display"; they cap energy, which matters for breeding and hunger.
- Graze and hunt fall back to `SWAGameWanderStrategy new` on every miss.

### 15.7.6 Smaller issues

- Generating one chunk calls `markAllDirty`: every chunk of the world is
  remeshed, not the new one and its four neighbours.
- `adoptWorld:` keeps the old `tickMillis`; a loaded world with another
  `secondsPerTick` would integrate at the wrong rate.
- `SWAGameWorld>>heightAtX:y:` names the z coordinate `y`, and
  `blockTypeAtX:z:y:` takes x, z, y. Both are one based, while `grassAt:` is
  zero based.
- Package categories disagree with the documented groups:
  `SWAGameVoxelChunks` and `SWAPerlinNoise` are in `SWAGame`, not
  `SWAGame-Voxels`.
- Transcript chatter on the normal path: `initialize`, `generateLevel`,
  `createButtonSlab`, `createToolSlab`, `removeBoxAt:` (every dug block),
  `lineThickness:`, `enable*`/`disable*`.
- `SWAGameConfigPanel>>doesNotUnderstand:` synthesises `get_Class_pref`,
  `set_...`, `txt_...` and `acc_...` selectors for the Morphic sliders. It
  works, but no browser or sender search can follow it.

### 15.7.7 Found while writing topics 4 to 6 and 10 to 14

- **`SWAGameWorld>>ensureVoxels` fills with id 1** (grass) for every block,
  not the block type by elevation. Harmless for collision, which only asks
  solid or not, but a headless world's voxels do not match its terrain.
- **Hand targets cast twice.** `updateHandTargets` casts each hand's ray
  against the whole scene every frame, in addition to `SRHand`'s own cast.
  The hand already knows what its ray hits.
- **`lastVoxelHit` is shared state** written during any cast that hits the
  game, by either hand or by the target update. The readers use it right
  after their own cast, which works because casts do not interleave; a
  per-cast result would make that explicit.
- **The tool slab and the hand tools** are two systems for the same edits
  ([Terrain Editing](editing.md)); `selectedTool` and `selectedSpecies` only
  serve the slab path.
- **Old comments in the not yet covered classes** are long and partly stale:
  `SWAGameXR>>lineThickness` ("mode #mesh only"), `gridHandle` ("The
  SWAGameGrid"), `finalize` ("No C resources to clean up anymore"),
  `createUI` ("Legacy entry point"), `SWAGameXR class>>boardGameScale` (0.1x,
  unsent).
- **Walk mode and scale are not part of a save**; `adoptWorld:` keeps
  whatever the open game has. Probably right, but not written down anywhere
  but [First Person](first-person.md).
- **Panels at the table lie flat**, so their text is upright only from the
  board side; from the menu they stand up and face the player.
- `SWAGameMobInspector` and `SWAGamePopGraph` override `onRaycast:` only to
  call `super`.
- No tests for dig, place, the height sync, or walk mode ([Tests](tests.md)).

## 15.8 Outside the image

- `AGENTS.md` in `squeak` still lists "SWAGame - FFI Integration" with
  `libswagame.c`, `Makefile.swagame` and `SWAGameLibrary default
  safeReloadWithState` as an active project.
- `squeak/notes/SWAGame.md` predates the chunked rewrite (the index says so).

## 15.9 Comments moved to these pages

Topics with a page had their method comments cut down to constraints
(see slide A.2 of the deck for the rule). The reasoning that was in them now
lives on these pages:

| page | mark set |
|---|---|
| 1 [Architecture](architecture.md) | `marks/01-architecture-and-frame-loop.json` |
| 2 [Terrain](terrain.md) | `marks/02-terrain-generation.json` |
| 3 [Chunks](chunks.md) | `marks/03-chunks.json` |
| 7 [Mobs](mobs.md) | `marks/07-mobs.json` |
| 8 [Behaviour](behaviour.md) | `marks/08-behaviour.json` |
| 9 [Ecosystem](ecosystem.md) | `marks/09-ecosystem.json` |
