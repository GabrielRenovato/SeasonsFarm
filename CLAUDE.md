# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Seasons Farm** — a Stardew Valley-inspired farming sim built with **Godot 4.6** (GDScript). Pixel art, 2D top-down perspective, viewport 480×240 scaled up to 1920×1080.

## Running the Game

There is no build/lint/test CLI. All development is done inside the Godot editor:

- **Run:** Open `farm-gaming/` in Godot 4.6, then press **F5** (runs from `ui/customization_menu/character_customization.tscn`)
- **Run current scene:** **F6**
- **Save game (in-game):** **F5**
- **Skip to next day (in-game):** **T**
- **Toggle inventory (in-game):** **Tab**

To verify UI changes without the editor, a `SubViewport` screenshot approach can be used — see memory for the technique.

## Architecture

### Autoloads (Global Singletons)

All registered in `project.godot`. Access anywhere without `$` or `get_node()`.

| Singleton | File | Responsibility |
|---|---|---|
| `TimeManager` | `core/autoloads/time_manager.gd` | In-game clock (6 AM–2 AM cycle, ~770 real seconds/day) |
| `FarmManager` | `core/autoloads/farm_manager.gd` | Tilling, watering, planting, harvesting, crop growth |
| `EconomyManager` | `core/autoloads/economy_manager.gd` | Gold balance, rarity-based crop prices |
| `SaveManager` | `core/autoloads/save_manager.gd` | JSON persistence (`user://savegame.json`) |
| `CustomizationManager` | `systems/customization_manager.gd` | Player appearance options and signals |

### Signal Flow

The architecture is **signal-driven** for loose coupling:

```
TimeManager.day_changed  →  FarmManager  (grow crops)
TimeManager.time_changed →  HUD          (clock display)
EconomyManager.gold_changed → HUD        (gold display)
InventoryData.inventory_updated → HotbarUI / InventoryMenuUI / ToolComponent
CustomizationManager.customization_changed → CustomizationComponent (player sprites)
```

### Player (Component-Based)

`entities/player/Player.tscn` is a `CharacterBody2D` with three child components:

- **`MovementComponent`** — WASD, animation state (idle/run/carry variants), max 150 px/s
- **`ToolComponent`** — tool detection from active slot, animation triggers, tile-based hit detection, carrying sprite for non-tool items
- **`CustomizationComponent`** — multi-layer sprite sheets (hair, eyes, clothes, body, pants)

`Player.gd` owns the HUD (instantiated as child) and the lantern (auto-enabled at 17:30, faded at sunrise).

### Farming System

Grid-based via `FarmManager`. The dirt `TileMapLayer` is found at runtime by group name (`"dirt_layer"`). Each tile tracks:
- `tilled` / `watered` booleans
- `crop_id`, `growth_days`, reference to the crop `Node`

Key flow: `use_tool` input → `ToolComponent` triggers animation → on `animation_finished` → `FarmManager.till_soil / water_soil / plant_seed / harvest_crop`.

Crops grow **once per day** if watered. Empty dry soil reverts to untilled with 50% chance each day.

### Inventory System

36 slots: indices 0–11 = hotbar, 12–35 = main inventory.

- `InventoryData` — array of `SlotData`, manages stacking, emits `inventory_updated` and `active_slot_changed`
- `ItemData` — item properties: `is_tool`, `tool_type`, `tier`, `is_seed`, `crop_type`, `rarity`, `icon_texture`
- Tools don't stack; seeds/crops stack by `id + rarity`
- Tool tiers: `Wood → Cooper → Iron → Gold → Platinum → Crimson → Frost → Shadow → Fairy → Obsidian`
- Crop rarities: `common` (70%), `silver` (25%), `gold` (5%) — rolled on harvest in `ToolComponent._roll_rarity()`

### Crop Configuration

All crop metadata lives in `FarmManager.CROP_CONFIGS` (single source of truth):

```gdscript
# Keys per crop: seasons, growth_stages, base_price, icon_row, icon_col, frame_map
```

Seed icons are loaded from `assets/All Crops.png` (atlas) using `icon_row`/`icon_col` coordinates from `CROP_CONFIGS`. Tool icons are loaded from `assets/sprites/icons/<tool_type>/<tier>.png`.

### UI — Tooltip System

`SlotUI` (`systems/inventory/ui/slot_ui.gd`) uses `_make_custom_tooltip()` to render a custom tooltip. It overrides the engine's `PopupPanel` style to transparent via `tree_entered` signal, then repositions the popup above the hovered slot with `call_deferred`.

## Code Conventions

- Language: **GDScript**, comments in **Portuguese**
- Class names use `PascalCase` (`class_name FarmManager`)
- Signals use `snake_case` (`inventory_updated`, `gold_changed`)
- `@onready` vars for node references; `@export` for designer-facing properties
- Deferred calls (`call_deferred`) used when modifying scene tree during notifications
- Group-based node lookup used in autoloads (e.g. `get_tree().get_nodes_in_group("dirt_layer")`)
