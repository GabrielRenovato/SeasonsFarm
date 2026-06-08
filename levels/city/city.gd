extends Node2D

# =====================================================================
# CITY MANAGER — Cidade (town)
# As casas (Ferreiro, Pescador) e o portal de retorno são gerados por código.
# O chão, calçada e rio foram "assados" (baked) para o editor.
# =====================================================================

const TILE := 16
const MAP_W := 32  # 512px
const MAP_H := 28  # 448px

# --- Texturas do pacote (atlas de construções) ---
const TEX_BASE   := preload("res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Exterior/Houses/NPCS houses/Base houses.png")
const TEX_BLACK  := preload("res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Exterior/Houses/NPCS houses/Blacksmith.png")
const TEX_FISH   := preload("res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Exterior/Houses/NPCS houses/Fishman.png")

const DAY_NIGHT := preload("res://levels/main_farm/day_night_cycle.gd")
const FARM_SCENE := "res://levels/main_farm/farm.tscn"

var _returning := false

func _ready() -> void:
	_build_buildings()
	_build_perimeter()
	_build_return_portal()
	_build_dynamic_water_collision()
	
	var day_night := CanvasModulate.new()
	day_night.set_script(DAY_NIGHT)
	day_night.name = "DayNightCycle"
	add_child(day_night)

	call_deferred("_setup_player_spawn")

# --- Colisão Dinâmica da Água ---
func _build_dynamic_water_collision() -> void:
	var water := get_node_or_null("WaterLayer") as TileMapLayer
	var path := get_node_or_null("PathLayer") as TileMapLayer
	
	var old_col := get_node_or_null("RiverCollision")
	if old_col:
		old_col.queue_free()
		
	if not water: return
		
	var body := StaticBody2D.new()
	body.collision_layer = 1
	body.collision_mask = 0
	water.add_child(body)
	
	for cell in water.get_used_cells():
		# Se tem uma calçada/ponte em cima da água, não cria colisão!
		if path and path.get_cell_source_id(cell) != -1:
			continue
			
		var shape := CollisionShape2D.new()
		var rect := RectangleShape2D.new()
		rect.size = Vector2(16, 16)
		shape.shape = rect
		shape.position = water.map_to_local(cell)
		body.add_child(shape)




# --- Chão de grama ---
func _build_buildings() -> void:
	var list := [
		# ----- Fileira NORTE -----
		{
			"foot": Vector2(256, 128),
			"sprites": [
				# Corpo principal (esquerda)
				{
					"tex": TEX_BASE, "reg": Rect2(17, 48, 104, 123),
					"pos": Vector2(-87.0, 0.0), "offset": Vector2(0.0, -123.0)
				},
				# Anexo (direita) - Y-Sort base é 16 pixels mais alto (-16)
				{
					"tex": TEX_BASE, "reg": Rect2(121, 48, 70, 123),
					"pos": Vector2(17.0, -16.0), "offset": Vector2(0.0, -107.0)
				}
			],
			"collisions": [
				# Corpo principal (esquerda)
				{"w": 104.0, "h": 28.0, "ox": -35.0, "oy": -14.0},
				# Anexo (direita) - ajustado para baixo (oy -30)
				{"w": 70.0, "h": 28.0, "ox": 52.0, "oy": -30.0}
			]
		},  # Casa loja marrom (Vendedor de Sementes)

		# ----- Fileira SUL -----
		{
			"foot": Vector2(100, 390),
			"sprites": [
				{"tex": TEX_BLACK, "reg": Rect2(4, 7, 72, 88), "pos": Vector2(-36.0, 0.0), "offset": Vector2(0.0, -88.0)}
			]
		},   # Ferreiro
		{
			"foot": Vector2(400, 390),
			"sprites": [
				{"tex": TEX_FISH, "reg": Rect2(2, 7, 76, 102), "pos": Vector2(-38.0, 0.0), "offset": Vector2(0.0, -102.0)}
			]
		},  # Pescador
	]
	for b in list:
		_make_building(b)


