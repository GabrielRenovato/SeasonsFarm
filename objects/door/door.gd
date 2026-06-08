extends Area2D

## DOOR COMPONENT
## Usado para transitar entre cenas (ex: entrar/sair de uma casa).
## Used to transition between scenes (e.g. entering/exiting a house).

@export_file("*.tscn") var target_scene_path: String
@export var target_door_name: String = ""

func _ready() -> void:
	# Conecta o sinal de colisão com o jogador (Connect collision signal with player)
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	# Se o corpo for o Player e tivermos uma cena configurada (If body is Player and we have a target scene)
	if body.is_in_group("player") and target_scene_path != "":
		# Chama o SceneManager global para fazer a transição (Call global SceneManager to transition)
		# O autoload SceneManager já deve estar configurado no project.godot
		if Engine.has_singleton("SceneManager"):
			var scene_manager = get_node("/root/SceneManager")
			scene_manager.change_scene(target_scene_path, target_door_name)
		else:
			printerr("SceneManager não encontrado! / SceneManager not found!")
