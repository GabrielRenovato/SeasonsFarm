extends Node
class_name FishingComponent

@export_group("References")
@export var actor: CharacterBody2D
@export var animation_tree: AnimationTree
@export var tool_component: Node # Reference to ToolComponent

@export_group("Tuning")
@export var min_wait_time: float = 2.0
@export var max_wait_time: float = 6.0
@export var bite_window: float = 1.5

const BITE_INDICATOR_SCENE = preload("res://systems/fishing/bite_indicator.gd")
const CATCH_POPUP_SCENE = preload("res://systems/fishing/fish_catch_popup.gd")

enum FishingState { IDLE, CASTING, WAITING, BITING, REELING, CATCHING }
var current_state: FishingState = FishingState.IDLE

var state_machine: AnimationNodeStateMachinePlayback
var timer: Timer
var bite_indicator: BiteIndicator
var is_fishing: bool = false
var strict_direction: Vector2 = Vector2.DOWN

func _ready() -> void:
	# Inicializa a máquina de estados
	if animation_tree:
		state_machine = animation_tree.get("parameters/playback")
	
	# Cria o timer internamente
	timer = Timer.new()
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)
	
	# Prepara a animação (adicionaria as animações novas aqui)
	call_deferred("_setup_animations")

func _setup_animations() -> void:
	# Aqui nós injetaríamos programaticamente as animações de pesca no AnimationPlayer
	# e os BlendSpace2D na AnimationTree, para evitar editar um arquivo .tscn gigante.
	# Como 'fish_cast' já existe (confirmado no planejamento), vamos assumir que as outras 
	# também serão criadas ou mapeadas. Para simplificar no protótipo, vamos focar no fluxo.
	pass

func _process(delta: float) -> void:
	if current_state == FishingState.BITING:
		# Se o jogador apertar a tecla de ferramenta durante a mordida (bite_window)
		if Input.is_action_just_pressed("use_tool"):
			_start_reeling()
			
	# Para interromper a pesca (cancela)
	if current_state == FishingState.WAITING and Input.is_action_just_pressed("use_tool"):
		_cancel_fishing()

## Inicia a pescaria se estiver olhando para a água
func start_fishing(direction: Vector2, target_cell: Vector2i) -> bool:
	if is_fishing:
		return false
		
	if not _is_water_tile(target_cell):
		return false # Não pode pescar na terra
		
	strict_direction = direction
	is_fishing = true
	current_state = FishingState.CASTING
	
	# Bloqueia movimento
	if actor and actor.has_node("MovementComponent"):
		actor.get_node("MovementComponent").stop_movement()
		
	# Atualiza blend positions
	animation_tree.set("parameters/FishCast/blend_position", direction)
	# Na prática, precisaria ter os outros BlendSpaces configurados (FishWait, FishBite, etc)
	# animation_tree.set("parameters/FishWait/blend_position", direction)
	# animation_tree.set("parameters/FishBite/blend_position", direction)
	# animation_tree.set("parameters/FishReel/blend_position", direction)
	# animation_tree.set("parameters/FishCatch/blend_position", direction)
	
	state_machine.travel("FishCast")
	return true

## Chamado pelo ToolComponent quando a animação de cast/reel/catch termina
func on_animation_finished(anim_name: String) -> void:
	if not is_fishing:
		return
		
	# A string anim_name geralmente vem do formato "fishcast_down"
	if "fish_cast" in anim_name or "fishcast" in anim_name:
		_start_waiting()
	elif "fish_reel" in anim_name or "fishreel" in anim_name:
		_start_catching()
	elif "fish_catch" in anim_name or "fishcatch" in anim_name:
		_finish_fishing()

func _start_waiting() -> void:
	current_state = FishingState.WAITING
	# Na falta de 'FishWait' configurado no AnimationTree original, podemos voltar pra Idle
	# No código completo, seria state_machine.travel("FishWait")
	state_machine.travel("Idle") 
	
	var wait_time = randf_range(min_wait_time, max_wait_time)
	timer.start(wait_time)

func _on_timer_timeout() -> void:
	if current_state == FishingState.WAITING:
		_start_biting()
	elif current_state == FishingState.BITING:
		# Peixe fugiu!
		if bite_indicator:
			bite_indicator.hide_indicator()
		_cancel_fishing()

func _start_biting() -> void:
	current_state = FishingState.BITING
	
	# Mostra indicador visual "!"
	if not bite_indicator:
		bite_indicator = BiteIndicator.new()
		actor.add_child(bite_indicator)
	
	bite_indicator.show_indicator()
	
	# No código completo: state_machine.travel("FishBite")
	
	# Tempo para o jogador reagir
	timer.start(bite_window)

func _start_reeling() -> void:
	current_state = FishingState.REELING
	timer.stop()
	
	if bite_indicator:
		bite_indicator.hide_indicator()
		
	# No código completo: state_machine.travel("FishReel")
	# Temporariamente volta pro idle e vai direto pro catch pra testar o fluxo
	_start_catching() 

func _start_catching() -> void:
	current_state = FishingState.CATCHING
	
	# No código completo: state_machine.travel("FishCatch")
	
	# Gera o peixe pescado!
	var fish = FishDatabase.roll_fish()
	
	# Cria popup de sucesso
	var popup = CATCH_POPUP_SCENE.new()
	actor.add_child(popup)
	popup.setup(fish["name"], fish["color"])
	
	# Adiciona ao inventário
	var new_item = ItemData.new()
	new_item.id = fish["id"]
	new_item.name = fish["name"]
	new_item.rarity = fish["rarity"]
	# TODO: definir icone do peixe usando AtlasTexture
	
	var inv = actor.inventory_data
	if inv:
		inv.add_item(new_item, 1)
		
	# Simula o fim da animação de catch
	timer.start(1.0)
	await timer.timeout
	_finish_fishing()

func _cancel_fishing() -> void:
	timer.stop()
	_finish_fishing()

func _finish_fishing() -> void:
	is_fishing = false
	current_state = FishingState.IDLE
	state_machine.travel("Idle")
	
	# Retorna o controle
	if tool_component:
		tool_component.is_using_tool = false
		tool_component._active_tool_in_use = ""

func _is_water_tile(cell: Vector2i) -> bool:
	var scene = get_tree().current_scene
	if not scene:
		return false
		
	var water = scene.get_node_or_null("WaterLayer") as TileMapLayer
	if water and water.get_cell_source_id(cell) != -1:
		return true
		
	return false
