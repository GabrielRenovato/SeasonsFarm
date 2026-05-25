extends StaticBody2D

@export var interior_scene: PackedScene
@onready var door_area: Area2D = $DoorArea
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	door_area.body_entered.connect(_on_door_area_body_entered)

func _on_door_area_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		if interior_scene != null:
			animation_player.play("open_door")
			await animation_player.animation_finished
			get_tree().change_scene_to_packed(interior_scene)
