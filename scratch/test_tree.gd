extends SceneTree

func _init():
	print("--- TEST STARTED ---")
	var tree_scene = preload("res://objects/nature/maple_tree.tscn")
	var t = tree_scene.instantiate()
	root.add_child(t)
	
	t.current_stage = t.GrowthStage.FULL
	t._update_appearance()
	
	print("Stage: ", t.current_stage)
	print("Health before: ", t.health)
	
	t.take_damage(3, Vector2(-10, 0), "Axe")
	
	print("Health after: ", t.health)
	
	# wait for physics/process
	await get_tree().create_timer(0.1).timeout
	
	print("Is queued for deletion: ", t.is_queued_for_deletion())
	print("Stumps in root: ")
	var has_stump = false
	for child in root.get_children():
		if child.name.begins_with("Stump") or child.name.begins_with("MapleStump"):
			print("Found stump!")
			has_stump = true
			
	if not has_stump:
		print("NO STUMP FOUND!")
		
	print("Animation playing: ", t.get_node("AnimationPlayer").current_animation)
	
	quit()
