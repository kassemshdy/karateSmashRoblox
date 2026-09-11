# Jawad Karate - Codex Instructions

## Product goal
Build a child-friendly Roblox karate training game for Jawad. The experience should reward practice, progression, exploration, and belt advancement rather than realistic violence.

## Tech stack
- Roblox Studio
- Luau
- Rojo
- GitHub

## Project rules
- Keep server-authoritative scoring and progression.
- Never trust client-supplied point rewards or belt changes.
- Prefer small modules over large scripts.
- Put shared constants/config in `src/shared`.
- Put authoritative gameplay logic in `src/server`.
- Put UI/input/visual feedback in `src/client`.
- Do not add external packages unless clearly justified.
- Keep the first version playable with keyboard/mouse and mobile touch.
- Do not remove Rojo mappings without updating `default.project.json` and README.

## Current gameplay loop
1. Spawn in the dojo.
2. Train at punch/kick stations.
3. Earn Karate Points.
4. Advance belts.
5. Reach 20 points to pass the Yellow Belt gate.

## Belt progression
- White: 0
- Yellow: 20
- Green: 50
- Brown: 75
- Black: 100

## Near-term roadmap
1. Add a real training dummy with health and hit feedback.
2. Add punch/kick input with animations.
3. Add a Sensei NPC tutorial.
4. Add a short karate obby after the Yellow Belt gate.
5. Save Karate Points and Belt with DataStoreService.
6. Add sound and visual feedback.
7. Improve mobile controls.

## Definition of done for changes
- Code runs without Luau errors in Roblox Studio.
- No client can arbitrarily grant itself Karate Points.
- Existing belt progression still works unless intentionally changed.
- README is updated when setup or workflow changes.
