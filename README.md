# Jawad Karate 🥋

Starter Roblox game project using **Rojo + Luau**.

## Included

- Karate Points leaderboard
- Belt progression: White → Yellow → Green → Brown → Black
- Reusable training-pad system using Roblox tags
- Responsive karate HUD with belt progress, coins, and touch controls
- Automatically generated Japanese-style dojo courtyard
- Karate Smash: punch/kick, wall HP, collectible trophies, player bases, passive coins
- Yellow Belt gate at 20 points
- Codex instructions in `AGENTS.md`
- Rojo project configuration

## Requirements

- Roblox Studio
- Rojo CLI
- Rojo Roblox Studio plugin
- Git

## Run

```bash
rojo serve
```

Then open Roblox Studio, open your place, open the **Rojo** plugin, and connect to the running server.

## First run

After Rojo connects, press **Play** in Roblox Studio. Scripts generate the dojo, training pads, three Smash Walls, a Yellow Belt gate, and a personal base for each player. Players spawn in the dojo even when the existing place contains another spawn. Shared base walkways remain when players leave.

## Create additional training pads in Roblox Studio

1. Insert a `Part` into `Workspace`.
2. Name it `PunchPad` or `KickPad`.
3. Open **View → Tag Editor**.
4. Add this tag to the part:

```text
KarateTrainingPad
```

5. Optional attributes on the Part:

```text
PointsReward = 1
Cooldown = 1
```

Use Number attributes for both.

When a player touches the pad, they receive Karate Points.

## Belt progression

| Belt | Points |
|---|---:|
| White | 0 |
| Yellow | 20 |
| Green | 50 |
| Brown | 75 |
| Black | 100 |

Edit `src/shared/BeltConfig.luau` to change the progression.

## Suggested first map

```text
Spawn
  ↓
Punch Training
  ↓
Kick Training
  ↓
Yellow Belt Gate
  ↓
Karate Obby
  ↓
Sensei Challenge
```

## GitHub

After creating an empty GitHub repository:

```bash
git init
git add .
git commit -m "Initial Jawad Karate game"
git branch -M main
git remote add origin YOUR_GITHUB_REPO_URL
git push -u origin main
```

On another Mac:

```bash
git clone YOUR_GITHUB_REPO_URL
cd jawad-karate
rojo serve
```


## Using Codex

This repository includes `AGENTS.md`. Give Codex feature requests such as:

```text
Read AGENTS.md. Add a training dummy that can be punched and kicked, gives server-authoritative Karate Points, shows hit feedback, and works with the existing belt system. Keep the implementation simple and child-friendly.
```

## Karate Smash — Phase 1

Phase 1 adds a complete session-based smash-and-collect loop to the starter dojo:

1. Face one of the three brick Smash Walls. **Click or F** punches (10 damage,
   0.4 second cooldown); **Q** kicks (25 damage, 0.9 second cooldown).
   On mobile, use the **Punch** and **Kick** touch buttons. Strikes have simple
   procedural visual effects that work with R6 and R15 without uploaded animations.
2. Walls show their HP, break at zero (60 starting HP), and respawn after 8 seconds.
   The player landing the final hit earns **5 Karate Points** and owns the drop.
3. Approach the gold trophy and press **E** or tap **Collect**. Only its owner can
   collect it, within 10 studs and with line of sight. It expires after 30 seconds.
4. A personal, named base is assigned along the walkway outside the dojo's front.
   Collecting automatically adds the trophy to your base's collection; its display
   shows the total. Each trophy earns **1 Coin every 5 seconds** while connected.
5. Karate Points still advance belts at **0 / 20 / 50 / 75 / 100**. Existing training
   pads and the Yellow Belt gate remain available. Gate passage is checked per player;
   a qualified player no longer opens it for everyone. Side walls close the walking
   bypass around the gate. Coins are separate from points.

The HUD shows coins, trophies, income, and belt progress. Bases and uncollected
owned drops are removed when their owner leaves. Phase 1 originally kept progress
for one session. The current Phase 2 implementation saves points, coins, and trophy
counts in published games; see the persistence section below. Offline income and
coin spending are not implemented.

### Implementation and authority

- `src/shared/SmashConfig.luau`: combat and economy tuning.
- `src/server/KarateSmash.server.luau`: setup and validated attack requests.
- `src/server/Smash/`: walls, drops, bases, and construction helpers.
- `src/client/KarateCombat.client.luau`: keyboard/mouse/touch input and strike effects.

