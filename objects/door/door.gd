extends Area2D

## DOOR COMPONENT
## Usado para transitar entre cenas (ex: entrar/sair de uma casa).
## Agora requer apertar o botão de ação (espaço) para interagir.

@export_file("*.tscn") var target_scene_path: String
@export var target_door_name: String = ""

# Referência do jogador se estiver na área da porta
var player_in_zone: Node2D = null

func _ready() -> void:
	# Conecta os sinais de colisão com o jogador
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	# Adiciona a porta num grupo para o player poder saber que está perto de uma porta
	add_to_group("door")

func _on_body_entered(body: Node2D) -> void:
	# Quando o player entra na área, armazenamos a referência
	if body.is_in_group("player"):
		player_in_zone = body

func _on_body_exited(body: Node2D) -> void:
	# Quando o player sai, removemos a referência
	if body == player_in_zone:
		player_in_zone = null

func _unhandled_input(event: InputEvent) -> void:
	# Verifica se o player está na zona e apertou o botão de usar ferramenta (espaço)
	if player_in_zone and target_scene_path != "" and event.is_action_pressed("use_tool"):
		# Consome o evento para evitar outros comportamentos não intencionais no Godot
		get_viewport().set_input_as_handled()
		
		print(" Transitioning to: ", target_scene_path)
		var scene_manager = get_node_or_null("/root/SceneManager")
		if scene_manager:
			scene_manager.change_scene(target_scene_path, target_door_name)
		else:
			printerr("SceneManager não encontrado! / SceneManager not found!")
