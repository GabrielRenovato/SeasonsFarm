extends Node
class_name ToolComponent

@export_group("References")
@export var animation_tree: AnimationTree
@export var actor: CharacterBody2D
@export var grid_anchor: Marker2D
@export var debug_rect: ColorRect

@export_group("Tuning")
@export var tilled_dirt_source_id: int = 0
@export var tilled_dirt_atlas_coords: Vector2i = Vector2i(0, 0)

const HIT_EFFECT_SCENE = preload("res://objects/nature/effects/hit_effect.tscn")

var dirt_layer: TileMapLayer
var state_machine: AnimationNodeStateMachinePlayback
var inventory_data: InventoryData
var is_using_tool: bool = false
var _active_tool_in_use: String = ""
var _tool_use_id: int = 0 ## Incrementa a cada uso; usado pelo watchdog para evitar liberar o uso errado
var strict_direction: Vector2 = Vector2.DOWN
var _pending_target_map_position: Vector2i = Vector2i.ZERO
var is_carrying: bool = false
var _carry_item: ItemData
var _carry_sprite: Sprite2D
var _bobbing_time: float = 0.0

var FurnitureItemScene = preload("res://objects/furniture/furniture_item.tscn")
var current_furniture_ghost: Node2D = null
var current_furniture_rotation: int = 0

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
	# Ao sair da árvore (troca de cena OU fazenda "guardada" ao entrar na casa),
	# cancela qualquer uso de ferramenta em andamento. Sem isto, o watchdog (um
	# await de timer) dispararia _on_animation_finished/_can_till com o nó fora da
	# árvore — onde get_tree() é null → crash — e o player voltaria preso na pose.
	tree_exiting.connect(_cancel_tool_use)
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
	
	match strict_direction:
		Vector2.UP:
			_carry_sprite.position = Vector2(0.0, -24.0 + bobbing_offset)
			_carry_sprite.z_index = -1
		Vector2.LEFT, Vector2.RIGHT:
			_carry_sprite.position = Vector2(0.0, -21.0 + bobbing_offset)
			_carry_sprite.z_index = 1
		_:
			_carry_sprite.position = Vector2(0.0, -20.0 + bobbing_offset)
			_carry_sprite.z_index = 1

func update_target_preview(direction: Vector2) -> void:
	_update_strict_direction(direction)

	var target_map_position: Vector2i = _get_target_map_position()
	var global_snapped: Vector2 = _cell_center_world(target_map_position)
	var tile_size := Vector2(_tile_size_px(), _tile_size_px())

	if debug_rect != null:
		debug_rect.size = tile_size
		debug_rect.global_position = global_snapped - (tile_size / 2.0)

	if current_furniture_ghost:
		current_furniture_ghost.global_position = global_snapped

func _unhandled_input(event: InputEvent) -> void:
	if not inventory_data or is_using_tool:
		return
		
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			var previous_slot = inventory_data.active_slot_index - 1
			if previous_slot < 0:
				previous_slot = 8
			inventory_data.active_slot_index = previous_slot
			get_viewport().set_input_as_handled()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			var next_slot = (inventory_data.active_slot_index + 1) % 9
			inventory_data.active_slot_index = next_slot
			get_viewport().set_input_as_handled()
		elif event.button_index == MOUSE_BUTTON_RIGHT and current_furniture_ghost:
			current_furniture_rotation = (current_furniture_rotation + 1) % 4
			current_furniture_ghost.current_rotation_index = current_furniture_rotation
			current_furniture_ghost.update_visuals()
			get_viewport().set_input_as_handled()

func handle_tool_switch() -> void:
	if FurnitureManager.is_edit_mode: return
	if not inventory_data or is_using_tool:
		return

	# Handle PC key for switching to next tool
	if Input.is_action_just_pressed("switch_tool"):
		var next_slot = (inventory_data.active_slot_index + 1) % 9
		inventory_data.active_slot_index = next_slot
		return

	# Handle Controller Right Bumper (RB)
	if Input.is_action_just_pressed("switch_tool_right"):
		var next_slot = (inventory_data.active_slot_index + 1) % 9
		inventory_data.active_slot_index = next_slot
		return

	# Handle Controller Left Bumper (LB)
	if Input.is_action_just_pressed("switch_tool_left"):
		var previous_slot = inventory_data.active_slot_index - 1
		if previous_slot < 0:
			previous_slot = 8
		inventory_data.active_slot_index = previous_slot
		return

	# Handle number keys (1 to 9)
	for iterator_index in range(9):
		var key_code = KEY_1 + iterator_index
		
		if Input.is_key_pressed(key_code):
			inventory_data.active_slot_index = iterator_index
			return

