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

@export_group("Animation Rows")
@export var big_idle_row: int = 1
## Linha (0-index) da árvore adulta em cada estação no sheet de animação.
## -1 = sem variante sazonal -> usa big_idle_row. Maple/Mahogany têm as 4
## variantes (verde/laranja/branco/verde-escuro); Pine/Birch são perenes e
## mantêm big_idle_row o ano todo.
@export var spring_row: int = -1
@export var summer_row: int = -1
@export var fall_row: int = -1
@export var winter_row: int = -1
## Árvores sem sprite de inverno (ex.: pinheiro/bétula) somem no inverno e
## voltam nas demais estações, em vez de exibir um sprite de inverno.
@export var hide_in_winter: bool = false
@onready var full_sprite: Sprite2D = $SpriteOffset/Sprite2D
@onready var growth_sprite: Sprite2D = $SpriteOffset.get_node_or_null("GrowthSprite")
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var area_collision: CollisionShape2D = $Area2D/CollisionShape2D

var is_stardew_tree: bool = false
var is_dying: bool = false

var _active_shake_tween: Tween
var _active_pos_tween: Tween
var _active_blink_tween: Tween

func _ready() -> void:
	if full_sprite.texture != null and "Animation" in full_sprite.texture.resource_path:
		is_stardew_tree = true

	# Reage à troca de estação (troca a cor da árvore adulta: outono/inverno, etc.)
	if not TimeManager.season_changed.is_connected(_on_season_changed):
		TimeManager.season_changed.connect(_on_season_changed)

	_update_appearance()

func _update_appearance() -> void:
	if current_stage == GrowthStage.FULL:
		full_sprite.visible = true
		if is_stardew_tree:
			full_sprite.frame = _get_seasonal_big_row() * full_sprite.hframes
		if is_instance_valid(growth_sprite):
			growth_sprite.visible = false
		# Reset da vida ao virar adulta (3 golpes). Sem isso, uma árvore que cresceu
		# de SMALL->FULL herdava health=2 e caía em 2 golpes (como a média).
		if not is_dying:
			health = 3
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

	# Aplica o estado de inverno por último (pode ocultar a árvore e desligar colisão)
	_apply_winter_state()

# Oculta/restaura a árvore conforme a estação. Árvores marcadas com hide_in_winter
# (sem sprite de galho seco) desaparecem do mapa no inverno e voltam nas outras
# estações. As demais ficam visíveis e mostram seu sprite sazonal normalmente.
func _apply_winter_state() -> void:
	var is_winter := TimeManager.current_season == TimeManager.Season.WINTER
	var hidden := hide_in_winter and is_winter
	visible = not hidden
	if hidden:
		collision_shape.set_deferred("disabled", true)
		area_collision.set_deferred("disabled", true)

# Retorna a linha (0-index) da árvore adulta conforme a estação atual.
# Árvores perenes (rows sazonais = -1) caem de volta em big_idle_row.
func _get_seasonal_big_row() -> int:
	match TimeManager.current_season:
		TimeManager.Season.SPRING:
			return spring_row if spring_row >= 0 else big_idle_row
		TimeManager.Season.SUMMER:
			return summer_row if summer_row >= 0 else big_idle_row
		TimeManager.Season.FALL:
			return fall_row if fall_row >= 0 else big_idle_row
		TimeManager.Season.WINTER:
			return winter_row if winter_row >= 0 else big_idle_row
	return big_idle_row

# Atualiza a árvore quando a estação muda: troca o sprite sazonal (verde ->
# laranja -> galho seco) e oculta/restaura as árvores que somem no inverno.
func _on_season_changed(_season: int) -> void:
	if is_dying:
		return
	_update_appearance()

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


	if current_stage < GrowthStage.SAPLING:
		# Mudinhas (Seed, Sprout) são destruídas em um único golpe
		health = 0
	elif current_stage == GrowthStage.SAPLING or current_stage == GrowthStage.SMALL:
		# Árvore média (Sapling/Small) leva 2 golpes: pisca no 1º, tomba no 2º
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
		# Pisca (flash branco) em qualquer estágio para um feedback de dano claro e
		# confiável, independente de o sheet ter ou não frames de balanço (ex.: a
		# bétula no outono usa frames estáticos e não "balança").
		_play_hit_blink()
		if current_stage == GrowthStage.FULL:
			_play_stardew_shake()
		elif is_instance_valid(growth_sprite):
			_play_small_shake()
	else:
		_die()

