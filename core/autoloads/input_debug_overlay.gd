extends Node

## Overlay de diagnóstico de input. Mostra em tempo real os controles conectados,
## eixos e botões. Liga/desliga com F12. Visível por padrão para depuração.
##
## Objetivo: descobrir o que o Godot REALMENTE recebe do ROG Ally —
##   - Aparece algum joypad em "Conectados"?  -> o SO repassa o controle
##   - Os eixos/botões reagem ao mexer?         -> o input chega ao jogo
## Se NADA aparece ao mexer no controle, o ROG Ally está em modo Desktop/Mouse
## (Armoury Crate), não em modo Gamepad — nenhum mapeamento resolve isso.

var _layer: CanvasLayer
var _label: Label
var _visible: bool = false  # começa OCULTO — aperte F12 para mostrar

func _ready() -> void:
	_layer = CanvasLayer.new()
	_layer.layer = 128
	_layer.visible = _visible
	add_child(_layer)

	var panel := PanelContainer.new()
	panel.position = Vector2(4, 4)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0.75)
	style.set_content_margin_all(3)
	panel.add_theme_stylebox_override("panel", style)
	_layer.add_child(panel)

	_label = Label.new()
	# Viewport logico tem 240px de altura -> fonte 4px p/ caber tudo
	_label.add_theme_font_size_override("font_size", 4)
	_label.add_theme_color_override("font_color", Color(0.6, 1.0, 0.6))
	panel.add_child(_label)

func _process(_delta: float) -> void:
	if not _visible:
		return

	var lines: Array[String] = []
	lines.append("=== DEBUG DE CONTROLE (F12 p/ ocultar) ===")

	var pads := Input.get_connected_joypads()
	if pads.is_empty():
		lines.append("NENHUM controle conectado.")
		lines.append("ROG Ally: aperte o botao de MODO p/ Gamepad,")
		lines.append("ou veja o Armoury Crate (modo Gamepad/XInput).")
	else:
		for id in pads:
			lines.append("Controle %d: %s" % [id, Input.get_joy_name(id)])
			lines.append("  GUID: %s" % Input.get_joy_guid(id))
			lines.append("  Reconhecido pelo Godot: %s" % ("SIM" if Input.is_joy_known(id) else "NAO"))
			# Eixos 0..5 (analogicos + gatilhos)
			var axes := ""
			for a in range(6):
				var v := Input.get_joy_axis(id, a)
				if abs(v) > 0.15:
					axes += "ax%d=%.2f " % [a, v]
			lines.append("  Eixos ativos: %s" % (axes if axes != "" else "(nenhum)"))
			# Botoes 0..16
			var btns := ""
			for b in range(17):
				if Input.is_joy_button_pressed(id, b):
					btns += "b%d " % b
			lines.append("  Botoes: %s" % (btns if btns != "" else "(nenhum)"))

	lines.append("")
	lines.append("Acoes do jogo (mexa o controle):")
	var vec := Input.get_vector("left", "right", "up", "down")
	lines.append("  Mover (left/right/up/down): %s" % vec)
	lines.append("  use_tool: %s" % Input.is_action_pressed("use_tool"))
	lines.append("  inventory: %s" % Input.is_action_pressed("inventory"))

	_label.text = "\n".join(lines)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_F12:
		_visible = not _visible
		_layer.visible = _visible
