extends CanvasLayer
class_name FishingMinigame

signal minigame_finished(success: bool)

# Referências de UI
var bg_panel: ColorRect
var water_bg: ColorRect
var progress_bg: ColorRect
var progress_fill: ColorRect
var capture_bar: ColorRect
var bobber_icon: Sprite2D # Usaremos ColorRect se não houver sprite
var bobber_rect: ColorRect

# Tuning
var bar_height: float = 300.0
var bar_width: float = 30.0
var capture_bar_height: float = 60.0
var max_progress: float = 100.0
var progress: float = 20.0 # Começa com um pouquinho

# Física do jogador
var player_y: float = 0.0 # 0 é o fundo, bar_height é o topo
var player_velocity: float = 0.0
var gravity: float = -400.0
var thrust: float = 800.0
var max_velocity: float = 500.0

# Inteligência do peixe
var fish_y: float = 0.0
var fish_target_y: float = 0.0
var fish_velocity: float = 0.0
var fish_timer: float = 0.0
var behavior: String = "smooth"
var difficulty: float = 50.0

var is_active: bool = false

func _ready() -> void:
	layer = 100 # Fica por cima de tudo
	
	# Fundo principal escuro
	bg_panel = ColorRect.new()
	bg_panel.color = Color(0, 0, 0, 0.5)
	bg_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg_panel)
	
	# Container central (ajustado para o tamanho da tela)
	var center = Control.new()
	center.set_anchors_preset(Control.PRESET_CENTER)
	bg_panel.add_child(center)
	
	# Água (fundo do minigame)
	water_bg = ColorRect.new()
	water_bg.color = Color(0.1, 0.4, 0.8, 0.9)
	water_bg.size = Vector2(bar_width, bar_height)
	water_bg.position = Vector2(-bar_width, -bar_height / 2)
	center.add_child(water_bg)
	
	# Barra de captura (jogador)
	capture_bar = ColorRect.new()
	capture_bar.color = Color(0.2, 0.8, 0.2, 0.8)
	capture_bar.size = Vector2(bar_width, capture_bar_height)
	# O y é ajustado no _process
	water_bg.add_child(capture_bar)
	
	# Peixe (bobber)
	bobber_rect = ColorRect.new()
	bobber_rect.color = Color(0.9, 0.1, 0.1)
	bobber_rect.size = Vector2(bar_width - 8, 10)
	bobber_rect.position.x = 4
	water_bg.add_child(bobber_rect)
	
	# Barra de progresso (lado direito)
	progress_bg = ColorRect.new()
	progress_bg.color = Color(0.2, 0.2, 0.2, 0.9)
	progress_bg.size = Vector2(10, bar_height)
	progress_bg.position = Vector2(10, -bar_height / 2)
	center.add_child(progress_bg)
	
	progress_fill = ColorRect.new()
	progress_fill.color = Color(0.1, 0.9, 0.1)
	progress_fill.size = Vector2(10, 0)
	progress_bg.add_child(progress_fill)

func start(fish_data: Dictionary) -> void:
	behavior = fish_data.get("behavior", "smooth")
	difficulty = float(fish_data.get("difficulty", 50.0))
	
	# Ajusta barra dependendo da dificuldade
	capture_bar_height = max(30.0, 80.0 - (difficulty * 0.3))
	capture_bar.size.y = capture_bar_height
	
	player_y = 0.0
	fish_y = bar_height * 0.2 # Começa um pouco acima do fundo
	fish_target_y = fish_y
	progress = 25.0
	is_active = true
	
	# Anima entrada
	bg_panel.modulate.a = 0
	var tw = create_tween()
	tw.tween_property(bg_panel, "modulate:a", 1.0, 0.3)

func _process(delta: float) -> void:
	if not is_active:
		return
		
	_process_player(delta)
	_process_fish(delta)
	_process_progress(delta)
	_update_visuals()

func _process_player(delta: float) -> void:
	if Input.is_action_pressed("use_tool"):
		player_velocity += thrust * delta
	else:
		player_velocity += gravity * delta
		
	player_velocity = clamp(player_velocity, -max_velocity, max_velocity)
	player_y += player_velocity * delta
	
	# Colisão com as bordas
	if player_y <= 0:
		player_y = 0
		# Quica um pouco ao bater no fundo
		if player_velocity < -100:
			player_velocity = -player_velocity * 0.3
		else:
			player_velocity = 0
	elif player_y >= bar_height - capture_bar_height:
		player_y = bar_height - capture_bar_height
		player_velocity = 0

