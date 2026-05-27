extends Node2D
class_name Crop

@export var crop_name: String = ""
@export var crop_row: int = 0
@export var max_growth_stages: int = 6
@export var current_stage: int = 0

var map_position: Vector2i

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	update_visuals()

func setup_crop(p_crop_name: String, p_row: int, p_max_stages: int, p_current_stage: int, p_pos: Vector2i) -> void:
	crop_name = p_crop_name
	crop_row = p_row
	max_growth_stages = p_max_stages
	current_stage = p_current_stage
	map_position = p_pos
	
	if is_inside_tree() and sprite:
		update_visuals()

func grow() -> void:
	if current_stage < max_growth_stages - 1:
		current_stage += 1
		update_visuals()
		_play_grow_effect()

func _play_grow_effect() -> void:
	# Efeito visual de wiggle (escala rápida) para simular o crescimento orgânico
	var tween = create_tween()
	tween.tween_property(sprite, "scale", Vector2(1.3, 1.3), 0.1)
	tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.1)

func is_fully_grown() -> bool:
	return current_stage >= max_growth_stages - 1

func update_visuals() -> void:
	if sprite:
		sprite.frame = (crop_row * 6) + current_stage
		# A partir do frame 1, o sprite na planilha possui a base deslocada para a borda inferior.
		# Usamos sprite.offset (não sprite.position) para não interferir no y-sort, evitando que a
		# planta suma atrás dos tiles do chão após crescer.
		if current_stage > 0:
			sprite.offset.y = -4
		else:
			sprite.offset.y = 0
