extends PanelContainer
class_name InventoryMenuUI

@onready var grid_container: GridContainer = $MarginContainer/VBoxContainer/GridContainer
@onready var close_button: Button = $MarginContainer/VBoxContainer/Header/CloseButton

const SLOT_UI_SCENE = preload("res://features/inventory/ui/slot_ui.tscn")

var inventory_data: InventoryData

func setup(p_inventory_data: InventoryData) -> void:
	inventory_data = p_inventory_data
	
	if inventory_data.inventory_updated.is_connected(update_slots):
		inventory_data.inventory_updated.disconnect(update_slots)
	inventory_data.inventory_updated.connect(update_slots)
	
	# Clear existing children
	for child in grid_container.get_children():
		child.queue_free()
		
	# Instantiate 36 slots in the 3x12 GridContainer
	for i in range(36):
		var slot_ui = SLOT_UI_SCENE.instantiate()
		grid_container.add_child(slot_ui)
		slot_ui.setup(inventory_data, i)

func update_slots() -> void:
	for slot_ui in grid_container.get_children():
		if is_instance_valid(slot_ui):
			slot_ui.update_ui()

func _ready() -> void:
	if close_button:
		close_button.pressed.connect(func(): visible = false)
