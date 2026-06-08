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
		{"tex": TEX_BASE,   "reg": Rect2(17, 48, 174, 123),"foot": Vector2(256, 128)},  # Casa loja marrom (Vendedor de Sementes)

		# ----- Fileira SUL -----
		{"tex": TEX_BLACK,  "reg": Rect2(4, 7, 72, 88),    "foot": Vector2(100, 390)},   # Ferreiro
		{"tex": TEX_FISH,   "reg": Rect2(2, 7, 76, 102),   "foot": Vector2(400, 390)},  # Pescador
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
	
	# Travar a câmera nos limites da grama
	call_deferred("_setup_camera_limits_delayed")

func _setup_camera_limits_delayed() -> void:
	var player = get_node_or_null("PlayerTeste") as CharacterBody2D
	if not player: return
	
	var cam := player.get_node_or_null("Camera2D") as Camera2D
	var ground := get_node_or_null("GroundLayer") as TileMapLayer
	if cam and ground:
		var rect := ground.get_used_rect()
		cam.limit_left = rect.position.x * TILE
		cam.limit_top = rect.position.y * TILE
		cam.limit_right = rect.end.x * TILE
		cam.limit_bottom = rect.end.y * TILE


