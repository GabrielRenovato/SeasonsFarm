extends Node
class_name MovementComponent

@export var actor: CharacterBody2D
@export var animation_tree: AnimationTree
@export var movement_speed: float = 150.0

var state_machine: AnimationNodeStateMachinePlayback
var last_direction: Vector2 = Vector2.DOWN

func _ready() -> void:
	animation_tree.active = true
	state_machine = animation_tree.get("parameters/playback")
	_update_blend_positions()

func _update_blend_positions() -> void:
	animation_tree.set("parameters/Idle/blend_position", last_direction)
	animation_tree.set("parameters/Walk/blend_position", last_direction)

func stop_movement() -> void:
	actor.velocity = Vector2.ZERO
	_update_blend_positions()
	actor.move_and_slide()

func handle_movement() -> void:
	var input_direction: Vector2 = Input.get_vector("left", "right", "up", "down")
	if input_direction != Vector2.ZERO:
		var new_direction: Vector2
		if abs(input_direction.x) > abs(input_direction.y):
			new_direction = Vector2(sign(input_direction.x), 0)
		else:
			new_direction = Vector2(0, sign(input_direction.y))

		if new_direction != last_direction:
			last_direction = new_direction
			_update_blend_positions()

		if state_machine.get_current_node() != "Walk":
			state_machine.travel("Walk")
		actor.velocity = input_direction * movement_speed
	else:
		_update_blend_positions()
		if state_machine.get_current_node() != "Idle":
			state_machine.travel("Idle")
		actor.velocity = Vector2.ZERO
	actor.move_and_slide()
