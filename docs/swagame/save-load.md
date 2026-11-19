# 13 Save and Load

[Deck](index.md) | [1 Architecture](architecture.md) | [2 Terrain](terrain.md) | [3 Chunks](chunks.md) | [4 Rendering](rendering.md) | [5 Picking](picking.md) | [6 Editing](editing.md) | [7 Mobs](mobs.md) | [8 Behaviour](behaviour.md) | [9 Ecosystem](ecosystem.md) | [10 Mob Rendering](mob-rendering.md) | [11 First Person](first-person.md) | [12 Panels](panels.md) | **13 Save and Load** | [14 Tests](tests.md) | [15 Findings](findings.md)

Mark set: [marks/13-save-and-load.json](marks/13-save-and-load.json)

A game is saved as one JSON file: the terrain, the mobs and the game's own
parameters. The same form is how a world is copied for a headless run.

## 13.1 Where and how

- Game menu > *game* > **Save game** writes `swagame-worlds/game-N.json`
  (`SWAGameWorld>>saveAs:`, `nextSavedName`), next to the image, which is the
  repository, so both desktop images see the files.
- One **Load** row per file (`savedNames`); loading replaces the world of the
  open game (`SWAGameXR>>adoptWorld:`) rather than opening a second game.
- From code:

```smalltalk
game gameWorld saveAs: 'my-valley'.
game adoptWorld: (SWAGameWorld loadNamed: 'my-valley').
```

## 13.2 The format

`SWAGameWorld>>asJson`, version 1:

| key | contents |
|---|---|
| `format`, `version` | `'swagame-world'`, 1; `fromJson:` refuses anything else |
| `gridSize`, `maxHeight`, `voxelHeight`, `secondsPerTick` | the world's dimensions and tick period |
| `noise` | the 256-byte permutation of `SWAPerlinNoise` |
| `chunks` | per generated chunk: `at` (chunk x, z), `heights`, `grass` |
| `voxels` | per chunk column: `at`, `sections` (one entry per 16-cube, `null` when empty) |
| `mobFields`, `mobs` | one array per mob: species, x, y, z, energy, age, remains, deathTimer |
| `config` | this game's own parameters ([Ecosystem](ecosystem.md)) |
| `simulationCentre`, `simulationRadiusChunks` | the simulated area ([Chunks](chunks.md)) |
| `eaten`, `starved` | the death tally |

**Bytes are deflated, then Base64** (`bytesToText:`): a 4096-byte section of
mostly one block type comes out at a few dozen characters. The test world
of `testTheSavedFormIsCompact` has 18 KB of block, height and grass bytes,
about 40 KB as JSON numbers, and saves in under 8000 characters. The save in
the image directory, `swagame-worlds/game-1.json`, is 6951 bytes.

**The noise is saved**, so a loaded world grows new chunks exactly as the
original would have (`testALoadedWorldGrowsAsTheOriginalWould`).

## 13.3 Saving while the game runs

The render process ticks the game. `capturedState` copies everything in one
`valueUnpreemptively` block, so the save is never of a half-ticked world; the
JSON is rendered from that copy afterwards, outside the block.

## 13.4 Loading

`SWAGameWorld class>>fromJson:` checks the format, and `restoreFromJson:`
rebuilds the height and grass maps, the voxel store chunk by chunk and the
mobs. Every mob enters through `addMobNow:`, so it gets the loaded game's
parameters ([Mobs](mobs.md)); a body is laid down again with its remains
(`lieDeadWith:after:`).

`SWAGameXR>>adoptWorld:` swaps the world in **between frames** (as a deferred
frame message), so the renderer never draws half of each game. It renews what
depends on the world: grid size, the mesher's grid (all chunks dirty), the
grass texture, the mob render entries, the chunk markers, the inspector.

## 13.5 What is not saved

- What mobs are doing: routes, targets, strategies, timers, velocities and the
  current meal. A loaded mob decides afresh at its next reconsider.
- Gaits, so animals start in the rest pose.
- The world's random stream, so a loaded world does not replay the same
  future.
- The river map (rivers are a dead feature, [Terrain](terrain.md)).
- Anything of the `SWAGameXR`: scale, walk mode, panels, tools.

## 13.6 Copies for headless runs

`SWAGameWorld>>detachedCopy` is `fromJson: self asJson`: a copy is exactly
what loading a save gives, sharing nothing with the running game.
`SWAGameSimulation` runs such copies headless
(`testASimulationLeavesItsGameAndTheImageAlone`, [Ecosystem](ecosystem.md)).

## 13.7 Tests

`SWAGameSaveTest` (4): `testASavedWorldLoadsAsItWas`,
`testALoadedWorldGrowsAsTheOriginalWould`, `testTheSavedFormIsCompact`,
`testASimulationLeavesItsGameAndTheImageAlone`.
