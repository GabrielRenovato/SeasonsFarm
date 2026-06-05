extends AnimatedSprite2D

func _ready() -> void:
	play("chips")
	animation_finished.connect(queue_free)
