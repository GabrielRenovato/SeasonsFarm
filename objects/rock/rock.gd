extends StaticBody2D

## Rocha mineravel. Igual as arvores, e atingida pela ferramenta via take_damage(),
## mas so reage a Pickaxe. Ao quebrar, dropa pedras (stone.tscn) e some.
##
## Aparencia sazonal: o sprite da pedra muda conforme a estacao (TimeManager) — cinza
## com leve musgo na primavera/outono, bem esverdeada no verao e coberta de neve no
## inverno. Cada pedra tem um "tier" de tamanho (pequena/media/grande) que define vida
## e quantidade de pedra dropada; a estacao so troca a textura/regiao, mantendo o tier.

@export var stone_scene: PackedScene = preload("res://objects/rock/stone.tscn")
const CHIP_EFFECT := preload("res://objects/rock/effects/rock_chip_effect.tscn")

# Texturas por estacao (grids de 16px). O outono nao tem sheet proprio de pedras no
# pacote de assets, entao reusa as pedras neutras da primavera (ver _resolve_season).
const TEX_SPRING := preload("res://assets/sprites/Props/Spring/Ground stones.png")
const TEX_SUMMER := preload("res://assets/sprites/Props/Summer/Stones Summer.png")
const TEX_WINTER := preload("res://assets/sprites/Props/Winter/Stones .png")

# Vida e pedra dropada por tier de tamanho.
const TIER_STATS := {
	0: { "health": 3, "stone": 2 }, # pequena
	1: { "health": 4, "stone": 3 }, # media
	2: { "health": 6, "stone": 5 }, # grande
}

# Conjuntos sazonais: estacao -> tier -> { textura, regioes possiveis no atlas }.
# Chaves de estacao seguem TimeManager.Season (0=SPRING, 1=SUMMER, 3=WINTER; o outono=2
# e resolvido para a primavera). Todas as estacoes oferecem os 3 tiers, entao a pedra
# nunca precisa "trocar de tamanho" ao virar a estacao. No verao as pedras pequenas/medias
# reusam o sheet da primavera (que ja tem musgo verde) e so as grandes usam o sheet proprio.
const SEASON_SETS := {
	0: { # PRIMAVERA — pedras cinza com leve musgo
		0: { "tex": TEX_SPRING, "regions": [Rect2(0, 0, 16, 16), Rect2(16, 0, 16, 16), Rect2(32, 0, 16, 16), Rect2(48, 0, 16, 16)] },
		1: { "tex": TEX_SPRING, "regions": [Rect2(16, 16, 16, 16), Rect2(48, 16, 16, 16)] },
		2: { "tex": TEX_SPRING, "regions": [Rect2(0, 32, 32, 16), Rect2(32, 32, 32, 16)] },
	},
	1: { # VERAO — musgo verde (grandes do sheet de verao; pequenas/medias da primavera)
		0: { "tex": TEX_SPRING, "regions": [Rect2(0, 0, 16, 16), Rect2(32, 0, 16, 16)] },
		1: { "tex": TEX_SPRING, "regions": [Rect2(16, 16, 16, 16), Rect2(48, 16, 16, 16)] },
		2: { "tex": TEX_SUMMER, "regions": [Rect2(0, 0, 32, 16), Rect2(32, 0, 32, 16)] },
	},
	3: { # INVERNO — pedras cobertas de neve
		0: { "tex": TEX_WINTER, "regions": [Rect2(32, 0, 16, 16), Rect2(0, 16, 16, 16), Rect2(0, 32, 16, 16)] },
		1: { "tex": TEX_WINTER, "regions": [Rect2(16, 16, 16, 16), Rect2(16, 32, 16, 16)] },
		2: { "tex": TEX_WINTER, "regions": [Rect2(0, 0, 32, 16), Rect2(0, 48, 32, 16)] },
	},
}

@export var health: int = 3
@export var stone_amount: int = 2

@onready var sprite: Sprite2D = $SpriteOffset/Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var area_collision: CollisionShape2D = $Area2D/CollisionShape2D

var is_breaking: bool = false
var spawn_direction: float = 1.0
var _active_shake_tween: Tween

var _tier: int = 0
var _region_index: int = 0 ## Mantem a "mesma" pedra ao trocar de estacao (mod nº de regioes)

