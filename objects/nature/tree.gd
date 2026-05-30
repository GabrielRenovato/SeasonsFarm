extends StaticBody2D

@export var health: int = 3
@export var wood_scene: PackedScene
@export var wood_amount: int = 3
@export var fall_right_anim: String = "falling_tree"
@export var fall_left_anim: String = "falling_tree_inverted"
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var stump_scene: PackedScene = preload("res://objects/nature/stump.tscn")

var chosen_fall_anim: String = ""
var spawn_direction: float = 1.0

# Growth logic
enum GrowthStage { SEED, SPROUT, SAPLING, SMALL, FULL }
@export var current_stage: GrowthStage = GrowthStage.FULL
@export var growth_sprite_sheet: Texture2D

@onready var full_sprite: Sprite2D = $SpriteOffset/Sprite2D
@onready var growth_sprite: Sprite2D = $SpriteOffset.get_node_or_null("GrowthSprite")
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var area_collision: CollisionShape2D = $Area2D/CollisionShape2D

var is_stardew_tree: bool = false
var is_dying: bool = false

var _active_shake_tween: Tween
var _active_pos_tween: Tween
var base_frame: int = 0

func _ready() -> void:
	if full_sprite.texture != null and "Animation" in full_sprite.texture.resource_path:
		is_stardew_tree = true
		full_sprite.frame = 4
		
	base_frame = full_sprite.frame
	
	_update_appearance()

func _update_appearance() -> void:
	if current_stage == GrowthStage.FULL:
		full_sprite.visible = true
		if is_instance_valid(growth_sprite):
			growth_sprite.visible = false
		collision_shape.set_deferred("disabled", false)
		area_collision.set_deferred("disabled", false)
	else:
		full_sprite.visible = false
		if not is_instance_valid(growth_sprite):
			return
		growth_sprite.visible = true
		growth_sprite.texture = growth_sprite_sheet
		
		# The sprite sheet stages are on a 32x48 grid on the top row
		growth_sprite.hframes = 1
		growth_sprite.vframes = 1
		growth_sprite.region_enabled = true
		
		match current_stage:
			GrowthStage.SEED:
				growth_sprite.region_rect = Rect2(0, 0, 32, 48)
				collision_shape.set_deferred("disabled", true)
				area_collision.set_deferred("disabled", false)
			GrowthStage.SPROUT:
				growth_sprite.region_rect = Rect2(32, 0, 32, 48)
				collision_shape.set_deferred("disabled", true)
				area_collision.set_deferred("disabled", false)
			GrowthStage.SAPLING:
				growth_sprite.region_rect = Rect2(64, 0, 32, 48)
				collision_shape.set_deferred("disabled", false)
				area_collision.set_deferred("disabled", false)
			GrowthStage.SMALL:
				growth_sprite.region_rect = Rect2(96, 0, 32, 48)
				# Reset health quando cresce para SMALL
				if not is_dying:
					health = 2
				collision_shape.set_deferred("disabled", false)
				area_collision.set_deferred("disabled", false)

func take_damage(amount: int, hitter_position: Vector2 = Vector2.ZERO, tool_name: String = "") -> void:
	if is_dying or health <= 0:
		return
		
	if tool_name != "Axe" and tool_name != "Pickaxe" and tool_name != "Scythe":
		return
		
	# Scythe/Pickaxe only work on seeds and sprouts
	if tool_name != "Axe" and current_stage >= GrowthStage.SAPLING:
		return
		
	# Axe only works once it leaves the seed stage (sprout and above)
	if tool_name == "Axe" and current_stage == GrowthStage.SEED:
		return
		
	if current_stage < GrowthStage.SMALL:
		# Seed, Sprout, Sapling are destroyed in a single hit
		health = 0
	elif current_stage == GrowthStage.SMALL:
		# Small trees take 2 hits (set health on first hit, then decrement)
		if health > 2:
			health = 2
		health -= amount
	else:
		health -= amount
	
	if hitter_position != Vector2.ZERO:
		if hitter_position.x > global_position.x:
			chosen_fall_anim = fall_left_anim
			spawn_direction = -1.0
		else:
			chosen_fall_anim = fall_right_anim
			spawn_direction = 1.0
			
	if health > 0:
		if current_stage == GrowthStage.FULL:
			_play_stardew_shake()
		else:
			if is_instance_valid(growth_sprite):
				_play_small_shake()
	else:
		_die()

func _die() -> void:
	if is_dying:
		return
	is_dying = true
	
	# Cancela as animações de hit para não atrapalhar a animação de queda
	animation_player.stop()
	if _active_shake_tween and _active_shake_tween.is_valid():
		_active_shake_tween.kill()
	if _active_pos_tween and _active_pos_tween.is_valid():
		_active_pos_tween.kill()
		
	# Reseta o frame, rotação e opacidade para o estado normal caso o tween/anim tenha parado no meio
	if current_stage == GrowthStage.FULL:
		full_sprite.frame = base_frame
		full_sprite.modulate.a = 1.0
		$SpriteOffset.rotation_degrees = 0.0
	elif is_instance_valid(growth_sprite):
		growth_sprite.position.x = 0.0
		growth_sprite.modulate.a = 1.0

	$CollisionShape2D.set_deferred("disabled", true)
	$Area2D/CollisionShape2D.set_deferred("disabled", true)

	if current_stage == GrowthStage.FULL:
		# A queda toca PRIMEIRO; toco e madeira só nascem depois, pra nada
		# poder abortar a animação de queda no meio.
		await _play_fall_tween()
		_spawn_stump()
		_spawn_wood()
	else:
		if is_instance_valid(growth_sprite):
			if current_stage == GrowthStage.SMALL:
				_play_small_shake()
				await get_tree().create_timer(0.15).timeout
			var fade_tween = create_tween()
			fade_tween.tween_property(growth_sprite, "modulate:a", 0.0, 0.2)
			fade_tween.tween_property(growth_sprite, "scale", Vector2(1.2, 1.2), 0.2)
			await fade_tween.finished
			
		if current_stage == GrowthStage.SMALL:
			_spawn_wood(2)
		elif current_stage == GrowthStage.SAPLING or current_stage == GrowthStage.SPROUT:
			_spawn_wood(1)
	
	queue_free()

