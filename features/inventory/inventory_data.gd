extends Resource
class_name InventoryData

signal inventory_updated
signal active_slot_changed(index: int)

@export var slots: Array[SlotData] = []
var active_slot_index: int = 0:
	set(value):
		active_slot_index = clamp(value, 0, 11)
		active_slot_changed.emit(active_slot_index)

func get_active_item() -> ItemData:
	if slots.size() > active_slot_index and slots[active_slot_index] != null:
		return slots[active_slot_index].item
	return null

func setup_default_inventory() -> void:
	slots.clear()
	for i in range(36):
		var sd = SlotData.new()
		sd.quantity = 0
		slots.append(sd)
	
	# Load tool sprite sheets (each is 160x128 = 10 cols x 8 rows of 16x16 frames, but 5x4 for 32x32)
	# Using wood tier tools as defaults
	var axe_sheet = load("res://assets/sprites/player/separate/axe/tool/axe_wood.png")
	var hoe_sheet = load("res://assets/sprites/player/separate/hoe/tool/hoe_wood.png")
	var pick_sheet = load("res://assets/sprites/player/separate/pickaxe/tool/pickaxe_wood.png")
	
	# Add default tools
	var hoe = ItemData.new()
	hoe.id = "hoe"
	hoe.name = "Enxada"
	hoe.is_tool = true
	hoe.tool_type = "Hoe"
	hoe.icon_color = Color(0.8, 0.4, 0.1)
	hoe.icon_texture = _get_tool_frame(hoe_sheet, 15)
	
	var axe = ItemData.new()
	axe.id = "axe"
	axe.name = "Machado"
	axe.is_tool = true
	axe.tool_type = "Axe"
	axe.icon_color = Color(0.8, 0.1, 0.1)
	axe.icon_texture = _get_tool_frame(axe_sheet, 15)
	
	var mining = ItemData.new()
	mining.id = "pickaxe"
	mining.name = "Picareta"
	mining.is_tool = true
	mining.tool_type = "Mining"
	mining.icon_color = Color(0.1, 0.6, 0.8)
	mining.icon_texture = _get_tool_frame(pick_sheet, 15)
	
	slots[0].item = hoe
	slots[0].quantity = 1
	
	slots[1].item = axe
	slots[1].quantity = 1
	
	slots[2].item = mining
	slots[2].quantity = 1
	
	inventory_updated.emit()

## Extracts a single 32x32 frame from a tool spritesheet (5 columns x 4 rows)
func _get_tool_frame(sheet: Texture2D, frame_index: int) -> AtlasTexture:
	if sheet == null:
		return null
	var cols = 5
	var frame_w = 32
	var frame_h = 32
	var col = frame_index % cols
	var row = frame_index / cols
	var tex = AtlasTexture.new()
	tex.atlas = sheet
	# Crop a 20x20 area adjusted for where the tools actually are in the 32x32 frame
	var crop_size = 20
	var offset_x = 2
	var offset_y = 8
	tex.region = Rect2((col * frame_w) + offset_x, (row * frame_h) + offset_y, crop_size, crop_size)
	return tex

func swap_slots(index_a: int, index_b: int) -> void:
	if index_a < 0 or index_a >= slots.size() or index_b < 0 or index_b >= slots.size():
		return
	var temp = slots[index_a]
	slots[index_a] = slots[index_b]
	slots[index_b] = temp
	inventory_updated.emit()
