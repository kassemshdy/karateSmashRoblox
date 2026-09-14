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


## Sensei tutorial

September 14, 2026, 05:17 UTC: the two-player suite passed all 16 groups (five
persistence and eleven gameplay/presentation/tutorial groups), exit code 0.
The new group checks six lesson states, returning-player credit, and Sensei
prompt initialization. Integration checks confirm a real server wall break
advances the owning player's tutorial; both clients initialize the guide panel.

The only logged script error was the intentional departure-test kick. Production
and test Rojo builds and whitespace checks pass. The final dialogue height and
expired-drop wording were adjusted after the run; these cosmetic changes were
build-checked. Native visual review of the Sensei and physical Talk-button input
remain manual checks.


## Yellow Belt obby

September 14, 2026, 05:25–05:27 UTC: the final two-player Studio run passed all
18 groups, including two new obby groups, with exit code 0. The pure rule checks
cover belt eligibility, ordered stages, minimum timing, duplicate finishes, and
replay cooldown. The live-server test traverses the seven generated stages,
rejects a White Belt start and a skipped finish, recovers from a fall at the
halfway checkpoint, checks the checkpoint respawn destination, and verifies
exactly 5 points and 10 coins on completion. Movement is driven by the test
harness; this is not a manual jump-difficulty or touch-control playtest.

The initial attempt caught a client button-bounds assertion during Studio's
viewport initialization. That check now waits up to five seconds for layout to
settle and still fails with position/viewport details if a button remains outside.

The final logs contain only the expected departure-test kick, with no unexpected
script errors or infinite-yield warnings. Production/test builds and whitespace
checks pass; production excludes all test scripts. Manual checks remain for the
course's visual layout, physical jumps, the exit prompt, and death/rejoin UX.


Expanded obby verification (September 14): reran all 18 groups successfully,
exit code 0, with a real `LoadCharacterAsync()` at the halfway checkpoint and
client activation of the Return to dojo proximity prompt. The character resumed
at its saved platform. The exit returned the player to the dojo with no extra
points or coins. The final logs contained the expected departure-test kick and
a Roblox built-in ChatScript CoreGuiChatConnections startup error on one client;
no project-script error was logged.
Manual course appearance and physical keyboard/mobile jumping remain unverified.


## Training dummy

September 14, 2026, 10:51–10:52 UTC: all 19 Studio test groups passed, exit code 0.
The new group drives the real combat remote against the dummy and checks invalid
requests, shared cooldown, damage, a single final-hit point reward, no collection
increase, automatic reset, and out-of-range rejection. Existing wall, tutorial,
obby, and persistence checks also pass after sharing server raycast targeting.

Production/test builds and whitespace checks pass, and production excludes test
scripts. No project-script error or infinite-yield warning was logged. Roblox's
built-in ChatScript reported CoreGuiChatConnections startup errors on both clients;
the departure-test kick was expected. Dummy appearance and physical touch input
remain manual checks.


## Sound feedback

September 14, 2026, 10:57–10:59 UTC: all 20 test groups passed, exit code 0.
Both clients initialize the five-instance sound pool and effects button. Tests
verify mute/unmute, muted playback suppression, cancellation of pending belt
notes, and stable pool size. Existing gameplay exercises confirmed hit/break,
collection, and belt-change event paths.

No sound-load failures, project-script errors, or infinite-yield warnings were
logged. One client logged Roblox's built-in ChatScript CoreGuiChatConnections
startup error; the departure-test kick was expected. Builds and whitespace checks
pass. Speaker/headphone listening, loudness balance, and physical mute-button
interaction remain manual checks; automated state checks do not establish sound
quality or audibility on a particular device.
