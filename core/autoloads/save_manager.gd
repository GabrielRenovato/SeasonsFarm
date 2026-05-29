extends Node

const SAVE_PATH = "user://savegame.json"

var _inventory_data: InventoryData = null

signal save_completed
signal load_completed(success: bool)

func setup(inventory: InventoryData) -> void:
	_inventory_data = inventory

func save_game() -> void:
	if _inventory_data == null:
		push_warning("SaveManager: inventory_data not set, cannot save.")
		return

	var data: Dictionary = {
		"gold": EconomyManager.gold,
		"day": TimeManager.day,
		"inventory": _serialize_inventory(),
		"farm": _serialize_farm(),
	}

	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("SaveManager: failed to open save file for writing.")
		return
	file.store_string(JSON.stringify(data, "\t"))
	file.close()
	print("SaveManager: game saved.")
	save_completed.emit()

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func load_game() -> void:
	if not has_save():
		load_completed.emit(false)
		return
	if _inventory_data == null:
		push_warning("SaveManager: inventory_data not set, cannot load.")
		load_completed.emit(false)
		return

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_error("SaveManager: failed to open save file for reading.")
		load_completed.emit(false)
		return

	var raw = file.get_as_text()
	file.close()

	var data = JSON.parse_string(raw)
	if data == null:
		push_error("SaveManager: failed to parse save file.")
		load_completed.emit(false)
		return

	EconomyManager.gold = int(data.get("gold", 0))
	EconomyManager.gold_changed.emit(EconomyManager.gold)
	TimeManager.day = int(data.get("day", 1))

	_deserialize_inventory(data.get("inventory", []))
	# Farm restore needs the scene tree ready — defer so FarmManager can find dirt_layer
	call_deferred("_deserialize_farm", data.get("farm", []))

	print("SaveManager: game loaded.")
	load_completed.emit(true)

# --- Serialization helpers ---

func _serialize_inventory() -> Array:
	var result: Array = []
	for i in range(_inventory_data.slots.size()):
		var slot: SlotData = _inventory_data.slots[i]
		if slot == null or slot.item == null or slot.quantity <= 0:
			continue
		result.append({
			"slot": i,
			"id": slot.item.id,
			"rarity": slot.item.rarity,
			"quantity": slot.quantity,
			"is_tool": slot.item.is_tool,
			"tool_type": slot.item.tool_type,
			"is_seed": slot.item.is_seed,
			"crop_type": slot.item.crop_type,
			"tier": slot.item.tier,
			"name": slot.item.name,
		})
	return result

func _serialize_farm() -> Array:
	var result: Array = []
	for pos in FarmManager.farm_data.keys():
		var d: Dictionary = FarmManager.farm_data[pos]
		if not d.get("tilled", false) and d.get("crop_id", "") == "":
			continue
		result.append({
			"x": pos.x,
			"y": pos.y,
			"tilled": d.get("tilled", false),
			"watered": d.get("watered", false),
			"crop_id": d.get("crop_id", ""),
			"days_grown": d.get("days_grown", 0),
		})
	return result

# --- Deserialization helpers ---

func _deserialize_inventory(slots_data: Array) -> void:
	# Reset inventory to empty first
	for slot in _inventory_data.slots:
		slot.item = null
		slot.quantity = 0

	var inv_ui_helper := _inventory_data  # for icon helpers

	for entry in slots_data:
		var idx: int = int(entry.get("slot", -1))
		if idx < 0 or idx >= _inventory_data.slots.size():
			continue

		var item := ItemData.new()
		item.id = entry.get("id", "")
		item.name = entry.get("name", item.id)
		item.rarity = entry.get("rarity", "common")
		item.is_tool = entry.get("is_tool", false)
		item.tool_type = entry.get("tool_type", "")
		item.is_seed = entry.get("is_seed", false)
		item.crop_type = entry.get("crop_type", "")
		item.tier = entry.get("tier", "Wood")

		# Restore icon
		if item.is_tool:
			item.icon_texture = inv_ui_helper._get_tool_icon(item.tool_type, item.tier)
		elif item.is_seed:
			var cfg = FarmManager.CROP_CONFIGS.get(item.crop_type, {})
			if not cfg.is_empty():
				item.icon_texture = inv_ui_helper._get_seed_bag_icon(cfg.get("seed_x", 0), cfg.get("seed_y", 0))
		else:
			# Harvested crop — ícone do All Crops.png (mesmo offset do seed, +2/3/4 por raridade)
			var cfg = FarmManager.CROP_CONFIGS.get(item.id, {})
			if not cfg.is_empty():
				var all_crops := load("res://assets/sprites/crops/All Crops.png") as Texture2D
				if all_crops:
					var rarity_col: int = {"common": 2, "silver": 3, "gold": 4}.get(item.rarity, 2)
					var atlas := AtlasTexture.new()
					atlas.atlas = all_crops
					atlas.region = Rect2(cfg.get("seed_x", 0) + rarity_col * 16, cfg.get("seed_y", 0), 16, 16)
					item.icon_texture = atlas
			elif item.id == "wood":
				# Restaura o ícone da madeira a partir do items.png
				var items_png = load("res://assets/sprites/ui/items.png") as Texture2D
				if items_png:
					var atlas := AtlasTexture.new()
					atlas.atlas = items_png
					atlas.region = Rect2(0, 112, 16, 16)
					item.icon_texture = atlas
			elif item.id == "stone":
				# Restaura o ícone da pedra a partir de Ground stones.png
				var stones_png = load("res://assets/sprites/Props/Spring/Ground stones.png") as Texture2D
				if stones_png:
					var atlas := AtlasTexture.new()
					atlas.atlas = stones_png
					atlas.region = Rect2(0, 16, 16, 16)
					item.icon_texture = atlas

		_inventory_data.slots[idx].item = item
		_inventory_data.slots[idx].quantity = int(entry.get("quantity", 1))

	_inventory_data.inventory_updated.emit()

func _deserialize_farm(farm_data: Array) -> void:
	var dirt_layer := get_tree().get_first_node_in_group("dirt_layer") as TileMapLayer
	if dirt_layer == null:
		push_error("SaveManager: cannot restore farm — dirt_layer not found.")
		return

	var crop_scene_path := "res://objects/crops/crop.tscn"
	var crop_scene := load(crop_scene_path) as PackedScene

	for entry in farm_data:
		var pos := Vector2i(int(entry.get("x", 0)), int(entry.get("y", 0)))

		# Restore tilled soil
		FarmManager.till_soil(pos)

		if entry.get("watered", false):
			FarmManager.water_soil(pos)

		var crop_id: String = entry.get("crop_id", "")
		if crop_id != "" and crop_scene:
			var days_grown: int = int(entry.get("days_grown", 0))
			var crop_instance := crop_scene.instantiate()
			dirt_layer.get_parent().add_child(crop_instance)
			var tile_center := dirt_layer.map_to_local(pos)
			crop_instance.global_position = dirt_layer.to_global(tile_center)

			FarmManager.plant_seed(pos, crop_id, crop_instance)

			# Advance growth manually to match saved state
			for _i in range(days_grown):
				if is_instance_valid(crop_instance) and crop_instance.has_method("grow"):
					crop_instance.grow()
			FarmManager.farm_data[pos].days_grown = days_grown
