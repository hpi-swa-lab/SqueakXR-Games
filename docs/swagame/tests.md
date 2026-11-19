# 14 Tests

[Deck](index.md) | [1 Architecture](architecture.md) | [2 Terrain](terrain.md) | [3 Chunks](chunks.md) | [4 Rendering](rendering.md) | [5 Picking](picking.md) | [6 Editing](editing.md) | [7 Mobs](mobs.md) | [8 Behaviour](behaviour.md) | [9 Ecosystem](ecosystem.md) | [10 Mob Rendering](mob-rendering.md) | [11 First Person](first-person.md) | [12 Panels](panels.md) | [13 Save and Load](save-load.md) | **14 Tests** | [15 Findings](findings.md)

Mark set: [marks/14-tests.json](marks/14-tests.json)

121 test methods in 13 classes, plus one isolation test that every
`SWAGameTestCase` subclass inherits. They run in the image like any SUnit
tests (package `SWAGame`, category of the test classes), and from the agent
through the MCP `evaluate` tool.

## 14.1 What they guard

| class | tests | guards | page |
|---|---|---|---|
| `SWAGameChunkedGridTest` | 12 | the chunked voxel store: keys, negative coordinates, empty space costs nothing, occlusion, support rules | [Chunks](chunks.md) |
| `SWAGameVoxelChunksTest` | 4 | mesh lifecycle (unload on rebuild, lost context), block id in alpha | [Chunks](chunks.md), [Terrain Rendering](rendering.md) |
| `SWAGameMobTest` | 28 | physics, energy, eating, resting, threats, chunk buckets, simulation radius, separation | [Mobs](mobs.md), [Behaviour](behaviour.md) |
| `SWAGameNavigatorTest` | 9 | routing: steps, walls, gaps, drops, unreachable columns, giving up | [Behaviour](behaviour.md) |
| `SWAGameScenarioTest` | 9 | scenarios, image defaults vs a game's parameters, JSON round trip | [Ecosystem](ecosystem.md) |
| `SWAGameSaveTest` | 4 | save and load, growth after loading, size, headless copies | [Save and Load](save-load.md) |
| `SWAGameXRMappingTest` | 23 | the game in the scene: cell mapping, picking, box sweep, hand targets, tool rows, menus, panels, grass texture | [Architecture](architecture.md), [Picking](picking.md), [Panels](panels.md) |
| `SWAGameLookTest` | 2 | defaults of the look preferences | [Terrain Rendering](rendering.md) |
| `SWAGameMobModelTest` | 9 | voxel models: culling, winding, limbs, poses | [Mob Rendering](mob-rendering.md) |
| `SWAGameMobGaitTest` | 7 | interpolation, heading, stride | [Mob Rendering](mob-rendering.md) |
| `SWAGameMobRendererTest` | 7 | transforms, bodies, lost context | [Mob Rendering](mob-rendering.md) |
| `SWAGameMobAnimationTest` | 5 | gaits fed by the ticks, entries, pruning | [Mob Rendering](mob-rendering.md) |
| `SWAGamePopGraphTest` | 2 | both series drawn, the swizzling shader | [Panels](panels.md) |

The test names are sentences about behaviour
(`testAThreatInterruptsAMeal`, `testFleeingNeverRunsPastTheThreat`), so the
list of selectors reads as a specification of the game.

## 14.2 Preference isolation: `SWAGameTestCase`

Species parameters, look settings and some SqueakXR settings are class
variables behind `<preference:>` getters that fall back to a literal when the
variable is nil. A test reading them would test whatever was last set in the
config window: retuning the rabbits' detection range from 6 to 2 once made a
flee test fail without a line of code changing.

`SWAGameTestCase` therefore:

- in `setUp`, saves and nils the preference variables of `SWAGameRabbit`,
  `SWAGameFox`, `SWAGameWorld`, `SWAGameXR` and `SRAvatar`
  (`preferenceHolders`, `preferenceVariablesOf:`), so the code defaults apply;
- in `tearDown`, restores them, also when the test fails, so running the
  tests never retunes the running game;
- inherits `testPreferencesAreTheCodeDefaults` to every subclass, which
  catches a `setUp` that forgets `super setUp`.

The holders and variables are **named**, not discovered: not every class
variable is a preference (`SWAGameBlocks` has a colour cache).

Four test classes (`SWAGameMobGaitTest`, `SWAGameMobModelTest`,
`SWAGameMobRendererTest`, `SWAGamePopGraphTest`) subclass `TestCase`
directly: they read no preferences.

## 14.3 Tests and the running world

- Most tests build their own headless `SWAGameWorld`, which needs no
  rendering ([Architecture](architecture.md)).
- `SWAGameXRMappingTest` builds its own `SWAGameXR` and, where a test needs
  hands, its own `SRWorld` (not started); `tearDown` destroys the game, since
  a leftover would be found by `SWAGameXR allInstances`, which is how the live
  game is found.
- The rendering tests (`SWAGameMobRendererTest`, `SWAGameVoxelChunksTest`)
  check transforms and resource bookkeeping, not pixels.

## 14.4 Not covered

- Dig, place and the height sync after an edit ([Terrain Editing](editing.md)).
- Walk mode: entering and leaving, panels brought to the hand
  ([First Person](first-person.md)).
- The terrain shader itself, beyond its inputs.
- The Morphic config window.
