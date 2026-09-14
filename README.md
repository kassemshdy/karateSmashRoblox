# Karate Smash 🥋

Players wear a white karate gi with pale lapels. New players start with a white
belt; returning players wear their earned belt color. Avatar shirts, pants,
layered clothing, and torso accessories are removed so they cannot cover the gi.
Head appearance is retained. Both R6 and R15 rigs are supported. Covered avatar
body meshes are hidden beneath the fabric, and the outfit refits if appearance
loading changes body proportions. The belt includes a front knot.

For the latest outfit and combat animation fixes, open **Karate-Smash-White-Gi.rbxl** using Studio
**File → Open from File**, then press Play. Rebuilding a file does not update an
already-open Studio place or a published game; reopen the file to load changes.

A child-friendly Roblox karate game built with Luau and Rojo. Practice, break
walls, collect creatures, build your base income, and advance belts.

## Current game — Phase 4 + medals and training upgrades

1. Spawn in the dojo. Sensei explains the loop; press **E** or tap **Talk** near him
   to reopen the current lesson.
2. Walk into training pads or fight the wooden training dummy to earn Karate Points.
   **Click / F** punches (10 damage); **Q** kicks (25 damage). Touch players have
   separate Punch and Kick buttons. Attacks share a server cooldown.
3. Break a brick wall (60 HP). The final hitter earns **5 points** and owns the
   creature drop. The wall rebuilds after 8 seconds; unclaimed drops expire after 30.
4. Approach your creature and press **E** or tap **Collect** within 10 studs. You
   can carry one creature at a time. A carried creature earns no income yet.
5. Carry it to your named base outside the entrance. Use **Place creature** at the
   matching species pedestal. Duplicates stack on that pedestal with a count and
   total income display; each placed creature contributes to income.
6. Earn coins every **5 seconds while connected**. Collect more creatures and
   spend coins on training upgrades and keep practicing toward higher belts.
   Offline earnings are not implemented.

| Creature | Rarity | Wall-drop chance | Coins per creature / 5 seconds |
|---|---|---:|---:|
| Bud Turtle | Common | 70% | 1 |
| Sky Drake | Rare | 25% | 4 |
| Sun Lion | Legendary | 5% | 12 |

Drops and placement are owner-only. Wrong-pedestal, distant, obstructed, duplicate,
and already-carrying requests do not consume or duplicate creatures. Death keeps
both the placed collection and the carried creature. Saves also preserve carrying
state, so a successful save/rejoin does not require claiming that creature again.
Each species count is bounded at 1,000,000; reaching the bound prevents further
pickups of that species.

Use **UPGRADES** to spend coins on **Hand Power** (punch) or **Leg Power** (kick).
Each has five levels, costing **25, 50, 100, 200, 400 coins** in order.
Each Hand Power level adds **2 damage** (10 → 20 at maximum); each Leg Power
level adds **5 damage** (25 → 50). Reach, cooldowns, and point rewards stay the
same. Purchases work anywhere while alive, use server-owned balances and levels,
and reject stale duplicate requests. Upgrade levels persist with your profile.

Use the **MEDALS** button to open a scrollable collection panel:

- **Dedicated Student:** reach 20 Karate Points.
- **Creature Collector:** place 3 creatures (duplicates count).
- **Legendary Friend:** place a Sun Lion.
- **Black Belt:** reach 100 Karate Points.

Medals are calculated on the server from saved points and placed creatures, so
returning players receive credit for existing progress. Carrying a creature does
not count as placing it. These are in-game achievements, not Roblox platform
badges, and they do not grant extra currency. No separate medal save is needed.

Creature models use native Roblox parts. The reference poster sets the visual
direction; cinematic artwork, additional worlds and championships are
not implemented.

## Belts and challenges

| Belt | Karate Points |
|---|---:|
| White | 0 |
| Yellow | 20 |
| Green | 50 |
| Brown | 75 |
| Black | 100 |

The training dummy has **100 HP**, pays **2 points** to its final hitter, and
resets after 4 seconds. It does not drop creatures.

At Yellow Belt, pass the gold gate and take the rear doorway to Sensei's balance
trial. Complete the seven stages in order to earn **5 points and 10 coins**. Falls
and character respawns return to the last safe checkpoint. Finish returns you to
the dojo; another rewarded run unlocks after 60 seconds. Use the start platform's
**Return to dojo** prompt to leave early. Checkpoints and replay cooldown are
session-only.

## Run and build

Requirements: Roblox Studio, Rojo CLI, and the Rojo Studio plugin for live sync.
`rokit.toml` pins Rojo 7.7.0 for Rokit users. No gameplay packages are required.

```bash
rojo build -o karate-smash-phase4.rbxl
rojo serve
```

Open the built file in Studio and press **Play**, or connect the Rojo plugin to
the running server. The world is generated at runtime, so the edit viewport starts
empty. The production Rojo mappings remain in `default.project.json`.

