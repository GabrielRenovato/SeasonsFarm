@tool
extends SceneTree

func _init():
	print("Fixing Stardew Valley Trees...")
	
	var trees = ["maple", "pine", "birch", "mahogany"]
	
	for t in trees:
		print("Fixing " + t + "...")
		
		# 1. Fix the Tree scene
		var tree_path = "res://objects/nature/" + t + "_tree.tscn"
		var tree_scene = load(tree_path)
		if tree_scene:
			var tree_node = tree_scene.instantiate()
			
			# Set default frame to 4 (standing tree)
			var sprite = tree_node.get_node("SpriteOffset/Sprite2D")
			sprite.frame = 4
			
			# We need to make AnimationPlayer unique and add custom falling animation
			var anim_player = tree_node.get_node("AnimationPlayer")
			var new_lib = AnimationLibrary.new()
			
			# Copy existing animations except falling_tree
			var old_lib = anim_player.get_animation_library("")
			for anim_name in old_lib.get_animation_list():
				if anim_name != "falling_tree" and anim_name != "falling_tree_inverted":
					new_lib.add_animation(anim_name, old_lib.get_animation(anim_name).duplicate())
			
			# Create Stardew Valley frame-by-frame falling animation
			var fall_anim = Animation.new()
			fall_anim.length = 0.6
			
			var track_idx = fall_anim.add_track(Animation.TYPE_VALUE)
			fall_anim.track_set_path(track_idx, "SpriteOffset/Sprite2D:frame")
			fall_anim.track_insert_key(track_idx, 0.0, 4) # Shaking start
			fall_anim.track_insert_key(track_idx, 0.1, 5) # Shake
			fall_anim.track_insert_key(track_idx, 0.2, 4) # Shake
			fall_anim.track_insert_key(track_idx, 0.3, 0) # Canopy detaches
			fall_anim.track_insert_key(track_idx, 0.4, 1) # Falling
			fall_anim.track_insert_key(track_idx, 0.5, 2) # On ground
			fall_anim.value_track_set_update_mode(track_idx, Animation.UPDATE_DISCRETE)
			
			# Keep rotation at 0
			var rot_idx = fall_anim.add_track(Animation.TYPE_VALUE)
			fall_anim.track_set_path(rot_idx, "SpriteOffset:rotation")
			fall_anim.track_insert_key(rot_idx, 0.0, 0.0)
			
			new_lib.add_animation("falling_tree", fall_anim)
			new_lib.add_animation("falling_tree_inverted", fall_anim) # same animation
			
			anim_player.add_animation_library("", new_lib)
			
			var packed = PackedScene.new()
			packed.pack(tree_node)
			ResourceSaver.save(packed, tree_path)
			tree_node.free()
			print(t + "_tree fixed.")
			
		# 2. Fix the Stump scene
		var stump_path = "res://objects/nature/" + t + "_stump.tscn"
		var stump_scene = load(stump_path)
		if stump_scene:
			var stump_node = stump_scene.instantiate()
			var sprite = stump_node.get_node("Sprite2D")
			
			# Switch to region
			sprite.region_enabled = true
			sprite.hframes = 1
			sprite.vframes = 1
			sprite.frame = 0
			sprite.region_rect = Rect2(0, 128, 32, 16) # Just the base stump
			sprite.position = Vector2(0, -8) # Adjust position so bottom touches 0
			
			var packed = PackedScene.new()
			packed.pack(stump_node)
			ResourceSaver.save(packed, stump_path)
			stump_node.free()
			print(t + "_stump fixed.")
			
	print("Done.")
	quit()
