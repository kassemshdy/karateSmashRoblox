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

## Phase 4 collectible creatures

September 14, 2026, 11:33–11:35 UTC: all 22 test groups passed in the
two-client Studio run, exit code 0. New checks cover rarity boundaries and income
rates, version 1 migration without losing existing points/coins/trophies,
saved collections and carried creatures across simulated storage rejoin,
invalid species/count rejection, and stale-session protection.

Live gameplay checks cover owner-only pickup, one-creature carrying, retention
through an actual character respawn, matching owner-only pedestals, distance and
obstruction checks, duplicate placement rejection, and species-based passive
income. Existing combat, belts, tutorial, obby, dummy, audio, drop expiry, and
departure cleanup regressions also pass.

An initial run timed out waiting for two clients. A subsequent run exposed a
test-camera issue when activating the obby exit after visiting a base; the test
now aims at the exit before activating its prompt. The final complete run passed.
No project-script errors, infinite-yield warnings, or sound-load failures were
logged. One client logged Roblox's built-in ChatScript CoreGuiChatConnections
startup error; the departure-test kick was expected.

Phase 4 creature appearance and physical keyboard/mobile interaction still need
manual playtesting. Storage tests use an injected in-memory adapter and do not
verify live cloud persistence. Prior jump-difficulty and sound-listening manual
checks also remain outstanding.


## Medals

September 14, 2026, 17:34–17:36 UTC: all 24 groups passed in the two-client
Studio suite, exit code 0. New checks cover medal threshold boundaries, multiple
unlocks, capped progress, live server updates, and isolation between players.
The prior gameplay and persistence regressions also pass. Medals are derived
from existing saved points and placed-creature counts; no save-schema change
was introduced.

Production builds include the medal modules and exclude test scripts. No project
script errors, infinite-yield warnings, or sound-load failures were logged.
One client logged Roblox's built-in ChatScript CoreGuiChatConnections startup
error, and the departure-test kick was expected. Panel appearance, scrolling,
and physical mouse/touch interaction remain manual checks; the automated suite
does not verify the new panel's layout. Live cloud persistence remains unverified.


## Training upgrades

September 14, 2026, 17:56–17:58 UTC: all 26 test groups passed in the
two-client Studio suite, exit code 0. New storage tests cover version-2 to
version-3 migration, saved upgrade rejoin, corrupt/missing/unknown upgrade levels,
and stale-session rejection. Version-1 migration remains covered by prior tests.

Live purchase tests cover insufficient funds, malformed requests, exact prices,
stale duplicate rejection, per-player isolation, maximum levels, unavailable
profiles, and upgraded punch damage against the real dummy. Kick damage and
shared-config immutability are also checked. Both clients initialize the shop.
All prior combat, creatures, medals, obby, persistence, and cleanup checks pass.

Production/test builds and whitespace checks pass. Production includes upgrades
and excludes the test modules. No project-script errors, infinite-yield warnings,
or sound-load failures were logged; the departure-test kick was expected.
Physical shop-button interaction, visual layout on phones, economy pacing, and
live cloud saving remain manual checks. Storage migration/rejoin tests use the
injected in-memory adapter.


## White player karate suit

September 14, 2026, 18:02–18:04 UTC: all 27 groups passed with two Studio
clients, exit code 0. Added R6/R15 checks for complete gi coverage, white starting
belts, removal of classic/layered clothing, idempotent appearance cleanup, and
earned belt recoloring. Existing real respawn and gameplay checks pass.

The first fixture used a Part for a WrapLayer and was corrected to MeshPart.
An intermediate run exposed avatar parenting warnings; clothing cleanup now
defers until Roblox finishes parenting the item. The final run has no such
warnings or project-script errors. The departure-test kick is expected.
Production/test builds and whitespace checks pass. Visual fitting across unusual
avatar packages and manual appearance review remain unverified.


White-gi follow-up, September 14, 18:21–18:23 UTC: the complete 27-group
suite passed again, exit code 0. Outfit tests now also assert covered avatar
meshes are hidden and a changed torso size rebuilds the garment to fit. Added a
front belt knot. No project-script errors or avatar-parenting warnings appeared;
the departure-test kick was expected. Native screen capture failed, so visual
matching to the Sensei is not claimed as verified.

The user confirmed they were testing a previously saved/published place. Local
changes do not update that place automatically. A distinctly named production
build, Karate-Smash-White-Gi.rbxl, is provided for reopening and testing in Studio.
No published place was modified.


## Combat limb animation compatibility

September 14, 2026: a focused two-client Studio run passed with exit code 0.
The client tests punch/kick Transform changes and recovery for Motor6D and
AnimationConstraint, then measures actual live arm and leg rotation relative to
the character root on both clients. Initial focused testing needed a character
spawn wait, which was added. CombatPose applies the pose at PreSimulation and
restores before PreAnimation, avoiding accumulated offsets.

Full-suite attempts stopped at the existing point-medal update check before
reaching animation tests; one runner attempt also returned no test result. The
full 28-group suite is therefore NOT recorded as passing for this change. No
medal behavior was changed. A focused test project is retained for reproduction:
`rojo build animation-test.project.json -o /tmp/karate-animation-tests.rbxlx`,
then use the existing runner and tests/run-studio.luau. Manual visual review and
physical button interaction remain unverified.


## Complete animation recheck

September 14, 2026, 18:30–18:32 UTC: all 28 groups passed in the full two-client
Studio suite, exit code 0. Live arm/leg rotation is now triggered by the real
Attack remote and server Feedback event, rather than directly calling the pose
module. Synthetic joint tests still cover Motor6D and AnimationConstraint pose
changes and restoration. White-gi, persistence, medals, and all gameplay
regressions also pass.

Diagnostic logging reproduced the medal failure: AncestryChanged fired during
initial setup while player.Parent was still Players, disconnecting its listeners.
Medal and tutorial cleanup now checks for actual departure before disconnecting.
Temporary diagnostics were removed before the passing run. This resolves the
full-suite blocker reported in the previous entry.

Production and test builds and whitespace checks pass. No project-script errors
or infinite-yield warnings were logged. One client logged the built-in ChatScript
CoreGuiChatConnections startup error; the departure-test kick was expected.
Manual visual review and physical touch/button interaction remain unverified.
Published games were not changed; reopen the rebuilt local file to test it.
