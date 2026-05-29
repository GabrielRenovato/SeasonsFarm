extends StaticBody2D

## Rocha mineravel. Igual as arvores, e atingida pela ferramenta via take_damage(),
## mas so reage a Pickaxe. Ao quebrar, dropa pedras (stone.tscn) e some.

@export var stone_scene: PackedScene = preload("res://objects/rock/stone.tscn")

# Variacoes de sprite lidas de "Ground stones.png" (grid de 16px).
# Cada entrada: regiao no atlas, vida e quantidade de pedra dropada.
const ROCK_VARIATIONS := [
	{ "region": Rect2(0, 0, 16, 16), "health": 3, "stone": 2 },
	{ "region": Rect2(16, 0, 16, 16), "health": 3, "stone": 2 },
	{ "region": Rect2(32, 0, 16, 16), "health": 3, "stone": 2 },
	{ "region": Rect2(48, 0, 16, 16), "health": 3, "stone": 2 },
	{ "region": Rect2(16, 16, 16, 16), "health": 4, "stone": 3 },
	{ "region": Rect2(48, 16, 16, 16), "health": 4, "stone": 3 },
	{ "region": Rect2(0, 32, 32, 16), "health": 6, "stone": 5 },
	{ "region": Rect2(32, 32, 32, 16), "health": 6, "stone": 5 },
]

@export var health: int = 3
@export var stone_amount: int = 2

@onready var sprite: Sprite2D = $SpriteOffset/Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var area_collision: CollisionShape2D = $Area2D/CollisionShape2D

var is_breaking: bool = false
var spawn_direction: float = 1.0
var _active_shake_tween: Tween

func _ready() -> void:
	# Sorteia uma variacao de rocha
	var variation = ROCK_VARIATIONS.pick_random()
	var region: Rect2 = variation["region"]
	health = variation["health"]
	stone_amount = variation["stone"]

	sprite.region_enabled = true
	sprite.region_rect = region
	# Ancora a base do sprite exatamente na origem (StaticBody2D) para o y_sort
	# ordenar a rocha pelo seu ponto de contato com o chao, igual as arvores.
	sprite.position = Vector2(0, -region.size.y / 2.0)

	# Colisao do corpo: retangulo cobrindo a metade inferior da rocha (o "footprint"),
	# proporcional a largura real escolhida para impedir o player de andar por cima.
	var body_shape := RectangleShape2D.new()
	body_shape.size = Vector2(region.size.x * 0.7, region.size.y * 0.5)
	collision_shape.shape = body_shape
	collision_shape.position = Vector2(0, -region.size.y * 0.22)

	# Area de deteccao da ferramenta: um pouco maior para facilitar acertar a picareta.
	var area_shape := RectangleShape2D.new()
	area_shape.size = Vector2(region.size.x * 0.85, region.size.y * 0.75)
	area_collision.shape = area_shape
	area_collision.position = Vector2(0, -region.size.y * 0.35)

	# Ajusta a sombra para acompanhar a largura da rocha
	var shadow := $FloorEffects/Shadow as Sprite2D
	if shadow and shadow.texture:
		shadow.scale.x = (region.size.x * 0.8) / float(shadow.texture.get_width())

func take_damage(amount: int, hitter_position: Vector2 = Vector2.ZERO, tool_name: String = "") -> void:
	if is_breaking or health <= 0:
		return

	# Rocha so pode ser minerada com a Picareta
	if tool_name != "Pickaxe":
		return

	health -= amount

	if hitter_position != Vector2.ZERO:
		spawn_direction = -1.0 if hitter_position.x > global_position.x else 1.0

	if health > 0:
		_play_shake()
	else:
		_break()

func _play_shake() -> void:
	if _active_shake_tween and _active_shake_tween.is_valid():
		_active_shake_tween.kill()
	_active_shake_tween = create_tween()
	_active_shake_tween.tween_property($SpriteOffset, "position:x", 2.0, 0.05)
	_active_shake_tween.tween_property($SpriteOffset, "position:x", -2.0, 0.1)
	_active_shake_tween.tween_property($SpriteOffset, "position:x", 0.0, 0.05)

func _break() -> void:
	if is_breaking:
		return
	is_breaking = true

	if _active_shake_tween and _active_shake_tween.is_valid():
		_active_shake_tween.kill()

	collision_shape.set_deferred("disabled", true)
	area_collision.set_deferred("disabled", true)

	_spawn_stone()

	# Fade out rapido antes de remover
	var fade_tween = create_tween()
	fade_tween.tween_property(sprite, "modulate:a", 0.0, 0.15)
	fade_tween.parallel().tween_property(sprite, "scale", Vector2(1.2, 1.2), 0.15)
	await fade_tween.finished

	queue_free()

func _spawn_stone() -> void:
	if stone_scene == null:
		return

	for i in range(stone_amount):
		var stone_instance = stone_scene.instantiate()
		get_parent().add_child(stone_instance)
		stone_instance.global_position = global_position

		var random_x = randf_range(10, 40) * spawn_direction
		var random_offset = Vector2(random_x, randf_range(8, 32))
		var target_position = global_position + random_offset

		var duration = 0.5
		var peak_y = global_position.y - randf_range(16, 32)

		var x_tween = stone_instance.create_tween()
		x_tween.tween_property(stone_instance, "global_position:x", target_position.x, duration).set_trans(Tween.TRANS_LINEAR)

		var y_tween = stone_instance.create_tween()
		y_tween.tween_property(stone_instance, "global_position:y", peak_y, duration / 2.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		y_tween.tween_property(stone_instance, "global_position:y", target_position.y, duration / 2.0).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
