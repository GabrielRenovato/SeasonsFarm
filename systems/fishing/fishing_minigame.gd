extends CanvasLayer
class_name FishingMinigame

signal minigame_finished(success: bool)
signal reel_tug(great: bool)   # emitido a cada acerto, para o player "puxar" a linha

## Minigame estilo "skill check" (Dead by Daylight): um ponteiro gira no círculo
## e o jogador aperta "use_tool" quando ele cruza a zona de acerto. Cada acerto
## enche a barra de progresso; errar (apertar fora ou deixar passar) faz regredir.
## Encher a barra = peixe fisgado; esvaziar = peixe escapou.
##
## A dificuldade é PROGRESSIVA: começa fácil (ponteiro lento, zona grande) e vai
## acelerando / encolhendo a zona conforme o tempo passa. Peixes mais difíceis
## chegam a um pico de dificuldade mais alto.

# Desenhador do anel/ponteiro (Control com _draw próprio que delega ao minigame).
class RingDrawer extends Control:
	var mg = null
	func _draw() -> void:
		if mg:
			mg.draw_ring(self)

# --- Progresso ---
var max_progress: float = 100.0
var progress: float = 22.0
var difficulty: float = 50.0          # dificuldade base do peixe (0..100)

# --- Skill check (ângulos em radianos; 0 = topo/12h, cresce no sentido horário) ---
var pointer_base: float = 0.0         # ângulo inicial do ponteiro (aleatório por check)
var traveled: float = 0.0             # quanto o ponteiro já girou desde o início (0..TAU)
var pointer_angle: float = 0.0        # ângulo absoluto atual (derivado, para desenho)
var pointer_speed: float = TAU        # rad/s
var zone_gap: float = 1.5             # distância angular do início do ponteiro até a zona
var zone_size: float = 0.9            # tamanho angular da zona "good"
var great_size: float = 0.3           # sub-zona "great" (no começo da good)
var check_active: bool = false
var pre_delay: float = 0.6            # pausa antes do próximo check

# --- Progressão de dificuldade ao longo do tempo ---
var elapsed: float = 0.0              # tempo total desde o início do minigame
var ramp_time: float = 13.0           # segundos até atingir a dificuldade máxima

# --- Ganhos/penalidades por acerto ---
var gain_great: float = 18.0
var gain_good: float = 10.0
var penalty_miss: float = 13.0

var is_active: bool = false

# --- Visual (compacto, estilo Stardew — não ocupa a tela toda) ---
var radius: float = 26.0
var center_pos: Vector2 = Vector2(240, 100)
var bg_panel: ColorRect
var ring: RingDrawer
var key_box: ColorRect
var key_label: Label
var feedback_label: Label
var title_label: Label
var progress_bg: ColorRect
var progress_fill: ColorRect
var hint_label: Label

func _ready() -> void:
	layer = 100
	var vp: Vector2 = get_viewport().get_visible_rect().size
	# Desloca para a direita, evitando o player no centro, mas sem ir muito para o canto
	center_pos = Vector2(vp.x * 0.65, vp.y * 0.46)

	# Container de tela cheia, transparente (só serve para o fade in/out via modulate).
	# Sem escurecer a tela: o skill check fica sobreposto e discreto.
	bg_panel = ColorRect.new()
	bg_panel.color = Color(0, 0, 0, 0)
	bg_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg_panel)

	ring = RingDrawer.new()
	ring.mg = self
	ring.set_anchors_preset(Control.PRESET_FULL_RECT)
	ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bg_panel.add_child(ring)

	# Caixa da tecla no centro do círculo (estilo "F"); dimensionada no start()
	key_box = ColorRect.new()
	key_box.color = Color(0.12, 0.12, 0.14, 0.92)
	key_box.size = Vector2(13, 13)
	bg_panel.add_child(key_box)

	key_label = Label.new()
	key_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	key_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	key_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_style_label(key_label, 8)
	key_box.add_child(key_label)

	# Título acima do círculo (nome do peixe)
	title_label = Label.new()
	title_label.position = Vector2(center_pos.x - 60, center_pos.y - radius - 14)
	title_label.size = Vector2(120, 10)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_style_label(title_label, 7)
	bg_panel.add_child(title_label)

	# Texto de feedback (GREAT/BOM/ERROU)
	feedback_label = Label.new()
	feedback_label.position = Vector2(center_pos.x - 60, center_pos.y + radius + 3)
	feedback_label.size = Vector2(120, 12)
	feedback_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_style_label(feedback_label, 9)
	feedback_label.modulate.a = 0.0
	bg_panel.add_child(feedback_label)

	# Barra de progresso na vertical, ao lado direito do círculo
	var bar_w: float = 8.0
	var bar_h: float = 80.0
	var bar_x: float = center_pos.x + radius + 16.0
	var bar_y: float = center_pos.y - (bar_h / 2.0)

	progress_bg = ColorRect.new()
	progress_bg.color = Color(0.12, 0.12, 0.14, 0.85)
	progress_bg.size = Vector2(bar_w, bar_h)
	progress_bg.position = Vector2(bar_x, bar_y)
	bg_panel.add_child(progress_bg)

	progress_fill = ColorRect.new()
	progress_fill.color = Color(0.3, 0.85, 0.4)
	progress_fill.size = Vector2(bar_w, 0)
	progress_bg.add_child(progress_fill)

	hint_label = Label.new()
	hint_label.text = "PUXAR"
	hint_label.position = Vector2(bar_x - 8, bar_y + bar_h + 4)
	_style_label(hint_label, 7)
	bg_panel.add_child(hint_label)

