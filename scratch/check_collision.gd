extends SceneTree

func _init():
	print("--- CHECK COLLISION ---")
	var scenes = [
		"res://objects/nature/birch_tree.tscn",
		"res://objects/nature/mahogany_tree.tscn",
		"res://objects/nature/maple_tree.tscn",
		"res://objects/nature/pine_tree.tscn"
	]
	
	for path in scenes:
		var scene = load(path)
		if scene:
			var t = scene.instantiate()
			root.add_child(t)
			
			print("\nTree: ", path)
			for stage in range(5):
				t.current_stage = stage
				t._update_appearance()
				# Set_deferred takes effect at the end of the frame, so wait a bit or print direct state if not deferred
				# Actually set_deferred won't update immediately, so let's wait a frame
				await get_tree().process_frame
				var col = t.get_node("CollisionShape2D")
				print("  Stage ", stage, " (", t.GrowthStage.keys()[stage], "): disabled = ", col.disabled)
			
			t.queue_free()
	
	quit()