For another development machine, clone this Git repository, install the tools,
and run the same build/serve commands. GitHub publishing is not required for local
Studio testing.

## UI and sound

The HUD displays points, belt progress, coins, income, and collection totals. Cards
adapt to portrait/short landscape viewports; attack targets remain 86 × 72 pixels.
Carrying a creature displays its rarity/name and the destination pedestal.

**Effects On/Off** beneath Punch controls the game's local strike, collection,
and belt cues. The preference survives character respawns within the session.
Bundled `rbxasset://sounds/` files require no uploads; Roblox's own avatar sounds
are separate. A fixed pool of five Sound instances bounds audio resource use.

Punch and kick use procedural limb poses compatible with Motor6D and
AnimationConstraint avatar joints. The poses extend and recover over 0.36 seconds
(punch) or 0.55 seconds (kick), including when striking air. Nearby clients play
poses only for server-accepted attacks; damage, range, and cooldowns remain on the
server. No uploaded animation assets are required.

## Saving and migration

Published games save points, coins, existing trophy counts, per-species placed
counts, the carried species, and both upgrade levels. Belts, medals, and income
are derived from those values.
Base positions are allocated again on each server. Unclaimed world drops are not
saved.

Schema **version 3** automatically migrates version-1 and version-2 saves, adding
zero-level upgrades and preserving existing creatures and carrying state. Existing points,
coins, and trophies are retained. Each old trophy still earns 1 coin per 5 seconds
and has a separate base display. Migration does not reroll or invent creatures.
The production store name remains **KarateSmash_PlayerData_v1**: the name is kept
stable even though the record schema advanced. Older builds reject
version-3 data, so do not roll back to an older build after migration.

Autosave runs every 60 seconds with departure/shutdown saves. UpdateAsync session
leases prevent concurrent or stale writers. Failed/corrupt loads disconnect the
player rather than replacing data with defaults; unknown versions/species are
preserved for investigation. Gameplay is blocked until loading succeeds and when
a session closes. An outage or crash can still lose progress since the last save.

Studio defaults to an **in-memory adapter**. Ordinary tests cannot touch production
saves, and progress disappears when the Studio server closes. To verify cloud
saving, use a dedicated published test experience, set `EnableStudioDataStore =
true` in `src/shared/PersistenceConfig.luau`, and enable Studio API access there.
Studio then uses `KarateSmash_StudioTest_v1`. Collect/place creatures, carry one,
leave, and rejoin to verify totals, carrying state, and income. Restore the flag to
false afterward. No publishing or cloud settings were changed during development.

## Authority and code map

Clients send attack names and use proximity prompts. The server chooses hit targets,
enforces shared cooldowns, rolls rarity, owns health and progression, validates
ownership/distance/line of sight, consumes carried creatures, and computes income.
No client-provided damage, reward, species roll, collection count, or belt is trusted.
Position checks use server-observed Roblox character movement; obby movement checks
are basic protection, not a complete teleport/flying anti-cheat.

- `src/shared/`: belts, combat, creatures, audio, obby, tutorial, persistence, theme.
- `src/server/Smash/`: targeting, walls, dummy, drops, bases, passive income.
- `src/server/Data/`: profile schema, migration, session locking, saves.
- `src/server/World/`: dojo, uniforms, scenery, procedural creature models.
- `src/server/Tutorial/` and `src/server/Obby/`: guided progression and trial logic.
- `src/client/` and `Presentation/`: input, HUD, carrying guide, visual/audio effects.

To add a training pad in Studio, tag a Part `KarateTrainingPad` and optionally set
Number attributes `PointsReward` (default 1) and `Cooldown` (default 1). These are
server-authored map settings. `AGENTS.md` contains project rules.

## Validation

The separate `test.project.json` adds Studio-only test scripts; production builds
exclude them. The suite uses two clients, drives real attack/collection/placement
requests, checks server state, and disconnects one client for cleanup testing.

```bash
rojo build test.project.json -o /tmp/karate-smash-tests.rbxlx
```

Open the test file and start **Server and Clients** with **2 clients**. The server
prints `PHASE1_ALL_TESTS_PASSED` on success or `PHASE1_TEST_FAILED` with a traceback.
The original marker is retained for compatibility and covers the later features.
Do not move the test characters manually during a run.

With the optional [Rojo test runner](https://github.com/rojo-rbx/run-in-roblox):

```bash
run-in-roblox --place /tmp/karate-smash-tests.rbxlx --script tests/run-studio.luau
```

`tests/VALIDATION.md` records actual runs and limitations. Local tests use injected
in-memory storage for schema migration, retries, locking, and save/rejoin checks.
The September 14 recheck passed all 28 groups with two clients, including live
arm/leg movement after server-approved attacks. The earlier medal-update failure
was fixed by keeping progress listeners connected during initial parenting.
Live cloud persistence, physical mobile controls, jump difficulty, and sound
loudness require separate manual/device checks.
