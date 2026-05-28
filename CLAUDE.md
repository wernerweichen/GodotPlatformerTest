# CLAUDE.md — The Blood Bloom / 鮮血花期

This is the session handoff document. Read it fully before making any changes. It is the single source of truth for tech decisions, conventions, and current state.

---

## Project Overview

**The Blood Bloom (鮮血花期)** is a pixel art gothic Metroidvania built in **Godot 4.4** using **GDScript**.
Full design spec: see `GDD.md`.

Player character **Gale**, a dead royal guard resurrected by alien spider lily spores, fights through a kingdom consumed by alien flora. Core mechanic: she burns her own HP (Blood Cost) to deal massive damage — power and self-destruction are the same thing.

**Repo:** `wernerweichen/GodotPlatformerTest`
**Live build:** `https://wernerweichen.github.io/GodotPlatformerTest/`

---

## Engine & Language Rules

- **Engine:** Godot 4.4 only. Do NOT use Godot 3 APIs or deprecated Godot 4.0–4.2 APIs.
- **Language:** GDScript for all game logic. Prefer readable over clever.
- **Nodes:** One responsibility per scene/node.
- **Signals:** Prefer signals over direct node references for loose coupling.
- **Exports:** All tunable values (speed, jump height, damage, timings, etc.) must be `@export` vars — editable in the Inspector without touching code.
- **Autoloads:** Only `GameManager`, `AudioManager`, and `LocalizationManager`. No others without explicit approval.
- **TileMapLayer** — use this, NOT the deprecated `TileMap` node.
- `move_and_slide()` does NOT take velocity as a parameter in Godot 4 — set `self.velocity` directly.
- Type hints are mandatory on all `@export` vars and function signatures.

---

## Tech Stack

| Layer | Choice |
|---|---|
| Engine | Godot 4.4 |
| Language | GDScript |
| Unit testing | GUT (Godot Unit Testing) — installed as `addons/gut/` |
| Localization | Godot built-in i18n — `.po`/`.pot` files in `assets/localization/` |
| Web export | HTML5 via Godot export presets |
| Web hosting | GitHub Pages — `gh-pages` branch |
| Art (placeholder) | Programmatically generated using Godot `Image` API in GDScript |
| Art (production) | ComfyUI / local Stable Diffusion — assets drop into `assets/sprites/` |
| Audio | SFX: `.wav` mono 44.1 kHz · Music: `.ogg` looping |

---

## Input Map

Configure in **Project Settings → Input Map**:

| Action | Default Keys | Gamepad |
|---|---|---|
| `move_left` | A, Left Arrow | D-pad Left / Left Stick Left |
| `move_right` | D, Right Arrow | D-pad Right / Left Stick Right |
| `jump` | Space, Z | A / Cross |
| `attack` | J | X / Square |
| `dash` | Shift | B / Circle |
| `ground_pound` | S (while jumping) | Down + A |
| `interact` | E, F | Y / Triangle |
| `pause` | Escape, P | Start |

**Important:**
- `attack` tap = greatsword slash; `attack` hold = Blood Cost charge
- Mouse is reserved for future systems — do NOT bind game actions to mouse buttons
- All inputs via `Input.is_action_*()` — never hardcode key scancodes
- Controls must be fully remappable from the Options menu

---

## Project Structure

