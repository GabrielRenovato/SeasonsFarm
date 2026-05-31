extends Node

# Saves and loads furniture data.
# Also keeps track of currently placed furniture in the active scene.

const SAVE_PATH = "user://house_furniture.json"

# Dictionary holding placed furniture data
# Format: { "unique_id": { "item_id": "bed_1", "position_x": 100, "position_y": 150, "rotation": 90 } }
var placed_furniture: Dictionary = {}

# We emit this when edit mode is toggled
signal edit_mode_changed(is_editing: bool)

# Catalog of available furniture items
# In a real game, this could be loaded from a Resource or JSON
var catalog: Dictionary = {
	"bed_single": {
		"name": "Single Blue Bed",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Beds.png",
		"regions": [
			Rect2(0, 0, 32, 48), Rect2(0, 0, 32, 48), Rect2(0, 0, 32, 48), Rect2(0, 0, 32, 48)
		],
		"collision_sizes": [
			Vector2(32, 48), Vector2(32, 48), Vector2(32, 48), Vector2(32, 48)
		],
		"collision_offsets": [
			Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)
		]
	},
	"bed_double": {
		"name": "Double Red Bed",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Beds.png",
		"regions": [
			Rect2(0, 256, 64, 48), Rect2(0, 256, 64, 48), Rect2(0, 256, 64, 48), Rect2(0, 256, 64, 48)
		],
		"collision_sizes": [
			Vector2(64, 48), Vector2(64, 48), Vector2(64, 48), Vector2(64, 48)
		],
		"collision_offsets": [
			Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)
		]
	},
	"chair_office": {
		"name": "Red Office Chair",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Chairs.png",
		"regions": [
			Rect2(0, 32, 16, 32),   # Down
			Rect2(48, 32, 16, 32),  # Right
			Rect2(16, 32, 16, 32),  # Up
			Rect2(32, 32, 16, 32)   # Left
		],
		"collision_sizes": [
			Vector2(14, 16), Vector2(14, 16), Vector2(14, 16), Vector2(14, 16)
		],
		"collision_offsets": [
			Vector2(0, 8), Vector2(0, 8), Vector2(0, 8), Vector2(0, 8)
		]
	},
	"chair_office_blue": {
		"name": "Blue Office Chair",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Chairs.png",
		"regions": [
			Rect2(0, 64, 16, 32),   # Down
			Rect2(48, 64, 16, 32),  # Right
			Rect2(16, 64, 16, 32),  # Up
			Rect2(32, 64, 16, 32)   # Left
		],
		"collision_sizes": [
			Vector2(14, 16), Vector2(14, 16), Vector2(14, 16), Vector2(14, 16)
		],
		"collision_offsets": [
			Vector2(0, 8), Vector2(0, 8), Vector2(0, 8), Vector2(0, 8)
		]
	},
	"desk": {
		"name": "Blue Desk",
		"texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Tables and desks.png",
		"regions": [
			Rect2(0, 0, 32, 32), Rect2(0, 0, 32, 32), Rect2(0, 0, 32, 32), Rect2(0, 0, 32, 32)
		],
		"collision_sizes": [
			Vector2(32, 32), Vector2(32, 32), Vector2(32, 32), Vector2(32, 32)
		],
		"collision_offsets": [
			Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)
		]
	}
}

var is_edit_mode: bool = false:
	set(value):
		is_edit_mode = value
		edit_mode_changed.emit(is_edit_mode)

func _ready() -> void:
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
