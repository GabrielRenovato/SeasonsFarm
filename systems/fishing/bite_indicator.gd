extends Node2D
class_name BiteIndicator

var label: Label
var tween: Tween

func _ready() -> void:
	# Configuração inicial: escondido
	visible = false
	
	# Cria o label "!"
	label = Label.new()
	label.text = "!"
	label.position = Vector2(-10, -20) # Centraliza
	
	# Ajusta as configurações de fonte
	var settings = LabelSettings.new()
	settings.font_size = 24
	settings.font_color = Color.WHITE
	settings.outline_color = Color.BLACK
	settings.outline_size = 4
	label.label_settings = settings
	
	add_child(label)
	
	# Posiciona acima do jogador
	position = Vector2(0, -30)

## Mostra o indicador com uma animação de "pulo"
func show_indicator() -> void:
	visible = true
	scale = Vector2.ZERO # Começa pequeno
	
	if tween:
		tween.kill() # Para a animação anterior, se houver
		
	tween = create_tween()
	# Faz crescer com um efeito de mola (overshoot)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.3).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	
	# Esconde automaticamente depois de 1.5s
	tween.tween_callback(hide_indicator).set_delay(1.5)

## Esconde o indicador com uma animação de desvanecimento
func hide_indicator() -> void:
	if not visible:
		return
		
	if tween:
		tween.kill()
		
	tween = create_tween()
	# Escala para baixo enquanto sobe um pouco mais
	tween.parallel().tween_property(self, "scale", Vector2.ZERO, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(self, "position", position + Vector2(0, -10), 0.2)
	# Quando terminar, esconde e reseta a posição
	tween.tween_callback(func():
		visible = false
		position = Vector2(0, -30)
	)