func _on_slot_changed(_index: int) -> void:
	# Ignora se a fazenda estiver "guardada" (fora da árvore, player na casa): o
	# inventário é compartilhado, então este sinal também chega ao player parado.
	if not is_inside_tree():
		return
	if not inventory_data or is_using_tool:
		return
	var item = inventory_data.get_active_item()
	var should_carry = item != null and not item.is_tool and not item.is_furniture
	
	_update_furniture_ghost(item)
	
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

func _update_furniture_ghost(item: ItemData) -> void:
	if not FurnitureManager.enabled:
		return
	if current_furniture_ghost:
		current_furniture_ghost.queue_free()
		current_furniture_ghost = null
		
	if item and item.is_furniture:
		var item_id = item.furniture_id
		if FurnitureManager.catalog.has(item_id):
			current_furniture_ghost = FurnitureItemScene.instantiate()
			current_furniture_ghost.item_id = item_id
			current_furniture_ghost.is_placed = false
			current_furniture_ghost.current_rotation_index = current_furniture_rotation
			
			var item_data = FurnitureManager.catalog[item_id]
			var tex = AtlasTexture.new()
			tex.atlas = load(item_data["texture_path"])
			
			var parent = get_tree().current_scene
			if parent.has_node("FurnitureContainer"):
				parent.get_node("FurnitureContainer").add_child(current_furniture_ghost)
			else:
				parent.add_child(current_furniture_ghost)
				
			current_furniture_ghost.set_texture(tex)
			current_furniture_ghost.update_visuals()

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
		# Não tenta usar a ferramenta ou item se estiver perto de uma porta interativa,
		# deixando a porta usar o input em _unhandled_input.
		if _is_near_door():
			return
			
		var target_map_position: Vector2i = _get_target_map_position()
		
		# If holding furniture, place it
		if current_furniture_ghost and current_furniture_ghost.can_place:
			current_furniture_ghost.place()
			current_furniture_ghost = null
			
			var current_slot = inventory_data.slots[inventory_data.active_slot_index]
			current_slot.quantity -= 1
			if current_slot.quantity <= 0:
				current_slot.item = null
			inventory_data.inventory_updated.emit()
			_update_furniture_ghost(inventory_data.get_active_item())
			return
			
		# Pick up furniture if looking at one and holding an empty hand or tool
		if _attempt_pickup_furniture():
			return
		
		if FarmManager and FarmManager.farm_data.has(target_map_position):
			var tile_data = FarmManager.farm_data[target_map_position]
			if tile_data.crop_id != "":
				var crop_node = tile_data.crop_node
				if is_instance_valid(crop_node) and crop_node.has_method("is_fully_grown") and crop_node.is_fully_grown():
					if PlayerStatsManager and PlayerStatsManager.energy <= 0:
						return
					if PlayerStatsManager:
						PlayerStatsManager.consume_energy(PlayerStatsManager.tool_energy_cost)
					is_using_tool = true
					_active_tool_in_use = "Harvest"
					_pending_target_map_position = target_map_position
					animation_tree.set("parameters/Sickle/blend_position", strict_direction)
					state_machine.travel("Sickle")
					_tool_use_id += 1
					_start_tool_use_watchdog(_tool_use_id)
					return
		
		var tool_name = get_current_tool()
		
		if tool_name == "FishCast":
			if PlayerStatsManager and PlayerStatsManager.energy <= 0:
				return
			
			var fishing = actor.get_node_or_null("FishingComponent")
			if fishing:
				# Tenta iniciar a pesca; se falhar (ex: não está olhando pra água), não faz nada
				var success = fishing.start_fishing(strict_direction, target_map_position)
				if success:
					if PlayerStatsManager:
						PlayerStatsManager.consume_energy(PlayerStatsManager.tool_energy_cost)
					is_using_tool = true
					_active_tool_in_use = "FishCast"
			return
		
		if tool_name != "":
			if PlayerStatsManager and PlayerStatsManager.energy <= 0:
				return
			if PlayerStatsManager:
				PlayerStatsManager.consume_energy(PlayerStatsManager.tool_energy_cost)
			is_using_tool = true
			_active_tool_in_use = tool_name
			_pending_target_map_position = target_map_position
			
			animation_tree.set("parameters/" + tool_name + "/blend_position", strict_direction)
			state_machine.travel(tool_name)
			_tool_use_id += 1
			_start_tool_use_watchdog(_tool_use_id)
		
		else:
			_attempt_planting()