The client sends only `Punch` or `Kick`. The server chooses the target with a
forward raycast from the living character, enforces a shared cooldown, and owns
HP, break rewards, drop ownership/claiming, base collections, and coin ticks.
No reward, damage, target, coin amount, or belt update is accepted from clients.
These checks use the server-observed character position; full movement/teleport
anti-cheat is outside Phase 1.

### Build and playtest

`rokit.toml` pins Rojo 7.7.0 for Rokit users. With that tool installed:

```bash
rojo build -o /tmp/karate-smash.rbxlx
rojo serve
```

Connect Studio's Rojo plugin and press Play, or open the built place in Studio.
No Rojo mappings changed and no external gameplay packages are required.

Studio acceptance checks (use **Test → Start** with two players for multiplayer):

- Six punches or three kicks break a fresh wall, award exactly 5 points to the
  final hitter, and create one trophy. Attacks facing away, out of reach, behind
  an obstruction, or while dead do not damage walls.
- Rapidly alternate punch/kick; requests inside the shared cooldown do not hit.
  Invalid attack names or extra supplied reward/target arguments grant nothing.
- Both players attack the same wall; a break rewards once. Only the owner can
  collect the trophy. Repeated collection and distant prompt triggers pay nothing.
- Collect two trophies: the base displays two and income is 2 coins per 5 seconds.
  Other players' collections do not affect your income. Death retains the base;
  leaving removes it and stops income. Published-game rejoining restores saved
  progress; default Studio sessions use an in-memory store.
- Check wall respawn after 8 seconds and uncollected drop expiry after 30 seconds.
- Verify White, Yellow, Green, Brown, Black at 0, 20, 50, 75, 100 points, including
  training-pad rewards. Test the Yellow gate and mobile controls in Device Emulator.
- Watch Studio Output for script errors during play, respawn, and player departure.


### Automated two-player integration tests

The separate `test.project.json` includes the game plus Studio-only test scripts.
The normal `default.project.json` excludes those scripts and their test remote.
The suite automatically positions test players, exercises the real attack remote
and collection prompts, checks server state, and disconnects one test player to
verify cleanup. Use a disposable local Studio test session.

```bash
rojo build test.project.json -o /tmp/karate-smash-tests.rbxlx
```

Open that file in Studio and start **Server and Clients** with **2 clients**.
The server Output reports `PHASE1_PASS` per group and
`PHASE1_ALL_TESTS_PASSED` on success, or `PHASE1_TEST_FAILED` with a traceback.
The suite takes roughly one minute after both clients connect; it includes a
30-second drop-expiry check. Do not move the test characters during the run.

