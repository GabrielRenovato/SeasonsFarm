extends Node2D
class_name Crop

@export var crop_name: String = ""
@export var texture_path: String = ""
@export var frame_size: int = 16
@export var max_growth_stages: int = 7
@export var current_stage: int = 0
# Maps each growth stage index to the actual frame in the texture strip.
# Needed because some PNGs have empty separator frames that must be skipped.
var frame_map: Array = []

var map_position: Vector2i

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	update_visuals()

func setup_crop(p_crop_name: String, p_texture_path: String, p_frame_size: int, p_max_stages: int, p_frame_map: Array, p_current_stage: int, p_pos: Vector2i) -> void:
	crop_name = p_crop_name
	texture_path = p_texture_path
	frame_size = p_frame_size
	max_growth_stages = p_max_stages
	frame_map = p_frame_map
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
	var tween = create_tween()
	tween.tween_property(sprite, "scale", Vector2(1.3, 1.3), 0.1)
	tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.1)

func is_fully_grown() -> bool:
	return current_stage >= max_growth_stages - 1

func update_visuals() -> void:
	if not sprite:
		return
	if texture_path:
		sprite.texture = load(texture_path)
	# Use total PNG frames for hframes so each cell is exactly frame_size px wide
	var total_frames := max_growth_stages
	if sprite.texture and frame_size > 0:
		total_frames = sprite.texture.get_width() / frame_size
	sprite.hframes = total_frames
	sprite.vframes = 1
	# Map stage to actual PNG frame, skipping empty separator frames
	var actual_frame := current_stage
	if frame_map.size() > 0 and current_stage < frame_map.size():
		actual_frame = frame_map[current_stage]
	sprite.frame = actual_frame
	
	# Default offset for 16x16 crops
	var base_offset = -4 if current_stage > 0 else 0
	
	# Se a textura for maior que 16px de altura (ex: 32px), precisamos deslocá-la
	# para cima para que a base da planta continue alinhada com a terra
	if sprite.texture and sprite.texture.get_height() > 16:
		var height_diff = sprite.texture.get_height() - 16
		base_offset -= height_diff / 2
		
	sprite.offset.y = base_offset
