extends PanelContainer
class_name HotbarUI

@onready var slots_container: HBoxContainer = $MarginContainer/HBoxContainer

const SLOT_UI_SCENE = preload("res://features/inventory/ui/slot_ui.tscn")

var inventory_data: InventoryData

func setup(p_inventory_data: InventoryData) -> void:
	inventory_data = p_inventory_data
	
	# Disconnect first to avoid double connections just in case
	if inventory_data.inventory_updated.is_connected(update_slots):
		inventory_data.inventory_updated.disconnect(update_slots)
	if inventory_data.active_slot_changed.is_connected(update_selection):
		inventory_data.active_slot_changed.disconnect(update_selection)
		
	inventory_data.inventory_updated.connect(update_slots)
	inventory_data.active_slot_changed.connect(update_selection)
	
	# Clear any previous children (in case of re-initialization)
	for child in slots_container.get_children():
		child.queue_free()
	
	# Instantiate 12 slots for the hotbar
	for i in range(12):
		var slot_ui = SLOT_UI_SCENE.instantiate()
		slots_container.add_child(slot_ui)
		slot_ui.setup(inventory_data, i)
		
	update_selection(inventory_data.active_slot_index)

func update_slots() -> void:
	for slot_ui in slots_container.get_children():
		if is_instance_valid(slot_ui):
			slot_ui.update_ui()

func update_selection(active_index: int) -> void:
	var children = slots_container.get_children()
	for i in range(children.size()):
		var slot_ui = children[i] as SlotUI
		if is_instance_valid(slot_ui):
			slot_ui.set_active(i == active_index)
