extends Resource
class_name ItemData

@export var id: String = ""
@export var name: String = ""
@export var is_tool: bool = false
@export var tool_type: String = "" # "Hoe", "Axe", "Pickaxe", "Water"
@export var is_seed: bool = false
@export var crop_type: String = "" # "tomato", "turnip"
@export var icon_color: Color = Color.WHITE
@export var icon_texture: Texture2D
