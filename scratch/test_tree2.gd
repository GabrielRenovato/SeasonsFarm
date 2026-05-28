extends SceneTree

func _init():
	var file = FileAccess.open("user://test_out.txt", FileAccess.WRITE)
	file.store_line("--- TEST STARTED ---")
	
	var tree_scene = preload("res://objects/nature/maple_tree.tscn")
	var t = tree_scene.instantiate()
	root.add_child(t)
	
	t.current_stage = t.GrowthStage.FULL
	t._update_appearance()
	
	file.store_line("Stage: " + str(t.current_stage))
	file.store_line("Health before: " + str(t.health))
	
	t.take_damage(3, Vector2(-10, 0), "Axe")
	
	file.store_line("Health after: " + str(t.health))
	
	await get_tree().create_timer(1.0).timeout
	
	file.store_line("Is queued for deletion: " + str(t.is_queued_for_deletion()))
	var has_stump = false
	for child in root.get_children():
		file.store_line("Child: " + child.name)
		if child.name.begins_with("Stump") or child.name.begins_with("MapleStump"):
			has_stump = true
			
	if not has_stump:
		file.store_line("NO STUMP FOUND!")
	
	file.close()
	quit()
