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
	
	# Add default tools
	var hoe = ItemData.new()
	hoe.id = "hoe"
	hoe.name = "Enxada"
	hoe.is_tool = true
	hoe.tool_type = "Hoe"
	hoe.icon_color = Color(0.8, 0.4, 0.1) # Brownish
	
	var axe = ItemData.new()
	axe.id = "axe"
	axe.name = "Machado"
	axe.is_tool = true
	axe.tool_type = "Axe"
	axe.icon_color = Color(0.8, 0.1, 0.1) # Reddish
	
	var mining = ItemData.new()
	mining.id = "pickaxe"
	mining.name = "Picareta"
	mining.is_tool = true
	mining.tool_type = "Mining"
	mining.icon_color = Color(0.1, 0.6, 0.8) # Bluish
	
	slots[0].item = hoe
	slots[0].quantity = 1
	
	slots[1].item = axe
	slots[1].quantity = 1
	
	slots[2].item = mining
	slots[2].quantity = 1
	
	inventory_updated.emit()

func swap_slots(index_a: int, index_b: int) -> void:
	if index_a < 0 or index_a >= slots.size() or index_b < 0 or index_b >= slots.size():
		return
	var temp = slots[index_a]
	slots[index_a] = slots[index_b]
	slots[index_b] = temp
	inventory_updated.emit()
