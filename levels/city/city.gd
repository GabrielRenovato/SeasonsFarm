extends Node2D

# =====================================================================
# CITY MANAGER — Cidade (town) estilo Stardew, construída por código a
# partir do "Farm RPG - Tiny Asset Pack". Segue o padrão do map_manager
# da fazenda: pinta chão/calçada em TileMapLayers e instancia construções
# e decoração a partir de tabelas de dados (fácil de reposicionar).
# =====================================================================

const TILE := 16
const MAP_W := 32  # 512px
const MAP_H := 24  # 384px

# --- Texturas do pacote (atlas de construções / props) ---
const TEX_BASE   := preload("res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Exterior/Houses/NPCS houses/Base houses.png")
const TEX_BLACK  := preload("res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Exterior/Houses/NPCS houses/Blacksmith.png")
const TEX_FISH   := preload("res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Exterior/Houses/NPCS houses/Fishman.png")
const TEX_PROPS  := preload("res://Farm RPG - Tiny Asset Pack - (All in One)/Tileset/ALL props seasons.png")
const TEX_STONES := preload("res://assets/sprites/Props/Spring/Ground stones.png")

# --- Tilesets ---
const TS_GRAMA := preload("res://levels/main_farm/tilesets/tileset_grama.tres")
const TS_PATH  := preload("res://levels/city/tilesets/tileset_path.tres")
const DAY_NIGHT := preload("res://levels/main_farm/day_night_cycle.gd")

# Atlas
const GRASS_SRC := 3
const GRASS_TILE := Vector2i(9, 2)
const PATH_SRC := 0
const PATH_NW := Vector2i(0, 0); const PATH_N := Vector2i(1, 0); const PATH_NE := Vector2i(2, 0)
const PATH_W  := Vector2i(0, 1); const PATH_C := Vector2i(1, 1); const PATH_E  := Vector2i(2, 1)
const PATH_SW := Vector2i(0, 2); const PATH_S := Vector2i(1, 2); const PATH_SE := Vector2i(2, 2)

# --- Cenas ---
const TREE_MAPLE := preload("res://objects/nature/maple_tree.tscn")
const TREE_MAHOG := preload("res://objects/nature/mahogany_tree.tscn")

# --- Props ---
const PROP_BUSH_A := Rect2(33, 1, 15, 15)
const PROP_BUSH_B := Rect2(97, 1, 15, 15)
const PROP_TUFT   := Rect2(0, 1, 15, 14)
const PROP_FLOWER := Rect2(0, 33, 15, 14)
const PROP_MUSH   := Rect2(64, 33, 15, 14)
const STONE_REGION := Rect2(0, 16, 16, 16)

const FARM_SCENE := "res://levels/main_farm/farm.tscn"

var _returning := false
var _plaza_lights: Array[PointLight2D] = []
var ground_layer: TileMapLayer
var path_layer: TileMapLayer


func _ready() -> void:
	_build_ground()
	_build_paths()
	_build_buildings()
	_build_decoration()
	_build_perimeter()
	_build_return_portal()
	_build_plaza_lights()

	var day_night := CanvasModulate.new()
	day_night.set_script(DAY_NIGHT)
	day_night.name = "DayNightCycle"
	add_child(day_night)

	call_deferred("_setup_player_spawn")


# --- Chão de grama ---
func _build_ground() -> void:
	ground_layer = TileMapLayer.new()
	ground_layer.name = "GroundLayer"
	ground_layer.add_to_group("ground_layer") # Necessário para os limites da câmera
	ground_layer.tile_set = TS_GRAMA
	ground_layer.z_index = -2
	add_child(ground_layer)
	for y in range(MAP_H):
		for x in range(MAP_W):
			ground_layer.set_cell(Vector2i(x, y), GRASS_SRC, GRASS_TILE)


# --- Calçada ---
func _build_paths() -> void:
	path_layer = TileMapLayer.new()
	path_layer.name = "PathLayer"
	path_layer.add_to_group("ground_layer")
	path_layer.tile_set = TS_PATH
	path_layer.z_index = -1
	add_child(path_layer)

	var cells := {}
	# Praça central (menor)
	for y in range(8, 14):
		for x in range(11, 21):
			cells[Vector2i(x, y)] = true
	# Rua principal horizontal
	for y in range(11, 14):
		for x in range(3, 29):
			cells[Vector2i(x, y)] = true
	# Estrada vertical sul (volta para a fazenda)
	for y in range(13, MAP_H):
		for x in range(14, 18):
			cells[Vector2i(x, y)] = true

	for cell in cells:
		path_layer.set_cell(cell, PATH_SRC, _path_role(cell, cells))


