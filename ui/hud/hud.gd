extends CanvasLayer
class_name HUD

@onready var time_label: Label = %TimeLabel
@onready var hotbar_ui: HotbarUI = $Control/HotbarUI
@onready var inventory_menu_ui: InventoryMenuUI = $Control/InventoryMenuUI

var inventory_data: InventoryData

func setup(p_inventory_data: InventoryData) -> void:
	inventory_data = p_inventory_data
	
	# Setup Hotbar and Inventory Menu
	hotbar_ui.setup(inventory_data)
	inventory_menu_ui.setup(inventory_data)
	inventory_menu_ui.visible = false # Closed by default

func _ready() -> void:
	if TimeManager:
		TimeManager.connect("time_changed", _on_time_changed)
		# Set initial time
		_update_time_display(TimeManager.day, TimeManager.hour, TimeManager.minute)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.keycode == KEY_T:
		if TimeManager:
			_update_time_display(TimeManager.day, TimeManager.hour, TimeManager.minute)
			
	if event is InputEventKey and event.pressed and event.keycode == KEY_TAB:
		toggle_inventory()
		get_viewport().set_input_as_handled()

func toggle_inventory() -> void:
	inventory_menu_ui.visible = not inventory_menu_ui.visible

func _on_time_changed(day: int, hour: int, minute: int) -> void:
	_update_time_display(day, hour, minute)

func _update_time_display(day: int, hour: int, minute: int) -> void:
	if time_label:
		var icon = "☀️" if hour >= 6 and hour < 18 else "🌙"
		if Input.is_key_pressed(KEY_T):
			icon = "⏩"
		time_label.text = "%s Dia %d | %02d:%02d" % [icon, day, hour, minute]