func _attempt_pickup_furniture() -> bool:
	if not FurnitureManager.enabled:
		return false
	var space_state = actor.get_world_2d().direct_space_state
	# Alcance de coleta de móvel: ~1,4 tile à frente dos pés do player.
	var hit_origin: Vector2 = actor.global_position + strict_direction * 22.0
	var shape_circle = CircleShape2D.new()
	shape_circle.radius = 12.0
	var physics_query = PhysicsShapeQueryParameters2D.new()
	physics_query.shape = shape_circle
	physics_query.transform = Transform2D(0.0, hit_origin)
	physics_query.collide_with_areas = false
	physics_query.collide_with_bodies = true
	physics_query.collision_mask = 4

	var query_results = space_state.intersect_shape(physics_query, 1)
	for result in query_results:
		var obj = result.collider
		if not obj.has_method("pickup"):
			continue
		var fid = obj.item_id

		if FurnitureManager.is_edit_mode:
			obj.pickup()
			obj.queue_free()
			var res_path = "res://systems/inventory/items/furniture_" + fid + ".tres"
			if FileAccess.file_exists(res_path):
				inventory_data.add_item(load(res_path), 1)
			else:
				var new_item = ItemData.new()
				new_item.id = "furniture_" + fid
				new_item.name = FurnitureManager.catalog[fid]["name"]
				new_item.is_furniture = true
				new_item.furniture_id = fid
				inventory_data.add_item(new_item, 1)
			return true

		# Modo normal: sentar em cadeiras independente do item na mão
		if fid.begins_with("chair"):
			var rot := int(obj.current_rotation_index)
			var dir_str := "down"
			match rot:
				1: dir_str = "right"
				2: dir_str = "up"
				3: dir_str = "left"
			actor.sit_down(obj, dir_str)
			return true

	return false

# Retorna true se o player está na mesma área de uma porta interativa.
# Return true if the player is in the same area as an interactive door.
func _is_near_door() -> bool:
	var doors = get_tree().get_nodes_in_group("door")
	for door in doors:
		if door is Area2D and door.overlaps_body(actor):
			return true
	return false

func _active_layer() -> TileMapLayer:
	if dirt_layer != null and is_instance_valid(dirt_layer):
		return dirt_layer
	var scene := get_tree().current_scene
	if scene:
		var layers := scene.find_children("*", "TileMapLayer")
		if layers.size() > 0:
			return layers[0] as TileMapLayer
	return null

func _tile_size_px() -> float:
	var layer := _active_layer()
	if layer != null and layer.tile_set != null:
		return float(layer.tile_set.tile_size.x)
	return 16.0

# Centro, em coordenadas globais, da célula informada. Origem única usada por preview,
# arado e golpe de ferramenta — garante que tudo aponte para a MESMA célula.
func _cell_center_world(cell: Vector2i) -> Vector2:
	var layer := _active_layer()
	if layer != null and layer.tile_set != null:
		return layer.to_global(layer.map_to_local(cell))
	var t := _tile_size_px()
	return Vector2(cell.x * t + t / 2.0, cell.y * t + t / 2.0)

# Célula onde o player está, ancorada no GridAnchor (origem canônica já calibrada).
func _player_cell() -> Vector2i:
	var origin: Vector2 = grid_anchor.global_position if grid_anchor != null else actor.global_position
	var layer := _active_layer()
	if layer != null and layer.tile_set != null:
		return layer.local_to_map(layer.to_local(origin))
	var t := _tile_size_px()
	return Vector2i(floori(origin.x / t), floori(origin.y / t))

# Célula imediatamente à frente do player, na direção cardinal atual.
func _target_cell() -> Vector2i:
	return _player_cell() + Vector2i(int(strict_direction.x), int(strict_direction.y))

