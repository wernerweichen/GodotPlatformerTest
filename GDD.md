# Game Design Document
## Project: *The Blood Bloom — 鮮血花期*

**Genre:** Gothic Tragedy · Dark Fantasy · Metroidvania / Action Platformer
**Engine:** Godot 4.4
**Target Platforms:** Windows, macOS, Linux, Web (HTML5 via GitHub Pages)
**Base Resolution:** 320×180 (integer scaling)
**Development Language:** GDScript

---

## 1. Vision Statement

*The Blood Bloom* is a pixel art Metroidvania set in a kingdom of cold iron and shattered honour, consumed by the invasion of an alien flora that blooms from the bodies of the dead. The player controls **Gale**, a royal guard captain who died protecting her princess — and was resurrected by the same parasitic spores she was killed by. She fights on pure obsession, her wound kept open by spider lilies that have taken root in her chest.

Think *Hollow Knight*'s melancholy exploration meets *Bloodborne*'s body-horror aesthetic — precise, punishing movement, a world that reveals its tragedy through environmental storytelling, and a narrative where the "right" ending requires the player to truly understand the world rather than blindly charge forward.

**Tone:** Dark, oppressive, romantically despairing. Gothic tragedy. The contrast of pale cold steel and violent crimson blossoms is the visual and emotional spine of the entire game.

---

## 2. Core Pillars

| Pillar | Description |
|---|---|
| **Feel** | Movement must feel weighty and deliberate. Every slash, dash, and landing has impact. Gale is undead — she moves with purpose, not lightness. |
| **Discovery** | The world hides the truth. Black rose petal fragments, lore shards, and environmental clues reveal the princess's real plan. Rushing yields only tragedy. |
| **Obsession** | Gale's core mechanic mirrors her character: she burns her own life force (HP) to deal greater damage. Power and self-destruction are the same thing. |
| **Readability** | Despite the dark, dense aesthetic, enemy attacks are always telegraphed. The horror is narrative, not cheap. |

---

## 3. World Setting

### The Flowerless World
The game begins in a world that has never known plant life. The Starlight Kingdom is built entirely from steel, stone, cold weapons, and arcane energy. Society worships honour, hierarchy, and order. There is no word for "flower" in the common tongue.

### The Flora Invasion
An alien life-form called **The Flora (蘺)** descended from beyond the sky. Beautiful, soft, and lethally hallucinogenic — every bloom represents a human life fully parasitised and drained. The spores drift like snow. The scent is intoxicating and fatal.

### The Conspiracy
The aging King of the Starlight Kingdom and his Grand Magister **Oswald** have classified the invasion not as catastrophe but as "divine evolution." They are secretly cultivating the Flora, weaponising the spore plague to conquer neighbouring kingdoms without a single sword drawn. The kingdom's gardens are now fields of the dead.

### The World Today
By the time Gale awakens in the catacombs, the castle and its surrounding lands are half-consumed. Cold stone corridors bloom with alien flowers. Infected guards patrol in silence, faces obscured by blooms growing from their helmets. The world is dying beautifully.

---

## 4. Player Character

**Name:** Gale (蓋爾)
**Role:** Captain of the Royal Guard; the Princess's personal shield
**Sprite size:** 16×24 px (taller to accommodate the flowing cloak of vines)

### Visual Design
- Long silver-white hair in a French twist updo; pale skin; deep, cold eyes with a faint crimson glow at the pupils (the spider lily ember)
- **Armour:** White plate armour, shattered — a massive fatal wound in the chest, now permanently bloomed with **spider lilies (彼岸花 / Lycoris radiata)** and thorned vines that form a tattered blood-red wing-like cloak
- **Weapon:** Two-handed greatsword **【Underworld Guide / 冥途之引】** — the blade wrapped in crimson root tendrils; attacks scatter blood-red petals and crimson sword-qi