func start(fish_data: Dictionary) -> void:
	difficulty = float(fish_data.get("difficulty", 50.0))
	title_label.text = str(fish_data.get("name", "Peixe")).to_upper()

	# Dimensiona a caixa da tecla conforme o rótulo (ex: "F" vs "SPC")
	key_label.text = _action_key_label("use_tool")
	var kw: float = max(13.0, key_label.text.length() * 6.0 + 8.0)
	key_box.size = Vector2(kw, 13)
	key_box.position = center_pos - key_box.size / 2.0

	progress = 22.0
	elapsed = 0.0
	is_active = true
	check_active = false
	pre_delay = 0.6

	bg_panel.modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(bg_panel, "modulate:a", 1.0, 0.25)
	_update_progress_visual()

func _process(delta: float) -> void:
	if not is_active:
		return

	elapsed += delta   # alimenta a progressão de dificuldade

	if pre_delay > 0.0:
		pre_delay -= delta
		if pre_delay <= 0.0:
			_spawn_check()
		return

	if check_active:
		traveled += pointer_speed * delta
		pointer_angle = pointer_base + traveled
		if Input.is_action_just_pressed("use_tool"):
			_resolve_press()
		elif traveled >= zone_gap + zone_size + 0.12:
			# Ponteiro passou da zona sem o jogador apertar
			_resolve("miss", -penalty_miss, Color(1, 0.3, 0.3))
		elif traveled >= TAU:
			# Volta completa sem acerto (segurança)
			_resolve("miss", -penalty_miss, Color(1, 0.3, 0.3))
		ring.queue_redraw()

func _spawn_check() -> void:
	# Dificuldade efetiva = rampa de tempo (0→1) escalada pelo teto do peixe.
	# ramp=0 → bem fácil para qualquer peixe; ramp=1 → pico (peixe difícil pesa mais).
	var d: float = clamp(difficulty / 100.0, 0.0, 1.0)
	var ramp: float = clamp(elapsed / ramp_time, 0.0, 1.0)
	var eff: float = ramp * (0.55 + 0.45 * d)

	zone_size = lerpf(1.0, 0.30, eff)        # zona começa grande e encolhe
	great_size = zone_size * 0.35
	pointer_speed = lerpf(TAU * 0.55, TAU * 1.5, eff)  # ponteiro começa lento e acelera

	# Ponteiro nasce em ângulo aleatório (zona aparece em qualquer ponto do círculo);
	# a folga até a zona garante tempo de reação e que a zona caiba em uma volta.
	pointer_base = randf() * TAU
	zone_gap = randf_range(TAU * 0.28, TAU * 0.92 - zone_size)
	traveled = 0.0
	pointer_angle = pointer_base
	check_active = true
	ring.queue_redraw()

func _resolve_press() -> void:
	var rel: float = traveled - zone_gap
	if rel >= 0.0 and rel <= great_size:
		_resolve("great", gain_great, Color(0.3, 1.0, 0.45))
	elif rel >= 0.0 and rel <= zone_size:
		_resolve("good", gain_good, Color(0.95, 0.9, 0.35))
	else:
		# Apertou fora da zona (cedo ou tarde demais)
		_resolve("miss", -penalty_miss, Color(1.0, 0.3, 0.3))

