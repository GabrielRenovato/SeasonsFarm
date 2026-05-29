extends Control
class_name InventoryMenuUI

const SLOT_UI_SCENE = preload("res://systems/inventory/ui/slot_ui.tscn")

@onready var slots_root: Control = %SlotsRoot
@onready var equip_root: Control = %EquipRoot
@onready var tabs_root: Control = %TabsRoot
@onready var buttons_root: Control = %ButtonsRoot
@onready var fallback_content: CenterContainer = %FallbackContent
@onready var fallback_label: Label = %FallbackLabel

const COLOR_TAB_ACTIVE := Color(1, 1, 1, 1)
const COLOR_TAB_INACTIVE := Color(0.7, 0.7, 0.7, 1)
const TAB_SCALE_ACTIVE := Vector2(1.05, 1.05)
const TAB_ANIM_TIME := 0.14

const SLOT_COUNT := 36
const TAB_COUNT := 8
const TAB_NAMES := ["🎒 Inv", "🔨 Skill", "❤️ Rel", "🗺️ Map", "⚙️ Craft", "⭐ Coll", "🔧 Set", "ℹ️ Info"]

var inventory_data: InventoryData
var tab_buttons: Array[Button] = []
var _tab_tween: Tween

enum Tab { INVENTORY, SKILLS, RELATIONSHIPS, MAP, CRAFTING, COLLECTIONS, SETTINGS, INFO }
var current_tab: Tab = Tab.INVENTORY

func _ready() -> void:
	_build_tabs()
	_build_equipment_slots()
	_build_side_buttons()
	_apply_tab_states(false)
	select_tab(Tab.INVENTORY)

func setup(p_inventory_data: InventoryData) -> void:
	inventory_data = p_inventory_data
	if inventory_data.inventory_updated.is_connected(update_slots):
		inventory_data.inventory_updated.disconnect(update_slots)
	inventory_data.inventory_updated.connect(update_slots)

	for child in slots_root.get_children():
		child.queue_free()

	for i in range(SLOT_COUNT):
		var slot_ui = SLOT_UI_SCENE.instantiate()
		slots_root.add_child(slot_ui)
		slot_ui.setup(inventory_data, i)

func update_slots() -> void:
	for slot_ui in slots_root.get_children():
		if is_instance_valid(slot_ui):
			slot_ui.update_ui()

func _build_tabs() -> void:
	tab_buttons.clear()
	for i in range(TAB_COUNT):
		var btn := Button.new()
		btn.text = TAB_NAMES[i]
		btn.custom_minimum_size = Vector2(0, 18)
		btn.add_theme_font_size_override("font_size", 8)
		
		# Adiciona uma cor quente que combina com o papel
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color(0.8, 0.6, 0.3, 1)
		sb.border_width_bottom = 2
		sb.border_color = Color(0.6, 0.4, 0.2, 1)
		btn.add_theme_stylebox_override("normal", sb)

		var idx := i
		btn.pressed.connect(func(): select_tab(idx))
		tabs_root.add_child(btn)
		tab_buttons.append(btn)

func _build_equipment_slots() -> void:
	for child in equip_root.get_children():
		child.queue_free()
	for i in range(6):
		var cell := Panel.new()
		cell.custom_minimum_size = Vector2(18, 18)
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color(0.6, 0.4, 0.2, 0.8)
		cell.add_theme_stylebox_override("panel", sb)
		equip_root.add_child(cell)

func _build_side_buttons() -> void:
	for child in buttons_root.get_children():
		child.queue_free()
	var btn_x := _make_button("Close")
	btn_x.pressed.connect(func(): visible = false)
	_make_button("Help")
	_make_button("Sort")
	_make_button("Trash")

func _make_button(label: String) -> Button:
	var b := Button.new()
	b.text = label
	b.custom_minimum_size = Vector2(30, 18)
	b.add_theme_font_size_override("font_size", 8)
	
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.5, 0.3, 0.1, 1)
	sb.corner_radius_top_left = 2
	sb.corner_radius_top_right = 2
	sb.corner_radius_bottom_right = 2
	sb.corner_radius_bottom_left = 2
	b.add_theme_stylebox_override("normal", sb)
	
	buttons_root.add_child(b)
	return b

func select_tab(tab: Tab) -> void:
	current_tab = tab
	_apply_tab_states(true)
	_update_content_visibility()

func _apply_tab_states(animate: bool) -> void:
	if _tab_tween and _tab_tween.is_valid():
		_tab_tween.kill()
	if animate:
		_tab_tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	for i in range(tab_buttons.size()):
		var btn := tab_buttons[i]
		var is_active := i == current_tab
		var target_scale := TAB_SCALE_ACTIVE if is_active else Vector2.ONE
		var target_mod := COLOR_TAB_ACTIVE if is_active else COLOR_TAB_INACTIVE
		btn.z_index = 1 if is_active else 0
		if animate:
			_tab_tween.tween_property(btn, "scale", target_scale, TAB_ANIM_TIME)
			_tab_tween.tween_property(btn, "self_modulate", target_mod, TAB_ANIM_TIME)
		else:
			btn.scale = target_scale
			btn.self_modulate = target_mod

func _update_content_visibility() -> void:
	slots_root.visible = current_tab == Tab.INVENTORY
	fallback_content.visible = current_tab != Tab.INVENTORY
	var texts = ["", "Skills", "Relationships", "Map", "Crafting", "Collections", "Settings", "Info"]
	fallback_label.text = texts[current_tab] + "\n(Development)"
