extends SceneTree

# Paths for the new animations
const BASE_PATH = "res://assets/sprites/Character/PNG/"
const WAIT_DIR = BASE_PATH + "12.1. Fishing - Wait/"
const BITE_DIR = BASE_PATH + "12.2. Fishing - Bite/"
const REEL_DIR = BASE_PATH + "12.3. Fishing - Reel/"
const CATCH_DIR = BASE_PATH + "12.4. Fishing - Catch/"

const DIRECTIONS = ["down", "left", "right", "up"]
const STATES = ["Wait", "Bite", "Reel", "Catch"]

func _init() -> void:
	print("Starting animation injection...")
	
	var scene_path = "res://entities/player/player.tscn"
	var packed_scene = ResourceLoader.load(scene_path)
	if not packed_scene:
		print("Error: Could not load player.tscn")
		quit()
		return
		
	var player = packed_scene.instantiate()
	var anim_player = player.get_node("AnimationPlayer")
	var anim_tree = player.get_node("AnimationTree")
	
	if not anim_player or not anim_tree:
		print("Error: Missing AnimationPlayer or AnimationTree")
		quit()
		return
		
	# Get the base fish_cast animations to copy their track structure
	var lib = anim_player.get_animation_library("")
	if not lib:
		print("Error: Default animation library not found")
		quit()
		return
		
	for state in STATES:
		var state_lower = state.to_lower()
		var is_looping = (state == "Wait" or state == "Reel")
		
		# hframes for each state
		var hframes = 16
		var length = 0.48
		if state == "Bite":
			hframes = 28
			length = 0.56
			
		for dir in DIRECTIONS:
			var base_anim_name = "fish_cast_" + dir
			var new_anim_name = "fish_" + state_lower + "_" + dir
			
			if not lib.has_animation(base_anim_name):
				print("Missing base animation: ", base_anim_name)
				continue
				
			if lib.has_animation(new_anim_name):
				print("Animation already exists, recreating: ", new_anim_name)
				lib.remove_animation(new_anim_name)
				
			var base_anim = lib.get_animation(base_anim_name)
			var new_anim = Animation.new()
			
			if is_looping:
				new_anim.loop_mode = Animation.LOOP_LINEAR
			else:
				new_anim.loop_mode = Animation.LOOP_NONE
				
			new_anim.length = length
			
			# Copy tracks
			for track_idx in range(base_anim.get_track_count()):
				var track_path = base_anim.track_get_path(track_idx)
				var track_type = base_anim.track_get_type(track_idx)
				
				var new_track_idx = new_anim.add_track(track_type)
				new_anim.track_set_path(new_track_idx, track_path)
				
				# For textures, we need to replace the value
				if track_type == Animation.TYPE_VALUE:
					var prop_name = track_path.get_subname(0)
					if prop_name == "texture":
						for key_idx in range(base_anim.track_get_key_count(track_idx)):
							var time = base_anim.track_get_key_time(track_idx, key_idx)
							var val = base_anim.track_get_key_value(track_idx, key_idx)
							new_anim.track_insert_key(new_track_idx, time, val)
					elif prop_name == "hframes":
						new_anim.track_insert_key(new_track_idx, 0.0, hframes)
					elif prop_name == "vframes":
						new_anim.track_insert_key(new_track_idx, 0.0, 1)
					elif prop_name == "frame" or prop_name == "frame_coords":
						# Generate frames based on direction
						var start_frame = 0
						if dir == "down": start_frame = 0
						elif dir == "left": start_frame = int(hframes / 4.0)
						elif dir == "right": start_frame = int(hframes / 4.0) * 2
						elif dir == "up": start_frame = int(hframes / 4.0) * 3
						
						var frame_count = int(hframes / 4.0)
						var step = length / frame_count
						
						for i in range(frame_count):
							new_anim.track_insert_key(new_track_idx, i * step, start_frame + i)
					else:
						# Copy other properties directly
						for key_idx in range(base_anim.track_get_key_count(track_idx)):
							var time = base_anim.track_get_key_time(track_idx, key_idx)
							var val = base_anim.track_get_key_value(track_idx, key_idx)
							new_anim.track_insert_key(new_track_idx, time, val)
				else:
					# Other track types (if any)
					pass
					
			lib.add_animation(new_anim_name, new_anim)
			print("Added animation: ", new_anim_name)

	# Now update AnimationTree StateMachine
	var root = anim_tree.tree_root as AnimationNodeStateMachine
	if root:
		for state in STATES:
			var state_name = "Fish" + state
			if not root.has_node(state_name):
				var blend_space = AnimationNodeBlendSpace2D.new()
				
				# Add 4 blend points
				var blend_anim_up = AnimationNodeAnimation.new()
				blend_anim_up.animation = "fish_" + state.to_lower() + "_up"
				blend_space.add_blend_point(blend_anim_up, Vector2(0, -1))
				
				var blend_anim_down = AnimationNodeAnimation.new()
				blend_anim_down.animation = "fish_" + state.to_lower() + "_down"
				blend_space.add_blend_point(blend_anim_down, Vector2(0, 1))
				
				var blend_anim_left = AnimationNodeAnimation.new()
				blend_anim_left.animation = "fish_" + state.to_lower() + "_left"
				blend_space.add_blend_point(blend_anim_left, Vector2(-1, 0))
				
				var blend_anim_right = AnimationNodeAnimation.new()
				blend_anim_right.animation = "fish_" + state.to_lower() + "_right"
				blend_space.add_blend_point(blend_anim_right, Vector2(1, 0))
				
				root.add_node(state_name, blend_space)
				print("Added blend space to state machine: ", state_name)

	print("Saving modified scene...")
	var new_packed = PackedScene.new()
	new_packed.pack(player)
	var err = ResourceSaver.save(new_packed, scene_path)
	if err == OK:
		print("Successfully saved player.tscn with new animations.")
	else:
		print("Failed to save player.tscn, error code: ", err)

	player.queue_free()
	quit()