### Resurrection Lore
Gale was killed interrupting the conspiracy. Her overwhelming, obsessive will to protect the Princess resonated with the alien spores. She woke in the catacombs with partial amnesia — she knows only that she must find Elena. The spider lilies blooming in her chest wound are her heartbeat now.

### Core Moveset (from the start)

| Move | Input | Notes |
|---|---|---|
| Run | `move_left` / `move_right` | Acceleration/deceleration curve; weighted feel |
| Jump | `jump` | Variable height — hold = higher, tap = short hop |
| Coyote time | (auto) | 6-frame grace period after walking off a ledge |
| Jump buffer | (auto) | 8-frame input buffer before landing |
| Wall slide | `move_left`/`move_right` into wall | Slow fall on walls |
| Wall jump | `jump` while wall sliding | Impulse away from wall |
| Greatsword slash | `attack` (tap) | Wide arc, 3-hit chain; slower but high reach |
| **Blood Cost** | `attack` (hold) | See §4.1 below |

### 4.1 The Blood Cost Mechanic

Gale sacrifices HP to unleash empowered attacks. This is her core identity mechanic.

**How it works:**
- Hold `attack` (J key by default) for `blood_cost_charge_frames`
- Visual feedback: crimson glow builds, vines extend from wound
- On release: deduct a fraction of max HP (cannot kill Gale — floors at 1 HP)
- Emit a bloom of spider lily projectiles in a wide arc; damage scales with charge duration
- Screen shakes briefly; petal particle burst plays

**Strategic role:**
- The only way to break certain enemy shields
- Required to stagger bosses out of invincible phases
- Forces the player to manage aggression vs. self-preservation
- Ties narrative obsession to gameplay: power costs Gale herself

### Acquired Abilities (unlocked through gameplay)

| Ability | Source | Flower | Description |
|---|---|---|---|
| **Dash** | Sentinel-Prime (Boss 1) | Spider Lily | Short invincible dash; refreshes on landing |
| **Ground Pound** | Forge Warden (Boss 2) | Aconite | Slam downward; stuns enemies, breaks infected floors |
| **Double Jump** | Yuri's sacrifice | Daisy | White petal burst on second jump |
| **Phase Blink** | The Architect (Boss 5) | Black Rose | Short teleport through thin walls or spore barriers |

---

## 5. Key Characters & Flower Language

Flower language (*hanakotoba*) is the narrative grammar of this world. Every major character is bound to a flower whose meaning reflects — and often ironically contradicts — their role.

### Elena, the Princess ——【The Thousand-Faced Flower: Black Rose / Pansy】
- *Flower meaning:* Tender sincerity / Betrayal / "Please remember me"
- First heir to the Starlight Kingdom. Her arranged marriage to Prince Ryan is the political cover for the conspiracy. Elena has known the truth about her father for a long time. She is using herself as bait to get close to the alien mother-organism and destroy it — and herself — at the same time.
- Her coldness toward Gale is deliberate: she is protecting Gale from being implicated. Her every dismissal is a concealed act of love.
- **Story role:** The mystery at the centre of everything. Black rose petal fragments (collectibles) gradually reveal her true thoughts.

### Ryan, Prince of the Sun Kingdom ——【Yellow Hyacinth】
- *Flower meaning:* Jealousy, anxiety, fierce competitive will
- The Sun Kingdom's heir. Outwardly flawless. Privately consumed by jealousy — he has noticed the understanding between Elena and Gale, and it enrages him. His jealous recklessness leads him to tamper with the Flora containment, and he is fully parasitised as punishment.
- **Boss role:** World 3 boss. A towering figure erupting with flowers; attacks with wild, grief-stricken rage.

### Oswald, Grand Magister ——【Aconite / Monkshood】
- *Flower meaning:* Malice, murder, hostility toward humanity
- The King's co-conspirator. A cold magical scientist who has been directing the Flora parasitism for years. He controls ice-cold neural-toxin purple vines.
- **Boss role:** World 4 boss. Clinical, precise fight — his attacks are deliberate and surgical, not frenzied.

