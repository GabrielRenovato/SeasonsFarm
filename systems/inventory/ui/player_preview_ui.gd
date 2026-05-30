extends Control
class_name PlayerPreviewUI

@onready var body_sprite: Sprite2D = %Body
@onready var hair_sprite: Sprite2D = %Hair
@onready var clothes_sprite: Sprite2D = %Clothes
@onready var eyes_sprite: Sprite2D = %Eyes
@onready var tool_sprite: Sprite2D = %Tool
@onready var equipment_label: Label = %EquipmentLabel

var inventory_data: InventoryData


func _ready() -> void:
	if CustomizationManager:
		CustomizationManager.customization_changed.connect(_on_customization_changed)
	_update_preview()


func setup(p_inventory_data: InventoryData) -> void:
	inventory_data = p_inventory_data
	if inventory_data.active_slot_changed.is_connected(_on_active_slot_changed):
		inventory_data.active_slot_changed.disconnect(_on_active_slot_changed)
	inventory_data.active_slot_changed.connect(_on_active_slot_changed)
	_update_equipment_label()


func _on_customization_changed() -> void:
	_update_preview()


func _on_active_slot_changed(_slot_index: int) -> void:
	_update_equipment_label()


func _update_preview() -> void:
	# Update hair color modulation
	if CustomizationManager:
		hair_sprite.modulate = CustomizationManager.hair_color


func _update_equipment_label() -> void:
	if not inventory_data:
		return

	var active_slot_index = inventory_data.active_slot_index
	if active_slot_index >= 0 and active_slot_index < inventory_data.slots.size():
		var slot = inventory_data.slots[active_slot_index]
		if slot and slot.item:
			var item_data = slot.item
			equipment_label.text = item_data.name

			# Update tool sprite if it's a tool
			if item_data.is_tool:
				var tool_icon_path = "res://assets/sprites/icons/Weapons and Armor/1. Wood/%s.png" % item_data.tool_type
				if ResourceLoader.exists(tool_icon_path):
					tool_sprite.texture = load(tool_icon_path)
					tool_sprite.scale = Vector2(2, 2)
				else:
					tool_sprite.texture = null
			else:
				tool_sprite.texture = null
		else:
			equipment_label.text = "Nenhum equipamento"
			tool_sprite.texture = null
	else:
		equipment_label.text = "Nenhum equipamento"
		tool_sprite.texture = null
