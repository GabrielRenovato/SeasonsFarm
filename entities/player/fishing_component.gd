extends Node
class_name FishingComponent

@export_group("References")
@export var actor: CharacterBody2D
@export var animation_tree: AnimationTree
@export var tool_component: Node

@export_group("Tuning")
@export var min_wait_time: float = 2.0
@export var max_wait_time: float = 6.0
@export var bite_window: float = 1.5

const BITE_INDICATOR_SCENE = preload("res://systems/fishing/bite_indicator.gd")
const CATCH_POPUP_SCENE = preload("res://systems/fishing/fish_catch_popup.gd")
const MINIGAME_SCENE = preload("res://systems/fishing/fishing_minigame.gd")
const FISH_SHADOW_SCENE = preload("res://systems/fishing/fish_shadow.gd")

enum FishingState { IDLE, CASTING, WAITING, BITING, REELING, CATCHING }
var current_state: FishingState = FishingState.IDLE

var state_machine: AnimationNodeStateMachinePlayback
var timer: Timer
var bite_indicator: BiteIndicator
var is_fishing: bool = false
var strict_direction: Vector2 = Vector2.DOWN
var current_target_cell: Vector2i = Vector2i.ZERO

var current_fish_data: Dictionary
var fish_shadow = null   # instância de FishShadow (Sprite2D); tipo dinâmico p/ não depender do class cache

var cached_fishes: Array[ItemData] = []

func _ready() -> void:
	if animation_tree:
		state_machine = animation_tree.get("parameters/playback")

	timer = Timer.new()
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)
	
	_load_fishes_to_cache()

func _load_fishes_to_cache() -> void:
	var dir = DirAccess.open("res://systems/inventory/items")
	if dir == null:
		push_warning("FishingComponent: nao foi possivel abrir a pasta de itens")
		return
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir():
			# Em builds EXPORTADOS os recursos do PCK aparecem com sufixo ".remap"
			# (ex.: "fish_catfish.tres.remap"); no editor vêm como ".tres" puro.
			# Sem normalizar isso, a lista de peixes fica VAZIA no .exe e a pesca
			# quebra (mesmo o conteúdo estando empacotado). O load() do .tres real
			# resolve o remap internamente.
			var clean_name: String = file_name.trim_suffix(".remap")
			if clean_name.ends_with(".tres"):
				var item = load("res://systems/inventory/items/" + clean_name) as ItemData
				if item and item.is_fish:
					cached_fishes.append(item)
		file_name = dir.get_next()
	dir.list_dir_end()

func _process(_delta: float) -> void:
	if current_state == FishingState.BITING:
		if Input.is_action_just_pressed("use_tool"):
			_start_minigame()

	if current_state == FishingState.WAITING and Input.is_action_just_pressed("use_tool"):
		_cancel_fishing()

func start_fishing(direction: Vector2, target_cell: Vector2i) -> bool:
	if is_fishing: return false
	if not _is_water_tile(target_cell): return false

	strict_direction = direction
	current_target_cell = target_cell
	is_fishing = true
	current_state = FishingState.CASTING

	if actor and actor.has_node("MovementComponent"):
		actor.get_node("MovementComponent").stop_movement()

	_set_blend_positions(direction)
	state_machine.travel("FishCast")
	return true

func _set_blend_positions(dir: Vector2) -> void:
	animation_tree.set("parameters/FishCast/blend_position", dir)
	animation_tree.set("parameters/FishWait/blend_position", dir)
	animation_tree.set("parameters/FishBite/blend_position", dir)
	animation_tree.set("parameters/FishReel/blend_position", dir)
	animation_tree.set("parameters/FishCatch/blend_position", dir)

func on_animation_finished(anim_name: String) -> void:
	if not is_fishing: return

	var anim := anim_name.to_lower()
	if "cast" in anim:
		_start_waiting()
	elif "catch" in anim:
		_finish_fishing()

func _start_waiting() -> void:
	current_state = FishingState.WAITING
	state_machine.travel("FishWait")
	timer.start(randf_range(min_wait_time, max_wait_time))

func _on_timer_timeout() -> void:
	if current_state == FishingState.WAITING:
		_start_biting()
	elif current_state == FishingState.BITING:
		if bite_indicator:
			bite_indicator.hide_indicator()
		_cancel_fishing()

func _start_biting() -> void:
	current_state = FishingState.BITING

	if not bite_indicator:
		bite_indicator = BiteIndicator.new()
		actor.add_child(bite_indicator)

	bite_indicator.show_indicator()
	state_machine.travel("FishBite")

	_roll_fish_for_current_season()

	# Mostra o peixe se debatendo na água (cor conforme a raridade sorteada)
	_spawn_fish_shadow()

	timer.start(bite_window)