### Yuri, Vice-Captain of the Guard ——【Daisy】
- *Flower meaning:* Purity, love hidden deep in the heart
- Gale's closest friend. Secretly in love with Gale but chose to say nothing. In the late game, Yuri throws herself in the path of an attack meant for Gale. As she dies, the Flora spores in her body crystallise into a gift — the double-jump ability made of white petals.
- Her death is the emotional centre of the game. It happens regardless of ending route.

### Selena, Head Lady-in-Waiting ——【Rosemary】
- *Flower meaning:* Hold fast to memory / The danger of betrayal
- A spy from an enemy nation, embedded in the Princess's household for years. Her power is aromatic — she reads memories through scent and induces compelled sleep. She reveals the world's truth to Gale: what the King is doing, what Elena has chosen, and the location of the mother-organism.
- Morally ambiguous — her loyalties have shifted after years of proximity to Elena.

---

## 6. World Map & Zone Structure

The interconnected map transitions from cold, pristine steel to grotesque overgrowth as the story progresses. Early areas are beautiful in their severity. Late areas are smothered in alien bloom.

Collectible **black rose petals** are hidden in every zone. Gathering them unlocks Elena's private memory fragments — the only way to understand her before the ending branches.

```
Zone 1 — The Iron Barracks          (tutorial zone; cold clean steel; first spore sightings)
Zone 2 — The Palace Gardens         (invasion visible; beauty and horror coexist)
Zone 3 — The Catacombs             (underground; dark; Yuri's sacrifice occurs here)
Zone 4 — The Magister's Tower      (Oswald's domain; purple vine infestation)
Zone 5 — The Bridal Chamber / Core (Elena's destination; the mother-organism thrives here)
```

Each zone has:
- **Seamless Metroidvania exploration** (no discrete level select; rooms connect)
- **1 major boss encounter**
- **Hidden lore rooms** accessible only with abilities unlocked later (backtracking rewarded)
- **Environmental storytelling:** infected guards frozen mid-motion, bloomed over; royal portraits with flowers growing from the frames

### Room Structure
Each zone is composed of interconnected rooms saved as individual `.tscn` files. The zone root scene loads and transitions between rooms via door triggers. Camera clamps to the current room boundary.

---

## 7. Bosses

| Boss | Zone | Flower | Core Gimmick |
|---|---|---|---|
| **Sentinel-Prime** | 1 | Spider Lily | Former royal guard, fully bloomed. Teaches Blood Cost mechanic — certain phases are invincible without it. Grants **Dash**. |
| **Forge Warden** | 2 | Sunflower (corrupted) | Arena slowly fills with spore mist limiting visibility. Grants **Ground Pound**. |
| **Ryan, the Bloomed Prince** | 3 | Yellow Hyacinth | Emotional fight; Ryan still speaks in fragmented sentences. Must be staggered with Blood Cost attacks. Grants nothing — only grief. |
| **Oswald, the Magister** | 4 | Aconite | Three-phase: containment, full bloom, perfected form. Grants map data revealing the Core. |
| **The Mother-Organism** | 5 (True) | Black Rose | Final boss; the alien source. Elena is bonded to it. Ending depends on petal count. |

---

## 8. Endings

### Bad Ending — 【The Eternal Flower Cage / 永生花籠】
*Trigger:* Reach Zone 5 with fewer than 12 blood petal fragments collected (fewer than half).

Gale charges the throne room on pure obsession, having never learned Elena's true plan. She finds Elena mid-ritual, about to sacrifice herself. Without understanding, Gale sees only that Elena is going to disappear. The player must fight Elena — a heartbreaking boss encounter where Elena barely defends herself. Gale "wins." The sacrifice is interrupted. The mother-organism is not destroyed.

The spore plague spreads to every kingdom. Gale uses her thorn vines to stitch herself and the dying Elena together on the shattered throne — permanently. They cannot hold each other. They can only exist in the same place, unmoving, as the world blooms into ruin around them.

*"Entwined in life and death. Never to meet."*

