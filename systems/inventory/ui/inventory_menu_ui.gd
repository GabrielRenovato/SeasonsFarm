extends Control
class_name InventoryMenuUI

const SLOT_UI_SCENE = preload("res://systems/inventory/ui/slot_ui.tscn")

# Página direita mostra TODOS os 36 slots (hotbar + inventário juntos)
const ALL_SLOTS_START := 0
const ALL_SLOTS_COUNT := 36  # 6 colunas × 6 linhas

@onready var slots_root: Control = %SlotsRoot
@onready var player_preview: PlayerPreviewUI = $LeftPage/PlayerPreview
@onready var selected_tool_icon: TextureRect = %ToolIcon

# Mantidos para compatibilidade
@onready var tabs_root: Control = %TabsRoot
@onready var buttons_root: Control = %ButtonsRoot

var inventory_data: InventoryData


func setup(p_inventory_data: InventoryData) -> void:
	inventory_data = p_inventory_data
	if inventory_data.inventory_updated.is_connected(update_slots):
		inventory_data.inventory_updated.disconnect(update_slots)
	inventory_data.inventory_updated.connect(update_slots)

	if inventory_data.active_slot_changed.is_connected(_on_active_slot_changed):
		inventory_data.active_slot_changed.disconnect(_on_active_slot_changed)
	inventory_data.active_slot_changed.connect(_on_active_slot_changed)

	player_preview.setup(inventory_data)

	# Página direita: todos os 36 slots
	for child in slots_root.get_children():
		child.queue_free()
	for i in range(ALL_SLOTS_START, ALL_SLOTS_START + ALL_SLOTS_COUNT):
		var slot_ui = SLOT_UI_SCENE.instantiate()
		slots_root.add_child(slot_ui)
		slot_ui.custom_minimum_size = Vector2(15, 15)
		slot_ui.setup(inventory_data, i)

	_update_selected_tool()


func update_slots() -> void:
	for slot_ui in slots_root.get_children():
		if is_instance_valid(slot_ui):
			slot_ui.update_ui()
	_update_selected_tool()


func _on_active_slot_changed(_slot_index: int) -> void:
	_update_selected_tool()


func _update_selected_tool() -> void:
	if not inventory_data or not selected_tool_icon:
		return
	var idx = inventory_data.active_slot_index
	if idx >= 0 and idx < inventory_data.slots.size():
		var slot = inventory_data.slots[idx]
		if slot and slot.item and slot.item.icon_texture:
			selected_tool_icon.texture = slot.item.icon_texture
			return
	selected_tool_icon.texture = null
