extends VBoxContainer
class_name InventoryMenuUI

@onready var grid_container: GridContainer = %GridContainer
@onready var close_button: Button = %CloseButton

# Tab buttons
@onready var btn_inventory: Button = %BtnInventory
@onready var btn_skills: Button = %BtnSkills
@onready var btn_relationships: Button = %BtnRelationships
@onready var btn_map: Button = %BtnMap
@onready var btn_crafting: Button = %BtnCrafting
@onready var btn_collections: Button = %BtnCollections
@onready var btn_options: Button = %BtnOptions
@onready var btn_exit: Button = %BtnExit

# Content panels
@onready var inventory_content: VBoxContainer = %InventoryContent
@onready var fallback_content: CenterContainer = %FallbackContent
@onready var fallback_label: Label = %FallbackLabel

const SLOT_UI_SCENE = preload("res://systems/inventory/ui/slot_ui.tscn")

var inventory_data: InventoryData
var active_style: StyleBox
var inactive_style: StyleBox
var hover_style: StyleBox

enum Tab { INVENTORY, SKILLS, RELATIONSHIPS, MAP, CRAFTING, COLLECTIONS, OPTIONS }
var current_tab: Tab = Tab.INVENTORY

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
	# Extract styles from existing button configurations
	active_style = btn_inventory.get_theme_stylebox("normal")
	inactive_style = btn_skills.get_theme_stylebox("normal")
	hover_style = btn_inventory.get_theme_stylebox("hover")

	# Hook up button presses
	btn_inventory.pressed.connect(func(): select_tab(Tab.INVENTORY))
	btn_skills.pressed.connect(func(): select_tab(Tab.SKILLS))
	btn_relationships.pressed.connect(func(): select_tab(Tab.RELATIONSHIPS))
	btn_map.pressed.connect(func(): select_tab(Tab.MAP))
	btn_crafting.pressed.connect(func(): select_tab(Tab.CRAFTING))
	btn_collections.pressed.connect(func(): select_tab(Tab.COLLECTIONS))
	btn_options.pressed.connect(func(): select_tab(Tab.OPTIONS))
	btn_exit.pressed.connect(func(): visible = false)
	
	if close_button:
		close_button.pressed.connect(func(): visible = false)

	# Initial UI update
	select_tab(Tab.INVENTORY)

func select_tab(tab: Tab) -> void:
	current_tab = tab
	_update_tab_buttons_styling()
	_update_content_visibility()

func _update_tab_buttons_styling() -> void:
	var tabs_buttons_map = {
		Tab.INVENTORY: btn_inventory,
		Tab.SKILLS: btn_skills,
		Tab.RELATIONSHIPS: btn_relationships,
		Tab.MAP: btn_map,
		Tab.CRAFTING: btn_crafting,
		Tab.COLLECTIONS: btn_collections,
		Tab.OPTIONS: btn_options
	}
	
	for tab_key in tabs_buttons_map:
		var button = tabs_buttons_map[tab_key] as Button
		if tab_key == current_tab:
			button.add_theme_stylebox_override("normal", active_style)
			button.add_theme_stylebox_override("focus", active_style)
		else:
			button.add_theme_stylebox_override("normal", inactive_style)
			button.add_theme_stylebox_override("focus", inactive_style)

func _update_content_visibility() -> void:
	# Hide all main content nodes first
	inventory_content.visible = false
	fallback_content.visible = false
	
	match current_tab:
		Tab.INVENTORY:
			inventory_content.visible = true
		Tab.SKILLS:
			fallback_content.visible = true
			fallback_label.text = "🔨 Habilidades\n(Tela em Desenvolvimento)"
		Tab.RELATIONSHIPS:
			fallback_content.visible = true
			fallback_label.text = "❤️ Relações\n(Tela em Desenvolvimento)"
		Tab.MAP:
			fallback_content.visible = true
			fallback_label.text = "🗺️ Mapa\n(Tela em Desenvolvimento)"
		Tab.CRAFTING:
			fallback_content.visible = true
			fallback_label.text = "⚙️ Criação\n(Tela em Desenvolvimento)"
		Tab.COLLECTIONS:
			fallback_content.visible = true
			fallback_label.text = "⭐ Coleções\n(Tela em Desenvolvimento)"
		Tab.OPTIONS:
			fallback_content.visible = true
			fallback_label.text = "🔧 Opções\n(Tela em Desenvolvimento)"
