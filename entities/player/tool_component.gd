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
var _pending_target_map_position: Vector2i = Vector2i.ZERO
var is_carrying: bool = false
var _carry_item: ItemData
var _carry_sprite: Sprite2D
var _bobbing_time: float = 0.0

func setup(new_inventory_data: InventoryData) -> void:
	inventory_data = new_inventory_data
	inventory_data.active_slot_changed.connect(_on_slot_changed)

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
	
	var animation_player = actor.get_node_or_null("AnimationPlayer") as AnimationPlayer
	if animation_player:
		for direction_name in ["down", "right", "up", "left"]:
			var animation_name = "carry_" + direction_name
			if animation_player.has_animation(animation_name):
				var animation_reference = animation_player.get_animation(animation_name)
				animation_reference.loop_mode = Animation.LOOP_LINEAR
	
	animation_tree.active = true
	state_machine.travel("Idle")
	
	_carry_sprite = Sprite2D.new()
	_carry_sprite.name = "CarrySprite"
	_carry_sprite.visible = false
	actor.call_deferred("add_child", _carry_sprite)

func _process(delta: float) -> void:
	if is_carrying and _carry_sprite != null:
		if actor.velocity.length() > 0.0:
			_bobbing_time += delta * 15.0
			_update_carry_sprite_position()
		elif _bobbing_time != 0.0:
			_bobbing_time = 0.0
			_update_carry_sprite_position()

func _update_strict_direction(direction: Vector2) -> void:
	if direction != Vector2.ZERO:
		if abs(direction.x) > abs(direction.y):
			strict_direction = Vector2(sign(direction.x), 0)
		elif abs(direction.y) > abs(direction.x):
			strict_direction = Vector2(0, sign(direction.y))
	if is_carrying:
		animation_tree.set("parameters/CarryWalk/blend_position", strict_direction)
		animation_tree.set("parameters/CarryIdle/blend_position", strict_direction)
		_update_carry_sprite_position()

func _update_carry_sprite_position() -> void:
	if _carry_sprite == null or not is_carrying:
		return
		
	var bobbing_offset: float = 0.0
	if actor.velocity.length() > 0.0:
		bobbing_offset = round(sin(_bobbing_time) * 2.0)
	
	if strict_direction == Vector2.UP:
		_carry_sprite.position = Vector2(0.0, -24.0 + bobbing_offset)
		_carry_sprite.z_index = -1
	elif strict_direction == Vector2.DOWN:
		_carry_sprite.position = Vector2(0.0, -20.0 + bobbing_offset)
		_carry_sprite.z_index = 1
	elif strict_direction == Vector2.LEFT:
		_carry_sprite.position = Vector2(0.0, -21.0 + bobbing_offset)
		_carry_sprite.z_index = 1
	elif strict_direction == Vector2.RIGHT:
		_carry_sprite.position = Vector2(0.0, -21.0 + bobbing_offset)
		_carry_sprite.z_index = 1
	else:
		_carry_sprite.position = Vector2(0.0, -20.0 + bobbing_offset)
		_carry_sprite.z_index = 1

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
			var previous_slot = inventory_data.active_slot_index - 1
			if previous_slot < 0:
				previous_slot = 11
			inventory_data.active_slot_index = previous_slot
			get_viewport().set_input_as_handled()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			var next_slot = (inventory_data.active_slot_index + 1) % 12
			inventory_data.active_slot_index = next_slot
			get_viewport().set_input_as_handled()

func handle_tool_switch() -> void:
	if not inventory_data or is_using_tool:
		return
		
	if Input.is_action_just_pressed("switch_tool"):
		var next_slot = (inventory_data.active_slot_index + 1) % 12
		inventory_data.active_slot_index = next_slot
		return

	for iterator_index in range(12):
		var key_code = KEY_1 + iterator_index
		if iterator_index == 9: key_code = KEY_0
		elif iterator_index == 10: key_code = KEY_MINUS
		elif iterator_index == 11: key_code = KEY_EQUAL
		
		if Input.is_key_pressed(key_code):
			inventory_data.active_slot_index = iterator_index
			return

func _on_slot_changed(_index: int) -> void:
	if not inventory_data or is_using_tool:
		return
	var item = inventory_data.get_active_item()
	var should_carry = item != null and not item.is_tool
	if should_carry != is_carrying:
		is_carrying = should_carry
		if is_carrying:
			_carry_item = item
			_show_carry_sprite(item)
			animation_tree.set("parameters/CarryWalk/blend_position", strict_direction)
			animation_tree.set("parameters/CarryIdle/blend_position", strict_direction)
			state_machine.travel("CarryIdle")
		else:
			_hide_carry_sprite()
			_carry_item = null
			state_machine.travel("Idle")
	elif is_carrying and item != _carry_item:
		_carry_item = item
		_show_carry_sprite(item)

