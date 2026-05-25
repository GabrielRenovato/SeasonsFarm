extends CharacterBody2D

@onready var movement_component: MovementComponent = $MovementComponent
@onready var tool_component: ToolComponent = $ToolComponent

func _physics_process(_delta: float) -> void:
	tool_component.update_target_preview(movement_component.last_direction)
	tool_component.handle_tool_switch()
	tool_component.handle_tool_use(movement_component.last_direction)

	if tool_component.is_using_tool:
		movement_component.stop_movement()
	else:
		movement_component.handle_movement()
