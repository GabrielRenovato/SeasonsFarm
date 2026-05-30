extends Control
class_name InventoryMenuUI

const SLOT_UI_SCENE = preload("res://systems/inventory/ui/slot_ui.tscn")

# Hotbar/ferramentas (índices 0-11) ficam na página esquerda
const HOTBAR_START := 0
const HOTBAR_COUNT := 12  # 3 colunas × 4 linhas

# Slots do inventário principal (índices 12-35) ficam na página direita
const MAIN_INV_START := 12
const MAIN_INV_COUNT := 24  # 6 colunas × 4 linhas

@onready var slots_root: Control = %SlotsRoot
@onready var equip_root: Control = %EquipRoot
@onready var fallback_content: CenterContainer = %FallbackContent
@onready var fallback_label: Label = %FallbackLabel

# Mantidos para compatibilidade mas não usados ativamente
@onready var tabs_root: Control = %TabsRoot
@onready var buttons_root: Control = %ButtonsRoot

var inventory_data: InventoryData


func _ready() -> void:
	pass

func setup(p_inventory_data: InventoryData) -> void:
	inventory_data = p_inventory_data
	if inventory_data.inventory_updated.is_connected(update_slots):
		inventory_data.inventory_updated.disconnect(update_slots)
	inventory_data.inventory_updated.connect(update_slots)

	# Página esquerda: hotbar/ferramentas (slots 0-11)
	for child in equip_root.get_children():
		child.queue_free()
	for i in range(HOTBAR_START, HOTBAR_START + HOTBAR_COUNT):
		var slot_ui = SLOT_UI_SCENE.instantiate()
		equip_root.add_child(slot_ui)
		slot_ui.custom_minimum_size = Vector2(16, 16)
		slot_ui.setup(inventory_data, i)

	# Página direita: inventário principal (slots 12-35)
	for child in slots_root.get_children():
		child.queue_free()
	for i in range(MAIN_INV_START, MAIN_INV_START + MAIN_INV_COUNT):
		var slot_ui = SLOT_UI_SCENE.instantiate()
		slots_root.add_child(slot_ui)
		slot_ui.custom_minimum_size = Vector2(14, 14)
		slot_ui.setup(inventory_data, i)

func update_slots() -> void:
	for root_node in [equip_root, slots_root]:
		for slot_ui in root_node.get_children():
			if is_instance_valid(slot_ui):
				slot_ui.update_ui()
