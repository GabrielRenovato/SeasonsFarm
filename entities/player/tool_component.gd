extends Node
class_name ToolComponent

@export var animation_tree: AnimationTree
@export var actor: CharacterBody2D
@export var grid_anchor: Marker2D
@export var debug_rect: ColorRect
@export var tool_area: Area2D
@export var tilled_dirt_source_id: int = 0
@export var tilled_dirt_atlas_coords: Vector2i = Vector2i(0, 0)
@export var axe_reach: float = 14.0
@export var axe_hit_radius: float = 8.0

const HIT_EFFECT_SCENE = preload("res://objects/nature/effects/hit_effect.tscn")

var dirt_layer: TileMapLayer
var state_machine: AnimationNodeStateMachinePlayback
var inventory_data: InventoryData
var is_using_tool: bool = false
var _active_tool_in_use: String = ""
var strict_direction: Vector2 = Vector2.DOWN
var _pending_hit_direction: Vector2 = Vector2.ZERO

func setup(p_inventory_data: InventoryData) -> void:
	inventory_data = p_inventory_data

func get_current_tool() -> String:
	if inventory_data:
		var item = inventory_data.get_active_item()
		if item and item.is_tool:
			return item.tool_type
	return ""


func _ready() -> void:
	state_machine = animation_tree.get("parameters/playback")
	animation_tree.animation_finished.connect(_on_animation_finished)
	dirt_layer = get_tree().get_first_node_in_group("dirt_layer") as TileMapLayer
	
	if debug_rect != null:
		debug_rect.set_as_top_level(true)
	
	animation_tree.active = true
	state_machine.start("Idle")

func _update_strict_direction(direction: Vector2) -> void:
	if direction != Vector2.ZERO:
		if abs(direction.x) > abs(direction.y):
			strict_direction = Vector2(sign(direction.x), 0)
		elif abs(direction.y) > abs(direction.x):
			strict_direction = Vector2(0, sign(direction.y))

func update_target_preview(direction: Vector2) -> void:
	_update_strict_direction(direction)
		
	if debug_rect != null and dirt_layer != null and dirt_layer.tile_set != null:
		var target_map_position: Vector2i = _get_target_map_position()
		var tile_size: Vector2i = dirt_layer.tile_set.tile_size
		
		var local_center: Vector2 = dirt_layer.map_to_local(target_map_position)
		var top_left_local: Vector2 = local_center - (Vector2(tile_size) / 2.0)
		
		debug_rect.size = Vector2(tile_size)
		debug_rect.global_position = dirt_layer.to_global(top_left_local)

func _unhandled_input(event: InputEvent) -> void:
	if not inventory_data or is_using_tool:
		return
		
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			var prev_slot = inventory_data.active_slot_index - 1
			if prev_slot < 0:
				prev_slot = 11
			inventory_data.active_slot_index = prev_slot
			get_viewport().set_input_as_handled()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			var next_slot = (inventory_data.active_slot_index + 1) % 12
			inventory_data.active_slot_index = next_slot
			get_viewport().set_input_as_handled()

func handle_tool_switch() -> void:
	if not inventory_data or is_using_tool:
		return
		
	# Cycle with switch_tool action (Z)
	if Input.is_action_just_pressed("switch_tool"):
		var next_slot = (inventory_data.active_slot_index + 1) % 12
		inventory_data.active_slot_index = next_slot
		return

	# Support numbers 1 to 9, 0, -, = keys directly
	for i in range(12):
		var key = KEY_1 + i
		if i == 9: key = KEY_0
		elif i == 10: key = KEY_MINUS
		elif i == 11: key = KEY_EQUAL
		
		if Input.is_key_pressed(key):
			inventory_data.active_slot_index = i
			return

func handle_tool_use(direction: Vector2) -> void:
	_update_strict_direction(direction)
	
	var tool_name = get_current_tool()
	if tool_name == "":
		return # No tool selected
		
	if Input.is_action_just_pressed("use_tool") and not is_using_tool:
		is_using_tool = true
		_active_tool_in_use = tool_name
		
		# Salva a direção do golpe no momento do input — usada no fim da animação
		_pending_hit_direction = strict_direction
		
		animation_tree.set("parameters/" + tool_name + "/blend_position", strict_direction)
		state_machine.start(tool_name)
		
		# Hoe age imediatamente (muda o tile)
		if tool_name == "Hoe" and dirt_layer != null:
			var target_map_position: Vector2i = _get_target_map_position()
			dirt_layer.set_cell(target_map_position, tilled_dirt_source_id, tilled_dirt_atlas_coords)

func _get_target_map_position() -> Vector2i:
	if dirt_layer == null or dirt_layer.tile_set == null or grid_anchor == null:
		return Vector2i.ZERO
		
	var tile_size: Vector2i = dirt_layer.tile_set.tile_size
	var offset_distance: Vector2 = Vector2(strict_direction.x * tile_size.x, strict_direction.y * tile_size.y)
	var target_global_position: Vector2 = grid_anchor.global_position + offset_distance
	
	return dirt_layer.local_to_map(dirt_layer.to_local(target_global_position))

# Disparado no FIM da animação — o golpe registra quando o swing termina
func _hit_objects_in_direction() -> void:
	var space_state = actor.get_world_2d().direct_space_state
	
	var hit_origin: Vector2 = actor.global_position + _pending_hit_direction * axe_reach
	
	var shape = CircleShape2D.new()
	shape.radius = axe_hit_radius
	
	var query = PhysicsShapeQueryParameters2D.new()
	query.shape = shape
	query.transform = Transform2D(0.0, hit_origin)
	query.collide_with_areas = true
	query.collide_with_bodies = false
	query.exclude = [actor.get_rid()]
	
	var results = space_state.intersect_shape(query, 8)
	
	var hit_something := false
	for result in results:
		var hit_object = result.collider
		var target_node = hit_object
		
		if hit_object is Area2D:
			target_node = hit_object.get_parent()
		
		if target_node == actor or target_node.is_ancestor_of(actor):
			continue
		
		if target_node.has_method("take_damage"):
			target_node.take_damage(1, actor.global_position, _active_tool_in_use)
			hit_something = true
			
			if _active_tool_in_use == "Axe" or _active_tool_in_use == "Mining":
				var effect = HIT_EFFECT_SCENE.instantiate()
				actor.get_parent().add_child(effect)
				effect.global_position = hit_origin
				
			break
	
	_flash_debug_rect(Color.GREEN if hit_something else Color.RED)

func _flash_debug_rect(flash_color: Color) -> void:
	if debug_rect == null:
		return
	var original_color = debug_rect.color
	debug_rect.color = flash_color
	await get_tree().create_timer(0.1).timeout
	debug_rect.color = original_color

func _on_animation_finished(_anim_name: StringName) -> void:
	if is_using_tool:
		# Executa o golpe no FIM da animação, não no início
		if _active_tool_in_use == "Axe" or _active_tool_in_use == "Mining":
			_hit_objects_in_direction()
		
		is_using_tool = false
		_active_tool_in_use = ""
		state_machine.start("Idle")
