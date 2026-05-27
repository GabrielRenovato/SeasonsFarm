extends PanelContainer
class_name SlotUI

@onready var item_icon: ColorRect = $MarginContainer/ItemIcon
@onready var quantity_label: Label = $MarginContainer/QuantityLabel
@onready var active_border: ReferenceRect = $ActiveBorder

var slot_index: int = -1
var inventory_data: InventoryData
var slot_data: SlotData

func setup(p_inventory_data: InventoryData, p_slot_index: int) -> void:
	inventory_data = p_inventory_data
	slot_index = p_slot_index
	slot_data = inventory_data.slots[slot_index]
	update_ui()

func update_ui() -> void:
	# Refresh slot_data reference in case slots were swapped or modified
	slot_data = inventory_data.slots[slot_index]
	
	if slot_data == null or slot_data.item == null or slot_data.quantity <= 0:
		item_icon.visible = false
		quantity_label.visible = false
		tooltip_text = ""
	else:
		item_icon.visible = true
		item_icon.color = slot_data.item.icon_color
		tooltip_text = slot_data.item.name
		
		if slot_data.item.is_tool:
			quantity_label.visible = false
		else:
			quantity_label.visible = true
			quantity_label.text = str(slot_data.quantity)

func set_active(is_active: bool) -> void:
	active_border.visible = is_active

# Drag & Drop Implementation
func _get_drag_data(_at_position: Vector2) -> Variant:
	if slot_data == null or slot_data.item == null:
		return null
		
	var drag_data = {
		"slot_index": slot_index,
		"inventory_data": inventory_data
	}
	
	# Create a visual drag preview
	var preview = PanelContainer.new()
	preview.custom_minimum_size = Vector2(20, 20)
	
	# Copy slot style or apply basic panel style
	var style_box = get_theme_stylebox("panel").duplicate()
	preview.add_theme_stylebox_override("panel", style_box)
	
	var preview_icon = ColorRect.new()
	preview_icon.color = slot_data.item.icon_color
	preview_icon.custom_minimum_size = Vector2(16, 16)
	preview_icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	preview_icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	preview.add_child(preview_icon)
	
	set_drag_preview(preview)
	return drag_data

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return data is Dictionary and data.has("slot_index") and data.has("inventory_data")

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	var from_index = data.slot_index
	var from_inventory = data.inventory_data
	
	if from_inventory == inventory_data:
		inventory_data.swap_slots(from_index, slot_index)
