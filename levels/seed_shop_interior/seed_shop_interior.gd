extends Node2D

## SEED SHOP INTERIOR
## Gerencia o interior da loja de sementes (Manages the seed shop interior).

@export var shop_name: String = "Seed Shop"

@onready var exit_door: Area2D = $ExitDoor
@onready var spawn_point: Marker2D = $SpawnPoint

func _ready() -> void:
	# Define a cena de destino da porta para a cidade (Set door target to city)
	exit_door.target_scene_path = "res://levels/city/city.tscn"
	exit_door.target_door_name = "seed_shop_door"
	
	# Se viemos da cidade, posicionamos o jogador no spawn point (If we came from city, place player at spawn point)
	if Engine.has_singleton("SceneManager"):
		var scene_manager = get_node("/root/SceneManager")
		if scene_manager.target_spawn_door_name == "seed_shop_interior_door":
			# O Player Manager ou próprio script de player pode se posicionar usando este spawn_point.
			# Uma forma simples é procurar o jogador no grupo "player" e forçar a posição.
			var player = get_tree().get_first_node_in_group("player")
			if player:
				player.global_position = spawn_point.global_position
