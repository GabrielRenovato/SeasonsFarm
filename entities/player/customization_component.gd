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
	if not hair_node:
		hair_node = animation_player.get_node_or_null("../Hair")
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
						
						if "Body/har:texture" in str_path or str_path == "Hair:texture":
							new_res_path = _get_new_path(old_res_path, "hair")
						elif "Body/Clothe:texture" in str_path or str_path == "Clothes:texture":
							new_res_path = _get_new_path(old_res_path, "clothes")
						elif "Body/Lags:texture" in str_path or str_path == "Pants:texture":
							new_res_path = _get_new_path(old_res_path, "pants")
						elif str_path == "Eyes:texture":
							new_res_path = _get_new_path(old_res_path, "eyes")
						elif str_path == "Body:texture" or str_path.ends_with("/Body:texture"):
							new_res_path = _get_new_path(old_res_path, "body")
						
						# If path changed and resource exists, load and apply it
						if new_res_path != old_res_path and ResourceLoader.exists(new_res_path):
							var new_tex = load(new_res_path)
							anim.track_set_key_value(track_idx, key_idx, new_tex)

func _get_new_path(old_path: String, track_type: String) -> String:
	if "Character/PNG" in old_path:
		var file_name = old_path.get_file()
		var dir_path = old_path.get_base_dir()
		
		if track_type == "hair":
			var parent_dir = dir_path.get_base_dir()
			return parent_dir + "/" + CustomizationManager.current_hair + "/" + file_name
		elif track_type == "clothes":
			return dir_path + "/" + CustomizationManager.current_clothes + ".png"
		elif track_type == "body":
			return dir_path + "/" + CustomizationManager.current_body + ".png"
		elif track_type == "eyes":
			return dir_path + "/" + CustomizationManager.current_eyes + ".png"
		return old_path
	else:
		var target_prefix = ""
		var available_prefixes = []
		if track_type == "hair":
			target_prefix = CustomizationManager.current_hair
			available_prefixes = CustomizationManager.available_hairstyles
		elif track_type == "clothes":
			target_prefix = CustomizationManager.current_clothes
			available_prefixes = CustomizationManager.available_clothes
		elif track_type == "pants":
			target_prefix = CustomizationManager.current_pants
			available_prefixes = CustomizationManager.available_pants
		elif track_type == "body":
			target_prefix = CustomizationManager.current_body
			available_prefixes = CustomizationManager.available_bodies
			
		var file_name = old_path.get_file()
		var dir_path = old_path.get_base_dir()
		var sorted_prefixes = available_prefixes.duplicate()
		sorted_prefixes.sort_custom(func(a, b): return a.length() > b.length())
		
		for prefix in sorted_prefixes:
			if file_name.begins_with(prefix + "_"):
				var new_file_name = file_name.replace(prefix + "_", target_prefix + "_")
				return dir_path + "/" + new_file_name
		return old_path
