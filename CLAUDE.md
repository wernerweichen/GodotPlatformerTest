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
| `pause` | Escape, P | Start (Button 6) |
| `open_inventory` | I | Select (Button 7) |

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
│   │   ├── player/
│   │   ├── enemies/
│   │   ├── tiles/
│   │   ├── ui/
│   │   └── effects/
│   ├── tilesets/
│   ├── audio/
│   │   ├── music/
│   │   └── sfx/                      # item_pickup.wav + heal.wav needed here
│   ├── fonts/
│   └── localization/
│       ├── blood_bloom.pot
│       ├── en.po
│       └── zh.po
├── resources/
│   └── items/
│       └── health_potion.tres        # Pre-configured ItemData (CONSUMABLE, heal, value 1)
├── scenes/
│   ├── player/
│   │   ├── Player.tscn / Player.gd
│   │   └── abilities/
│   │       ├── DashAbility.tscn / DashAbility.gd
│   │       ├── GroundPoundAbility.tscn / GroundPoundAbility.gd
│   │       ├── DoubleJumpAbility.tscn / DoubleJumpAbility.gd
│   │       └── PhaseBlinkAbility.tscn / PhaseBlinkAbility.gd
│   ├── enemies/
│   │   ├── EnemyBase.gd
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
│   │   │   ├── Zone1.tscn
│   │   │   └── rooms/
│   │   ├── zone_2_gardens/
│   │   ├── zone_3_catacombs/
│   │   ├── zone_4_tower/
│   │   └── zone_5_core/
│   ├── ui/
│   │   ├── HUD.tscn / HUD.gd
│   │   ├── PickupPopup.tscn / PickupPopup.gd   # Pickup notification overlay
│   │   ├── InventoryUI.tscn / InventoryUI.gd   # In-game inventory panel (layer 15)
│   │   ├── PauseMenu.tscn / PauseMenu.gd
│   │   ├── MainMenu.tscn / MainMenu.gd
│   │   └── LoreArchive.tscn / LoreArchive.gd
│   └── shared/
│       ├── SilentAltar.tscn / SilentAltar.gd
│       ├── BloodPetalFragment.tscn
│       ├── PickupItem.tscn / PickupItem.gd      # Generic world pickup item
│       ├── Hazard.tscn
│       └── Camera.tscn / Camera.gd
├── scripts/
│   ├── autoload/
│   │   ├── GameManager.gd
│   │   ├── AudioManager.gd
│   │   └── LocalizationManager.gd
│   └── resources/
│       ├── AbilityResource.gd
│       ├── EnemyStats.gd
│       ├── ItemData.gd               # Custom Resource: Type enum + effect_id
│       └── PetalMemory.gd
└── tests/
    ├── test_runner.gd
    ├── test_player_movement.gd
    ├── test_blood_cost.gd
    ├── test_pickup_item.gd
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

**Abilities** are modular — each is a separate scene/script that Player instantiates and delegates to.

### Blood Cost Mechanic

```gdscript
@export var blood_cost_charge_frames: int = 30
@export var blood_cost_hp_fraction: float = 0.25
@export var blood_cost_min_hp: int = 1
```

- Hold `attack` → charge timer increments each physics frame
- On `attack` release after threshold: spend HP, emit spider lily projectile arc
- HP floor: `max(current_hp - cost, blood_cost_min_hp)`

### Camera (`scenes/shared/Camera.gd`)

- `Camera2D` with `position_smoothing_enabled = true`
- Look-ahead in movement direction
- Clamp to room boundaries
- `shake(intensity, duration)` via signal

### Enemy Base Class (`scenes/enemies/EnemyBase.gd`)

- Health, knockback, hit flash, death, scrap drop
- Signal: `enemy_died(scrap_amount: int)`
- **No contact damage** — only explicit attack hitboxes
- All attacks ≥8 frame wind-up

### Save System (`scripts/autoload/GameManager.gd`)

- `FileAccess` → JSON → `user://save.json`
- Save only at Silent Altars
- Saved state: zone/room, abilities, max health, scrap, petals, inventory
- On death: reload last save; scrap from run is kept

### Pickup Item System (`scenes/shared/PickupItem.gd`)

- `Area2D` — collision_layer 32, collision_mask 2 (detects player body)
- On body_entered with player: calls `GameManager.add_item(item_data)`, plays `item_pickup` SFX, `queue_free()`
- Hover animation via looping `Tween`
- `@export var item_data: ItemData` — set in Inspector

