extends StaticBody2D

@export var interior_scene: PackedScene
@onready var door_area: Area2D = $DoorArea
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var window_light: PointLight2D = null

func _ready() -> void:
	door_area.body_entered.connect(_on_door_area_body_entered)
	_setup_window_light()

func _setup_window_light() -> void:
	window_light = PointLight2D.new()
	var texture_2d = GradientTexture2D.new()
	var gradient = Gradient.new()
	gradient.offsets = [0.0, 1.0]
	gradient.colors = [Color(1.0, 0.8, 0.4, 0.95), Color(1.0, 0.8, 0.4, 0.0)]
	texture_2d.gradient = gradient
	texture_2d.fill = GradientTexture2D.FILL_RADIAL
	texture_2d.fill_from = Vector2(0.5, 0.5)
	texture_2d.fill_to = Vector2(1.0, 0.5)
	texture_2d.width = 128
	texture_2d.height = 128
	
	window_light.texture = texture_2d
	window_light.texture_scale = 2.0
	window_light.energy = 0.0
	window_light.position = Vector2(0, -16) # Posiciona um pouco acima do centro da casa (altura da janela/porta)
	window_light.blend_mode = Light2D.BLEND_MODE_ADD
	window_light.name = "WindowLight"
	add_child(window_light)

func _process(_delta: float) -> void:
	if not window_light or not is_instance_valid(window_light):
		return
		
	var time_mgr = get_node_or_null("/root/TimeManager")
	if not time_mgr:
		return
		
	var hour = time_mgr.hour
	var minute = time_mgr.minute
	var time: float = hour + (minute / 60.0)
	
	var target_energy: float = 0.0
	
	# Turn window lights on between 18:00 and 6:00
	if time >= 18.0 or time < 6.0:
		target_energy = 1.0
	# Sunset transition (17:00 to 18:00) -> Fade in
	elif time >= 17.0 and time < 18.0:
		target_energy = (time - 17.0) * 1.0
	# Sunrise transition (6:00 to 7:00) -> Fade out
	elif time >= 6.0 and time < 7.0:
		target_energy = (1.0 - (time - 6.0)) * 1.0
		
	window_light.energy = lerp(window_light.energy, target_energy, 0.1)


func _on_door_area_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		print("Passou: body é CharacterBody2D")
		
		if interior_scene != null:
			print("Passou: interior_scene NÃO é nulo")
			
			if animation_player != null:
				print("Passou: animation_player NÃO é nulo")
				
				# SE CHEGAR AQUI E NÃO TOCAR, O PROBLEMA É A ANIMAÇÃO OU O NOME
				print("Tentando dar play na animação 'open_door'")
				animation_player.play("open_door")
				await animation_player.animation_finished
				get_tree().change_scene_to_packed(interior_scene)
			else:
				print("FALHOU: animation_player é NULO")
		else:
			print("FALHOU: interior_scene é NULO")