```
GodotPlatformerTest/
├── CLAUDE.md                         # This file
├── GDD.md                            # Full game design document
├── project.godot
├── addons/
│   └── gut/                          # GUT testing framework
├── assets/
│   ├── sprites/
│   │   ├── player/                   # Gale spritesheets (16×24 base)
│   │   ├── enemies/                  # 16×16 common, 32×32 large, 64×64 bosses
│   │   ├── tiles/                    # 16×16 tile PNGs, one folder per zone
│   │   ├── ui/                       # Heart icons, petal icons, ability icons
│   │   └── effects/                  # Particle textures, petal FX
│   ├── tilesets/                     # .tres TileSet resources
│   ├── audio/
│   │   ├── music/                    # .ogg zone themes + Elena's leitmotif
│   │   └── sfx/                      # .wav combat, movement, UI
│   ├── fonts/                        # .ttf pixel fonts (must include CJK range)
│   └── localization/
│       ├── blood_bloom.pot           # Translation template (auto-generated)
│       ├── en.po                     # English strings
│       └── zh.po                     # Traditional Chinese strings
├── scenes/
│   ├── player/
│   │   ├── Player.tscn
│   │   ├── Player.gd
│   │   └── abilities/
│   │       ├── DashAbility.tscn / DashAbility.gd
│   │       ├── GroundPoundAbility.tscn / GroundPoundAbility.gd
│   │       ├── DoubleJumpAbility.tscn / DoubleJumpAbility.gd
│   │       └── PhaseBlinkAbility.tscn / PhaseBlinkAbility.gd
│   ├── enemies/
│   │   ├── EnemyBase.gd              # Base class — all enemies extend this
│   │   ├── InfectedGuard.tscn / InfectedGuard.gd
│   │   ├── Patroller.tscn / Patroller.gd
│   │   └── Shooter.tscn / Shooter.gd
│   ├── bosses/
│   │   ├── SentinelPrime.tscn / SentinelPrime.gd
│   │   ├── ForgeWarden.tscn / ForgeWarden.gd
│   │   ├── RyanBloomedPrince.tscn / RyanBloomedPrince.gd
│   │   ├── OswaldMagister.tscn / OswaldMagister.gd
│   │   └── MotherOrganism.tscn / MotherOrganism.gd
│   ├── zones/
│   │   ├── zone_1_barracks/
│   │   │   ├── Zone1.tscn            # Zone root; rooms are children
│   │   │   └── rooms/               # Individual room .tscn files
│   │   ├── zone_2_gardens/
│   │   ├── zone_3_catacombs/
│   │   ├── zone_4_tower/
│   │   └── zone_5_core/
│   ├── ui/
│   │   ├── HUD.tscn / HUD.gd
│   │   ├── PauseMenu.tscn / PauseMenu.gd
│   │   ├── MainMenu.tscn / MainMenu.gd
│   │   └── LoreArchive.tscn / LoreArchive.gd
│   └── shared/
│       ├── SilentAltar.tscn / SilentAltar.gd   # Save point / respawn
│       ├── BloodPetalFragment.tscn              # Collectible lore item
│       ├── Hazard.tscn
│       └── Camera.tscn / Camera.gd
├── scripts/
│   ├── autoload/
│   │   ├── GameManager.gd            # Global state, save/load, ending branch logic
│   │   ├── AudioManager.gd           # play_sfx() / play_music() only interface
│   │   └── LocalizationManager.gd   # tr() wrapper + language switching
│   └── resources/
│       ├── AbilityResource.gd        # Custom Resource for ability data
│       ├── EnemyStats.gd             # Custom Resource for enemy stat sheets
│       └── PetalMemory.gd            # Custom Resource for lore fragments
└── tests/
    ├── test_runner.gd                # GUT test suite entry point
    ├── test_player_movement.gd
    ├── test_blood_cost.gd
    ├── test_save_system.gd
    └── test_localization.gd
```

---

## Core Systems — Implementation Notes

### Player Controller (`scenes/player/Player.gd`)

```gdscript
enum State { IDLE, RUN, JUMP, FALL, WALL_SLIDE, DASH, BLOOD_COST, HURT, DEAD }
```

- `CharacterBody2D` — NOT `RigidBody2D`
- `_physics_process(delta)` at 60 Hz
- Gravity applied manually every frame
- `move_and_slide()` for movement

**Required features:**
- Variable jump height: hold `jump` = higher; tap = short hop via velocity cutoff
- **Coyote time:** 6-frame buffer after walking off a ledge
- **Jump buffer:** 8-frame buffer — if `jump` pressed before landing, execute on land
- Wall slide: reduce fall speed when pressing into a wall
- Wall jump: impulse away from wall on `jump`
- Greatsword slash (tap `attack`): wide arc, 3-hit chain; slower than typical platformer
- **Blood Cost** (hold `attack`): see section below
- All values are `@export` floats

**Abilities** are modular — each is a separate scene/script that Player instantiates and delegates to. Zero ability logic inline in `Player.gd`.

### Blood Cost Mechanic

```gdscript
@export var blood_cost_charge_frames: int = 30
@export var blood_cost_hp_fraction: float = 0.25  # fraction of max HP spent
@export var blood_cost_min_hp: int = 1            # cannot kill Gale
```

- Hold `attack` → charge timer increments each physics frame
- At threshold: visual feedback (crimson glow, vine extension, screen pulse)
- On `attack` release after threshold: spend HP, emit spider lily projectile arc
- HP floor: `max(current_hp - cost, blood_cost_min_hp)`
- Damage output scales with actual charge duration
- Required mechanic to break certain enemy shields and stagger bosses

### Camera (`scenes/shared/Camera.gd`)

- `Camera2D` with `position_smoothing_enabled = true`
- Look-ahead: offset in movement direction (`look_ahead_distance` export)
- Clamp to room boundaries via `limit_left`, `limit_right`, `limit_top`, `limit_bottom`
- `shake(intensity: float, duration: float)` method — called via signal, never directly
- Boss fights: camera zooms out to show full arena (lerped transition)