func _resolve(kind: String, amount: float, color: Color) -> void:
	progress = clamp(progress + amount, 0.0, max_progress)
	check_active = false
	if kind != "miss":
		reel_tug.emit(kind == "great")   # puxão sincronizado com o acerto
	_show_feedback(kind, color)
	_update_progress_visual()
	ring.queue_redraw()

	if progress >= max_progress:
		_end_minigame(true)
	elif progress <= 0.0:
		_end_minigame(false)
	else:
		pre_delay = 0.45

func _show_feedback(kind: String, color: Color) -> void:
	var txt: String = {"great": "GREAT!", "good": "BOM", "miss": "ERROU"}.get(kind, "")
	feedback_label.text = txt
	feedback_label.modulate = color
	feedback_label.modulate.a = 1.0
	var tw := create_tween()
	tw.tween_property(feedback_label, "modulate:a", 0.0, 0.5).set_delay(0.15)

func _update_progress_visual() -> void:
	var frac: float = progress / max_progress
	var current_h = progress_bg.size.y * frac
	progress_fill.size.y = current_h
	progress_fill.position.y = progress_bg.size.y - current_h
	if frac > 0.66:
		progress_fill.color = Color(0.3, 0.85, 0.4)
	elif frac > 0.33:
		progress_fill.color = Color(0.9, 0.85, 0.3)
	else:
		progress_fill.color = Color(0.9, 0.45, 0.3)

# Desenha o anel base, a zona de acerto e o ponteiro. Chamado pelo RingDrawer._draw.
func draw_ring(c: Control) -> void:
	var ctr: Vector2 = center_pos
	# Disco escuro discreto atrás do skill check (contraste sem escurecer a tela toda)
	c.draw_circle(ctr, radius + 5.0, Color(0, 0, 0, 0.33))
	# Anel de fundo (a "pista")
	c.draw_arc(ctr, radius, 0.0, TAU, 40, Color(1, 1, 1, 0.45), 2.0, true)

	if check_active:
		# Converte do meu sistema (0 = topo) para o do draw_arc (0 = direita)
		var a0: float = (pointer_base + zone_gap) - PI / 2.0
		# Zona "good" (amarela)
		c.draw_arc(ctr, radius, a0, a0 + zone_size, 18, Color(0.95, 0.8, 0.2, 0.95), 4.0, true)
		# Zona "great" (branca, no começo da good)
		c.draw_arc(ctr, radius, a0, a0 + great_size, 10, Color(1, 1, 1, 1), 4.0, true)
		# Ponteiro radial
		var dir: Vector2 = Vector2(sin(pointer_angle), -cos(pointer_angle))
		c.draw_line(ctr + dir * (radius - 6.0), ctr + dir * (radius + 4.0), Color(0.95, 0.2, 0.2), 2.0)

func _end_minigame(success: bool) -> void:
	if not is_active:
		return
	is_active = false
	check_active = false
	ring.queue_redraw()

	var tw := create_tween()
	tw.tween_property(bg_panel, "modulate:a", 0.0, 0.3)
	tw.tween_callback(func():
		minigame_finished.emit(success)
		queue_free()
	)

# Aplica fonte pequena + contorno preto para legibilidade sobre qualquer fundo.
func _style_label(lbl: Label, size: int) -> void:
	lbl.add_theme_font_size_override("font_size", size)
	lbl.add_theme_color_override("font_color", Color(1, 1, 1))
	lbl.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	lbl.add_theme_constant_override("outline_size", 2)

# Retorna o rótulo da tecla mapeada para a ação (ex: "F", "SPC", "LMB") para exibir no centro.
func _action_key_label(action: String) -> String:
	if not InputMap.has_action(action):
		return "!"
	for ev in InputMap.action_get_events(action):
		if ev is InputEventKey:
			var kc: int = ev.physical_keycode if ev.physical_keycode != 0 else ev.keycode
			var s: String = OS.get_keycode_string(kc)
			if s == "Space":
				return "SPC"
			return s.to_upper()
		elif ev is InputEventMouseButton:
			match ev.button_index:
				MOUSE_BUTTON_LEFT: return "LMB"
				MOUSE_BUTTON_RIGHT: return "RMB"
				_: return "MB"
	return "!"
