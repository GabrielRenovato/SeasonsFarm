extends Node
class_name ToolComponent

@export var animation_tree: AnimationTree
@export var actor: CharacterBody2D
@export var grid_anchor: Marker2D
@export var debug_rect: ColorRect
@export var tilled_dirt_source_id: int = 0
@export var tilled_dirt_atlas_coords: Vector2i = Vector2i(0, 0)

var dirt_layer: TileMapLayer
var state_machine: AnimationNodeStateMachinePlayback
var is_using_tool: bool = false
var available_tools: Array[String] = ["Hoe", "Mining", "Axe"]
var current_tool_index: int = 0
var current_tool: String = "Hoe"
var strict_direction: Vector2 = Vector2.DOWN

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

func handle_tool_switch() -> void:
	if Input.is_action_just_pressed("switch_tool") and not is_using_tool:
		current_tool_index += 1
		if current_tool_index >= available_tools.size():
			current_tool_index = 0
		current_tool = available_tools[current_tool_index]

func handle_tool_use(direction: Vector2) -> void:
	_update_strict_direction(direction)
	
	if Input.is_action_just_pressed("use_tool") and not is_using_tool:
		is_using_tool = true
		
		animation_tree.set("parameters/" + current_tool + "/blend_position", strict_direction)
		state_machine.start(current_tool)
		_execute_tool_action()

func _get_target_map_position() -> Vector2i:
	if dirt_layer == null or dirt_layer.tile_set == null or grid_anchor == null:
		return Vector2i.ZERO
		
	var tile_size: Vector2i = dirt_layer.tile_set.tile_size
	var offset_distance: Vector2 = Vector2(strict_direction.x * tile_size.x, strict_direction.y * tile_size.y)
	var target_global_position: Vector2 = grid_anchor.global_position + offset_distance
	
	return dirt_layer.local_to_map(dirt_layer.to_local(target_global_position))

func _execute_tool_action() -> void:
	var target_map_position: Vector2i = _get_target_map_position()
	
	if current_tool == "Hoe" and dirt_layer != null:
		dirt_layer.set_cell(target_map_position, tilled_dirt_source_id, tilled_dirt_atlas_coords)
	elif current_tool == "Axe" or current_tool == "Mining":
		_check_for_interactables(target_map_position)

func _check_for_interactables(map_pos: Vector2i) -> void:
	var world_pos = dirt_layer.map_to_local(map_pos)
	var space_state = actor.get_world_2d().direct_space_state
	
	var query = PhysicsPointQueryParameters2D.new()
	query.position = dirt_layer.to_global(world_pos)
	query.collide_with_areas = true
	query.collide_with_bodies = true
	
	var results = space_state.intersect_point(query)
	
	if results.is_empty():
		_flash_debug_rect(Color.RED)
	else:
		_flash_debug_rect(Color.GREEN)
		
	for result in results:
		var hit_object = result.collider
		var target_node = hit_object
		
		if hit_object is Area2D:
			target_node = hit_object.get_parent()
			
		if target_node.has_method("take_damage"):
			target_node.take_damage(1, actor.global_position, current_tool)

func _flash_debug_rect(flash_color: Color) -> void:
	if debug_rect == null:
		return
	var original_color = debug_rect.color
	debug_rect.color = flash_color
	await get_tree().create_timer(0.1).timeout
	debug_rect.color = original_color

func _on_animation_finished(_anim_name: StringName) -> void:
	if is_using_tool:
		is_using_tool = false
		state_machine.start("Idle")