func _get_target_map_position() -> Vector2i:
	if grid_anchor == null:
		return Vector2i.ZERO
	return _target_cell()

# Consulta física centrada na célula informada. include_areas pega também as Area2D
# (mudas que só têm hitbox de área, sem corpo sólido); size_mult amplia o shape além do
# tile para tolerar hitboxes ancoradas na base do objeto (deslocadas para baixo da
# célula lógica).
func _query_in_cell(cell: Vector2i, size_mult: float, include_areas: bool) -> Array:
	if actor == null:
		return []
	var space_state := actor.get_world_2d().direct_space_state
	var t := _tile_size_px()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(t, t) * size_mult
	var physics_query := PhysicsShapeQueryParameters2D.new()
	physics_query.shape = shape
	physics_query.transform = Transform2D(0.0, _cell_center_world(cell))
	physics_query.collide_with_areas = include_areas
	physics_query.collide_with_bodies = true
	physics_query.exclude = [actor.get_rid()]
	return space_state.intersect_shape(physics_query, 8)

# Objeto atacável (com take_damage) que OCUPA a célula mirada. Faz uma consulta de física
# num shape 1,5x o tile (pega árvores grandes, médias, mudas e pedras de qualquer direção)
# e, para cada candidato, calcula a CÉLULA-DONA dele e exige que seja a célula mirada.
# Isso resolve na raiz o bug do alvo errado: antes ordenávamos por distância (ao centro da
# célula OU ao player) e, como a base do tronco fica a meio-tile do centro — bem na
# FRONTEIRA entre duas células —, árvores vizinhas empatavam e a grande às vezes "perdia"
# para uma média/muda ao lado, tocando a animação errada.
func _get_attackable_in_cell(cell: Vector2i) -> Node:
	var layer := _active_layer()
	var cell_center := _cell_center_world(cell)
	var half_tile := _tile_size_px() * 0.5
	var max_distance := _tile_size_px() * 0.9

	# Preferimos sempre o objeto cuja célula-dona É a mirada. Só caímos no "fallback" (o
	# mais próximo do centro, dentro de ~1 tile) quando NENHUM candidato ocupa exatamente a
	# célula — ex.: objeto desalinhado do grid (árvore nascida por dispersão de semente) ou
	# árvore atingida pela célula de baixo.
	var exact_target: Node = null
	var exact_distance := INF
	var fallback_target: Node = null
	var fallback_distance := INF

	for collision_result in _query_in_cell(cell, 1.5, true):
		var hit_object = collision_result.collider
		if not is_instance_valid(hit_object):
			continue
		var target_node = hit_object
		if hit_object is Area2D:
			target_node = hit_object.get_parent()
		if not is_instance_valid(target_node):
			continue
		if target_node == actor or target_node.is_ancestor_of(actor):
			continue
		if not target_node.has_method("take_damage"):
			continue

		var base_pos: Vector2 = target_node.global_position
		var dist_center := base_pos.distance_to(cell_center)

		# Célula-dona do objeto. A base do tronco fica ~meio-tile ABAIXO do centro da célula
		# (offset visual), logo na FRONTEIRA com a célula de baixo — mapear a base direto a
		# atribuiria à célula errada de forma instável. Subtraímos meio-tile para trazer o
		# ponto de volta ao centro da célula real antes de mapear.
		var owner_cell := cell
		if layer != null:
			owner_cell = layer.local_to_map(layer.to_local(base_pos) - Vector2(0, half_tile))

		if owner_cell == cell:
			# Desempate estável entre objetos na MESMA célula (raro): o mais próximo do
			# centro. Não depende da ordem da física nem da posição do player.
			if dist_center < exact_distance:
				exact_distance = dist_center
				exact_target = target_node
		elif dist_center <= max_distance:
			if dist_center < fallback_distance:
				fallback_distance = dist_center
				fallback_target = target_node

	return exact_target if exact_target != null else fallback_target

func _hit_objects_in_direction(tool_name: String) -> void:
	var best_target := _get_attackable_in_cell(_pending_target_map_position)

	if best_target != null:
		best_target.take_damage(1, actor.global_position, tool_name)

		if tool_name == "Pickaxe":
			var effect_instance = HIT_EFFECT_SCENE.instantiate()
			actor.get_parent().add_child(effect_instance)
			effect_instance.global_position = _cell_center_world(_pending_target_map_position)

	_flash_debug_rect(Color.GREEN if best_target != null else Color.RED)