func _die() -> void:
	if is_dying:
		return
	is_dying = true
	if has_meta("env_id"):
		FarmManager.remove_env_object(get_meta("env_id"))
	
	# Cancela as animações de hit para não atrapalhar a animação de queda
	animation_player.stop()
	if _active_shake_tween and _active_shake_tween.is_valid():
		_active_shake_tween.kill()
	if _active_pos_tween and _active_pos_tween.is_valid():
		_active_pos_tween.kill()
	if _active_blink_tween and _active_blink_tween.is_valid():
		_active_blink_tween.kill()

	# Reseta frame, rotação e modulate (cor + opacidade) caso um tween/flash tenha
	# parado no meio — modulate completo para limpar também o brilho do flash de hit.
	if current_stage == GrowthStage.FULL:
		if is_stardew_tree:
			full_sprite.frame = _get_seasonal_big_row() * full_sprite.hframes
		full_sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)
		$SpriteOffset.rotation_degrees = 0.0
	elif is_instance_valid(growth_sprite):
		growth_sprite.position.x = 0.0
		growth_sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)

	$CollisionShape2D.set_deferred("disabled", true)
	$Area2D/CollisionShape2D.set_deferred("disabled", true)

	# Árvore grande (FULL) e média (SAPLING/SMALL) tombam e caem ao serem quebradas.
	# O toco só nasce da árvore grande (ver _play_fall_tween); a média cai sem toco.
	# Mudinhas (SPROUT/SEED) apenas desaparecem.
	if current_stage >= GrowthStage.SAPLING:
		# Aguarda a animação da árvore (tremida e queda) terminar
		await _play_fall_tween()

		# Só após a árvore cair completamente que a madeira deve spawnar
		if current_stage == GrowthStage.FULL:
			_spawn_wood()
		else:
			_spawn_wood(2)
	else:
		if is_instance_valid(growth_sprite):
			var fade_tween = create_tween()
			fade_tween.tween_property(growth_sprite, "modulate:a", 0.0, 0.2)
			fade_tween.tween_property(growth_sprite, "scale", Vector2(1.2, 1.2), 0.2)
			await fade_tween.finished

		if current_stage == GrowthStage.SPROUT:
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
	var height_offset = -30.0 if current_stage == GrowthStage.FULL else -15.0
	var drop_origin = global_position + Vector2(0, height_offset)
	
	for i in range(amount):
		var wood_instance = wood_scene.instantiate()
		get_parent().add_child(wood_instance)
		wood_instance.global_position = drop_origin
		
		var random_x = randf_range(10, 50) * spawn_direction
		var random_offset = Vector2(random_x, randf_range(10, 40))
		var target_position = global_position + random_offset
		
		var duration = 0.5
		var peak_y = drop_origin.y - randf_range(10, 20)
		
		var x_tween = wood_instance.create_tween()
		x_tween.tween_property(wood_instance, "global_position:x", target_position.x, duration).set_trans(Tween.TRANS_LINEAR)
		
		var y_tween = wood_instance.create_tween()
		y_tween.tween_property(wood_instance, "global_position:y", peak_y, duration / 2.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		y_tween.tween_property(wood_instance, "global_position:y", target_position.y, duration / 2.0).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)

