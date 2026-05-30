extends CanvasLayer
class_name HUD

# Referências aos nós visuais na interface (UI)
@onready var day_label: Label = %DayLabel       # Mostra o dia atual (ex: Day 1)
@onready var time_label: Label = %TimeLabel     # Mostra o horário atual (ex: 06:00 am)
@onready var gold_digits_container: HBoxContainer = %GoldDigitsContainer # Container dos quadrados do ouro
@onready var clock_round: TextureRect = %ClockRound # Relógio redondo cenográfico (muda com hora/estação)
@onready var hotbar_ui: HotbarUI = $Control/HotbarUI
@onready var inventory_menu_ui: InventoryMenuUI = $Control/InventoryMenuUI
@onready var energy_bar: ProgressBar = %EnergyBar

var inventory_data: InventoryData
var digit_labels: Array[Label] = []
# 7 quadradinhos de dígitos — corresponde às 7 células do sprite do Farm RPG asset pack
var max_digits: int = 7

# Função chamada para inicializar a HUD com os dados do inventário do jogador
func setup(p_inventory_data: InventoryData) -> void:
	inventory_data = p_inventory_data

	# Configura a Hotbar e o Menu de Inventário usando os dados do inventário
	hotbar_ui.setup(inventory_data)
	inventory_menu_ui.setup(inventory_data)
	inventory_menu_ui.visible = false # O menu do inventário começa fechado por padrão

# Função chamada assim que a HUD entra no jogo (no primeiro frame)
func _ready() -> void:
	_setup_gold_digits()
	
	# Se o sistema de tempo (TimeManager) existir, conecta seus sinais
	if TimeManager:
		TimeManager.connect("time_changed", _on_time_changed)
		# Define o horário inicial logo que o jogo começa
		_update_time_display(TimeManager.day, TimeManager.hour, TimeManager.minute)
	
	# Se o sistema de economia (EconomyManager) existir, conecta seus sinais para atualizar o ouro
	if EconomyManager:
		EconomyManager.gold_changed.connect(_on_gold_changed)
		_on_gold_changed(EconomyManager.gold) # Atualiza o ouro para o valor inicial
		
	# Conecta o sinal de energia para atualizar a barra verde de estamina
	if PlayerStatsManager:
		PlayerStatsManager.energy_changed.connect(_on_energy_changed)
		_on_energy_changed(PlayerStatsManager.energy, PlayerStatsManager.max_energy)

# Cria os labels para cada casa decimal do ouro — as células visuais já vêm do sprite do panel
func _setup_gold_digits() -> void:
	var pixel_font := load("res://assets/fonts/Silkscreen-Regular.ttf") as Font
	for i in range(max_digits):
		var label = Label.new()
		label.text = ""
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		if pixel_font:
			label.add_theme_font_override("font", pixel_font)
		# Silkscreen renderiza nítida em múltiplos de 8 — manter 8 e deixar o glyph encostar nas bordas
		label.add_theme_font_size_override("font_size", 8)
		label.add_theme_color_override("font_color", Color("#8f1b1b"))
		label.custom_minimum_size = Vector2(5, 7)
		gold_digits_container.add_child(label)
		digit_labels.append(label)

# Monitora as teclas que o jogador aperta
func _input(event: InputEvent) -> void:
	# Ao pressionar "T" (avançar tempo), atualiza o mostrador
	if event is InputEventKey and event.keycode == KEY_T:
		if TimeManager:
			_update_time_display(TimeManager.day, TimeManager.hour, TimeManager.minute)
			
	# Ao pressionar "TAB", abre ou fecha o inventário principal
	if event is InputEventKey and event.pressed and event.keycode == KEY_TAB:
		toggle_inventory()
		get_viewport().set_input_as_handled() # Impede que outro sistema processe a tecla "TAB" novamente

# Alterna a visibilidade do menu de inventário (se estiver aberto ele fecha, se estiver fechado ele abre)
func toggle_inventory() -> void:
	inventory_menu_ui.visible = not inventory_menu_ui.visible

