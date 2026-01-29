# AGENTS.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

**逆果溯因 (Reverse Causality)** is a cognitive reasoning game built with Godot 4.6. Players construct causal chains to understand complex system logic, working backwards from given results to identify the causes. The game supports Web (HTML5) export and features a comprehensive narrative system.

**Current Status:** MVP (v0.1.0) with core systems in place; advanced features (resonance detection, multiple solution paths, world logs) planned for future versions.

## Architecture Overview

### High-Level Structure

The project follows a modular pattern across 4 key layers:

1. **Data Layer** (`scripts/data/`)
   - `CauseNode.gd` — Represents individual causal nodes with metadata (ID, label, time_stage, distractor_type)
   - `CausalRule.gd` — Defines connections between nodes with strength and time constraints
   - `LevelData.gd` — Complete level definition including result node, candidates, rules, and valid solution paths

2. **Core Systems** (`scripts/core/`)
   - `GameManager.gd` — Manages global game state and current level
   - `SaveGame.gd` — JSON-based persistence for progress, resonances, world logs
   - `CausalValidator.gd` — Core validation logic (error detection, strength calculation, path matching)
   - `UndoRedoManager.gd` — Tracks placement history (max 20 actions)
   - `ResonanceDatabase.gd` + `ResonanceDetector.gd` — Pattern matching for unlockable resonances (e.g., "Luddite Loop")
   - `PathAnalyzer.gd` — Identifies which solution path the player discovered
   - `I18nManager.gd` — Localization system
   - `AudioManager.gd` — Sound and music control
   - `ThemeManager.gd` (in `ui/`) — Dynamic theme application using Dark Academic color palette
   - `ResponsiveUI.gd` — Viewport scaling for Web
   - `Preloader.gd` — Scene/audio preloading for Web performance
   - `PerformanceMonitor.gd` — Debug metrics

3. **Game Logic** (`scripts/game/`)
   - `GameMain.gd` — Main game interface controller; orchestrates drag-and-drop, validation, slot management
   
4. **UI & Components** (`scripts/ui/` and `scripts/components/`)
   - **UI Scenes**: `MainMenu.gd`, `LevelSelect.gd`, `ResultPanel.gd`, `Archive.gd` (resonance/world log viewer)
   - **Components**: 
     - `CauseCard.gd` — Draggable candidate cards with distractor styling
     - `ChainSlot.gd` — Drop zones with visual state feedback (empty→hover→filled)
     - `LevelCard.gd` — Level selection cards with lock/grade display
   - `ErrorToast.gd` — Transient error notifications
   - `ThemeManager.gd` — Theme initialization and application

5. **Narrative Systems** (`scripts/narrative/`)
   - `WorldLogGenerator.gd` — Procedural world history generation based on chains
   - `WorldLogTemplates.gd` — Narrative building blocks

6. **Tools & Setup** (`scripts/tools/`)
   - `CreateLevelData.gd` — EditorScript that generates 3 default levels

### Theme System Architecture

The theme system in `/themes/` is **modular and generative**:

- **GenerateTheme.gd** — EditorScript that compiles all style modules into `default_theme.tres`
- **ColorPalette.gd** — Dark Academic color definitions (8 background levels, text hierarchy, 4 functional color sets)
- **TypographySystem.gd** — Type scale (Display→H1→H3→Caption), weights, line heights
- **SpacingSystem.gd** — Margin/padding standards
- **ShadowSystem.gd** — Elevation-based shadow definitions
- **AnimationSystem.gd** — Transition timings and easing curves

To apply changes: edit the module, run `GenerateTheme.gd` in the editor, then refresh scenes.

### Scene Organization

```
scenes/
├── ui/MainMenu.tscn          # Title, menu buttons
├── ui/LevelSelect.tscn        # Grid of level cards with unlock states
├── ui/ResultPanel.tscn        # Grade display, metric bars, unlock messages
├── ui/Archive.tscn            # Resonance gallery + world log viewer
├── game/GameMain.tscn         # Core gameplay (5 slots + 8 candidates + validation)
├── components/
│   ├── CauseCard.tscn         # Draggable node card
│   ├── ChainSlot.tscn         # Drop zone with state visualization
│   └── LevelCard.tscn         # Selection card
└── tutorial/Tutorial.tscn     # Step-by-step onboarding
```

**Scenes are NOT version-controlled** (.tscn files) but scene structures are documented in `SCENE_SETUP.md`.

### Data Storage

**Save file format:** `user://save_data.json`

Structure includes:
- `level_progress` — { level_id: { grade, score, best_chain, discovered_paths } }
- `archive.resonances` — Array of unlocked resonance IDs
- `archive.world_logs` — Array of { level_id, chain, log_text, timestamp }
- `settings` — Volume levels, language preference

## Development Workflow

### Running & Testing

**In Godot Editor:**
```
F5 or Project → Run → Play Scene
```

**Play a specific level:**
- Modify `GameManager.current_level_id` before running, or select level from menu

**Running a single test/tool script:**
- Open script in editor
- Tools → Run Script (for EditorScripts)

### Building for Web

