extends Node

# Saves and loads furniture data.
# Also keeps track of currently placed furniture in the active scene.

const SAVE_PATH = "user://house_furniture.json"

# Dictionary holding placed furniture data
# Format: { "unique_id": { "item_id": "bed_1", "position_x": 100, "position_y": 150, "rotation": 90 } }
var placed_furniture: Dictionary = {}

# We emit this when edit mode is toggled
signal edit_mode_changed(is_editing: bool)
signal furniture_picked_up(item: Node2D)

# Catalog of available furniture items
# In a real game, this could be loaded from a Resource or JSON
var catalog: Dictionary = {}

# Liga/desliga TODO o sistema de móveis: itens no inventário, colocar, sentar e
# carregar móveis na casa. Desligado temporariamente.
# Para reativar a mobília mais tarde, basta voltar para `true`.
var enabled: bool = false

var is_edit_mode: bool = false:
	set(value):
		is_edit_mode = value
		edit_mode_changed.emit(is_edit_mode)

func _ready() -> void:
	var catalog_script := preload("res://systems/furniture/furniture_catalog_data.gd").new()
	catalog = catalog_script.data
	
	load_furniture_data()

# Saves the current furniture configuration to a JSON file
func save_furniture_data() -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(placed_furniture, "\t")
		file.store_string(json_string)
		file.close()

# Loads the furniture configuration from the JSON file
func load_furniture_data() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file:
			var json_string = file.get_as_text()
			var json = JSON.new()
			var error = json.parse(json_string)
			if error == OK:
				var data = json.get_data()
				if typeof(data) == TYPE_DICTIONARY:
					placed_furniture = data
			file.close()

# Adds a new furniture item to our tracking dictionary
func add_furniture(id: String, item_id: String, pos: Vector2, rot: float) -> void:
	placed_furniture[id] = {
		"item_id": item_id,
		"position_x": pos.x,
		"position_y": pos.y,
		"rotation": rot
	}
	save_furniture_data()

# Updates an existing furniture's position and rotation
func update_furniture(id: String, pos: Vector2, rot: float) -> void:
	if placed_furniture.has(id):
		placed_furniture[id]["position_x"] = pos.x
		placed_furniture[id]["position_y"] = pos.y
		placed_furniture[id]["rotation"] = rot
		save_furniture_data()

# Removes a furniture item from tracking
func remove_furniture(id: String) -> void:
	if placed_furniture.has(id):
		placed_furniture.erase(id)
		save_furniture_data()