func _path_role(cell: Vector2i, cells: Dictionary) -> Vector2i:
	var n := cells.has(cell + Vector2i(0, -1))
	var s := cells.has(cell + Vector2i(0, 1))
	var w := cells.has(cell + Vector2i(-1, 0))
	var e := cells.has(cell + Vector2i(1, 0))
	if not n and not w: return PATH_NW
	if not n and not e: return PATH_NE
	if not s and not w: return PATH_SW
	if not s and not e: return PATH_SE
	if not n: return PATH_N
	if not s: return PATH_S
	if not w: return PATH_W
	if not e: return PATH_E
	return PATH_C


# --- Construções ---
func _build_buildings() -> void:
	var list := [
		# ----- Fileira NORTE -----
		{"tex": TEX_BASE,   "reg": Rect2(17, 48, 174, 123),"foot": Vector2(256, 128)},  # Casa loja marrom (Vendedor de Sementes)

		# ----- Fileira SUL -----
		{"tex": TEX_BLACK,  "reg": Rect2(4, 7, 72, 88),    "foot": Vector2(100, 310)},   # Ferreiro
		{"tex": TEX_FISH,   "reg": Rect2(2, 7, 76, 102),   "foot": Vector2(400, 310)},  # Pescador
	]
	for b in list:
		_make_building(b["tex"], b["reg"], b["foot"])


func _make_building(tex: Texture2D, reg: Rect2, foot: Vector2) -> void:
	var body := StaticBody2D.new()
	body.collision_layer = 1
	body.collision_mask = 0
	add_child(body)
	body.position = foot

	var spr := Sprite2D.new()
	spr.texture = tex
	spr.region_enabled = true
	spr.region_rect = reg
	spr.centered = false
	spr.position = Vector2(-reg.size.x / 2.0, -reg.size.y)
	body.add_child(spr)

	var col := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	var col_h: float = clampf(reg.size.y * 0.26, 12.0, 40.0)
	rect.size = Vector2(reg.size.x * 0.72, col_h)
	col.shape = rect
	col.position = Vector2(0, -col_h / 2.0)
	body.add_child(col)


# --- Decoração ---
func _build_decoration() -> void:
	var tree_spots: Array[Vector2] = []
	for x in range(24, MAP_W * TILE, 72):       # topo
		tree_spots.append(Vector2(x, 26))
	for y in range(64, MAP_H * TILE - 20, 88):  # laterais
		tree_spots.append(Vector2(20, y))
		tree_spots.append(Vector2(MAP_W * TILE - 20, y))
	tree_spots.append_array([                   # cantos inferiores
		Vector2(60, 350), Vector2(100, 355), Vector2(400, 355), Vector2(450, 350),
	])
	var i := 0
	for p in tree_spots:
		_make_tree(TREE_MAPLE if i % 2 == 0 else TREE_MAHOG, p)
		i += 1

	for p in [Vector2(110, 150), Vector2(420, 140), Vector2(100, 250), Vector2(400, 260)]:
		_make_prop(TEX_STONES, STONE_REGION, p)

	var flora := [
		[PROP_BUSH_A, Vector2(140, 120)], [PROP_FLOWER, Vector2(172, 125)],
		[PROP_BUSH_B, Vector2(300, 122)], [PROP_TUFT, Vector2(340, 130)],
		[PROP_FLOWER, Vector2(135, 140)], [PROP_MUSH, Vector2(180, 145)],
		[PROP_FLOWER, Vector2(252, 210)], [PROP_FLOWER, Vector2(350, 210)],
		[PROP_BUSH_B, Vector2(260, 242)], [PROP_BUSH_A, Vector2(342, 242)],
	]
	for f in flora:
		_make_prop(TEX_PROPS, f[0], f[1])


