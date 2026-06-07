extends Node2D

# =====================================================================
# CITY MANAGER — Cidade (town) estilo Stardew, construída por código a
# partir do "Farm RPG - Tiny Asset Pack". Segue o padrão do map_manager
# da fazenda: pinta chão/calçada em TileMapLayers e instancia construções
# e decoração a partir de tabelas de dados (fácil de reposicionar).
#
# Layout (em tiles, mapa 56x36):
#   - Rua principal horizontal (calçada) cruzando o mapa
#   - Praça central
#   - Estrada vertical ao SUL ligando à fazenda (portal de volta)
#   - Fileira NORTE e fileira SUL de construções
# As coordenadas (region_rect) das construções foram medidas pixel a pixel
# nos atlas do pacote (ver _build_buildings).
# =====================================================================

const TILE := 16
const MAP_W := 56
const MAP_H := 36

# --- Texturas do pacote (atlas de construções / props) ---
const TEX_BASE   := preload("res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Exterior/Houses/NPCS houses/Base houses.png")
const TEX_BLACK  := preload("res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Exterior/Houses/NPCS houses/Blacksmith.png")
const TEX_FISH   := preload("res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Exterior/Houses/NPCS houses/Fishman.png")
const TEX_SCHOOL := preload("res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Exterior/Houses/NPCS houses/School.png")
const TEX_WIZ    := preload("res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Exterior/Houses/NPCS houses/wizard's house.png")
const TEX_TRAIN  := preload("res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Exterior/Houses/NPCS houses/train station.png")
const TEX_PROPS  := preload("res://Farm RPG - Tiny Asset Pack - (All in One)/Tileset/ALL props seasons.png")
const TEX_STONES := preload("res://assets/sprites/Props/Spring/Ground stones.png")

# --- Tilesets (grama reusa o da fazenda; calçada é novo) ---
const TS_GRAMA := preload("res://levels/main_farm/tilesets/tileset_grama.tres")
const TS_PATH  := preload("res://levels/city/tilesets/tileset_path.tres")
const DAY_NIGHT := preload("res://levels/main_farm/day_night_cycle.gd")

# Atlas: grama lisa (source id 3) e calçada cremosa 3x3 (source id 0)
const GRASS_SRC := 3
const GRASS_TILE := Vector2i(9, 2)
const PATH_SRC := 0
# Bloco cremoso 3x3 de Path tiles.png (cantos/bordas pintadas)
const PATH_NW := Vector2i(0, 0); const PATH_N := Vector2i(1, 0); const PATH_NE := Vector2i(2, 0)
const PATH_W  := Vector2i(0, 1); const PATH_C := Vector2i(1, 1); const PATH_E  := Vector2i(2, 1)
const PATH_SW := Vector2i(0, 2); const PATH_S := Vector2i(1, 2); const PATH_SE := Vector2i(2, 2)

# --- Cenas de árvore (decoração; full-grown, não somem no inverno) ---
const TREE_MAPLE := preload("res://objects/nature/maple_tree.tscn")
const TREE_MAHOG := preload("res://objects/nature/mahogany_tree.tscn")

# --- Props (flores/arbustos) — regions medidas em ALL props seasons.png ---
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

	# CanvasModulate dia/noite (mesma da fazenda) para a cidade escurecer à noite.
	var day_night := CanvasModulate.new()
	day_night.set_script(DAY_NIGHT)
	day_night.name = "DayNightCycle"
	add_child(day_night)

	# Player nasce olhando para cima (entrou pela estrada de baixo).
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