```
Project → Export
→ Select "Web (HTML5)" preset
→ Configure (thread support OFF for compatibility)
→ Export as index.html
```

Export directory: `/export/` (custom HTML template in `export_templates/web/`)

### Common Development Tasks

**Generate theme after editing:**
1. Edit theme modules in `themes/ColorPalette.gd`, `TypographySystem.gd`, etc.
2. Tools → Run Script → `themes/GenerateTheme.gd`
3. Rescan project files (Project → Rescan Project Files)
4. Reload scenes

**Create new levels:**
1. Data file: `data/levels/level_XX.tres` (LevelData resource)
2. Register in game selection UI
3. Export level data using `scripts/tools/CreateLevelData.gd` or create manually

**Test a causal validator change:**
- Modify `CausalValidator.gd` logic
- Open `game/GameMain.tscn` and play
- Test various chain configurations and check console output

**Debug drag-and-drop issues:**
- Check `CauseCard._gui_input()` and `ChainSlot._can_drop_data()`
- Ensure `z_index` is being set during drag
- Verify slot overlap detection in `GameMain._on_card_drag_ended()`

### Key Configuration Files

- **project.godot** — Viewport (1280×720), autoload managers, main scene (`scenes/ui/MainMenu.tscn`)
- **export_presets.cfg** — Web export settings (thread support, HTML template path)

## Data Models & Validation

### Causal Chain Validation

**Validation pipeline** (in `CausalValidator.gd`):

1. **Basic checks**: Empty chain? Duplicate nodes? Length within `max_steps`?
2. **Rule matching**: Does each pair (node[i] → node[i+1]) exist in `level.rules`?
3. **Time gap penalties**: Compare `abs(node[i+1].time_stage - node[i].time_stage)` against rule's `min_time_gap`, `max_time_gap`, `optimal_gap`
4. **Distractor detection**: If `node.is_distractor == true`, flag as error; accumulate `cleanliness` score
5. **Strength calculation**: Sum all rule strengths (modified by time penalties)
6. **Final checks**: Is `total_strength >= level.required_strength`?

Result object includes: `{ passed, strength, errors[], completeness, strength_ratio, cleanliness }`

### Path Identification

When validation passes, `PathAnalyzer.gd` checks if the chain matches any `level.valid_paths`. Each path has:
- `id`, `name`, `difficulty` (1–3), `bonus` (1.0–1.5 multiplier)
- First match wins; unknown chains get `bonus = 1.0`

### Resonance Detection

`ResonanceDetector.gd` checks if the current chain contains causal patterns from `ResonanceDatabase`. Example:
- **"luddite_loop"**: [tech_breakthrough → job_displacement → social_unrest]
- Bonus: ×1.2 score multiplier
- Side effect: Unlock archive entry, trigger world log generation

## Important Development Patterns

### Autoload Managers

All globally accessible singletons are defined in `project.godot` autoload section:
```
SaveGame, GameManager, AudioManager, ResponsiveUI, 
UndoRedoManager, Preloader, I18nManager
```

Access via `SaveGame.save_data`, `GameManager.load_level()`, etc. No instantiation needed.

### Signal Connections in GameMain

Drag-and-drop works through paired signals:
- **Card**: emits `drag_started`, `drag_ended` → GameMain updates slot hints
- **Slot**: emits `card_placed`, `card_removed` → GameMain updates strength bar

Manual drop detection in `GameMain._on_card_drag_ended()` checks intersection with slots.

### Undo/Redo

- `UndoRedoManager.record_action(type, data)` called on placement
- `UndoRedoManager.undo()`, `.redo()` retrieve past actions
- History capped at 20 actions; clearing chain empties history

### i18n Usage

Strings wrapped with `I18nManager.translate("ui.game.level")` etc. Fallback to Chinese hardcoded strings if I18nManager unavailable. See `I18nManager.gd` for key structure.

## Known Limitations & Technical Debt

- **Web threading**: Disabled for browser compatibility (impacts async scene loading)
- **Mobile support**: Not tested; game optimized for 1280×720 (16:9)
- **Animation system**: Basic tweens; no advanced particle effects
- **Networking**: None; purely local gameplay
- **Performance**: Should hit 60 FPS on modern browsers; monitor with `PerformanceMonitor.gd`

## References & Documentation

- **Full technical guide**: `reverse_causality_dev_guide.md` (comprehensive architecture, implementation patterns, prioritized feature roadmap)
- **Design specifications**: `m3.md` (UI/UX color system, typography, spacing standards)
- **Scene setup**: `SCENE_SETUP.md` (node hierarchies, scene creation checklists)
- **README.md**: High-level game overview, quick start, feature roadmap

## Development Priorities

**P0 (MVP core)**
- Basic causal validation
- Drag-and-drop UI
- 3 playable levels with manual causal rules
- Save/load system

**P1 (Polish)**
- Tutorial/onboarding
- Distractor node identification
- Path discovery tracking
- Theme visual refinements

**P2 (Advanced)**
- Resonance system unlock conditions
- World log procedural generation
- Multiple solution path detection
- Archive/gallery UI completion
