extends SceneTree

const BASE_PATH = "res://assets/sprites/Character/PNG/"
const DIRECTIONS = ["down", "left", "right", "up"]
const STATES = ["Wait", "Bite", "Reel", "Catch"]

func _init() -> void:
	print("Building animation library...")
	
	# Load the original player scene just to copy tracks from fish_cast
	var player = load("res://entities/player/player.tscn").instantiate()
	var anim_player = player.get_node("AnimationPlayer")
	var lib_orig = anim_player.get_animation_library("")
	
	var new_lib = AnimationLibrary.new()
	
	for state in STATES:
		var state_lower = state.to_lower()
		var is_looping = (state == "Wait" or state == "Reel")
		
		var hframes = 16
		var length = 0.48
		if state == "Bite":
			hframes = 28
			length = 0.56
			
		var folder = ""
		if state == "Wait": folder = "12.1. Fishing - Wait"
		elif state == "Bite": folder = "12.2. Fishing - Bite"
		elif state == "Reel": folder = "12.3. Fishing - Reel"
		elif state == "Catch": folder = "12.4. Fishing - Catch"
			
		for dir in DIRECTIONS:
			var base_anim_name = "fish_cast_" + dir
			var new_anim_name = "fish_" + state_lower + "_" + dir
			
			var base_anim = lib_orig.get_animation(base_anim_name)
			var new_anim = Animation.new()
			
			if is_looping:
				new_anim.loop_mode = Animation.LOOP_LINEAR
			else:
				new_anim.loop_mode = Animation.LOOP_NONE
				
			new_anim.length = length
			
			for track_idx in range(base_anim.get_track_count()):
				var track_path = base_anim.track_get_path(track_idx)
				var track_type = base_anim.track_get_type(track_idx)
				
				var new_track_idx = new_anim.add_track(track_type)
				new_anim.track_set_path(new_track_idx, track_path)
				
				if track_type == Animation.TYPE_VALUE:
					var prop_name = track_path.get_subname(0)
					if prop_name == "texture":
						# Replace the path base
						for key_idx in range(base_anim.track_get_key_count(track_idx)):
							var time = base_anim.track_get_key_time(track_idx, key_idx)
							var val = base_anim.track_get_key_value(track_idx, key_idx)
							if val and val is Texture2D:
								var old_path = val.resource_path
								var new_path = old_path.replace("12. Fishing - Cast", folder)
								var new_tex = load(new_path)
								new_anim.track_insert_key(new_track_idx, time, new_tex)
							else:
								new_anim.track_insert_key(new_track_idx, time, val)
					elif prop_name == "hframes":
						new_anim.track_insert_key(new_track_idx, 0.0, hframes)
					elif prop_name == "vframes":
						new_anim.track_insert_key(new_track_idx, 0.0, 1)
					elif prop_name == "frame" or prop_name == "frame_coords":
						var start_frame = 0
						if dir == "down": start_frame = 0
						elif dir == "left": start_frame = hframes / 4
						elif dir == "right": start_frame = (hframes / 4) * 2
						elif dir == "up": start_frame = (hframes / 4) * 3
						
						var frame_count = hframes / 4
						var step = length / frame_count
						
						for i in range(frame_count):
							new_anim.track_insert_key(new_track_idx, i * step, start_frame + i)
					else:
						for key_idx in range(base_anim.track_get_key_count(track_idx)):
							var time = base_anim.track_get_key_time(track_idx, key_idx)
							var val = base_anim.track_get_key_value(track_idx, key_idx)
							new_anim.track_insert_key(new_track_idx, time, val)
							
			new_lib.add_animation(new_anim_name, new_anim)
			
	var save_path = "res://systems/fishing/fishing_animations.tres"
	var err = ResourceSaver.save(new_lib, save_path)
	if err == OK:
		print("Successfully saved fishing_animations.tres!")
	else:
		print("Error saving: ", err)
		
	player.queue_free()
	quit()
