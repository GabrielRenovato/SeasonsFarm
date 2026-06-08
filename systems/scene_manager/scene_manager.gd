extends CanvasLayer

## SCENE MANAGER
## Gerencia as transições entre cenas, criando um efeito de fade in e fade out.
## Manage scene transitions, creating a fade in and fade out effect.

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var color_rect: ColorRect = $ColorRect

## Velocidade da animação (Animation speed)
@export var transition_speed: float = 1.0

## Variável para guardar de qual porta viemos (Store which door we came from)
## Usada para spawnar o jogador no lugar certo (Used to spawn player at right spot)
var target_spawn_door_name: String = ""

func _ready() -> void:
	# Garante que o painel de cor não bloqueie os cliques (Make sure the color rect doesn't block clicks)
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	color_rect.modulate.a = 0 # Fica invisível no começo (Invisible at start)

## Inicia a transição para uma nova cena (Starts transition to a new scene)
func change_scene(scene_path: String, spawn_door_name: String = "") -> void:
	target_spawn_door_name = spawn_door_name
	
	# Bloqueia cliques durante a transição (Block clicks during transition)
	color_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	
	# Ajusta a velocidade e toca o fade_out (tela preta) (Adjust speed and play fade out to black)
	animation_player.speed_scale = transition_speed
	animation_player.play("fade_out")
	
	# Espera a animação de fade_out terminar (Wait for fade out to finish)
	await animation_player.animation_finished
	
	# Muda a cena atual (Change current scene)
	get_tree().change_scene_to_file(scene_path)
	
	# Toca o fade_in (tela clareando) (Play fade in to clear screen)
	animation_player.play("fade_in")
	
	# Espera a animação de fade_in terminar (Wait for fade in to finish)
	await animation_player.animation_finished
	
	# Libera os cliques (Release clicks)
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
