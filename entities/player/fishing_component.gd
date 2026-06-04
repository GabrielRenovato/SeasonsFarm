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

func _ready() -> void:
	if animation_tree:
		state_machine = animation_tree.get("parameters/playback")

	timer = Timer.new()
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)

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

	var db := get_node_or_null("/root/FishDatabase")
	if db:
		current_fish_data = db.roll_fish()
	else:
		current_fish_data = {"id": "bluegill", "name": "Bluegill", "rarity": "common", "weight": 1.0, "color": Color(0.8, 0.8, 0.8)}

	# Mostra o peixe se debatendo na água (cor conforme a raridade sorteada)
	_spawn_fish_shadow()

	timer.start(bite_window)

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

	var new_item := ItemData.new()
	new_item.id = current_fish_data["id"]
	new_item.name = current_fish_data["name"]
	new_item.rarity = current_fish_data["rarity"]

	var inv: InventoryData = actor.inventory_data
	if inv:
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
