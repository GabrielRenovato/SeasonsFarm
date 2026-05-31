extends CanvasLayer

@onready var panel = $Panel
@onready var item_list = $Panel/VBoxContainer/ItemList
@onready var rotate_btn = $Panel/VBoxContainer/HBoxContainer/RotateBtn
@onready var delete_btn = $Panel/VBoxContainer/HBoxContainer/DeleteBtn
@onready var close_btn = $Panel/VBoxContainer/CloseBtn

var FurnitureItemScene = preload("res://objects/furniture/furniture_item.tscn")
var current_ghost: Node2D = null
var current_item_id: String = ""

# Snapping size. 16 is good for tiny asset pack.
@export var snap_size: int = 16

func _ready() -> void:
	panel.hide()
	FurnitureManager.edit_mode_changed.connect(_on_edit_mode_changed)
	
	rotate_btn.pressed.connect(_on_rotate_pressed)
	delete_btn.pressed.connect(_on_delete_pressed)
	close_btn.pressed.connect(_on_close_pressed)
	item_list.item_selected.connect(_on_item_selected)
	
	# Populate catalog
	for key in FurnitureManager.catalog:
		var item_data = FurnitureManager.catalog[key]
		item_list.add_item(item_data["name"])
		item_list.set_item_metadata(item_list.item_count - 1, key)

func _on_edit_mode_changed(is_editing: bool) -> void:
	if is_editing:
		panel.show()
	else:
		panel.hide()
		_clear_ghost()

func _input(event: InputEvent) -> void:
	if not FurnitureManager.is_edit_mode:
		# Toggle edit mode with a key (e.g. 'F' or something else, let's use a specific key if requested, for now we will assume the UI can be opened somehow, or we map 'F' to it here temporarily)
		if Input.is_action_just_pressed("ui_accept"): # temporary
			pass
		return
		
	if current_ghost:
		if event is InputEventMouseMotion:
			var mouse_pos = current_ghost.get_global_mouse_position()
			# Snapping logic
			mouse_pos.x = round(mouse_pos.x / snap_size) * snap_size
			mouse_pos.y = round(mouse_pos.y / snap_size) * snap_size
			current_ghost.global_position = mouse_pos
			
		elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			# Check if we didn't click on UI
			if not _is_mouse_over_ui():
				if current_ghost.can_place:
					_place_ghost()

func _is_mouse_over_ui() -> bool:
	var m_pos = get_viewport().get_mouse_position()
	return panel.get_global_rect().has_point(m_pos)

func _on_item_selected(index: int) -> void:
	var item_id = item_list.get_item_metadata(index)
	_spawn_ghost(item_id)

func _spawn_ghost(item_id: String) -> void:
	_clear_ghost()
	current_item_id = item_id
	var item_data = FurnitureManager.catalog[item_id]
	
	current_ghost = FurnitureItemScene.instantiate()
	current_ghost.item_id = item_id
	current_ghost.is_placed = false
	current_ghost.current_rotation_index = 0
	
	# Create base AtlasTexture, the region is updated in update_visuals()
	var tex = AtlasTexture.new()
	tex.atlas = load(item_data["texture_path"])
	
	var parent = get_tree().current_scene
	if parent.has_node("FurnitureContainer"):
		parent.get_node("FurnitureContainer").add_child(current_ghost)
	else:
		parent.add_child(current_ghost)
		
	current_ghost.set_texture(tex)
	current_ghost.update_visuals()

func _clear_ghost() -> void:
	if current_ghost:
		current_ghost.queue_free()
		current_ghost = null

func _place_ghost() -> void:
	if not current_ghost: return
	
	current_ghost.place()
		
	# Spawn a new ghost of the same type for rapid placement
	var old_pos = current_ghost.position
	current_ghost = null
	_spawn_ghost(current_item_id)
	current_ghost.position = old_pos

func _on_rotate_pressed() -> void:
	if current_ghost:
		current_ghost.rotate_item()

func _on_delete_pressed() -> void:
	_clear_ghost()

func _on_close_pressed() -> void:
	FurnitureManager.is_edit_mode = false
