extends Node2D
class_name FishCatchPopup

var panel: ColorRect
var label: Label

func _ready() -> void:
	# Painel de fundo escuro e semi-transparente
	panel = ColorRect.new()
	panel.color = Color(0, 0, 0, 0.6)
	panel.size = Vector2(80, 20)
	panel.position = Vector2(-40, -10) # Centraliza
	add_child(panel)
	
	# Texto do peixe
	label = Label.new()
	label.position = Vector2(-40, -10)
	label.size = Vector2(80, 20)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
	var settings = LabelSettings.new()
	settings.font_size = 12
	settings.font_color = Color.WHITE
	label.label_settings = settings
	add_child(label)
	
	# Posição inicial acima do jogador
	position = Vector2(0, -35)

## Configura e mostra o popup
func setup(fish_name: String, color: Color = Color.WHITE) -> void:
	if not is_node_ready():
		await ready
		
	label.text = fish_name
	label.label_settings.font_color = color
	
	# Animação de entrada
	scale = Vector2.ZERO
	var tween = create_tween()
	# Sobe e cresce
	tween.parallel().tween_property(self, "scale", Vector2.ONE, 0.4).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(self, "position", position + Vector2(0, -10), 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	# Espera 2.5 segundos
	tween.tween_interval(2.5)
	
	# Animação de saída
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.parallel().tween_property(self, "position", position + Vector2(0, -25), 0.3)
	
	# Remove o node quando terminar
	tween.tween_callback(queue_free)
