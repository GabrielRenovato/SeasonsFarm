extends Sprite2D
class_name FishShadow

## Sombra/peixe que aparece se debatendo na água enquanto o peixe está fisgado.
## Usa os sprites "best fish point" do pacote Farm RPG (4 frames de salto, em loop).
## A cor varia conforme a raridade do peixe.

const RARITY_TEXTURES := {
	"common": "res://assets/sprites/fishing/fish_jump_common.png",
	"uncommon": "res://assets/sprites/fishing/fish_jump_uncommon.png",
	"rare": "res://assets/sprites/fishing/fish_jump_rare.png",
	"legendary": "res://assets/sprites/fishing/fish_jump_legendary.png",
}

@export var frame_time: float = 0.18   # duração de cada um dos 4 frames

var _t: float = 0.0
var _alive: bool = true

func setup(rarity: String) -> void:
	var path: String = RARITY_TEXTURES.get(rarity, RARITY_TEXTURES["common"])
	texture = load(path) as Texture2D
	hframes = 4
	vframes = 1
	frame = 0
	centered = true
	modulate.a = 0.0
	# Fade in suave ao aparecer
	var tw := create_tween()
	tw.tween_property(self, "modulate:a", 1.0, 0.25)

func _process(delta: float) -> void:
	if texture == null:
		return
	_t += delta
	if _t >= frame_time:
		_t -= frame_time
		frame = (frame + 1) % hframes

## Some com fade out e se remove. Idempotente.
func dismiss() -> void:
	if not _alive:
		return
	_alive = false
	set_process(false)
	var tw := create_tween()
	tw.tween_property(self, "modulate:a", 0.0, 0.2)
	tw.tween_callback(queue_free)
