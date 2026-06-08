extends SceneTree

func _init() -> void:
	print("Building city base...")
	var scene = PackedScene.new()
	var root = Node2D.new()
	root.name = "City"
	
	# Create GroundLayer
	var ground = TileMapLayer.new()
	ground.name = "GroundLayer"
	ground.tile_set = preload("res://levels/main_farm/tilesets/tileset_grama.tres")
	ground.z_index = -2
	ground.add_to_group("ground_layer")
	root.add_child(ground)
	ground.owner = root
	
	for y in range(28):
		for x in range(32):
			ground.set_cell(Vector2i(x, y), 3, Vector2i(9, 2))
			
	# Save to a test file
	scene.pack(root)
	ResourceSaver.save(scene, "res://_test_city.tscn")
	print("Saved to _test_city.tscn")
	quit()