func _flash_debug_rect(flash_color: Color) -> void:
	if debug_rect == null:
		return
	var original_color = debug_rect.color
	debug_rect.color = flash_color
	await get_tree().create_timer(0.1).timeout
	debug_rect.color = original_color

# Cancela o uso de ferramenta em andamento (chamado ao sair da árvore).
func _cancel_tool_use() -> void:
	is_using_tool = false
	_active_tool_in_use = ""

func _on_animation_finished(_animation_name: StringName) -> void:
	# Defesa: callbacks (watchdog/animation_finished) não devem agir com o nó fora
	# da árvore, onde get_tree() (usado em _can_till/_hit_objects) seria null.
	if not is_inside_tree():
		return
	if not is_using_tool:
		return

	var tool_used := _active_tool_in_use

	if tool_used == "FishCast":
		var fishing = actor.get_node_or_null("FishingComponent")
		if fishing:
			fishing.on_animation_finished(_animation_name)
		return

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
		if FarmManager and _can_till(_pending_target_map_position):
			FarmManager.till_soil(_pending_target_map_position)
	elif tool_used == "Water":
		if FarmManager:
			FarmManager.water_soil(_pending_target_map_position)
	elif tool_used == "Harvest":
		_do_harvest(_pending_target_map_position)

func _current_tool_anim_length() -> float:
	# Duracao da animacao atual da ferramenta (ex: "axe_down"), usada pelo watchdog.
	var anim_player := actor.get_node_or_null("AnimationPlayer") as AnimationPlayer
	if anim_player == null:
		return 1.0
	# Colheita usa a animacao da foice (estado "Sickle")
	var prefix := "sickle" if _active_tool_in_use == "Harvest" else _active_tool_in_use.to_lower()
	var suffix := "down"
	if strict_direction == Vector2.UP: suffix = "up"
	elif strict_direction == Vector2.LEFT: suffix = "left"
	elif strict_direction == Vector2.RIGHT: suffix = "right"
	var anim_name := prefix + "_" + suffix
	if anim_player.has_animation(anim_name):
		return anim_player.get_animation(anim_name).length
	return 1.0

func _start_tool_use_watchdog(use_id: int) -> void:
	# Rede de seguranca: o sinal animation_finished do AnimationTree as vezes nao
	# dispara (hitch de frame ao derrubar a arvore / peculiaridade da state machine
	# do Godot 4), deixando o player preso na pose de bater. Garante a liberacao
	# apos a duracao da animacao, sem interferir no caso normal (idempotente).
	var timeout := _current_tool_anim_length() + 0.25
	await get_tree().create_timer(timeout).timeout
	if is_using_tool and _tool_use_id == use_id:
		_on_animation_finished(&"watchdog")

# Bloqueia o arado se a célula tiver qualquer corpo sólido (árvore, pedra, casa, cerca,
# móvel). Shape do tamanho do tile e só corpos, para não bloquear falsamente as células
# vizinhas a um objeto.
func _cell_has_obstacle(cell: Vector2i) -> bool:
	for collision_result in _query_in_cell(cell, 1.0, false):
		var obj = collision_result.collider
		if is_instance_valid(obj) and obj != actor:
			return true
	return false

# Só permite arar onde: ainda não está arado, existe chão no grupo "ground_layer", não
# há grama decorativa (Grass_layer) e não há obstáculo sólido na célula.
func _can_till(cell: Vector2i) -> bool:
	if FarmManager and FarmManager.farm_data.has(cell):
		return false
	var has_ground := false
	for layer in get_tree().get_nodes_in_group("ground_layer"):
		if layer is TileMapLayer and layer.get_cell_source_id(cell) != -1:
			has_ground = true
			break
	if not has_ground:
		return false
	var scene := get_tree().current_scene
	if scene:
		var grass := scene.get_node_or_null("Grass_layer") as TileMapLayer
		if grass != null and grass.get_cell_source_id(cell) != -1:
			return false
		# Não permite arar dentro do lago.
		var water := scene.get_node_or_null("WaterLayer") as TileMapLayer
		if water != null and water.get_cell_source_id(cell) != -1:
			return false
	if _cell_has_obstacle(cell):
		return false
	return true

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
