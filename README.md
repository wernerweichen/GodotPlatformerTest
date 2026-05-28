# The Blood Bloom · 鮮血花期

A gothic pixel-art Metroidvania built in **Godot 4.4**.

Play the live build: **https://wernerweichen.github.io/GodotPlatformerTest/**

---

## Story

You are **Gale**, a royal guard captain resurrected by alien spider lily spores — the same organisms that slaughtered your kingdom. You fight through the infected ruins of Aeloria to find the source of the bloom, kept alive only by the very thing that killed you.

Scattered across the world are **24 Blood Petal Fragments**, memories left behind by **Elena**, a scholar who may have intended the bloom all along. Collect them all to understand the truth — and choose what to do with it.

---

## Core Mechanic: Blood Cost

Hold `attack` to charge for ~0.5 seconds, then **spend 25% of your max HP** to launch a devastating projectile arc. You cannot die from Blood Cost — it always leaves at least 1 HP — but using it recklessly makes every hit that follows more dangerous.

Power = self-destruction.

---

## Gameplay Features

- **Movement:** Run, jump (variable height), wall-slide, wall-jump, coyote time, jump buffering
- **Combat:** 3-hit greatsword chain + Blood Cost charged attack
- **Abilities unlocked via bosses:** Dash, Ground Pound, Double Jump, Phase Blink
- **World:** 5 interconnected zones (barracks → gardens → catacombs → tower → alien core)
- **Save system:** Silent Altars restore HP and set respawn point; progress is kept on death
- **Two endings** depending on how many petal fragments you collect

---

## Controls

| Action | Keyboard | Gamepad |
|---|---|---|
| Move | A / D or ← / → | D-pad / Left stick |
| Jump | Space or Z | A / Cross |
| Attack | J | X / Square |
| Dash | Shift | B / Circle |
| Ground Pound | S (in air) | Down + A |
| Interact | E or F | Y / Triangle |
| Pause | Escape or P | Start |

---

## Tech Stack

| | |
|---|---|
| Engine | Godot 4.4 |
| Language | GDScript |
| Resolution | 320×180, integer scaling |
| Testing | GUT (Godot Unit Testing) |
| Localization | Godot i18n (English + Traditional Chinese) |
| Audio | WAV (SFX) · OGG (music) |
| Web export | HTML5 (GitHub Pages) |

---

## Project Structure

```
GodotPlatformerTest/
├── scenes/
│   ├── player/          # Gale — state machine, Blood Cost, combat
│   ├── enemies/         # EnemyBase + InfectedGuard (Zone 1)
│   ├── bosses/          # SentinelPrime (Zone 1) + boss templates
│   ├── zones/           # Zone rooms (zone1_start is the playable demo)
│   ├── ui/              # MainMenu, HUD, PauseMenu
│   └── shared/          # Camera, SilentAltar, BloodPetalFragment, projectiles
├── scripts/
│   ├── autoload/        # GameManager, AudioManager, LocalizationManager
│   ├── resources/       # AbilityResource, EnemyStats, PetalMemory
│   └── utils/           # PlaceholderSpriteGenerator (runtime art until assets exist)
├── assets/
│   ├── sprites/         # player · enemies · tiles · ui · effects
│   ├── audio/           # music · sfx (stubs — not yet recorded)
│   ├── fonts/           # pixel fonts with CJK support (not yet added)
│   └── localization/    # blood_bloom.pot · en.po · zh.po
├── tests/               # GUT test stubs
├── GDD.md               # Full game design document
└── CLAUDE.md            # Technical conventions and architecture notes
```

---

## Running Locally

1. Install **Godot 4.4** from [godotengine.org](https://godotengine.org).
2. Clone this repository.
3. Open the project in Godot (`project.godot`).
4. Press **F5** (or the Run button) to start from the main scene.

> Audio and pixel-font assets are not yet in the repository. The placeholder sprite generator creates colored rectangles at runtime so all systems work without final art.

### Running tests

Install the **GUT** plugin via Godot's AssetLib, then open `tests/test_runner.gd` in the GUT panel and run all tests.

---

## Development Status

### Vertical slice — complete in code

- [x] Player controller (all movement + Blood Cost)
- [x] SentinelPrime boss with phase system
- [x] InfectedGuard enemy
- [x] Save / load + respawn at last altar
- [x] HUD with heart icons and petal counter
- [x] Main Menu + Pause Menu with Lore Archive stub
- [x] Silent Altar save points
- [x] Localization skeleton (EN + ZH)
- [x] Audio manager API
- [x] Zone 1 demo room

### Remaining

- [ ] Install GUT plugin and wire resources in Inspector
- [ ] HTML5 export preset (Cross-Origin Isolation headers for GitHub Pages)
- [ ] 4 remaining ability scenes (Dash, Ground Pound, Double Jump, Phase Blink)
- [ ] All 5 zones and their rooms
- [ ] 4 remaining bosses
- [ ] 24 petal fragments with Elena's memory text
- [ ] Both ending sequences
- [ ] Production art (ComfyUI / Stable Diffusion pipeline)
- [ ] SFX and music
- [ ] Full Traditional Chinese localization

---

## License

This project is unlicensed — all rights reserved.
