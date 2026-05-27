extends CanvasLayer

@onready var time_label: Label = %TimeLabel

func _ready() -> void:
	if TimeManager:
		TimeManager.connect("time_changed", _on_time_changed)
		# Set initial time
		_update_time_display(TimeManager.day, TimeManager.hour, TimeManager.minute)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.keycode == KEY_T:
		if TimeManager:
			_update_time_display(TimeManager.day, TimeManager.hour, TimeManager.minute)

func _on_time_changed(day: int, hour: int, minute: int) -> void:
	_update_time_display(day, hour, minute)

func _update_time_display(day: int, hour: int, minute: int) -> void:
	if time_label:
		var icon = "☀️" if hour >= 6 and hour < 18 else "🌙"
		if Input.is_key_pressed(KEY_T):
			icon = "⏩"
		time_label.text = "%s Dia %d | %02d:%02d" % [icon, day, hour, minute]