**ItemData resource** (`scripts/resources/ItemData.gd`):
```gdscript
enum Type { CONSUMABLE, KEY_ITEM, UPGRADE, SCRAP }
@export var item_type: Type = Type.CONSUMABLE
@export var item_name_key: String = ""   # tr() key
@export var item_value: int = 0
@export var effect_id: String = ""       # "heal" | ""
```
- `item_type` is an enum — shows as dropdown in Inspector
- `effect_id` drives `GameManager._apply_effect()` dispatch
- Stored in `inventory` as `{ type: int, name_key: String, value: int, effect_id: String }`

**Inventory** (`GameManager.inventory: Array[Dictionary]`):
- Persisted to save file
- `add_item(ItemData)` → appends entry + emits `item_picked_up`
- `use_item(slot_index)` → applies effect, removes entry, emits `item_used` (CONSUMABLE only)
- `_apply_effect("heal", value)` → heals player up to max_health, plays `heal` SFX

**InventoryUI** (`scenes/ui/InventoryUI.gd`):
- `CanvasLayer` layer=15 (above HUD at 10, below PauseMenu at 20)
- Toggle with `open_inventory` action (I key / Select); blocks input if tree already paused
- Pressing `pause` while inventory is open closes inventory instead of opening PauseMenu
- Lists all items: name, colour-coded type badge, Use button for CONSUMABLEs
- Rebuilds list on open and after each `item_used` signal
- Instanced as child of `HUD.tscn` — always available in-game

**Health Potion** (`resources/items/health_potion.tres`):
- Pre-configured `ItemData`: `item_type=CONSUMABLE`, `item_name_key="ITEM_HEALTH_POTION"`, `item_value=1`, `effect_id="heal"`
- Assign to a `PickupItem` node's `item_data` in Inspector to place it in the world

### Localization (`scripts/autoload/LocalizationManager.gd`)

- All display strings use `tr("KEY")` — never hardcode English text
- Language stored in save data

### HUD (`scenes/ui/HUD.gd`)

- Listens to signals from `GameManager` and `Player` — **never polls**
- `PickupPopup` and `InventoryUI` are instanced children — both self-manage their signals

### Silent Altar (`scenes/shared/SilentAltar.gd`)

- Interactable when player is in area and presses `interact`
- Saves game via `GameManager.save_game()`
- Emits `altar_activated` signal

---

## Art Rules

- All sprites: pixel art — import filter **Nearest**
- Base resolution: **320×180** — integer scaling only
- Palette: ≤24 colours per zone

---

## Audio Rules

- SFX: `.wav`, mono, 44.1 kHz
- Music: `.ogg`, looping
- **All audio via `AudioManager` autoload only**
- API: `AudioManager.play_sfx("key")`, `AudioManager.play_music("key")`
- Required SFX keys (drop matching `.wav` into `assets/audio/sfx/`):
  - `item_pickup` — played when any PickupItem is collected
  - `heal` — played when a health potion is used

---

## Testing Rules

- **GUT** is installed at `addons/gut/`
- Test filenames: `tests/test_<system>.gd`
- Run: `godot --headless -s addons/gut/gut_cmdln.gd -gdir=res://tests/`
- All tests must pass before a feature is marked done

---

## GitHub Pages Deployment

```bash
godot --headless --export-release "HTML5" ./web/index.html
git subtree push --prefix web origin gh-pages
```

Enable **Cross-Origin Isolation** in the HTML5 export preset.

---

## Coding Conventions

```gdscript
@export var jump_velocity: float = -380.0

signal health_changed(new_health: int)

enum State { IDLE, RUN, JUMP, FALL, WALL_SLIDE, DASH, BLOOD_COST, HURT, DEAD }
var state: State = State.IDLE

label.text = tr("HUD_PETALS_LABEL")

velocity.y = jump_velocity       # Good
velocity.y = -380.0              # Bad

@onready var hud: HUD = $HUD     # Good
get_node("../../UI/HUD")         # Bad
```

- `snake_case` variables/functions; `PascalCase` classes/nodes
- No magic number literals — always use `@export` vars
- No `get_node("../../")` — use `@onready` or signals

---

## Completed Systems Checklist

### Vertical Slice (current milestone)

