extends Node2D
class_name Crop

@export var crop_name: String = ""
@export var max_growth_stages: int = 4
@export var current_stage: int = 0

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	update_visuals()

func grow() -> void:
	if current_stage < max_growth_stages - 1:
		current_stage += 1
		animation_player.play("grow")
		update_visuals()

func is_fully_grown() -> bool:
	return current_stage >= max_growth_stages - 1

func harvest() -> void:
	if is_fully_grown():
		queue_free()

func update_visuals() -> void:
	sprite.frame = current_stage
