extends Sprite2D
class_name SafeSprite

func _set(property: StringName, value: Variant) -> bool:
	if property == &"hframes":
		var new_h = value as int
		if new_h * vframes <= frame:
			frame = 0
		hframes = new_h
		return true
	elif property == &"vframes":
		var new_v = value as int
		if hframes * new_v <= frame:
			frame = 0
		vframes = new_v
		return true
	elif property == &"frame":
		var new_f = value as int
		var max_f = hframes * vframes
		if new_f >= max_f:
			frame = max(0, max_f - 1)
			return true
	return false