func _roll_fish_for_current_season() -> void:
	var possible_fishes: Array[ItemData] = []
	var season_map = { "Spring": 0, "Summer": 1, "Fall": 2, "Winter": 3 }
	var current_season = 0 # Default spring
	var time_manager = get_node_or_null("/root/TimeManager")
	if time_manager:
		current_season = time_manager.current_season

	for item in cached_fishes:
		if item.fish_season == "Any" or season_map.get(item.fish_season, 0) == current_season:
			possible_fishes.append(item)
			
	if possible_fishes.size() == 0:
		current_fish_data = {"id": "bluegill", "name": "Bluegill", "rarity": "common", "weight": 1.0, "color": Color(0.8, 0.8, 0.8), "item": null}
		return
		
	# Sorteio com base na raridade (pesos: Common=60, Uncommon=25, Rare=10, Legendary=5)
	var weights = { "Common": 60, "Uncommon": 25, "Rare": 10, "Legendary": 5 }
	var total_weight = 0
	for item in possible_fishes:
		total_weight += weights.get(item.fish_rarity, 10)
		
	var roll = randi() % total_weight
	var current_weight = 0
	var chosen_item: ItemData = possible_fishes[0]
	
	for item in possible_fishes:
		current_weight += weights.get(item.fish_rarity, 10)
		if roll < current_weight:
			chosen_item = item
			break
			
	# Salva os dados do peixe escolhido no dicionário usado pelo minigame e popup
	current_fish_data = {
		"id": chosen_item.id,
		"name": chosen_item.name,
		"rarity": chosen_item.fish_rarity.to_lower(),
		"weight": 1.0, # Placeholder para o minigame
		"color": chosen_item.icon_color,
		"item": chosen_item
	}

func _start_minigame() -> void:
	current_state = FishingState.REELING
	timer.stop()

	if bite_indicator:
		bite_indicator.hide_indicator()

	state_machine.travel("FishReel")

	var minigame := MINIGAME_SCENE.new()
	add_child(minigame)
	minigame.start(current_fish_data)
	minigame.minigame_finished.connect(_on_minigame_finished)
	minigame.reel_tug.connect(_on_reel_tug)

func _on_reel_tug(_great: bool) -> void:
	# A cada acerto no skill check o player dá um "puxão": reinicia o gesto de
	# recolher a linha (FishReel toca do início), sincronizando com o acerto.
	if current_state == FishingState.REELING:
		state_machine.start("FishReel")

func _on_minigame_finished(success: bool) -> void:
	if success:
		_start_catching()
	else:
		_cancel_fishing()

func _start_catching() -> void:
	current_state = FishingState.CATCHING
	state_machine.travel("FishCatch")
	_clear_fish_shadow()   # o peixe foi fisgado: some da água

	var popup := CATCH_POPUP_SCENE.new()
	actor.add_child(popup)
	popup.setup(current_fish_data["name"], current_fish_data["color"])

	var inv: InventoryData = actor.inventory_data
	if inv:
		if current_fish_data.has("item") and current_fish_data["item"] != null:
			# Adiciona o resource original que já contém preço, ícone, etc.
			inv.add_item(current_fish_data["item"], 1)
		else:
			# Fallback para o default se falhar (ex: bluegill de fallback)
			var new_item := ItemData.new()
			new_item.id = current_fish_data["id"]
			new_item.name = current_fish_data["name"]
			new_item.rarity = current_fish_data["rarity"]
			inv.add_item(new_item, 1)

func _cancel_fishing() -> void:
	timer.stop()
	_finish_fishing()

func _finish_fishing() -> void:
	is_fishing = false
	current_state = FishingState.IDLE
	state_machine.travel("Idle")
	_clear_fish_shadow()   # segurança: garante remoção ao cancelar/encerrar

	if tool_component:
		tool_component.is_using_tool = false
		tool_component._active_tool_in_use = ""

func _is_water_tile(cell: Vector2i) -> bool:
	var scene := get_tree().current_scene
	if not scene: return false
	var water := scene.get_node_or_null("WaterLayer") as TileMapLayer
	return water != null and water.get_cell_source_id(cell) != -1

# Cria a sombra do peixe no centro da célula de água mirada (à frente do player).
func _spawn_fish_shadow() -> void:
	_clear_fish_shadow()
	var scene := get_tree().current_scene
	if not scene:
		return
	var water := scene.get_node_or_null("WaterLayer") as TileMapLayer
	if not water:
		return
	fish_shadow = FISH_SHADOW_SCENE.new()
	scene.add_child(fish_shadow)
	fish_shadow.global_position = water.to_global(water.map_to_local(current_target_cell))
	fish_shadow.z_index = 1   # sobre a água animada
	fish_shadow.setup(str(current_fish_data.get("rarity", "common")))

func _clear_fish_shadow() -> void:
	if fish_shadow and is_instance_valid(fish_shadow):
		fish_shadow.dismiss()
	fish_shadow = null
