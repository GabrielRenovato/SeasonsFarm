extends CanvasModulate

@export var night_color: Color = Color(0.15, 0.15, 0.35)
@export var sunrise_color: Color = Color(0.95, 0.6, 0.4)
@export var day_color: Color = Color(1.0, 1.0, 1.0)
@export var sunset_color: Color = Color(0.85, 0.45, 0.3)

func _process(_delta: float) -> void:
	if not is_inside_tree():
		return
	
	# Calculate smooth float hour (e.g., 6.5 for 06:30)
	var time: float = TimeManager.hour + (TimeManager.minute / 60.0) + (TimeManager.time_accumulator / TimeManager.minute_duration) / 60.0
	color = get_color_for_time(time)

func get_color_for_time(time: float) -> Color:
	if time < 4.0:
		return night_color
	elif time < 6.0:
		# Night to Sunrise
		var t = (time - 4.0) / 2.0
		return night_color.lerp(sunrise_color, t)
	elif time < 8.0:
		# Sunrise to Day
		var t = (time - 6.0) / 2.0
		return sunrise_color.lerp(day_color, t)
	elif time < 17.0:
		# Day
		return day_color
	elif time < 19.0:
		# Day to Sunset
		var t = (time - 17.0) / 2.0
		return day_color.lerp(sunset_color, t)
	elif time < 21.0:
		# Sunset to Night
		var t = (time - 19.0) / 2.0
		return sunset_color.lerp(night_color, t)
	else:
		return night_color