func _show_carry_sprite(item: ItemData) -> void:
	if _carry_sprite == null or item == null:
		return
	_carry_sprite.texture = item.icon_texture
	_carry_sprite.hframes = 1
	_carry_sprite.vframes = 1
	_carry_sprite.frame = 0
	_carry_sprite.scale = Vector2(0.8, 0.8)
	_update_carry_sprite_position()
	_carry_sprite.visible = true

func _hide_carry_sprite() -> void:
	if _carry_sprite == null:
		return
	_carry_sprite.visible = false

func handle_tool_use(direction: Vector2) -> void:
	_update_strict_direction(direction)
	
	if Input.is_action_just_pressed("use_tool") and not is_using_tool:
		var target_map_position: Vector2i = _get_target_map_position()
		
		if FarmManager and FarmManager.farm_data.has(target_map_position):
			var tile_data = FarmManager.farm_data[target_map_position]
			if tile_data.crop_id != "":
				var crop_node = tile_data.crop_node
				if is_instance_valid(crop_node) and crop_node.has_method("is_fully_grown") and crop_node.is_fully_grown():
					if PlayerStatsManager and PlayerStatsManager.energy <= 0:
						return
					if PlayerStatsManager:
						PlayerStatsManager.consume_energy(2.0)
					is_using_tool = true
					_active_tool_in_use = "Harvest"
					_pending_target_map_position = target_map_position
					animation_tree.set("parameters/Sickle/blend_position", strict_direction)
					state_machine.travel("Sickle")
					return
		
		var tool_name = get_current_tool()
		
		if tool_name != "":
			if PlayerStatsManager and PlayerStatsManager.energy <= 0:
				return
			if PlayerStatsManager:
				PlayerStatsManager.consume_energy(2.0)
			is_using_tool = true
			_active_tool_in_use = tool_name
			_pending_hit_direction = strict_direction
			_pending_target_map_position = target_map_position
			
			animation_tree.set("parameters/" + tool_name + "/blend_position", strict_direction)
			state_machine.travel(tool_name)
		
		else:
			_attempt_planting()

func _get_target_map_position() -> Vector2i:
	if dirt_layer == null or dirt_layer.tile_set == null or grid_anchor == null:
		return Vector2i.ZERO
		
	var tile_size: Vector2i = dirt_layer.tile_set.tile_size
	var offset_distance: Vector2 = Vector2(strict_direction.x * tile_size.x, strict_direction.y * tile_size.y)
	var target_global_position: Vector2 = grid_anchor.global_position + offset_distance
	
	return dirt_layer.local_to_map(dirt_layer.to_local(target_global_position))

func _hit_objects_in_direction(tool_name: String) -> void:
	var space_state = actor.get_world_2d().direct_space_state

	var hit_origin: Vector2 = actor.global_position + _pending_hit_direction * axe_reach

	var shape_circle = CircleShape2D.new()
	shape_circle.radius = axe_hit_radius

	var physics_query = PhysicsShapeQueryParameters2D.new()
	physics_query.shape = shape_circle
	physics_query.transform = Transform2D(0.0, hit_origin)
	physics_query.collide_with_areas = true
	physics_query.collide_with_bodies = false
	physics_query.exclude = [actor.get_rid()]

	var query_results = space_state.intersect_shape(physics_query, 8)

	var hit_something := false
	for collision_result in query_results:
		var hit_object = collision_result.collider
		# Ignora colliders de objetos que já estão sendo liberados (ex: árvore caindo)
		if not is_instance_valid(hit_object):
			continue

		var target_node = hit_object
		if hit_object is Area2D:
			target_node = hit_object.get_parent()

		if not is_instance_valid(target_node):
			continue
		if target_node == actor or target_node.is_ancestor_of(actor):
			continue

		if target_node.has_method("take_damage"):
			target_node.take_damage(1, actor.global_position, tool_name)
			hit_something = true

			if tool_name == "Pickaxe":
				var effect_instance = HIT_EFFECT_SCENE.instantiate()
				actor.get_parent().add_child(effect_instance)
				effect_instance.global_position = hit_origin

			break

	_flash_debug_rect(Color.GREEN if hit_something else Color.RED)

func _flash_debug_rect(flash_color: Color) -> void:
	if debug_rect == null:
		return
	var original_color = debug_rect.color
	debug_rect.color = flash_color
	await get_tree().create_timer(0.1).timeout
	debug_rect.color = original_color