### Enemy Base Class (`scenes/enemies/EnemyBase.gd`)

All enemies extend this. It handles:
- Health, taking damage, death (drop scrap, play death anim, `queue_free`)
- Knockback
- Hit flash (brief `modulate` colour change)
- Signal: `enemy_died(scrap_amount: int)`

**Rules:**
- **No contact damage** — enemies deal damage only through explicit attack hitboxes
- All attacks have a ≥8 frame wind-up animation before hitbox activates

### Save System (`scripts/autoload/GameManager.gd`)

- `FileAccess` → JSON → `user://save.json`
- Save only at Silent Altars — never mid-room
- Saved state: current zone/room ID, unlocked abilities (Array), max health, scrap total, petals collected (Array of IDs)
- On death: reload last save; scrap from current run is kept (by design)
- Ending branch check: `petals_collected.size() >= 24` → True Ending; else Bad Ending

### Localization (`scripts/autoload/LocalizationManager.gd`)

- All display strings use `tr("KEY")` — never hardcode English text in scene labels
- `.pot` template auto-generated by Godot's localization tools
- Language stored in save data (default: system locale → English fallback)
- Switchable from Options menu at runtime without restart
- CJK (Chinese) font loaded separately to avoid bloating builds that don't need it

### HUD (`scenes/ui/HUD.gd`)

- Listens to signals from `GameManager` and `Player` — **never polls**
- Health: instantiate spider lily heart icons from `PackedScene`
- Petal counter: `tr("HUD_PETALS")` label + N/24 count; animates on pickup
- Ability icon: swaps texture on ability change; dims on cooldown

### Silent Altar (`scenes/shared/SilentAltar.gd`)

- Interactable when player is in area and presses `interact`
- Saves game via `GameManager.save_game()`
- Restores full HP
- Emits `altar_activated` signal (HUD animates, AudioManager plays chime)
- Sets `GameManager.respawn_position` and `respawn_zone`

---

## Art Rules

- All sprites: pixel art — import filter set to **Nearest** (never Linear or Lanczos)
- Base resolution: **320×180** — `canvas_items` stretch mode, integer scaling only
- Placeholder sprites generated via `Image` API — colored rectangles in zone palette, with `Label` overlay
- All placeholder references in scenes tagged with `# PLACEHOLDER` comment
- **ComfyUI/SD pipeline:** Drop production `.png` into `assets/sprites/<subfolder>/` — scenes reference fixed paths, no code change required
- Palette: ≤24 colours per zone (see GDD §9 for per-zone palette specs)
- Gale's palette (red/white/silver) must be readable in every zone

---

## Audio Rules

- SFX: `.wav`, mono, 44.1 kHz
- Music: `.ogg`, looping
- **All audio via `AudioManager` autoload only** — never call `.play()` on an `AudioStreamPlayer` from game logic
- API: `AudioManager.play_sfx("attack")`, `AudioManager.play_music("zone_1")`
- Keys are lowercase snake_case strings matching filenames without extension

---

## Testing Rules

- **GUT** is installed at `addons/gut/`
- **After every new system or feature:** write or update the matching test file in `tests/`
- Test filenames: `tests/test_<system>.gd`
- Run tests headlessly: `godot --headless -s addons/gut/gut_cmdln.gd -gdir=res://tests/`
- All tests must pass (zero failures) before a feature is marked done
- Tests cover: input → state transitions, physics edge cases, save/load round-trips, `tr()` key existence

---

## GitHub Pages Deployment

HTML5 export is configured in Godot's export presets as **"HTML5"**.

```bash
# 1. Export HTML5 build (run from project root)
godot --headless --export-release "HTML5" ./web/index.html

# 2. Deploy to gh-pages branch
git subtree push --prefix web origin gh-pages
```

Live URL: `https://wernerweichen.github.io/GodotPlatformerTest/`

**Note:** Enable **Cross-Origin Isolation** in Godot's HTML5 export settings — required for threads in Godot 4.4 web builds.

---

## Coding Conventions

```gdscript
# Exported, typed — all tunable values
@export var jump_velocity: float = -380.0
@export var blood_cost_hp_fraction: float = 0.25

# Signals — past-tense verbs, typed parameters
signal health_changed(new_health: int)
signal petal_collected(total_collected: int)
signal enemy_died(scrap_dropped: int)

# State enum at top of file
enum State { IDLE, RUN, JUMP, FALL, WALL_SLIDE, DASH, BLOOD_COST, HURT, DEAD }
var state: State = State.IDLE

# Localization — always tr(), never hardcoded strings
label.text = tr("HUD_PETALS_LABEL")

# No magic numbers
velocity.y = jump_velocity       # Good
velocity.y = -380.0              # Bad — use the exported var

# No path hacks
@onready var hud: HUD = $HUD     # Good
get_node("../../UI/HUD")         # Bad
```

