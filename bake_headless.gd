extends SceneTree

func _init():
	print("--- INICIANDO BAKING HEADLESS ---")
	var city_scene = load("res://levels/city/city.tscn")
	var city = city_scene.instantiate()
	
	# Manually build layers on the instanced city node
	city._build_ground()
	city._build_river()
	city._build_paths()
	
	# Clean up any existing children of these names if present
	for child in city.get_children():
		if child is TileMapLayer and child.name in ["GroundLayer", "PathLayer", "WaterLayer"] and not child.has_meta("new"):
			child.free()
		if child is StaticBody2D and child.name == "RiverCollision" and not child.has_meta("new"):
			child.free()

	for child in city.get_children():
		if child.name in ["GroundLayer", "PathLayer", "WaterLayer", "RiverCollision"]:
			child.owner = city
			child.set_meta("new", true)
			for c in child.get_children():
				c.owner = city
	
	var packed = PackedScene.new()
	var err = packed.pack(city)
	if err == OK:
		err = ResourceSaver.save(packed, "res://levels/city/city.tscn")
		if err == OK:
			print("--- BAKING CONCLUIDO COM SUCESSO ---")
		else:
			print("Erro ao salvar: ", err)
	else:
		print("Erro ao empacotar: ", err)
	quit()