If you already use the optional [Rojo test runner](https://github.com/rojo-rbx/run-in-roblox),
the equivalent automated command is:

```bash
run-in-roblox --place /tmp/karate-smash-tests.rbxlx --script tests/run-studio.luau
```

This uses Roblox's [StudioTestService](https://create.roblox.com/docs/reference/engine/classes/StudioTestService)
to launch two clients and end the test. The runner is a development-only tool;
it is not required by the game or installed by this project.

### Validation status (September 13, 2026)

- The final two-player Studio integration suite passed all nine test groups:
  spawning/bases, remote validation/combat, owner-only collection, collection
  distance/obstruction and income isolation, wall respawn/attack geometry, belt
  boundaries, death/respawn, drop expiry, and departure cleanup.
- The runner completed with `PHASE1_ALL_TESTS_PASSED` and exit code 0. The test
  intentionally disconnects one client; its “Server Kick Message” is expected.
  See `tests/VALIDATION.md` for the recorded output.
- Production and test Rojo builds and whitespace checks pass. Test-only scripts
  are excluded from the production place.
- Keyboard/mouse and mobile touch bindings are implemented. Visual testing in
  the mobile Device Emulator remains unverified because the native computer-use
  connection could not start. Manual gate and training-pad acceptance checks
  above remain available for those mechanics outside the automated suite.
- Phase 2 now adds persistence as described below. Offline earnings are not included.


## Phase 2 — saved progression

Published games now save **Karate Points, coins, and trophy counts**. On rejoin,
the belt is recalculated from points, the assigned base restores its trophy display,
and passive income resumes. Base position is allocated again in the new server.
Uncollected drops and offline income are not saved.

- Autosave runs every 60 seconds, with final saves on departure and shutdown.
- `UpdateAsync` acquires a unique session lease, renewed on saves. A second server
  cannot load an active profile or overwrite a newer session's data.
- A stale lease expires after 180 seconds, allowing recovery after a server crash.
  The old server refuses writes after expiry and stops gameplay if it loses access.
- A failed/corrupt load disconnects the player without creating or saving defaults.
  Unsupported schema versions are preserved for a future migration.
- Temporary errors retry up to three times. The HUD shows loading, saved, or delayed
  save status. A prolonged outage ends the session before its lease expires.
- Gameplay rewards and passive income are blocked until data is ready and while the
  session closes. Saving uses only server-owned values; there is no save remote.

An abrupt crash or sustained service outage can still lose progress since the last
successful save. Session locking prevents stale overwrites; it does not guarantee
that every recent action has reached storage.

### Configuration and cloud verification

`src/shared/PersistenceConfig.luau` contains store names, timing, and the Studio flag.
The production store is `KarateSmash_PlayerData_v1`. Keep its name stable when
publishing updates so existing progress remains available.

Studio defaults to an **in-memory adapter**, so ordinary Play tests require no API
access and cannot touch production saves. Its contents disappear when that Studio
server ends. The HUD shows **Studio session** in this mode.

To verify actual cloud persistence in a dedicated published test experience:

1. Set `EnableStudioDataStore = true` and enable **Studio Access to API Services**
   in that test experience's security settings if testing through Studio.
2. Studio uses the separate `KarateSmash_StudioTest_v1` store. Published Roblox
   clients use the production-named store in that experience.
3. Earn points, collect trophies, and wait for a coin tick. Leave and rejoin; confirm
   all three totals, the derived belt, and the restored base/income.
4. Allow an autosave, stop the server, then rejoin and confirm restoration.
5. Restore `EnableStudioDataStore = false` for routine local tests.

No cloud settings or published experiences were changed during implementation.
Live DataStore connectivity and a real cross-server rejoin remain unverified here.

### Persistence tests

The existing two-player test build also runs `tests/PersistenceTests.luau` against
an injected in-memory storage adapter. It checks default profiles, exclusive
sessions, release/rejoin, stale writes, lease expiry/renewal, corrupt data, unknown
versions, temporary failures, and a committed write whose response was lost.
These use the same storage transforms as production without network requests.

Run the existing test command above. `PERSISTENCE_PASS` identifies five persistence
groups, followed by ten gameplay/presentation groups. `tests/VALIDATION.md`
records the results. The `PHASE1_ALL_TESTS_PASSED` marker is retained for compatibility
with the runner and now includes the persistence assertions.


## Phase 3 — visual foundation

Phase 3 starts bringing the concept image into the playable game:

- Red torii entrance, navy-and-gold roofs, garden trees, lanterns, and training mats.
- Brick-faced walls with HP bars, damage numbers, and local break debris.
- Personal pavilion bases with trophy pedestals and gold collection displays.
- White karate uniforms with belt colors that follow server-owned progression.
- Navy/red/gold HUD for points, next belt, coins, trophy income, and save status.
- Separate Punch and Kick buttons for touch, plus Click/F and Q on desktop.
- Procedural punch/kick poses and warm daytime lighting.

Build and open the current visual version:

```bash
rojo build -o karate-smash-phase3.rbxl
```

Open `karate-smash-phase3.rbxl` in Studio and press **Test / Play**. The map is
created when the game runs, so the edit viewport starts empty. Existing Rojo
serve/connect workflows still work.

The image is an art-direction reference. This version uses native Roblox parts
and procedural effects; the cinematic character art and creature models in the
poster are not game assets. Creature collecting, additional worlds, championships,
and medals belong to later feature/content phases. The existing trophy loop and
belt thresholds are retained.

Visual configuration lives in `src/shared/Theme.luau`; world construction and
uniforms live in `src/server/World/`; client UI, lighting, controls, and effects
live in `src/client/Presentation/`. Cosmetic effects do not decide damage or
rewards. The server confirms hits and sends nearby clients the visual feedback.
No external art packages or uploaded animation IDs are required.


The Phase 3 two-player Studio suite passes all **15 groups** (five persistence,
ten gameplay/presentation), including client HUD/control/uniform startup.
Production and test builds pass; the production build excludes test scripts.
See `tests/VALIDATION.md` for evidence and remaining manual-device checks.


### Small-screen layout

The HUD adapts to both width and height. Portrait screens use smaller stacked
progress/earnings cards; short landscape screens use smaller cards in opposite
corners. Income and trophy counts remain visible on mobile. Punch/Kick buttons
retain their 86 × 72 pixel touch targets and sit above the jump-control area.
The objective banner hides on small screens to leave more room for gameplay.