func _make_tree(scene: PackedScene, pos: Vector2) -> void:
	var t := scene.instantiate()
	if "current_stage" in t:
		t.current_stage = 4
	add_child(t)
	t.global_position = pos


func _make_prop(tex: Texture2D, reg: Rect2, foot: Vector2) -> void:
	var spr := Sprite2D.new()
	spr.texture = tex
	spr.region_enabled = true
	spr.region_rect = reg
	spr.centered = false
	spr.offset = Vector2(-reg.size.x / 2.0, -reg.size.y)
	add_child(spr)
	spr.position = foot


# --- Paredes de borda ---
func _build_perimeter() -> void:
	var body := StaticBody2D.new()
	body.name = "Walls"
	body.collision_layer = 1
	body.collision_mask = 0
	add_child(body)
	var w := MAP_W * TILE
	var h := MAP_H * TILE
	var t := 8
	_add_wall(body, Vector2(w / 2.0, -t / 2.0), Vector2(w + 2 * t, t))      # topo
	_add_wall(body, Vector2(w / 2.0, h + t / 2.0), Vector2(w + 2 * t, t))   # base
	_add_wall(body, Vector2(-t / 2.0, h / 2.0), Vector2(t, h + 2 * t))      # esquerda
	_add_wall(body, Vector2(w + t / 2.0, h / 2.0), Vector2(t, h + 2 * t))   # direita


func _add_wall(body: StaticBody2D, center: Vector2, size: Vector2) -> void:
	var cs := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = size
	cs.shape = rect
	cs.position = center
	body.add_child(cs)


# --- Portal de volta ---
func _build_return_portal() -> void:
	var area := Area2D.new()
	area.name = "ReturnPortal"
	area.collision_layer = 4
	area.collision_mask = 1
	add_child(area)
	area.position = Vector2(16 * TILE, 23 * TILE + 8)  # x=256, y=376
	var cs := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(64, 20)
	cs.shape = rect
	area.add_child(cs)
	area.body_entered.connect(_on_return_portal_body_entered)
	
	area.monitoring = false
	get_tree().create_timer(0.3).timeout.connect(func(): if is_instance_valid(area): area.monitoring = true)


func _on_return_portal_body_entered(body: Node2D) -> void:
	if _returning or not (body is CharacterBody2D):
		return
	_returning = true
	if SaveManager:
		SaveManager.call_deferred("exit_to_farm")
	else:
		get_tree().call_deferred("change_scene_to_file", FARM_SCENE)


# --- Lampiões da praça ---
func _build_plaza_lights() -> void:
	var tex := GradientTexture2D.new()
	var grad := Gradient.new()
	grad.offsets = [0.0, 1.0]
	grad.colors = [Color(1.0, 0.85, 0.5, 0.95), Color(1.0, 0.85, 0.5, 0.0)]
	tex.gradient = grad
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.5)
	tex.fill_to = Vector2(1.0, 0.5)
	tex.width = 128
	tex.height = 128
	for p in [Vector2(176, 128), Vector2(336, 128), Vector2(176, 224), Vector2(336, 224)]:
		var light := PointLight2D.new()
		light.texture = tex
		light.texture_scale = 2.0
		light.energy = 0.0
		light.blend_mode = Light2D.BLEND_MODE_ADD
		light.position = p
		add_child(light)
		_plaza_lights.append(light)


func _process(delta: float) -> void:
	if _plaza_lights.is_empty():
		return
	var tm = get_node_or_null("/root/TimeManager")
	if not tm:
		return
	var time: float = tm.hour + (tm.minute / 60.0)
	var target := 0.0
	if time >= 18.5 or time < 5.5:
		target = 0.9
	elif time >= 17.5 and time < 18.5:
		target = (time - 17.5) * 0.9
	elif time >= 5.5 and time < 6.5:
		target = (1.0 - (time - 5.5)) * 0.9
	for l in _plaza_lights:
		if is_instance_valid(l):
			l.energy = lerp(l.energy, target, 1.0 - exp(-delta * 5.0))


func _setup_player_spawn() -> void:
	var player := get_node_or_null("Player")
	if player == null:
		return
	var movement = player.get_node_or_null("MovementComponent")
	if movement:
		movement.last_direction = Vector2.UP
		if movement.has_method("_update_blend_positions"):
			movement._update_blend_positions()
