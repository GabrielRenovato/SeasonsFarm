extends Node
class_name CustomizationComponent

@export var animation_player: AnimationPlayer

func _ready() -> void:
	if CustomizationManager:
		CustomizationManager.customization_changed.connect(_on_customization_changed)
		# Delay to ensure AnimationPlayer is fully initialized
		call_deferred("_apply_customization")

func _on_customization_changed() -> void:
	_apply_customization()

func _apply_customization() -> void:
	if not animation_player:
		push_warning("CustomizationComponent: AnimationPlayer is not set.")
		return
		
	# Apply Hair Color modulation directly to the hair sprite node
	var hair_node = animation_player.get_node_or_null("../Body/har")
	if hair_node:
		hair_node.modulate = CustomizationManager.hair_color

	var anim_list = animation_player.get_animation_list()
	for anim_name in anim_list:
		var anim = animation_player.get_animation(anim_name)
		for track_idx in anim.get_track_count():
			var path = anim.track_get_path(track_idx)
			var str_path = String(path)
			
			# We only care about texture tracks
			if str_path.ends_with(":texture"):
				for key_idx in anim.track_get_key_count(track_idx):
					var old_tex = anim.track_get_key_value(track_idx, key_idx)
					if old_tex and old_tex is Texture2D:
						var old_res_path = old_tex.resource_path
						var new_res_path = old_res_path
						
						if "Body/har:texture" in str_path:
							new_res_path = _replace_prefix(old_res_path, CustomizationManager.available_hairstyles, CustomizationManager.current_hair)
						elif "Body/Clothe:texture" in str_path:
							new_res_path = _replace_prefix(old_res_path, CustomizationManager.available_clothes, CustomizationManager.current_clothes)
						elif "Body/Lags:texture" in str_path:
							new_res_path = _replace_prefix(old_res_path, CustomizationManager.available_pants, CustomizationManager.current_pants)
						elif str_path == "Body:texture" or str_path.ends_with("/Body:texture"):
							new_res_path = _replace_prefix(old_res_path, CustomizationManager.available_bodies, CustomizationManager.current_body)
						
						# If path changed and resource exists, load and apply it
						if new_res_path != old_res_path and ResourceLoader.exists(new_res_path):
							var new_tex = load(new_res_path)
							anim.track_set_key_value(track_idx, key_idx, new_tex)

func _replace_prefix(path: String, available_prefixes: Array, target_prefix: String) -> String:
	var file_name = path.get_file()
	var dir_path = path.get_base_dir()
	
	# Sort prefixes by length descending to match more specific prefixes first (e.g. "pants_suit" before "pants")
	var sorted_prefixes = available_prefixes.duplicate()
	sorted_prefixes.sort_custom(func(a, b): return a.length() > b.length())
	
	for prefix in sorted_prefixes:
		if file_name.begins_with(prefix + "_"):
			var new_file_name = file_name.replace(prefix + "_", target_prefix + "_")
			return dir_path + "/" + new_file_name
	return path

