extends Control
class_name HotbarUI

const SLOT_UI_SCENE = preload("res://systems/inventory/ui/slot_ui.tscn")

const SLOT_COUNT := 9
const SLOT_PITCH := 17
const FIRST_X := 5
const SLOT_Y := 6
const SLOT_SIZE := 16

@onready var slots_root: Control = $SlotsRoot
@onready var active_overlay: Control = %ActiveOverlay

var inventory_data: InventoryData


func setup(p_inventory_data: InventoryData) -> void:
	inventory_data = p_inventory_data

	if inventory_data.inventory_updated.is_connected(update_slots):
		inventory_data.inventory_updated.disconnect(update_slots)
	if inventory_data.active_slot_changed.is_connected(update_selection):
		inventory_data.active_slot_changed.disconnect(update_selection)

	inventory_data.inventory_updated.connect(update_slots)
	inventory_data.active_slot_changed.connect(update_selection)

	for child in slots_root.get_children():
		child.queue_free()

	for i in range(SLOT_COUNT):
		var slot_ui = SLOT_UI_SCENE.instantiate()
		slot_ui.show_background = false
		slots_root.add_child(slot_ui)
		slot_ui.setup(inventory_data, i)
		# Posiciona sobre as células embutidas do sprite da barra
		slot_ui.position = Vector2(FIRST_X + i * SLOT_PITCH, SLOT_Y)
		slot_ui.custom_minimum_size = Vector2(SLOT_SIZE, SLOT_SIZE)
		slot_ui.size = Vector2(SLOT_SIZE, SLOT_SIZE)
		# Substitui o painel escuro padrão do modo show_background=false por um vazio
		var empty := StyleBoxEmpty.new()
		slot_ui.add_theme_stylebox_override("panel", empty)
		slot_ui.add_theme_stylebox_override("hover", empty)
		slot_ui.add_theme_stylebox_override("pressed", empty)
		slot_ui.add_theme_stylebox_override("focus", empty)
		slot_ui.add_theme_stylebox_override("disabled", empty)
		# Esconde o highlight amarelo da SlotUI — usamos o overlay laranja do sprite
		if slot_ui.has_node("HighlightRect"):
			slot_ui.get_node("HighlightRect").visible = false

	update_selection(inventory_data.active_slot_index)


func update_slots() -> void:
	for slot_ui in slots_root.get_children():
		if is_instance_valid(slot_ui):
			slot_ui.update_ui()


func update_selection(active_index: int) -> void:
	if active_index < 0 or active_index >= SLOT_COUNT:
		active_overlay.visible = false
		return
	active_overlay.visible = true
	active_overlay.position = Vector2(FIRST_X + active_index * SLOT_PITCH, SLOT_Y)