### True Ending — 【The Last Petal / 最後一片花瓣】
*Trigger:* Collect all 24 black rose petal fragments. Read all of Elena's memories.

Gale understands. She helps Elena reach the mother-organism. She fights it alongside her rather than against her — a cooperative final sequence where Gale draws its attention using Blood Cost attacks (deliberately draining her own life) while Elena executes the ritual.

The mother-organism is destroyed. Elena survives, barely. Gale does not — the spider lilies in her wound finally go dark without the alien life force sustaining them.

In the final image: Elena kneels in a world still scarred but no longer spreading. She holds one spider lily — the last thing blooming — in both hands. The flower slowly closes. A long silence.

*"She finally understood me. That was enough."*

---

## 9. Art Direction

### Core Visual Identity
**The contrast of cold pale steel and violent crimson bloom** must be present in every zone, every character design, every UI element.

### Palette Rules
- **Per-zone limit:** 24 colours
- **Zone palettes:**
  - Zone 1 (Barracks): steel grey, stone white, faint crimson accents
  - Zone 2 (Gardens): ivory, dark green corruption, crimson bloom
  - Zone 3 (Catacombs): near-black, bone white, spider lily red
  - Zone 4 (Tower): deep purple, cold silver, toxin green
  - Zone 5 (Core): black, deep crimson, dim gold
- **Gale's palette** (red/white/silver) is consistent across all zones — she must always be readable

### Sprite Sizes

| Element | Base Size |
|---|---|
| Gale (player) | 16×24 (taller for vine cloak) |
| Common enemies | 16×16 |
| Large enemies / minibosses | 32×32 |
| Bosses | 64×64 or larger |
| Tiles | 16×16 |
| UI elements | 8×8, 16×16 |

### Art Pipeline
- **Placeholders:** Generated programmatically in GDScript using the `Image` API. Colored rectangles using zone palette with label text. All placeholder assets are tagged with a `# PLACEHOLDER` comment in the scene that references them.
- **Production art:** ComfyUI / local Stable Diffusion pipeline. When real `.png` assets are ready, drop them into the matching `assets/sprites/` subfolder. Scenes reference fixed paths — no code change needed.

### Animation Targets (Gale)
Idle (vines sway slowly) → Run → Jump rise → Jump apex → Fall → Land → Wall slide → Dash → Greatsword slash (3-hit chain) → Crimson Release (Blood Cost charge + release) → Double Jump (white petal burst) → Hurt → Death (flowers bloom fully, then go dark)

### Environmental Art Rules
- Alien flora must always feel **wrong** — shapes that shouldn't grow that way, colours too saturated for the stone world around them
- Spore particles drift constantly in bloom-heavy zones (subtle, not distracting)
- Infected human enemies retain their armour/uniform silhouette — they are recognisable, which makes them worse

---

## 10. Camera

- Lerp-smoothed follow camera, locked to room boundaries
- Slight look-ahead in movement direction
- Screen shake (configurable in Accessibility settings) on: impacts, Blood Cost use, boss phase transitions
- During boss fights: camera pulls back to show full arena

---

## 11. Audio

- **Music:** Dark orchestral chiptune hybrid. String and organ motifs over SNES-era percussion. Each zone theme degrades (more alien, more distorted) as the flora spreads.
- **Elena's leitmotif:** A simple piano phrase heard faintly in safe rooms. In the True Ending, it plays in full for the first time.
- **SFX:** Heavy, resonant. Sword impacts have weight. Crimson Release should sound like tearing and blooming simultaneously.
- **Ambient:** Spore zones have a faint, unsettling floral hum — beautiful and wrong.
- Format: SFX as `.wav` (mono, 44.1 kHz), music as `.ogg` (looping)

---

## 12. UI / HUD

```
┌──────────────────────────────────────────────┐
│ 🌸🌸🌸🌸🌸          ZONE 1        [SLASH]  │
│ 🌹 × 1 / 24                                  │
└──────────────────────────────────────────────┘
```