func _play_stardew_shake() -> void:
	if _active_shake_tween and _active_shake_tween.is_valid():
		_active_shake_tween.kill()
	_active_shake_tween = create_tween()
	
	if is_instance_valid(full_sprite):
		var big_base_frame = _get_seasonal_big_row() * full_sprite.hframes
		# The hit animation for the big tree is at frame + 1, 2, 3 of its row
		_active_shake_tween.tween_callback(func(): full_sprite.frame = big_base_frame + 1)
		_active_shake_tween.tween_interval(0.08)
		_active_shake_tween.tween_callback(func(): full_sprite.frame = big_base_frame + 2)
		_active_shake_tween.tween_interval(0.08)
		_active_shake_tween.tween_callback(func(): full_sprite.frame = big_base_frame + 3)
		_active_shake_tween.tween_interval(0.08)
		_active_shake_tween.tween_callback(func(): full_sprite.frame = big_base_frame)
	else:
		_active_shake_tween.tween_property($SpriteOffset, "rotation_degrees", 3.0, 0.05)
		_active_shake_tween.tween_property($SpriteOffset, "rotation_degrees", -3.0, 0.1)
		_active_shake_tween.tween_property($SpriteOffset, "rotation_degrees", 0.0, 0.05)

func _play_small_shake() -> void:
	if not is_instance_valid(growth_sprite):
		return
	if _active_pos_tween and _active_pos_tween.is_valid():
		_active_pos_tween.kill()

	# Árvores pequenas/médias (SEED..SMALL) só existem no sheet de crescimento
	# (growth_sprite). NÃO trocamos para o sheet de animação: a linha 0 dele contém
	# frames de CRESCIMENTO de tamanhos diferentes (largura ~25 -> 29 -> 32 px), o que
	# fazia a árvore "encolher e voltar a crescer" ao ser atingida. Aqui só balançamos
	# o sprite no lugar, mantendo o tamanho constante.
	growth_sprite.visible = true
	if is_instance_valid(full_sprite):
		full_sprite.visible = false

	_active_pos_tween = create_tween()
	_active_pos_tween.tween_property(growth_sprite, "position:x", 2.0, 0.05)
	_active_pos_tween.tween_property(growth_sprite, "position:x", -2.0, 0.1)
	_active_pos_tween.tween_property(growth_sprite, "position:x", 0.0, 0.05)

# Pisca rápido (flash branco) no sprite visível como feedback de dano. Funciona em
# qualquer estágio e independe dos frames do sheet de animação, garantindo o "piscar"
# tanto na árvore média (sprite único, sem frames de balanço) quanto em árvores cujo
# sheet sazonal não tem frames de balanço (ex.: bétula no outono).
func _play_hit_blink() -> void:
	var spr: Sprite2D = full_sprite if current_stage == GrowthStage.FULL else growth_sprite
	if not is_instance_valid(spr):
		return
	if _active_blink_tween and _active_blink_tween.is_valid():
		_active_blink_tween.kill()
	# Brilho > 1 clareia o sprite (flash branco) em 2D no Godot; volta ao normal suave.
	spr.modulate = Color(2.2, 2.2, 2.2, 1.0)
	_active_blink_tween = create_tween()
	_active_blink_tween.tween_property(spr, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.18)

func _play_fall_tween() -> void:
	# Tremida rápida antes de cair (vale para árvore grande e média, pois balança
	# o $SpriteOffset que contém ambos os sprites).
	var shake_tween = create_tween()
	shake_tween.tween_property($SpriteOffset, "position:x", 3.0 * spawn_direction, 0.05)
	shake_tween.tween_property($SpriteOffset, "position:x", -3.0 * spawn_direction, 0.1)
	shake_tween.tween_property($SpriteOffset, "position:x", 0.0, 0.05)
	await shake_tween.finished

	# O toco só nasce da árvore grande (FULL). A árvore média (SMALL) cai sem deixar toco.
	if current_stage == GrowthStage.FULL:
		_spawn_stump()
	
	# Then fall smoothly (Inicia a inclinação e queda suave)
	var tween = create_tween().set_parallel(true)
	var target_rotation = 1.5708 * spawn_direction
	var target_position = Vector2(15.0 * spawn_direction, 16.0)
	
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
			var env_id = FarmManager.register_env_object(scene_file_path, spawn_pos, GrowthStage.SEED)
			new_seed.set_meta("env_id", env_id)
			print("Tree spread seed of type ", scene_file_path, " to position ", spawn_pos)
