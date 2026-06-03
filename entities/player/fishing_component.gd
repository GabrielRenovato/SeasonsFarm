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
const MINIGAME_SCENE = preload("res://systems/fishing/fishing_minigame.gd")

enum FishingState { IDLE, CASTING, WAITING, BITING, REELING, CATCHING }
var current_state: FishingState = FishingState.IDLE

var state_machine: AnimationNodeStateMachinePlayback
var timer: Timer
var bite_indicator: BiteIndicator
var is_fishing: bool = false
var strict_direction: Vector2 = Vector2.DOWN

var current_fish_data: Dictionary

func _ready() -> void:
	if animation_tree:
		state_machine = animation_tree.get("parameters/playback")
	
	timer = Timer.new()
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)

func _process(delta: float) -> void:
	if current_state == FishingState.BITING:
		if Input.is_action_just_pressed("use_tool"):
			_start_minigame()
			
	if current_state == FishingState.WAITING and Input.is_action_just_pressed("use_tool"):
		_cancel_fishing()

func start_fishing(direction: Vector2, target_cell: Vector2i) -> bool:
	if is_fishing: return false
	if not _is_water_tile(target_cell): return false
		
	strict_direction = direction
	is_fishing = true
	current_state = FishingState.CASTING
	
	if actor and actor.has_node("MovementComponent"):
		actor.get_node("MovementComponent").stop_movement()
		
	_set_blend_positions(direction)
	state_machine.travel("FishCast")
	return true

func _set_blend_positions(dir: Vector2) -> void:
	animation_tree.set("parameters/FishCast/blend_position", dir)
	
	# Only set these if the nodes exist (added by our injection script)
	var root = animation_tree.tree_root as AnimationNodeStateMachine
	if root and root.has_node("FishWait"):
		animation_tree.set("parameters/FishWait/blend_position", dir)
		animation_tree.set("parameters/FishBite/blend_position", dir)
		animation_tree.set("parameters/FishReel/blend_position", dir)
		animation_tree.set("parameters/FishCatch/blend_position", dir)

func on_animation_finished(anim_name: String) -> void:
	if not is_fishing: return
	
	var anim = anim_name.to_lower()
	if "cast" in anim:
		_start_waiting()
	elif "catch" in anim:
		_finish_fishing()
	# Note: "Reel" is looping during the minigame, so it doesn't trigger this usually.

func _start_waiting() -> void:
	current_state = FishingState.WAITING
	var root = animation_tree.tree_root as AnimationNodeStateMachine
	if root and root.has_node("FishWait"):
		state_machine.travel("FishWait")
	else:
		state_machine.travel("Idle") 
	
	var wait_time = randf_range(min_wait_time, max_wait_time)
	timer.start(wait_time)

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
	
	var root = animation_tree.tree_root as AnimationNodeStateMachine
	if root and root.has_node("FishBite"):
		state_machine.travel("FishBite")
		
	# Rola o peixe agora para passar a dificuldade pro minigame
	current_fish_data = FishDatabase.roll_fish()
	
	timer.start(bite_window)

func _start_minigame() -> void:
	current_state = FishingState.REELING
	timer.stop()
	
	if bite_indicator:
		bite_indicator.hide_indicator()
		
	var root = animation_tree.tree_root as AnimationNodeStateMachine
	if root and root.has_node("FishReel"):
		state_machine.travel("FishReel")
		
	var minigame = MINIGAME_SCENE.new()
	add_child(minigame)
	minigame.start(current_fish_data)
	minigame.minigame_finished.connect(_on_minigame_finished)

func _on_minigame_finished(success: bool) -> void:
	if success:
		_start_catching()
	else:
		_cancel_fishing()

func _start_catching() -> void:
	current_state = FishingState.CATCHING
	
	var root = animation_tree.tree_root as AnimationNodeStateMachine
	if root and root.has_node("FishCatch"):
		state_machine.travel("FishCatch")
	
	var popup = CATCH_POPUP_SCENE.new()
	actor.add_child(popup)
	popup.setup(current_fish_data["name"], current_fish_data["color"])
	
	var new_item = ItemData.new()
	new_item.id = current_fish_data["id"]
	new_item.name = current_fish_data["name"]
	new_item.rarity = current_fish_data["rarity"]
	
	var inv = actor.inventory_data
	if inv:
		inv.add_item(new_item, 1)
		
	# Fallback timer just in case FishCatch animation isn't fully wired or doesn't emit signal
	if not (root and root.has_node("FishCatch")):
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
	
	if tool_component:
		tool_component.is_using_tool = false
		tool_component._active_tool_in_use = ""

func _is_water_tile(cell: Vector2i) -> bool:
	var scene = get_tree().current_scene
	if not scene: return false
	var water = scene.get_node_or_null("WaterLayer") as TileMapLayer
	if water and water.get_cell_source_id(cell) != -1: return true
	return false