- **Health:** Crimson spider lily bloom icons (max 5, upgradable to 8)
- **Petal counter:** Black rose icon + collected/total — always visible; the player's "are you understanding the story?" meter
- **Ability indicator:** Small icon, bottom right; dims if ability is on cooldown
- **Pause menu:** Resume / Map / Lore Archive / Options / Quit
- **Lore Archive:** All collected petal memories readable from pause menu (displayed as Elena's handwritten notes)

---

## 13. Localization

- Supported languages at launch: **English** and **Traditional Chinese (繁體中文)**
- All display strings use Godot's built-in translation system (`tr("KEY")`)
- `.pot` template generated from project; `.po` files per language in `assets/localization/`
- Language preference stored in save data; switchable from Options menu at any time
- CJK text requires a separate font with full Unicode range — loaded conditionally

---

## 14. Progression & Economy

### Crystallised Spores (Currency)
- Dropped by enemies; found in sealed flower buds (breakable with Ground Pound)
- Spent at **Silent Altars** (save points) — carved stone shrines, half-bloomed
- Upgrades: max health +1, Blood Cost ratio, dash distance, sword reach

### Blood Petal Fragments (Collectibles / Narrative Key)
- 24 total across all zones; each unlocks one of Elena's memory fragments
- Required for True Ending (need all 24)
- Cannot be missed permanently — any fragment not collected on first visit can be retrieved on backtrack

### Save System
- Auto-save at every Silent Altar
- One save slot (v1)
- On death: respawn at last Altar; currency earned in the run is kept

---

## 15. Input Map

| Action | Default Keys | Gamepad |
|---|---|---|
| `move_left` | A, Left Arrow | D-pad Left / Left Stick |
| `move_right` | D, Right Arrow | D-pad Right / Left Stick |
| `jump` | Space, Z | A / Cross |
| `attack` | J (tap = slash, hold = Blood Cost) | X / Square |
| `dash` | Shift | B / Circle |
| `ground_pound` | S + jump | Down + A |
| `interact` | E, F | Y / Triangle |
| `pause` | Escape, P | Start |

**Note:** Mouse input is reserved for future systems. All in-game actions use keyboard/gamepad bindings only.
All inputs read via `Input.is_action_*()` — never hardcode key scancodes.
Controls are fully remappable from the Options menu.

---

## 16. Technical Requirements

| Requirement | Detail |
|---|---|
| Engine | Godot 4.4 |
| Language | GDScript (primary) |
| Target FPS | 60 fps (physics at 60 Hz) |
| Resolution | 320×180 base, integer scaling to window |
| Export targets | Windows, macOS, Linux, Web (HTML5) |
| Web hosting | GitHub Pages (`gh-pages` branch of `wernerweichen/GodotPlatformerTest`) |
| Input | Keyboard (primary); full gamepad support (XInput / DInput) |
| Testing | GUT (Godot Unit Testing); tests run after every feature update |
| Localization | Godot i18n system; English + Traditional Chinese at launch |
| Accessibility | Remappable controls, screen shake toggle, subtitles for all lore text |

---

## 17. Milestones

| Milestone | Goal |
|---|---|
| **Vertical Slice** | Zone 1 complete with placeholder art, Sentinel-Prime boss, Blood Cost mechanic, one petal fragment, Silent Altar save, HUD, GitHub Pages deploy |
| **Prototype Expansion** | All abilities; all 5 zones navigable (placeholder art); all bosses placeholder-complete |
| **Alpha** | Full story path; all 24 petal fragments; both endings implemented |
| **Beta** | Full art (ComfyUI/SD pipeline); SFX and music complete; localization complete |
| **Release** | Polish pass; platform export builds; itch.io + GitHub Pages live |

---

## 18. Out of Scope (v1)

- Multiplayer
- Procedural generation
- Full voice acting (lore is text-only)
- Mobile / touch controls
- New Game Plus (planned for post-launch)
- Mouse-driven UI (mouse reserved for future systems)
