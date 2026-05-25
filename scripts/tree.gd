extends StaticBody2D

@export var health: int = 3
@export var wood_scene: PackedScene
@export var wood_amount: int = 3
@export var fall_right_anim: String = "falling_tree"
@export var fall_left_anim: String = "falling_tree_inverted"
@onready var animation_player: AnimationPlayer = $AnimationPlayer

const STUMP_SCENE = preload("res://scenes/objects/stump.tscn")

var chosen_fall_anim: String = ""
var spawn_direction: float = 1.0

func take_damage(amount: int, hitter_position: Vector2 = Vector2.ZERO, tool_name: String = "") -> void:
	if tool_name != "Axe":
		return
		
	health -= amount
	
	if hitter_position != Vector2.ZERO:
		if hitter_position.x > global_position.x:
			chosen_fall_anim = fall_left_anim
			spawn_direction = -1.0
		else:
			chosen_fall_anim = fall_right_anim
			spawn_direction = 1.0
			
	if health > 0:
		animation_player.play("tree_shake")
	else:
		_die()

func _die() -> void:
	$CollisionShape2D.set_deferred("disabled", true)
	$Area2D/CollisionShape2D.set_deferred("disabled", true)
	
	var stump_instance = STUMP_SCENE.instantiate()
	get_tree().current_scene.add_child(stump_instance)
	stump_instance.global_position = global_position
	
	if chosen_fall_anim != "" and animation_player.has_animation(chosen_fall_anim):
		animation_player.play(chosen_fall_anim)
		await animation_player.animation_finished
	elif animation_player.has_animation(fall_right_anim):
		animation_player.play(fall_right_anim)
		await animation_player.animation_finished
	
	_spawn_wood()
	queue_free()

func _spawn_wood() -> void:
	if wood_scene == null:
		return
		
	for i in range(wood_amount):
		var wood_instance = wood_scene.instantiate()
		get_tree().current_scene.add_child(wood_instance)
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