- `snake_case` for variables and functions
- `PascalCase` for classes and node names
- Every public method gets a one-line doc comment
- No `get_node("../../")` path strings — use `@onready` or signals
- No magic number literals inline — always use `@export` vars

---

## Completed Systems Checklist

### Vertical Slice (current milestone)

- [x] `project.godot` — name, resolution (320×180), integer scaling, autoloads, input map
- [x] Full folder structure created
- [ ] GUT installed and configured (`addons/gut/`) — install via Godot AssetLib
- [x] Localization skeleton — `.pot`, `en.po`, `zh.po`; `LocalizationManager` autoload
- [x] `AudioManager` autoload stub
- [x] `GameManager` autoload — state, save/load, ending branch check
- [x] Placeholder sprite generator utility (`scripts/utils/PlaceholderSpriteGenerator.gd`)
- [ ] **Player controller** — movement, jump, coyote time, jump buffer, wall slide/jump
- [ ] **Greatsword slash** — 3-hit chain
- [ ] **Blood Cost mechanic** — charge, HP drain, projectile arc
- [ ] **Camera** — lerp follow, look-ahead, room clamping, screen shake
- [ ] **EnemyBase** class
- [ ] **InfectedGuard** enemy (Zone 1 common)
- [ ] **Sentinel-Prime** boss (teaches Blood Cost; grants Dash)
- [ ] **Zone 1 tilemap** — TileMapLayer room structure
- [ ] **Silent Altar** — save/load, respawn point
- [ ] **Blood Petal Fragment** — one collectible placed in Zone 1
- [ ] **HUD** — health hearts, petal counter, ability icon
- [ ] **Main Menu**
- [ ] **Pause Menu**
- [ ] **GUT test suite** — movement, blood cost, save system, localization
- [ ] **HTML5 export** — Cross-Origin Isolation enabled
- [ ] **GitHub Pages deploy** — `gh-pages` branch live

### Post-Vertical-Slice

- [ ] Dash ability
- [ ] Ground Pound ability
- [ ] Double Jump ability
- [ ] Phase Blink ability
- [ ] All 5 zones (rooms, TileMaps, transitions)
- [ ] All 5 bosses (full fight logic)
- [ ] All 24 petal fragments + Elena memory lore
- [ ] Bad ending sequence
- [ ] True ending sequence (cooperative final sequence)
- [ ] Lore Archive (pause menu readable memories)
- [ ] Full SFX implementation
- [ ] Full music implementation + Elena's leitmotif
- [ ] Production art via ComfyUI/SD pipeline
- [ ] Accessibility: screen shake toggle, control remapping UI, subtitles
- [ ] Traditional Chinese localization complete
- [ ] itch.io build + page

---

## Current Task

**Step 2 — Player Controller**

Scaffolding is complete. Build next:
1. `scenes/player/Player.tscn` — `CharacterBody2D` with `CollisionShape2D` and `Sprite2D` (placeholder from `PlaceholderSpriteGenerator`)
2. `scenes/player/Player.gd` — full state machine, movement, coyote time, jump buffer, wall slide/jump, greatsword slash, Blood Cost
3. Wire `GameManager.take_damage()` to player hurt state
4. Add `scenes/shared/Camera.tscn` with lerp follow + look-ahead
5. Create a minimal test room to validate movement feel

**One-time setup required:**
- Install GUT via the Godot editor's **AssetLib** tab (search "GUT") so test files compile

---

## Known Issues

*(none yet — project not started)*

---

## Known Constraints & Gotchas

- `TileMapLayer` replaced `TileMap` in Godot 4.3 — never use the old `TileMap` node
- `move_and_slide()` in Godot 4 does NOT accept velocity as an argument — set `self.velocity` before calling
- HTML5 export in Godot 4.4 requires **Cross-Origin Isolation** enabled in export settings for thread support
- Web export requires an HTTP server with correct CORS / `SharedArrayBuffer` headers — test early
- Integer scaling can cause black bars on non-standard resolutions — test on multiple window sizes
- GDScript is dynamically typed by default — always add type hints on exports and function signatures
- CJK (Chinese) text requires a font that includes the full Unicode CJK range — load it separately to avoid inflating the English build's download size
- Blood Cost HP drain must be floored at 1 — enforce this in code, not just design intent
- GUT must live in `addons/gut/` — do NOT vendor it inside `scripts/`
- `AudioManager.play_sfx()` is the only legal way to trigger sound from game logic — no exceptions
