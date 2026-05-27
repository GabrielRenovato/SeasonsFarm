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
	# Apenas passa o tempo normalmente
	time_accumulator += delta
		
	while time_accumulator >= minute_duration:
		time_accumulator -= minute_duration
		_add_minute()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_T:
			_advance_to_next_day()
			get_viewport().set_input_as_handled()

func _advance_to_next_day() -> void:
	day += 1
	hour = 6
	minute = 0
	time_accumulator = 0.0
	print("TimeManager: Press 'T' - Advancing immediately to next day: ", day)
	emit_signal("day_changed", day)
	emit_signal("time_changed", day, hour, minute)

func _add_minute() -> void:
	minute += 1
	if minute >= 60:
		minute = 0
		hour += 1
		if hour >= 24:
			hour = 0
			day += 1
			emit_signal("day_changed", day)
			print("TimeManager: Natural day rollover. Day: ", day)
	
	emit_signal("time_changed", day, hour, minute)
