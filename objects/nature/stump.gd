extends StaticBody2D

@export var health: int = 3
@export var wood_scene: PackedScene
@export var wood_amount: int = 2

var spawn_direction: float = 1.0

var _active_blink_tween: Tween
var _active_pos_tween: Tween

func take_damage(amount: int, hitter_position: Vector2 = Vector2.ZERO, tool_name: String = "") -> void:
	if tool_name != "Axe":
		return
		
	health -= amount
	
	if hitter_position != Vector2.ZERO:
		if hitter_position.x > global_position.x:
			spawn_direction = -1.0
		else:
			spawn_direction = 1.0
			
	if health > 0:
		_play_hit_blink()
		_play_shake()
	else:
		_die()

func _die() -> void:
	$CollisionShape2D.set_deferred("disabled", true)
	$Area2D/CollisionShape2D.set_deferred("disabled", true)
	
	_play_hit_blink()
	_play_shake()
	
	_spawn_wood()
	
	var fade_tween = create_tween().set_parallel(true)
	fade_tween.tween_property(self, "modulate:a", 0.0, 0.15)
	fade_tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.15)
	await fade_tween.finished
	queue_free()

func _play_hit_blink() -> void:
	var spr = $Sprite2D
	if not is_instance_valid(spr):
		return
	if _active_blink_tween and _active_blink_tween.is_valid():
		_active_blink_tween.kill()
	spr.modulate = Color(2.2, 2.2, 2.2, 1.0)
	_active_blink_tween = create_tween()
	_active_blink_tween.tween_property(spr, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.18)

func _play_shake() -> void:
	var spr = $Sprite2D
	if not is_instance_valid(spr):
		return
	if _active_pos_tween and _active_pos_tween.is_valid():
		_active_pos_tween.kill()
	
	var orig_x = spr.position.x
	_active_pos_tween = create_tween()
	_active_pos_tween.tween_property(spr, "position:x", orig_x + 2.0, 0.05)
	_active_pos_tween.tween_property(spr, "position:x", orig_x - 2.0, 0.1)
	_active_pos_tween.tween_property(spr, "position:x", orig_x, 0.05)

func _spawn_wood() -> void:
	if wood_scene == null:
		return
		
	var drop_origin = global_position + Vector2(0, -10.0)
		
	for i in range(wood_amount):
		var wood_instance = wood_scene.instantiate()
		get_parent().add_child(wood_instance)
		wood_instance.global_position = drop_origin
		
		var random_x = randf_range(10, 50) * spawn_direction
		var random_offset = Vector2(random_x, randf_range(10, 30))
		var target_position = global_position + random_offset
		
		var duration = 0.5
		var peak_y = drop_origin.y - randf_range(10, 20)
		
		var x_tween = wood_instance.create_tween()
		x_tween.tween_property(wood_instance, "global_position:x", target_position.x, duration).set_trans(Tween.TRANS_LINEAR)
		
		var y_tween = wood_instance.create_tween()
		y_tween.tween_property(wood_instance, "global_position:y", peak_y, duration / 2.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		y_tween.tween_property(wood_instance, "global_position:y", target_position.y, duration / 2.0).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
