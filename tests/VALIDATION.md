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
