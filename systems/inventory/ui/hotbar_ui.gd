extends PanelContainer
class_name HotbarUI

# Container onde os slots da hotbar serão instanciados
@onready var slots_container: HBoxContainer = $MarginContainer/HBoxContainer

# Cena do slot individual
const SLOT_UI_SCENE = preload("res://systems/inventory/ui/slot_ui.tscn")

# Dados do inventário
var inventory_data: InventoryData

# Configura a hotbar com os dados do inventário
func setup(p_inventory_data: InventoryData) -> void:
	inventory_data = p_inventory_data
	
	# Desconecta sinais antigos para evitar duplicação caso setup seja chamado de novo
	if inventory_data.inventory_updated.is_connected(update_slots):
		inventory_data.inventory_updated.disconnect(update_slots)
	if inventory_data.active_slot_changed.is_connected(update_selection):
		inventory_data.active_slot_changed.disconnect(update_selection)
		
	# Conecta os sinais para atualizar a hotbar quando o inventário mudar
	inventory_data.inventory_updated.connect(update_slots)
	inventory_data.active_slot_changed.connect(update_selection)
	
	# Limpa slots antigos
	for child in slots_container.get_children():
		child.queue_free()
	
	# Cria 12 slots para a hotbar
	for i in range(12):
		var slot_ui = SLOT_UI_SCENE.instantiate()
		slot_ui.show_background = false
		slots_container.add_child(slot_ui)
		slot_ui.setup(inventory_data, i)
		
	# Atualiza qual slot está selecionado atualmente
	update_selection(inventory_data.active_slot_index)

# Atualiza visualmente todos os slots da hotbar
func update_slots() -> void:
	for slot_ui in slots_container.get_children():
		if is_instance_valid(slot_ui):
			slot_ui.update_ui()

# Atualiza o destaque visual do slot selecionado
func update_selection(active_index: int) -> void:
	var children = slots_container.get_children()
	for i in range(children.size()):
		var slot_ui = children[i] as SlotUI
		if is_instance_valid(slot_ui):
			slot_ui.set_active(i == active_index)
