extends CanvasLayer
class_name HUD

# Referências aos nós visuais na interface (UI)
@onready var day_label: Label = %DayLabel       # Mostra o dia atual (ex: Day 1)
@onready var time_label: Label = %TimeLabel     # Mostra o horário atual (ex: 06:00 am)
@onready var gold_digits_container: HBoxContainer = %GoldDigitsContainer # Container dos quadrados do ouro
@onready var dial_icon: Label = %DialIcon       # Mostra o ícone de sol ou lua dependendo da hora
@onready var hotbar_ui: HotbarUI = $Control/HotbarUI
@onready var inventory_menu_ui: InventoryMenuUI = $Control/InventoryMenuUI

var inventory_data: InventoryData
var digit_labels: Array[Label] = []
var max_digits: int = 8 # Total de quadradinhos de decimais

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

# Cria os quadradinhos de cada casa decimal do ouro (estilo Stardew)
func _setup_gold_digits() -> void:
	var gold_inner_style = StyleBoxFlat.new()
	gold_inner_style.bg_color = Color("#eedbb6")
	gold_inner_style.border_color = Color("#c7834a")
	gold_inner_style.set_border_width_all(1)
	
	for i in range(max_digits):
		var panel = PanelContainer.new()
		panel.add_theme_stylebox_override("panel", gold_inner_style)
		
		var margin = MarginContainer.new()
		margin.add_theme_constant_override("margin_left", 1)
		margin.add_theme_constant_override("margin_right", 1)
		panel.add_child(margin)
		
		var label = Label.new()
		label.text = "" # Começa vazio
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 6)
		label.add_theme_color_override("font_color", Color("#8f1b1b"))
		label.custom_minimum_size = Vector2(5, 8)
		
		margin.add_child(label)
		gold_digits_container.add_child(panel)
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

# Atualiza os textos da interface de tempo para Inglês (lançamento global) com formato AM/PM
func _update_time_display(day: int, hour: int, minute: int) -> void:
	# Atualiza o dia
	if day_label:
		day_label.text = "Day " + str(day)
		
	# Muda o ícone entre Sol (de dia) ou Lua (de noite)
	if dial_icon:
		var icon = "☀️" if hour >= 6 and hour < 18 else "🌙"
		# Se o jogador estiver apertando "T" para passar o tempo mais rápido, mostra um ícone de "Avançar"
		if Input.is_key_pressed(KEY_T):
			icon = "⏩"
		dial_icon.text = icon
		
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
			
		# Exibe a hora no formato "06:00 am" (o %02d faz com que os números fiquem sempre com 2 casas ex: "05" ao invés de "5")
		time_label.text = "%02d:%02d %s" % [display_hour, minute, am_pm]
