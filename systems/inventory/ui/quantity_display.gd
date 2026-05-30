extends Control
class_name QuantityDisplay

# Renderiza um número inteiro usando o sprite atlas digits_3x5.png (3px largura × 5px altura por dígito)
# Bem mais compacto que qualquer fonte TTF — ideal para slots de inventário pequenos

const DIGIT_W: int = 3
const DIGIT_H: int = 4
const DIGIT_SPACING: int = 1
const OUTLINE_COLOR := Color(0, 0, 0, 1)
const FILL_COLOR := Color("#ffd83d") # amarelo pixel-art tipo moeda

var _atlas: Texture2D = preload("res://assets/sprites/ui/digits_3x5.png")
var _value: int = 0

func set_value(v: int) -> void:
	_value = v
	queue_redraw()

func _draw() -> void:
	if _value < 0:
		return
	var s := str(_value)
	var total_w: int = s.length() * DIGIT_W + max(s.length() - 1, 0) * DIGIT_SPACING
	# Reserva 1px de cada lado pro contorno preto
	var x: int = int(size.x) - total_w - 1
	var y: int = 1
	for ch in s:
		var d := int(ch)
		var src := Rect2(d * (DIGIT_W + 1), 0, DIGIT_W, DIGIT_H)
		# Contorno preto: 4 cópias deslocadas (cima, baixo, esquerda, direita)
		for offset in [Vector2(-1, 0), Vector2(1, 0), Vector2(0, -1), Vector2(0, 1)]:
			draw_texture_rect_region(_atlas, Rect2(Vector2(x, y) + offset, Vector2(DIGIT_W, DIGIT_H)), src, OUTLINE_COLOR)
		# Dígito amarelo por cima
		draw_texture_rect_region(_atlas, Rect2(x, y, DIGIT_W, DIGIT_H), src, FILL_COLOR)
		x += DIGIT_W + DIGIT_SPACING