func _make_building(data: Dictionary) -> void:
	var foot: Vector2 = data.get("foot")
	var reg: Rect2 = data.get("reg", Rect2())

	var body := StaticBody2D.new()
	body.collision_layer = 1
	body.collision_mask = 0
	body.y_sort_enabled = true # ATIVANDO Y-SORT!
	add_child(body)
	body.position = foot

	if data.has("sprites"):
		for s_data in data["sprites"]:
			var spr := Sprite2D.new()
			spr.texture = s_data["tex"]
			spr.region_enabled = true
			spr.region_rect = s_data["reg"]
			spr.centered = false
			spr.position = s_data["pos"]
			spr.offset = s_data["offset"]
			spr.y_sort_enabled = true
			body.add_child(spr)
	else:
		# Fallback para prédios simples (se precisar)
		var tex: Texture2D = data.get("tex")
		var spr := Sprite2D.new()
		spr.texture = tex
		spr.region_enabled = true
		spr.region_rect = reg
		spr.centered = false
		spr.position = Vector2(-reg.size.x / 2.0, 0)
		spr.offset = Vector2(0, -reg.size.y)
		spr.y_sort_enabled = true
		body.add_child(spr)

	if data.has("collisions"):
		for c_data in data["collisions"]:
			var col := CollisionShape2D.new()
			var rect := RectangleShape2D.new()
			rect.size = Vector2(c_data["w"], c_data["h"])
			col.shape = rect
			col.position = Vector2(c_data["ox"], c_data["oy"])
			body.add_child(col)
	else:
		var col := CollisionShape2D.new()
		var rect := RectangleShape2D.new()
		# Pega os valores customizados, ou usa a fórmula padrão se não existir
		var default_h = clampf(reg.size.y * 0.26, 12.0, 40.0)
		var c_w = data.get("col_w", reg.size.x * 0.72)
		var c_h = data.get("col_h", default_h)
		var c_ox = data.get("col_ox", 0.0)
		var c_oy = data.get("col_oy", -default_h / 2.0)
		
		rect.size = Vector2(c_w, c_h)
		col.shape = rect
		col.position = Vector2(c_ox, c_oy)
		body.add_child(col)





# --- Paredes de borda ---
func _build_perimeter() -> void:
	var body := StaticBody2D.new()
	body.name = "Walls"
	body.collision_layer = 1
	body.collision_mask = 0
	add_child(body)
	
	var ground := get_node_or_null("GroundLayer") as TileMapLayer
	var rect := ground.get_used_rect() if ground else Rect2i(0, 0, MAP_W, MAP_H)
	
	var min_px := Vector2(rect.position) * TILE
	var max_px := Vector2(rect.end) * TILE
	var w := max_px.x - min_px.x
	var h := max_px.y - min_px.y
	var center_x := min_px.x + w / 2.0
	var center_y := min_px.y + h / 2.0
	var t := 16.0
	
	_add_wall(body, Vector2(center_x, min_px.y - t / 2.0), Vector2(w + 2 * t, t))      # topo
	_add_wall(body, Vector2(center_x, max_px.y + t / 2.0), Vector2(w + 2 * t, t))      # base
	_add_wall(body, Vector2(min_px.x - t / 2.0, center_y), Vector2(t, h + 2 * t))      # esquerda
	_add_wall(body, Vector2(max_px.x + t / 2.0, center_y), Vector2(t, h + 2 * t))      # direita


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
	area.position = Vector2(16 * TILE, 27 * TILE + 8)  # x=256, y=440
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





func _setup_player_spawn() -> void:
	var player := get_node_or_null("Player")
	if player == null:
		return
	var movement = player.get_node_or_null("MovementComponent")
	if movement:
		movement.last_direction = Vector2.UP
		if movement.has_method("_update_blend_positions"):
			movement._update_blend_positions()
	
	# Verifica de onde o jogador veio (Check where player came from)
	var scene_manager = get_node_or_null("/root/SceneManager")
	if scene_manager:
		if scene_manager.target_spawn_door_name == "seed_shop_door":
			player.global_position = Vector2(256, 150) # Posição em frente à porta (Position in front of the door)
	
	# O gerenciamento de limites da câmera agora é feito pelo próprio player.gd
	# call_deferred("_setup_camera_limits_delayed")

func _setup_camera_limits_delayed() -> void:
	pass # Removido para usar a lógica global e segura do player.gd