# Função chamada toda vez que os minutos do jogo passam (sinal do TimeManager)
func _on_time_changed(day: int, hour: int, minute: int) -> void:
	_update_time_display(day, hour, minute)

# Função chamada toda vez que a quantidade de ouro muda (sinal do EconomyManager)
func _on_gold_changed(new_amount: int) -> void:
	if gold_digits_container:
		var amount_str = str(new_amount)
		# Se o jogador tiver mais dígitos que o limite (ex: passou de 99 milhões), mostra os últimos ou ajusta
		if amount_str.length() > max_digits:
			amount_str = amount_str.substr(amount_str.length() - max_digits, max_digits)
			
		var empty_slots = max_digits - amount_str.length()
		
		# Atualiza cada quadradinho
		for i in range(max_digits):
			if i < empty_slots:
				digit_labels[i].text = "" # Deixa vazio os quadrados da esquerda que não tem número
			else:
				digit_labels[i].text = amount_str[i - empty_slots] # Preenche com o dígito correto

# Função chamada toda vez que a energia muda
func _on_energy_changed(current_energy: float, max_energy: float) -> void:
	if energy_bar:
		energy_bar.max_value = max_energy
		# Usa um Tween para a barra descer/subir suavemente
		var tween = create_tween()
		tween.tween_property(energy_bar, "value", current_energy, 0.2)

# Atualiza os textos da interface de tempo para Inglês (lançamento global) com formato AM/PM
func _update_time_display(day: int, hour: int, minute: int) -> void:
	# Atualiza o dia
	if day_label:
		day_label.text = "Day " + str(day)
		
	# Formata e atualiza a hora em inglês (AM = manhã, PM = tarde/noite)
	if time_label:
		var am_pm = "am"
		var display_hour = hour
		
		# Converte o formato de 24 horas para o formato 12 horas americano (AM/PM)
		if display_hour >= 12:
			am_pm = "pm"
			if display_hour > 12:
				display_hour -= 12 # Transforma 13h em 1h pm, 14h em 2h pm, etc.
		if display_hour == 0:
			display_hour = 12 # Meia-noite (0h) vira 12h am
			
		# Formato compacto "6:00a" / "12:30p" — cabe nos 31px do sprite
		time_label.text = "%d:%02d%s" % [display_hour, minute, am_pm.substr(0, 1)]

	# Atualiza o sprite do relógio redondo com base na hora e estação
	_update_clock_sprite(hour)

# Atlas Clock/Others/clock.png: 6 colunas × 3 linhas de 32x32 = 192x96
# Colunas representam o momento do dia, linhas representam a "vibe" da estação:
#   Linha 0: primavera/verão (verde)
#   Linha 1: outono (vermelho)
#   Linha 2: inverno (neve)
# Colunas: 0=manhã, 1=meio-dia, 2=tarde, 3=pôr-do-sol, 4=início da noite, 5=madrugada
func _update_clock_sprite(hour: int) -> void:
	if not clock_round:
		return
	var col := 0
	if hour >= 6 and hour < 9: col = 0       # 6h–9h manhã
	elif hour >= 9 and hour < 13: col = 1    # 9h–13h meio-dia
	elif hour >= 13 and hour < 17: col = 2   # 13h–17h tarde
	elif hour >= 17 and hour < 19: col = 3   # 17h–19h pôr-do-sol
	elif hour >= 19 and hour < 22: col = 4   # 19h–22h início da noite
	else: col = 5                            # 22h–6h madrugada

	var row := 0
	if TimeManager:
		match TimeManager.current_season:
			TimeManager.Season.SPRING, TimeManager.Season.SUMMER:
				row = 0
			TimeManager.Season.FALL:
				row = 1
			TimeManager.Season.WINTER:
				row = 2

	var atlas := clock_round.texture as AtlasTexture
	if atlas:
		atlas.region = Rect2(col * 32, row * 32, 32, 32)
