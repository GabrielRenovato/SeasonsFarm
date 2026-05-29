extends Node

func _ready() -> void:
	test_sprite_dimensions()

func test_sprite_dimensions() -> void:
	var sprites = {
		"Slots": preload("res://assets/sprites/ui/Inventory/Slots.png"),
		"Book": preload("res://assets/sprites/ui/Inventory/Book.png"),
		"Extras": preload("res://assets/sprites/ui/Inventory/Extras.png"),
		"Decor": preload("res://assets/sprites/ui/Inventory/Decor.png"),
	}

	for name in sprites:
		var tex = sprites[name]
		print("%s: %dx%d" % [name, tex.get_width(), tex.get_height()])

	queue_free()
