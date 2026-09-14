# Phase 1 validation

September 13, 2026 — Roblox Studio 0.738.0.7381393, Rojo 7.7.0.

Executed `tests/run-studio.luau` against the `test.project.json` build with
`run-in-roblox` 0.3.0. Roblox Studio launched one server and two simulated clients.
The command exited with code 0 after about 75 seconds.

Server output:

```text
PHASE1_PASS: two players spawn in dojo with separate bases and zero stats
PHASE1_PASS: remote validation, punch/kick damage, spam cooldown, multiplayer final-hit reward
PHASE1_PASS: owner-only prompt collection updates only the owner's base
PHASE1_PASS: distance/obstruction collection checks and isolated passive income
PHASE1_PASS: wall respawn and attack range, facing, and obstruction checks
PHASE1_PASS: all belt thresholds and boundary values
PHASE1_PASS: dead attack rejected; respawn retains base and trophies
PHASE1_PASS: uncollected drops expire
PHASE1_PASS: departure removes owned base/drops, stops income, and preserves walkways
PHASE1_ALL_TESTS_PASSED
```

The departure test intentionally kicks one simulated client. No unexpected
script errors appeared in this run. The initial runner attempt was corrected
so only the edit DataModel launches tests, and the collection test now moves
the other player out of the owner's line of sight.

Mobile-emulator visual QA remains unverified: native computer-use startup failed.
The automated suite does not exercise physical keyboard/touch presses, gate
contact, or training-pad contact; README contains those manual acceptance checks.

## Phase 2 persistence regression

September 13, 2026 — the same Studio engine and runner launched two clients
against the persistence-enabled build, with an in-memory adapter. Exit code: 0.

```text
PERSISTENCE_PASS: defaults, exclusive session, save/release/rejoin, stale write rejection
PERSISTENCE_PASS: expired lease, crash recovery, autosave renewal
PERSISTENCE_PASS: corrupt data and unsupported versions remain untouched
PERSISTENCE_PASS: transient retry and outage refusal
PERSISTENCE_PASS: lost-response retries are idempotent
PHASE1_PASS: two players spawn in dojo with separate bases and zero stats
PHASE1_PASS: remote validation, punch/kick damage, spam cooldown, multiplayer final-hit reward
PHASE1_PASS: owner-only prompt collection updates only the owner's base
PHASE1_PASS: distance/obstruction collection checks and isolated passive income
PHASE1_PASS: wall respawn and attack range, facing, and obstruction checks
PHASE1_PASS: all belt thresholds and boundary values
PHASE1_PASS: dead attack rejected; respawn retains base and trophies
PHASE1_PASS: uncollected drops expire
PHASE1_PASS: departure removes owned base/drops, stops income, and preserves walkways
PHASE1_ALL_TESTS_PASSED
```

Cloud DataStore access was not enabled or exercised. Live rejoin verification
requires a dedicated published test experience; README documents the steps.


## Phase 3 presentation regression

September 13, 2026 — production/test Rojo builds passed. The final two-player
Studio runner completed with exit code 0 and `PHASE1_ALL_TESTS_PASSED`.
All five persistence groups and ten gameplay/presentation groups passed.
The additional group reports:

```text
PHASE1_PASS: client HUD, touch-sized controls, uniforms, courtyard, and wall HP displays
```

Both clients initialize the HUD and controls, receive a karate uniform, and have
Punch/Kick buttons at least 64 pixels across within the current viewport.
The world contains courtyard scenery and wall HP displays. Existing combat,
collection, passive income, belt, respawn, expiry, and cleanup assertions pass.

Client/server logs for the final 16:45–16:47 UTC run contain no unexpected script
errors or infinite-yield warnings. The intentional departure kick is expected.
The test caught and led to fixes for presentation-module startup timing and
character events firing before the assembled avatar is parented to Workspace.

The production XML contains 29 scripts/modules and excludes all test scripts.
`git diff --check` passes. Physical mobile touch and Device Emulator visual QA
remain separate manual checks; button geometry assertions do not simulate touch.
Cloud DataStore verification remains outside this local test.


September 14 follow-up: reran the full suite after delaying uniform attachment
until the character enters Workspace, keeping wall HP bars visible, and starting
chat collapsed. All 15 groups passed; runner exit code 0. The 04:43–04:44 UTC
server/client logs contain only the expected departure-test kick.

A native Studio desktop preview confirmed the generated dojo, HUD, separate
Punch/Kick buttons, and unobscured wall HP values. The player received the
13-piece R15 uniform. Chat remains accessible through Roblox's chat button.
Device Emulator and physical mobile-touch testing remain unverified.


## Small-screen layout follow-up

September 14, 2026: progress and earnings cards now scale for short landscape
and narrow portrait viewports, and mobile retains income/trophy details. Action
buttons remain 86 × 72 pixels, with a smaller bottom offset on short screens.

The first regression attempt timed out waiting for both clients. A fresh run at
05:06–05:07 UTC passed all 15 groups with exit code 0. No unexpected client/server
script errors appeared. Production and test builds and whitespace checks pass.
These checks verify normal client startup and button bounds; they do not replace
Device Emulator or physical phone verification of the new responsive layouts.
