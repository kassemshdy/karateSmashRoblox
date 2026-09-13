# Jawad Karate 🥋

Starter Roblox game project using **Rojo + Luau**.

## Included

- Karate Points leaderboard
- Belt progression: White → Yellow → Green → Brown → Black
- Reusable training-pad system using Roblox tags
- Basic on-screen HUD
- Automatically generated starter dojo
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

1. Face one of the three orange Smash Walls. **Click or F** punches (10 damage,
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
owned drops are removed when their owner leaves. Coins, trophies, points, and
belts reset when leaving: DataStore saving, offline income, and coin spending are
outside this phase.

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
  leaving removes it and stops income. Rejoining starts a fresh session.
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

### Validation status (September 11, 2026)

- The single-player Studio session passed real-remote tests for invalid request
  rejection, a 50-request spam burst, punch/kick damage, and a single break reward.
- The same session passed wall respawn, real prompt collection, base trophy updates,
  and passive coin income. The game scripts produced no errors in that session.
- Subsequent fixes add reliable dojo spawning, shared-walkway retention, training-pad
  proximity checks, gate side walls, and a clearer HUD. Final Rojo builds and
  whitespace checks pass; their final Studio regression run is still pending.
- The two-player suite and mobile Device Emulator checks are prepared but not yet
  verified. Native Studio control timed out, and automatic approval review blocked
  running the downloaded test runner at Studio plugin-level security.