# --- Calçada (rua + praça + estrada sul) com bordas autotile ---
func _build_paths() -> void:
	path_layer = TileMapLayer.new()
	path_layer.name = "PathLayer"
	path_layer.add_to_group("ground_layer") # Necessário para os limites da câmera
	path_layer.tile_set = TS_PATH
	path_layer.z_index = -1
	add_child(path_layer)

	var cells := {}
	# Praça central
	for y in range(13, 22):
		for x in range(22, 34):
			cells[Vector2i(x, y)] = true
	# Rua principal horizontal
	for y in range(16, 19):
		for x in range(3, 53):
			cells[Vector2i(x, y)] = true
	# Estrada vertical sul (volta para a fazenda)
	for y in range(18, MAP_H):
		for x in range(26, 30):
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
# Cada entrada: tex, region (no atlas), foot (posição mundial do "pé"/base).
func _build_buildings() -> void:
	var list := [
		# ----- Fileira NORTE (de frente para a rua), foot y ~ 198 -----
		{"tex": TEX_SCHOOL, "reg": Rect2(1, 5, 214, 154),  "foot": Vector2(120, 198)},  # Escola
		{"tex": TEX_BASE,   "reg": Rect2(17, 48, 174, 123),"foot": Vector2(320, 198)},  # Casa loja marrom
		{"tex": TEX_WIZ,    "reg": Rect2(10, 2, 60, 135),  "foot": Vector2(470, 188)},  # Torre do mago
		{"tex": TEX_BASE,   "reg": Rect2(337, 48, 94, 113),"foot": Vector2(575, 198)},  # Casa vermelha
		{"tex": TEX_TRAIN,  "reg": Rect2(576, 45, 256, 99),"foot": Vector2(765, 198)},  # Estação de trem

		# ----- Fileira SUL (de frente para a rua), foot y ~ 490 -----
		{"tex": TEX_BLACK,  "reg": Rect2(4, 7, 72, 88),    "foot": Vector2(70, 490)},   # Ferreiro
		{"tex": TEX_BASE,   "reg": Rect2(0, 201, 80, 120), "foot": Vector2(170, 490)},  # Casa rosa
		{"tex": TEX_FISH,   "reg": Rect2(2, 7, 76, 102),   "foot": Vector2(270, 490)},  # Pescador
		{"tex": TEX_BASE,   "reg": Rect2(224, 25, 80, 136),"foot": Vector2(365, 490)},  # Casa A-frame
		# (vão da estrada sul: x ~408..488)
		{"tex": TEX_BASE,   "reg": Rect2(545, 77, 106, 94),"foot": Vector2(548, 490)},  # Casa loja teal
		{"tex": TEX_BASE,   "reg": Rect2(672, 57, 95, 104),"foot": Vector2(652, 490)},  # Casa laranja
		{"tex": TEX_BASE,   "reg": Rect2(96, 201, 80, 120),"foot": Vector2(748, 490)},  # Casa laranja A
		{"tex": TEX_BASE,   "reg": Rect2(192, 201, 80, 146),"foot": Vector2(840, 490)}, # Casa azul A
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
	# Base do sprite alinhada ao "pé" (origem do corpo), centralizada em x.
	spr.position = Vector2(-reg.size.x / 2.0, -reg.size.y)
	body.add_child(spr)

	# Colisão só na base sólida (parte inferior) → player passa por trás (y-sort).
	var col := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	var col_h: float = clampf(reg.size.y * 0.26, 12.0, 40.0)
	rect.size = Vector2(reg.size.x * 0.72, col_h)
	col.shape = rect
	col.position = Vector2(0, -col_h / 2.0)
	body.add_child(col)


# --- Decoração: árvores, pedras, flores/arbustos ---
func _build_decoration() -> void:
	# Árvores de borda (moldura natural ao redor da cidade)
	var tree_spots: Array[Vector2] = []
	for x in range(24, MAP_W * TILE, 72):       # topo
		tree_spots.append(Vector2(x, 26))
	for y in range(64, 520, 88):                # laterais
		tree_spots.append(Vector2(20, y))
		tree_spots.append(Vector2(MAP_W * TILE - 20, y))
	tree_spots.append_array([                   # cantos inferiores (longe da estrada)
		Vector2(60, 545), Vector2(140, 552), Vector2(760, 552), Vector2(850, 545),
	])
	var i := 0
	for p in tree_spots:
		_make_tree(TREE_MAPLE if i % 2 == 0 else TREE_MAHOG, p)
		i += 1

	# Pedras decorativas espalhadas nos quintais
	for p in [Vector2(230, 260), Vector2(640, 250), Vector2(180, 360), Vector2(720, 370), Vector2(430, 250)]:
		_make_prop(TEX_STONES, STONE_REGION, p)

	# Flores / arbustos pela praça e quintais
	var flora := [
		[PROP_BUSH_A, Vector2(360, 230)], [PROP_FLOWER, Vector2(392, 235)],
		[PROP_BUSH_B, Vector2(520, 232)], [PROP_TUFT, Vector2(560, 240)],
		[PROP_FLOWER, Vector2(255, 250)], [PROP_MUSH, Vector2(300, 255)],
		[PROP_BUSH_A, Vector2(650, 255)], [PROP_TUFT, Vector2(700, 250)],
		[PROP_FLOWER, Vector2(372, 300)], [PROP_FLOWER, Vector2(470, 300)],
		[PROP_BUSH_B, Vector2(380, 332)], [PROP_BUSH_A, Vector2(462, 332)],
		[PROP_MUSH, Vector2(420, 346)],
		[PROP_BUSH_A, Vector2(120, 430)], [PROP_TUFT, Vector2(600, 430)],
		[PROP_FLOWER, Vector2(790, 420)],
	]
	for f in flora:
		_make_prop(TEX_PROPS, f[0], f[1])


func _make_tree(scene: PackedScene, pos: Vector2) -> void:
	var t := scene.instantiate()
	if "current_stage" in t:
		t.current_stage = 4  # GrowthStage.FULL
	add_child(t)
	t.global_position = pos


func _make_prop(tex: Texture2D, reg: Rect2, foot: Vector2) -> void:
	var spr := Sprite2D.new()
	spr.texture = tex
	spr.region_enabled = true
	spr.region_rect = reg
	spr.centered = false
	# Offset desenha o sprite ACIMA do pé; node.position = foot → ordena por y-sort.
	spr.offset = Vector2(-reg.size.x / 2.0, -reg.size.y)
	add_child(spr)
	spr.position = foot


# --- Paredes de borda (confinam o player ao mapa) ---
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


# --- Portal de volta (estrada sul) → recoloca a fazenda guardada ---
func _build_return_portal() -> void:
	var area := Area2D.new()
	area.name = "ReturnPortal"
	area.collision_layer = 4
	area.collision_mask = 1
	add_child(area)
	area.position = Vector2(28 * TILE, 34 * TILE + 8)  # base da estrada
	var cs := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(64, 20)
	cs.shape = rect
	area.add_child(cs)
	area.body_entered.connect(_on_return_portal_body_entered)
	
	# Desarmado inicialmente para evitar re-trigger imediato ao voltar da fazenda
	area.monitoring = false
	get_tree().create_timer(0.3).timeout.connect(func(): if is_instance_valid(area): area.monitoring = true)


func _on_return_portal_body_entered(body: Node2D) -> void:
	if _returning or not (body is CharacterBody2D):
		return
	_returning = true
	if SaveManager:
		# Recoloca a fazenda viva (sem recriá-la → sem travada).
		SaveManager.call_deferred("exit_to_farm")
	else:
		get_tree().call_deferred("change_scene_to_file", FARM_SCENE)


# --- Lampiões da praça (luz quente que acende à noite) ---
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
	for p in [Vector2(360, 232), Vector2(520, 232), Vector2(360, 340), Vector2(520, 340)]:
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


# Faz o player olhar para cima ao entrar (mesma ideia do interior da casa).
func _setup_player_spawn() -> void:
	var player := get_node_or_null("Player")
	if player == null:
		return
	var movement = player.get_node_or_null("MovementComponent")
	if movement:
		movement.last_direction = Vector2.UP
		if movement.has_method("_update_blend_positions"):
			movement._update_blend_positions()
