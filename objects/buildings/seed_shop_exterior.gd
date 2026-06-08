extends StaticBody2D

# =====================================================================
# SEED SHOP EXTERIOR
# Script dedicado para a loja de sementes, permitindo colisão própria,
# porta interativa com animação (se configurada) e envio de eventos
# para o SceneManager para entrar na loja.
# =====================================================================

@export_file("*.tscn") var interior_scene: String

@onready var door_area: Area2D = $DoorArea
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var _player_in_range: bool = false
var _is_opening: bool = false

func _ready() -> void:
	door_area.body_entered.connect(_on_door_area_body_entered)
	door_area.body_exited.connect(_on_door_area_body_exited)
	
	# Adiciona ao grupo door para o tool_component ignorar uso de ferramenta
	door_area.add_to_group("door")

func _unhandled_input(event: InputEvent) -> void:
	# Quando o jogador aperta espaço e está no alcance da porta
	if _player_in_range and not _is_opening and event.is_action_pressed("use_tool"):
		# Consome a ação de espaço para nada mais atuar com este mesmo evento (Ex: não bater picareta)
		get_viewport().set_input_as_handled()
		_open_door()

func _on_door_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_range = true

func _on_door_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_range = false

func _open_door() -> void:
	_is_opening = true
	
	# Toca a animação da porta (se houver alguma configurada pelo usuário no AnimationPlayer)
	if animation_player and animation_player.has_animation("open_door"):
		animation_player.play("open_door")
		await animation_player.animation_finished
	
	# Troca de cena usando o gerenciador de cenas global
	var scene_manager = get_node_or_null("/root/SceneManager")
	if scene_manager and interior_scene != "":
		# "CityDoor" indica na loja de semente de onde ele veio, para voltar ao mesmo ponto
		scene_manager.change_scene(interior_scene, "CityDoor")
