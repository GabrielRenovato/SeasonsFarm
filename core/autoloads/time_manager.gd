extends Node

signal time_changed(day: int, hour: int, minute: int)
signal day_changed(day: int)

@export var minute_duration: float = 1.0 # 1 real-world second = 1 in-game minute

var minute: int = 0
var hour: int = 6 # Start at 6:00 AM
var day: int = 1

var time_accumulator: float = 0.0

# Returns the current progress of the day as a value between 0.0 and 1.0
func get_time_of_day() -> float:
	return (hour + minute / 60.0) / 24.0

func _process(delta: float) -> void:
	if Input.is_key_pressed(KEY_T):
		# Avança o tempo 30 vezes mais rápido ao segurar 'T'
		time_accumulator += delta * 30.0
	else:
		time_accumulator += delta
		
	while time_accumulator >= minute_duration:
		time_accumulator -= minute_duration
		_add_minute()


func _add_minute() -> void:
	minute += 1
	if minute >= 60:
		minute = 0
		hour += 1
		if hour >= 24:
			hour = 0
			day += 1
			emit_signal("day_changed", day)
	
	emit_signal("time_changed", day, hour, minute)