func _ready() -> void:
	_tier = _roll_tier()
	_region_index = randi()
	_apply_seasonal_appearance(true)

	# Reage a troca de estacao (repinta a pedra: musgo no verao, neve no inverno, etc.)
	if not TimeManager.season_changed.is_connected(_on_season_changed):
		TimeManager.season_changed.connect(_on_season_changed)

	# Alinha ao grid no fim do frame: no restore de save a posicao e definida DEPOIS do
	# add_child, entao o snap precisa ser deferido para ler a posicao ja correta.
	call_deferred("_align_to_cell")

# Sorteia o tamanho da pedra: a maioria pequena, poucas grandes.
func _roll_tier() -> int:
	var r := randf()
	if r < 0.6:
		return 0
	elif r < 0.9:
		return 1
	return 2

# O outono nao possui sheet de pedras no pacote -> usa as pedras neutras da primavera.
func _resolve_season(season: int) -> int:
	return 0 if season == 2 else season

# Aplica textura/regiao da estacao atual ao tier da pedra. Quando reset_health=true a
# vida volta ao maximo do tier (no spawn e a cada virada de estacao).
func _apply_seasonal_appearance(reset_health: bool) -> void:
	var season := _resolve_season(TimeManager.current_season)
	var tier_data: Dictionary = SEASON_SETS[season][_tier]
	var regions: Array = tier_data["regions"]
	var region: Rect2 = regions[_region_index % regions.size()]

	sprite.region_enabled = true
	sprite.texture = tier_data["tex"]
	sprite.region_rect = region
	# Ancora a base do sprite exatamente na origem (StaticBody2D) para o y_sort ordenar a
	# rocha pelo seu ponto de contato com o chao, igual as arvores.
	sprite.position = Vector2(0, -region.size.y / 2.0)

	var stats: Dictionary = TIER_STATS[_tier]
	if reset_health:
		health = int(stats["health"])
	stone_amount = int(stats["stone"])

	_resize_collisions(region)
	_resize_shadow(region)

# Colisao do corpo (footprint que bloqueia o player) e area de deteccao da ferramenta,
# proporcionais a largura real da regiao escolhida.
func _resize_collisions(region: Rect2) -> void:
	var body_shape := RectangleShape2D.new()
	body_shape.size = Vector2(region.size.x * 0.7, region.size.y * 0.5)
	collision_shape.shape = body_shape
	collision_shape.position = Vector2(0, -region.size.y * 0.22)

	# Area um pouco maior para facilitar acertar a picareta.
	var area_shape := RectangleShape2D.new()
	area_shape.size = Vector2(region.size.x * 0.85, region.size.y * 0.75)
	area_collision.shape = area_shape
	area_collision.position = Vector2(0, -region.size.y * 0.35)

func _resize_shadow(region: Rect2) -> void:
	var shadow := $FloorEffects/Shadow as Sprite2D
	if shadow and shadow.texture:
		shadow.scale.x = (region.size.x * 0.8) / float(shadow.texture.get_width())

# Alinha a base da pedra a borda INFERIOR da celula do grid (mesma convencao das arvores).
# Sem isso a pedra nascia centrada na celula, enquanto a deteccao da ferramenta assume a
# base meio-tile abaixo do centro: o calculo caia bem na fronteira entre duas celulas,
# deixando o golpe da picareta instavel (as vezes acertava, as vezes nao). Ancorar na
# borda inferior tambem encaixa o sprite exatamente dentro da celula.
func _align_to_cell() -> void:
	if is_breaking:
		return
	var layer := get_tree().get_first_node_in_group("dirt_layer") as TileMapLayer
	if layer == null or layer.tile_set == null:
		return
	var half_tile: float = layer.tile_set.tile_size.y * 0.5
	var cell: Vector2i = layer.local_to_map(layer.to_local(global_position))
	global_position = layer.to_global(layer.map_to_local(cell) + Vector2(0, half_tile))

func _on_season_changed(_season: int) -> void:
	if is_breaking:
		return
	_apply_seasonal_appearance(true)

func take_damage(amount: int, hitter_position: Vector2 = Vector2.ZERO, tool_name: String = "") -> void:
	if is_breaking or health <= 0:
		return

	# Rocha so pode ser minerada com a Picareta
	if tool_name != "Pickaxe":
		return

	health -= amount

	if hitter_position != Vector2.ZERO:
		spawn_direction = -1.0 if hitter_position.x > global_position.x else 1.0

	_spawn_chip_effect()

	if health > 0:
		_play_shake()
	else:
		_break()

func _spawn_chip_effect() -> void:
	var fx: AnimatedSprite2D = CHIP_EFFECT.instantiate()
	get_parent().add_child(fx)
	fx.global_position = global_position

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
	if has_meta("env_id"):
		FarmManager.remove_env_object(get_meta("env_id"))

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
