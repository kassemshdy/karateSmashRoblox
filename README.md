# Jawad Karate 🥋

Starter Roblox game project using **Rojo + Luau**.

## Included

- Karate Points leaderboard
- Belt progression: White → Yellow → Green → Brown → Black
- Reusable training-pad system using Roblox tags
- Basic on-screen HUD
- Automatically generated starter dojo
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

After Rojo connects, press **Play** in Roblox Studio. The starter scripts automatically generate a simple dojo with a spawn point, Punch Pad, Kick Pad, Yellow Belt gate, and Jawad Karate sign.

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
