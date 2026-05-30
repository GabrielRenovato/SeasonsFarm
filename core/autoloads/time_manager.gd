extends Node

signal time_changed(day: int, hour: int, minute: int)
signal day_changed(day: int)
signal season_changed(season: int)
signal year_changed(year: int)

enum Season { SPRING, SUMMER, FALL, WINTER }

@export var minute_duration: float = 0.64166667 # 1200 in-game minutes (6 AM to 2 AM) = 770 real-world seconds
@export var days_per_season: int = 28

var minute: int = 0
var hour: int = 6 # Start at 6:00 AM
var day: int = 1
var year: int = 1
var current_season: Season = Season.SPRING

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
	_increment_day()
	hour = 6
	minute = 0
	time_accumulator = 0.0
	if PlayerStatsManager:
		PlayerStatsManager.restore_full_energy()
	print("TimeManager: Press 'T' - Advancing immediately to next day: ", day, " Season: ", current_season, " Year: ", year)
	emit_signal("day_changed", day)
	emit_signal("time_changed", day, hour, minute)

func _add_minute() -> void:
	minute += 1
	if minute >= 60:
		minute = 0
		hour += 1
		if hour >= 24:
			hour = 0
			
	if hour == 2 and minute == 0:
		_increment_day()
		hour = 6
		minute = 0
		time_accumulator = 0.0
		if PlayerStatsManager:
			PlayerStatsManager.restore_full_energy()
		emit_signal("day_changed", day)
		print("TimeManager: Natural day rollover at 2:00 AM. Day: ", day, " Season: ", current_season, " Year: ", year)
	
	emit_signal("time_changed", day, hour, minute)

func _increment_day() -> void:
	day += 1
	if day > days_per_season:
		day = 1
		_advance_season()

func _advance_season() -> void:
	current_season = (current_season + 1) as Season
	if current_season > Season.WINTER:
		current_season = Season.SPRING
		year += 1
		emit_signal("year_changed", year)
		print("TimeManager: Happy New Year! Year ", year)
		
	emit_signal("season_changed", current_season)
	print("TimeManager: Season changed to ", current_season)