- [x] `project.godot` — name, resolution (320×180), integer scaling, autoloads, input map
- [x] Full folder structure created
- [ ] GUT installed and configured (`addons/gut/`) — install via Godot AssetLib
- [x] Localization skeleton — `.pot`, `en.po`, `zh.po`; `LocalizationManager` autoload
- [x] `AudioManager` autoload stub
- [x] `GameManager` autoload — state, save/load, ending branch check
- [x] Placeholder sprite generator utility
- [x] **Player controller** — movement, jump, coyote time, jump buffer, wall slide/jump
- [x] **Greatsword slash** — 3-hit chain with combo window
- [x] **Blood Cost mechanic** — charge, HP drain floor at 1, projectile arc
- [x] **Camera** — lerp follow, look-ahead, room clamping, screen shake
- [x] **EnemyBase** class — health, knockback, hit flash, death, scrap drop
- [x] **InfectedGuard** enemy — patrol, wind-up (16f), attack, cooldown
- [x] **Sentinel-Prime** boss — patrol/wind-up/attack/charge, Phase 2 Blood Cost shield, grants Dash
- [x] **Zone 1 room** — `zone1_start.tscn` with platforms, entities, camera wired
- [x] **Silent Altar** — save/load, respawn position, prompt label
- [x] **Blood Petal Fragment** — `petal_01` placed in Zone 1, hover animation
- [x] **Pickup item system** — `ItemData` resource with `Type` enum + `effect_id`; `PickupItem` world scene; `PickupPopup` HUD overlay; inventory in `GameManager`; `InventoryUI` panel (I to open); health potion item
- [x] **HUD** — spider lily hearts, petal counter, zone label, ability icon
- [x] **Main Menu** — Play transitions to Zone 1
- [x] **Pause Menu** — pause/resume, Lore Archive panel, Quit to Menu
- [ ] **GUT test suite** — stubs exist; install GUT via AssetLib to activate
- [ ] **HTML5 export** — enable Cross-Origin Isolation in export preset
- [ ] **GitHub Pages deploy** — `gh-pages` branch

### Post-Vertical-Slice

- [ ] Dash ability
- [ ] Ground Pound ability
- [ ] Double Jump ability
- [ ] Phase Blink ability
- [ ] All 5 zones (rooms, TileMaps, transitions)
- [ ] All 5 bosses (full fight logic)
- [ ] All 24 petal fragments + Elena memory lore
- [ ] Bad ending sequence
- [ ] True ending sequence
- [ ] Lore Archive (pause menu readable memories)
- [ ] Full SFX implementation
- [ ] Full music implementation + Elena's leitmotif
- [ ] Production art via ComfyUI/SD pipeline
- [ ] Accessibility: screen shake toggle, control remapping UI, subtitles
- [ ] Traditional Chinese localization complete
- [ ] itch.io build + page

---

## Current Task

**Vertical Slice is feature-complete in code.**

Remaining steps require the Godot 4.4 editor:

1. **Open project** in Godot 4.4 — editor will import assets and regenerate UIDs
2. **Install GUT** via AssetLib tab (search "GUT")
3. **Add EnemyStats resource** to InfectedGuard and SentinelPrime in Inspector
4. **Place a PickupItem** in Zone 1 — instance `PickupItem.tscn`, set `item_data` to `resources/items/health_potion.tres` in Inspector
5. **Add SFX files:** `assets/audio/sfx/item_pickup.wav` and `assets/audio/sfx/heal.wav`
6. **HTML5 export preset** — enable Cross-Origin Isolation
7. **GitHub Pages** — push `web/` output to `gh-pages` branch

Next code milestone: **DashAbility component** (`scenes/player/abilities/DashAbility.gd` + `.tscn`).

---

## Known Issues

*(none)*

---

## Known Constraints & Gotchas

- `TileMapLayer` replaced `TileMap` in Godot 4.3 — never use the old `TileMap` node
- `move_and_slide()` in Godot 4 does NOT accept velocity as an argument
- HTML5 export requires **Cross-Origin Isolation** in export settings
- GDScript is dynamically typed by default — always add type hints on exports and signatures
- GUT must live in `addons/gut/` — do NOT vendor inside `scripts/`
- `AudioManager.play_sfx()` is the only legal way to trigger sound — no exceptions
- `InventoryUI` sets `get_tree().paused = true` when open — it guards against opening when already paused (PauseMenu open), but do not add a third system that also sets `paused`
- `ItemData.item_type` is now a `Type` enum (int), not a String — stored as int in save JSON; compare with `ItemData.Type.*` constants
- `heal` SFX required at `assets/audio/sfx/heal.wav` for health potion to play audio
- `InventoryUI` and `PickupPopup` are both children of `HUD.tscn` and self-connect to `GameManager` signals in their own `_ready()` — `HUD.gd` does not need to reference them