func _on_animation_finished(_animation_name: StringName) -> void:
	if not is_using_tool:
		return

	var tool_used := _active_tool_in_use

	# Libera o estado ANTES de executar a ação: se a ação falhar/erro,
	# o player não fica preso na pose da ferramenta.
	is_using_tool = false
	_active_tool_in_use = ""

	if is_carrying:
		_show_carry_sprite(_carry_item)
		state_machine.travel("CarryIdle")
	else:
		state_machine.travel("Idle")

	if tool_used == "Axe" or tool_used == "Pickaxe":
		_hit_objects_in_direction(tool_used)
	elif tool_used == "Hoe":
		if FarmManager:
			FarmManager.till_soil(_pending_target_map_position)
	elif tool_used == "Water":
		if FarmManager:
			FarmManager.water_soil(_pending_target_map_position)
	elif tool_used == "Harvest":
		_do_harvest(_pending_target_map_position)

func _attempt_planting() -> void:
	if not inventory_data:
		return
		
	var item = inventory_data.get_active_item()
	if not item or not item.is_seed:
		return
		
	var target_map_position: Vector2i = _get_target_map_position()
	
	if FarmManager and FarmManager.farm_data.has(target_map_position):
		var tile_data = FarmManager.farm_data[target_map_position]
		if tile_data.tilled and tile_data.crop_id == "":
			var crop_scene = load("res://objects/crops/crop.tscn")
			if crop_scene:
				var crop_instance = crop_scene.instantiate()
				
				dirt_layer.get_parent().add_child(crop_instance)
				
				var tile_local_center = dirt_layer.map_to_local(target_map_position)
				crop_instance.global_position = dirt_layer.to_global(tile_local_center)
				
				var success_plant = FarmManager.plant_seed(target_map_position, item.crop_type, crop_instance)
				if success_plant:
					var current_slot = inventory_data.slots[inventory_data.active_slot_index]
					current_slot.quantity -= 1
					if current_slot.quantity <= 0:
						current_slot.item = null
					inventory_data.inventory_updated.emit()

func _harvest_crop_at(target_position: Vector2i) -> void:
	if not FarmManager or not inventory_data:
		return
		
	var crop_identifier = FarmManager.harvest_crop(target_position)
	if crop_identifier != "":
		var new_item = ItemData.new()
		new_item.id = crop_identifier
		
		var items_sprite_sheet = load("res://assets/sprites/ui/items.png")
		if crop_identifier == "tomato":
			new_item.name = "Tomate"
			new_item.icon_color = Color(1.0, 1.0, 1.0)
			new_item.icon_texture = inventory_data._get_item_frame(items_sprite_sheet, 1)
		elif crop_identifier == "turnip":
			new_item.name = "Nabo"
			new_item.icon_color = Color(1.0, 1.0, 1.0)
			new_item.icon_texture = inventory_data._get_item_frame(items_sprite_sheet, 7)
			
		inventory_data.add_item(new_item, 1)

func _roll_rarity() -> String:
	var r = randf()
	if r < 0.05: return "gold"
	elif r < 0.30: return "silver"
	else: return "common"

func _get_crop_harvest_icon(crop_id: String, rarity: String = "common") -> Texture2D:
	if not FarmManager:
		return null
	var config = FarmManager.CROP_CONFIGS.get(crop_id, {})
	if config.is_empty():
		return null
	var all_crops = load("res://assets/sprites/crops/All Crops.png") as Texture2D
	if all_crops == null:
		return null
	# All Crops.png layout por linha de crop:
	# col +0 = seed bag pequena, +1 = seed bag colorida
	# col +2 = common, +3 = silver (estrela branca), +4 = gold (estrela dourada)
	var seed_x: int = config.get("seed_x", 0)
	var seed_y: int = config.get("seed_y", 0)
	var rarity_col = {"common": 2, "silver": 3, "gold": 4}.get(rarity, 2)
	var atlas = AtlasTexture.new()
	atlas.atlas = all_crops
	atlas.region = Rect2(seed_x + rarity_col * 16, seed_y, 16, 16)
	return atlas

func _do_harvest(target_position: Vector2i) -> void:
	if not FarmManager or not inventory_data:
		return

	var crop_id = FarmManager.harvest_crop(target_position)
	if crop_id != "":
		var config = FarmManager.CROP_CONFIGS.get(crop_id, {})
		var rarity = _roll_rarity()
		var new_item = ItemData.new()
		new_item.id = crop_id
		new_item.rarity = rarity
		new_item.name = config.get("name", crop_id)
		new_item.icon_color = Color.WHITE
		new_item.icon_texture = _get_crop_harvest_icon(crop_id, rarity)

		inventory_data.add_item(new_item, 1)