func _spawn_stump() -> void:
	if stump_scene == null:
		return
	var stump_instance = stump_scene.instantiate()
	get_parent().add_child(stump_instance)
	stump_instance.global_position = global_position

func _spawn_wood(amount_override: int = -1) -> void:
	if wood_scene == null:
		return
		
	var amount = wood_amount if amount_override == -1 else amount_override
	for i in range(amount):
		var wood_instance = wood_scene.instantiate()
		get_parent().add_child(wood_instance)
		wood_instance.global_position = global_position
		
		var random_x = randf_range(10, 50) * spawn_direction
		var random_offset = Vector2(random_x, randf_range(10, 40))
		var target_position = global_position + random_offset
		
		var duration = 0.5
		var peak_y = global_position.y - randf_range(20, 40)
		
		var x_tween = wood_instance.create_tween()
		x_tween.tween_property(wood_instance, "global_position:x", target_position.x, duration).set_trans(Tween.TRANS_LINEAR)
		
		var y_tween = wood_instance.create_tween()
		y_tween.tween_property(wood_instance, "global_position:y", peak_y, duration / 2.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		y_tween.tween_property(wood_instance, "global_position:y", target_position.y, duration / 2.0).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)

func _play_stardew_shake() -> void:
	if _active_shake_tween and _active_shake_tween.is_valid():
		_active_shake_tween.kill()
	_active_shake_tween = create_tween()
	# Usa rotação física no Node ao invés de trocar frames para evitar glitches com spritesheets diferentes
	_active_shake_tween.tween_property($SpriteOffset, "rotation_degrees", 3.0, 0.05)
	_active_shake_tween.tween_property($SpriteOffset, "rotation_degrees", -3.0, 0.1)
	_active_shake_tween.tween_property($SpriteOffset, "rotation_degrees", 0.0, 0.05)

func _play_small_shake() -> void:
	if not is_instance_valid(growth_sprite):
		return
	if _active_pos_tween and _active_pos_tween.is_valid():
		_active_pos_tween.kill()
	_active_pos_tween = create_tween()
	# Usa movimentação física ao invés de trocar region_rect para evitar exibir sprites vazios ou tocos
	_active_pos_tween.tween_property(growth_sprite, "position:x", 2.0, 0.05)
	_active_pos_tween.tween_property(growth_sprite, "position:x", -2.0, 0.1)
	_active_pos_tween.tween_property(growth_sprite, "position:x", 0.0, 0.05)

func _play_fall_tween() -> void:
	# Brief shake first
	if current_stage == GrowthStage.SMALL:
		_play_small_shake()
		
	var shake_tween = create_tween()
	shake_tween.tween_property($SpriteOffset, "position:x", 3.0 * spawn_direction, 0.05)
	shake_tween.tween_property($SpriteOffset, "position:x", -3.0 * spawn_direction, 0.1)
	shake_tween.tween_property($SpriteOffset, "position:x", 0.0, 0.05)
	await shake_tween.finished
	
	# Then fall smoothly
	var tween = create_tween().set_parallel(true)
	var target_rotation = 1.5708 * spawn_direction
	var target_position = Vector2(15.0 * spawn_direction, 6.0)
	
	tween.tween_property($SpriteOffset, "rotation", target_rotation, 0.8).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property($SpriteOffset, "position", target_position, 0.8).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	
	var fade_tween = create_tween()
	fade_tween.tween_interval(0.5)
	var active_sprite = full_sprite if current_stage == GrowthStage.FULL else growth_sprite
	if is_instance_valid(active_sprite):
		fade_tween.tween_property(active_sprite, "modulate:a", 0.0, 0.3)
	
	await tween.finished

func _spread_seed() -> void:
	if scene_file_path == "":
		return
		
	var parent = get_parent()
	if not parent:
		return
		
	var angle = randf_range(0.0, 2.0 * PI)
	var distance = randf_range(32.0, 96.0)
	var spawn_pos = global_position + Vector2(cos(angle), sin(angle)) * distance
	
	var too_close = false
	for child in parent.get_children():
		if child is StaticBody2D and child.has_method("take_damage"):
			if child.global_position.distance_to(spawn_pos) < 24.0:
				too_close = true
				break
				
	if not too_close:
		var seed_scene = load(scene_file_path)
		if seed_scene:
			var new_seed = seed_scene.instantiate()
			new_seed.current_stage = GrowthStage.SEED
			new_seed.global_position = spawn_pos
			parent.add_child(new_seed)
			print("Tree spread seed of type ", scene_file_path, " to position ", spawn_pos)