func _process_fish(delta: float) -> void:
	fish_timer -= delta
	if fish_timer <= 0:
		# Escolhe novo alvo
		_choose_new_fish_target()
		
	# Move em direção ao alvo baseado no comportamento
	var speed_mult = 1.0 + (difficulty / 100.0)
	var max_fish_speed = 150.0 * speed_mult
	
	if behavior == "dart":
		# Move instantaneamente e depois para
		fish_y = lerp(fish_y, fish_target_y, 10.0 * delta)
	elif behavior == "smooth":
		# Move suavemente
		fish_y = lerp(fish_y, fish_target_y, 2.0 * delta)
	elif behavior == "sinker":
		if fish_target_y < fish_y: # Subindo é lento
			fish_y = lerp(fish_y, fish_target_y, 1.5 * delta)
		else: # Caindo é rápido
			fish_y = lerp(fish_y, fish_target_y, 5.0 * delta)
	elif behavior == "floater":
		if fish_target_y > fish_y: # Caindo é lento
			fish_y = lerp(fish_y, fish_target_y, 1.5 * delta)
		else: # Subindo é rápido
			fish_y = lerp(fish_y, fish_target_y, 5.0 * delta)
	else: # mixed
		fish_y = lerp(fish_y, fish_target_y, randf_range(1.0, 5.0) * delta)
		
	fish_y = clamp(fish_y, 0, bar_height - 10) # 10 = tamanho do peixe

func _choose_new_fish_target() -> void:
	fish_target_y = randf_range(0, bar_height - 10)
	
	if behavior == "dart":
		fish_timer = randf_range(0.3, 1.0)
	elif behavior == "smooth":
		fish_timer = randf_range(1.0, 3.0)
	elif behavior == "sinker":
		fish_timer = randf_range(0.5, 2.0)
		if randf() > 0.3:
			fish_target_y = randf_range(0, bar_height * 0.3) # Prefere o fundo
	elif behavior == "floater":
		fish_timer = randf_range(0.5, 2.0)
		if randf() > 0.3:
			fish_target_y = randf_range(bar_height * 0.7, bar_height - 10) # Prefere o topo
	else:
		fish_timer = randf_range(0.5, 2.5)

func _process_progress(delta: float) -> void:
	# Verifica se o peixe está dentro da barra de captura
	var fish_center = fish_y + 5
	var bar_top = player_y + capture_bar_height
	var bar_bottom = player_y
	
	var in_bar = (fish_center >= bar_bottom and fish_center <= bar_top)
	
	if in_bar:
		# Ganha progresso (mais rápido se for fácil)
		progress += (15.0 + (100.0 - difficulty) * 0.2) * delta
		capture_bar.color = Color(0.2, 0.9, 0.2, 0.9) # Verde forte
	else:
		# Perde progresso
		progress -= 20.0 * delta
		capture_bar.color = Color(0.8, 0.2, 0.2, 0.8) # Vermelho
		
	progress = clamp(progress, 0, max_progress)
	
	if progress >= max_progress:
		_end_minigame(true)
	elif progress <= 0:
		_end_minigame(false)

func _update_visuals() -> void:
	# Sistema de coordenadas invertido (0 é o topo na UI, então subtraímos do bar_height)
	capture_bar.position.y = bar_height - player_y - capture_bar_height
	bobber_rect.position.y = bar_height - fish_y - 10
	
	var fill_height = (progress / max_progress) * bar_height
	progress_fill.size.y = fill_height
	progress_fill.position.y = bar_height - fill_height
	
	# Muda cor do progresso dependendo do quanto falta
	if progress > 75:
		progress_fill.color = Color(0.2, 0.9, 0.2)
	elif progress < 25:
		progress_fill.color = Color(0.9, 0.2, 0.2)
	else:
		progress_fill.color = Color(0.9, 0.9, 0.2)

func _end_minigame(success: bool) -> void:
	if not is_active: return
	is_active = false
	
	var tw = create_tween()
	tw.tween_property(bg_panel, "modulate:a", 0.0, 0.3)
	tw.tween_callback(func():
		minigame_finished.emit(success)
		queue_free()
	)
