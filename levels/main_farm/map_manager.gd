extends Node2D

const DAY_NIGHT_SCRIPT = preload("res://levels/main_farm/day_night_cycle.gd")

# --- Lago (laguinho estilo Stardew) ---
const WATER_TILESET = preload("res://levels/main_farm/tilesets/tileset_water.tres")
# Coords no atlas water_lake.png. Cada peça tem 4 frames de animação, então a
# coluna-base avança de 4 em 4. A animação (espuma da costa) só ocorre nas bordas;
# o centro é água calma.
const WATER_EDGE_TILES := {
	"NW": Vector2i(0, 0), "N": Vector2i(4, 0), "NE": Vector2i(8, 0),
	"W": Vector2i(0, 1), "E": Vector2i(8, 1),
	"SW": Vector2i(0, 2), "S": Vector2i(4, 2), "SE": Vector2i(8, 2),
}
const WATER_CENTER_TILE := Vector2i(4, 1)

# Anel de terra (margem) ao redor do lago — tileset estático terra↔grama (pixels do pacote).
const DIRT_TILESET = preload("res://levels/main_farm/tilesets/tileset_dirt_grass.tres")
const DIRT_EDGE_TILES := {
	"NW": Vector2i(0, 0), "N": Vector2i(1, 0), "NE": Vector2i(2, 0),
	"W": Vector2i(0, 1), "E": Vector2i(2, 1),
	"SW": Vector2i(0, 2), "S": Vector2i(1, 2), "SE": Vector2i(2, 2),
}
const DIRT_CENTER_TILE := Vector2i(1, 1)
const _NEIGHBORS_8 := [
	Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0),
	Vector2i(-1, -1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(1, 1),
]

@export var tree_scene: PackedScene
@export var stump_scene: PackedScene

var stump_variations: Array[PackedScene] = [
	preload("res://objects/nature/birch_stump.tscn"),
	preload("res://objects/nature/mahogany_stump.tscn"),
	preload("res://objects/nature/maple_stump.tscn"),
	preload("res://objects/nature/pine_stump.tscn")
]

var tree_variations: Array[PackedScene] = [
	preload("res://objects/nature/birch_tree.tscn"),
	preload("res://objects/nature/mahogany_tree.tscn"),
	preload("res://objects/nature/maple_tree.tscn"),
	preload("res://objects/nature/pine_tree.tscn")
]

@export var rock_scene: PackedScene = preload("res://objects/rock/rock.tscn")

# Lookup preloaded scenes by path para evitar load() em loop no restore
var _scene_lookup: Dictionary = {}

@export_group("Procedural Generation")
@export var spawn_trees: bool = true
@export var spawn_stumps: bool = true
## Seed for noise generation. If set to 0, a random seed will be used each time.
@export var noise_seed: int = 0
## Frequency of the noise. Higher values create smaller, denser patches.
@export_range(0.01, 1.0, 0.01) var noise_frequency: float = 0.15
## Noise threshold for spawning trees. Higher values make forests smaller and sparser. (range -1.0 to 1.0)
@export_range(-1.0, 1.0, 0.05) var spawn_threshold: float = 0.15
## Extra organic random chance (0.0 to 1.0) to spawn a tree on a valid noise cell. Helps break up uniform shapes.
@export_range(0.0, 1.0, 0.05) var spawn_chance: float = 0.7
@export_range(16.0, 128.0, 8.0) var min_tree_distance: float = 32.0

## Random chance (0.0 to 1.0) to spawn a stump on any valid ground cell outside of forests.
@export_range(0.0, 1.0, 0.01) var stump_spawn_chance: float = 0.04

## Whether to scatter mineable rocks across the map.
@export var spawn_rocks: bool = true
## Random chance (0.0 to 1.0) to spawn a rock on any valid ground cell.
@export_range(0.0, 1.0, 0.01) var rock_spawn_chance: float = 0.05

@export_group("Lake")
## Gera um laguinho na fazenda (com colisão; sem árvores/pedras dentro).
@export var spawn_lake: bool = true
## Tamanho do lago em tiles (largura x altura).
@export var lake_size: Vector2i = Vector2i(10, 7)
## Célula central do lago. No valor sentinela (-9999,-9999) é escolhido
## automaticamente um canto afastado da casa e do player.
@export var lake_center_cell: Vector2i = Vector2i(-9999, -9999)
## Largura (em tiles) da margem de terra ao redor do lago. 0 = sem margem.
@export_range(0, 4) var lake_shore_width: int = 2

# Células ocupadas pelo lago (Vector2i -> true). Usado para excluir spawn e arar.
var lake_cells: Dictionary = {}
# Células da margem de terra ao redor do lago (Vector2i -> true). Excluem spawn.
var shore_cells: Dictionary = {}

@onready var ground_layer: TileMapLayer = $GroundLayer

func _ready() -> void:
	# Build lookup de cenas já preloaded para evitar load() em loop
	for s in tree_variations:
		_scene_lookup[s.resource_path] = s
	for s in stump_variations:
		_scene_lookup[s.resource_path] = s
	if rock_scene:
		_scene_lookup[rock_scene.resource_path] = rock_scene

	# Clean up SpawnLayer if it exists in the scene
	if has_node("SpawnLayer"):
		$SpawnLayer.queue_free()

	# Gera o lago ANTES do ambiente, para que árvores/pedras o evitem.
	if spawn_lake:
		_generate_lake()

	print("MapManager _ready: env_objects tem ", FarmManager.env_objects.size(), " objetos")
	if not FarmManager.env_objects.is_empty():
		_restore_environment()
	elif spawn_trees or spawn_stumps:
		generate_environment_procedurally()

	# Dynamic Day/Night Cycle CanvasModulate
	var canvas_modulate = CanvasModulate.new()
	canvas_modulate.set_script(DAY_NIGHT_SCRIPT)
	canvas_modulate.name = "DayNightCycle"
	add_child(canvas_modulate)

	if not TimeManager.day_changed.is_connected(_on_day_changed):
		TimeManager.day_changed.connect(_on_day_changed)
		
	if not TimeManager.season_changed.is_connected(_on_season_changed):
		TimeManager.season_changed.connect(_on_season_changed)
		
	_apply_season_tiles(TimeManager.current_season)


func generate_environment_procedurally() -> void:
	if tree_variations.is_empty() and not tree_scene:
		push_warning("MapManager: tree_scene is not assigned!")
		return
		
	if not ground_layer:
		push_warning("MapManager: GroundLayer not found!")
		return

	# Configure FastNoiseLite as standard in Godot 4
	var noise := FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	
	if noise_seed == 0:
		noise.seed = randi()
	else:
		noise.seed = noise_seed
		
	noise.frequency = noise_frequency

	# Set up seeded random generator for the density filter
	var rng := RandomNumberGenerator.new()
	rng.seed = noise.seed

	var used_cells := ground_layer.get_used_cells()
	
	# Fetch player position to prevent spawning a tree directly on top of the player
	var player_pos := Vector2.ZERO
	var check_player := false
	if has_node("Player"):
		player_pos = $Player.global_position
		check_player = true

	# Fetch farmhouse position to prevent spawning trees on top of it
	var farmhouse_pos := Vector2.ZERO
	var check_farmhouse := false
	if has_node("PlayerHouse"):
		farmhouse_pos = $PlayerHouse.global_position
		check_farmhouse = true

	# Keep track of spawned positions to enforce minimum distance between trees/stumps
	var spawned_positions: Array[Vector2] = []
	var spawned_trees_count := 0
	var spawned_stumps_count := 0
	var spawned_rocks_count := 0

	for cell in used_cells:
		# Check if there is grass on top of this dirt. If so, skip spawning here.
		if has_node("Grass_layer") and $Grass_layer.get_cell_source_id(cell) != -1:
			continue

		# Não spawnar dentro do lago nem na margem de terra.
		if _is_water_or_shore(cell):
			continue

		var world_position := ground_layer.map_to_local(cell)
		
		# Prevent spawning within player's starting area (80 pixels radius)
		if check_player and world_position.distance_to(player_pos) < 80.0:
			continue
			
		# Prevent spawning within farmhouse area (140 pixels radius)
		if check_farmhouse and world_position.distance_to(farmhouse_pos) < 140.0:
			continue
			
		# Sample noise value at grid cell coordinates
		var noise_val := noise.get_noise_2d(cell.x, cell.y)
		
		# 1. Attempt tree spawn (inside forest noise patches)
		if spawn_trees and noise_val > spawn_threshold:
			if rng.randf() < spawn_chance:
				# Check if this position is too close to any already spawned object
				var too_close := false
				for pos in spawned_positions:
					if world_position.distance_to(pos) < min_tree_distance:
						too_close = true
						break
				
				if not too_close:
					var chosen_tree_scene = tree_variations.pick_random() if not tree_variations.is_empty() else tree_scene
					var new_tree = chosen_tree_scene.instantiate()

					# Randomize growth stage (more likely to be FULL)
					var rand_val = randf()
					if rand_val < 0.1:
						new_tree.current_stage = 0 # SEED
					elif rand_val < 0.2:
						new_tree.current_stage = 1 # SPROUT
					elif rand_val < 0.3:
						new_tree.current_stage = 2 # SAPLING
					elif rand_val < 0.4:
						new_tree.current_stage = 3 # SMALL
					else:
						new_tree.current_stage = 4 # FULL

					new_tree.global_position = world_position + Vector2(0, 8)
					add_child(new_tree)
					var env_id = FarmManager.register_env_object(chosen_tree_scene.resource_path, new_tree.global_position, new_tree.current_stage)
					new_tree.set_meta("env_id", env_id)

					spawned_positions.append(world_position)
					spawned_trees_count += 1
					continue # Skip stump check if tree is spawned

		# 2. Attempt rock spawn (scattered across any valid ground cell)
		if spawn_rocks and rock_scene and rng.randf() < rock_spawn_chance:
			var rock_too_close := false
			for pos in spawned_positions:
				if world_position.distance_to(pos) < min_tree_distance:
					rock_too_close = true
					break

			if not rock_too_close:
				var new_rock = rock_scene.instantiate()
				new_rock.global_position = world_position
				add_child(new_rock)
				var env_id = FarmManager.register_env_object(rock_scene.resource_path, world_position, -1)
				new_rock.set_meta("env_id", env_id)
				spawned_positions.append(world_position)
				spawned_rocks_count += 1
				continue # Skip stump check if rock is spawned

		# 3. Attempt stump spawn (outside forest noise patches, more scattered)
		if spawn_stumps and (stump_scene or not stump_variations.is_empty()) and noise_val <= spawn_threshold:
			if rng.randf() < stump_spawn_chance:
				var too_close := false
				for pos in spawned_positions:
					if world_position.distance_to(pos) < min_tree_distance:
						too_close = true
						break
				
				if not too_close:
					var chosen_stump_scene = stump_variations.pick_random() if not stump_variations.is_empty() else stump_scene
					var new_stump = chosen_stump_scene.instantiate()
					new_stump.global_position = world_position
					add_child(new_stump)
					var env_id = FarmManager.register_env_object(chosen_stump_scene.resource_path, world_position, -1)
					new_stump.set_meta("env_id", env_id)
					spawned_positions.append(world_position)
					spawned_stumps_count += 1
				
	print("MapManager: Procedurally generated ", spawned_trees_count, " trees, ", spawned_rocks_count, " rocks and ", spawned_stumps_count, " stumps using seed ", noise.seed)

# Gera o laguinho: define as células, pinta água + margens e cria a colisão.
func _generate_lake() -> void:
	if not ground_layer:
		return
	var used_cells := ground_layer.get_used_cells()
	if used_cells.is_empty():
		return

	# Bounding box do chão caminhável.
	var min_c := used_cells[0]
	var max_c := used_cells[0]
	for c in used_cells:
		min_c.x = mini(min_c.x, c.x)
		min_c.y = mini(min_c.y, c.y)
		max_c.x = maxi(max_c.x, c.x)
		max_c.y = maxi(max_c.y, c.y)

	# Centro automático num canto afastado da casa (≈30% largura, 70% altura).
	var center := lake_center_cell
	if center == Vector2i(-9999, -9999):
		center = Vector2i(
			int(lerp(float(min_c.x), float(max_c.x), 0.30)),
			int(lerp(float(min_c.y), float(max_c.y), 0.70))
		)

	var rx := maxi(1, lake_size.x / 2)
	var ry := maxi(1, lake_size.y / 2)
	# Retângulo com cantos cortados → formato arredondado (autotiling ortogonal encaixa).
	var cut := clampi(mini(rx, ry) - 1, 0, 4)

	lake_cells.clear()
	for dy in range(-ry, ry + 1):
		for dx in range(-rx, rx + 1):
			var ex := maxi(0, absi(dx) - (rx - cut))
			var ey := maxi(0, absi(dy) - (ry - cut))
			if ex + ey <= cut:
				lake_cells[Vector2i(center.x + dx, center.y + dy)] = true

	# Margem de terra (anel) ao redor da água, ABAIXO da água e ACIMA da grama.
	shore_cells.clear()
	if lake_shore_width > 0:
		var solid := lake_cells.duplicate()       # lago ∪ margem (já expandida)
		var frontier: Array = lake_cells.keys()
		for _step in range(lake_shore_width):
			var next_frontier: Array = []
			for c in frontier:
				for d in _NEIGHBORS_8:
					var nb: Vector2i = c + d
					if not solid.has(nb):
						solid[nb] = true
						shore_cells[nb] = true
						next_frontier.append(nb)
			frontier = next_frontier

		var terra := TileMapLayer.new()
		terra.name = "ShoreLayer"
		terra.tile_set = DIRT_TILESET
		terra.z_index = -1
		add_child(terra)
		# A borda da margem (transição p/ grama) é onde o vizinho NÃO está em solid.
		for cell in shore_cells:
			var role := _lake_edge_role(cell, solid)
			if role != "":
				terra.set_cell(cell, 0, DIRT_EDGE_TILES[role])
			else:
				terra.set_cell(cell, 0, DIRT_CENTER_TILE)

	# Camada de água animada com bordas de terra (por cima da margem).
	var water := TileMapLayer.new()
	water.name = "WaterLayer"
	water.tile_set = WATER_TILESET
	water.z_index = -1
	add_child(water)

	for cell in lake_cells:
		var role := _lake_edge_role(cell)
		if role != "":
			water.set_cell(cell, 0, WATER_EDGE_TILES[role])
		else:
			water.set_cell(cell, 0, WATER_CENTER_TILE) # Centro do lago (água calma)

	_build_lake_collision()

# Decide qual peça de margem usar para uma célula, conforme os vizinhos ortogonais.
func _lake_edge_role(cell: Vector2i, cells: Dictionary = lake_cells) -> String:
	var n := cells.has(cell + Vector2i(0, -1))
	var s := cells.has(cell + Vector2i(0, 1))
	var w := cells.has(cell + Vector2i(-1, 0))
	var e := cells.has(cell + Vector2i(1, 0))
	if not n and not w: return "NW"
	if not n and not e: return "NE"
	if not s and not w: return "SW"
	if not s and not e: return "SE"
	if not n: return "N"
	if not s: return "S"
	if not w: return "W"
	if not e: return "E"
	return ""  # interior (sem margem, mostra a água base)

# Verdadeiro se a célula é água do lago OU margem de terra (não spawnar objetos aqui).
func _is_water_or_shore(cell: Vector2i) -> bool:
	return lake_cells.has(cell) or shore_cells.has(cell)

# Colisão do lago: um retângulo 16x16 por célula de água (bloqueia o player).
func _build_lake_collision() -> void:
	if lake_cells.is_empty() or not ground_layer:
		return
	var body := StaticBody2D.new()
	body.name = "LakeCollision"
	body.collision_layer = 1
	body.collision_mask = 0
	add_child(body)
	for cell in lake_cells:
		var shape := CollisionShape2D.new()
		var rect := RectangleShape2D.new()
		rect.size = Vector2(16, 16)
		shape.shape = rect
		shape.position = ground_layer.map_to_local(cell)
		body.add_child(shape)

# Lago animado do Farm RPG não tem variações de estação, mantido vazio para evitar crash
func _apply_season_water(_season: int) -> void:
	pass

func _on_day_changed(_day: int) -> void:
	# Centralized daily update to optimize signal connections and enforce population caps
	var trees: Array[Node] = []
	for child in get_children():
		# Identify active trees (must have the current_stage property, which stumps do not)
		if child is StaticBody2D and "current_stage" in child:
			trees.append(child)
			
	var tree_count = trees.size()
	
	# 1. Update growth stages and manage seed spreading
	for tree in trees:
		if tree.current_stage < 4: # GrowthStage.FULL is stage 4
			# 20% growth chance
			if randf() <= 0.2:
				tree.current_stage += 1
				tree._update_appearance()
				if tree.has_meta("env_id"):
					FarmManager.update_env_stage(tree.get_meta("env_id"), tree.current_stage)
		else:
			# Fully grown trees spread seeds only if we are below population limit (max 100 trees)
			# 2% spread chance per day prevents rapid overpopulation
			if tree_count < 100 and randf() <= 0.02:
				tree._spread_seed()
				tree_count += 1
				
	# 2. Spawn a new random wild seed somewhere (15% chance per day) ONLY if under population cap (max 80 trees)
	if tree_count < 80 and randf() <= 0.15:
		_spawn_random_wild_seed()

	# 3. Respawn rocks daily (rocks do not grow; new ones simply appear over time)
	if spawn_rocks and rock_scene:
		var rock_count := 0
		for child in get_children():
			if child is StaticBody2D and "is_breaking" in child:
				rock_count += 1
		# 25% chance per day to add a new rock, capped at 40 rocks
		if rock_count < 40 and randf() <= 0.25:
			_spawn_random_rock()

func _spawn_random_wild_seed() -> void:
	if not ground_layer or tree_variations.is_empty():
		return
		
	var used_cells = ground_layer.get_used_cells()
	if used_cells.is_empty():
		return
		
	# Try up to 10 random valid cells
	for attempt in range(10):
		var cell = used_cells.pick_random()
		
		# Check if grass_layer has grass here (if so, skip or allow)
		if has_node("Grass_layer") and $Grass_layer.get_cell_source_id(cell) != -1:
			continue

		# Não spawnar dentro do lago nem na margem de terra.
		if _is_water_or_shore(cell):
			continue

		var world_position = ground_layer.map_to_local(cell)
		
		# Prevent spawning too close to player or farmhouse
		if has_node("Player") and world_position.distance_to($Player.global_position) < 80.0:
			continue
		if has_node("PlayerHouse") and world_position.distance_to($PlayerHouse.global_position) < 140.0:
			continue
			
		# Enforce distance to other trees or stumps
		var too_close = false
		for child in get_children():
			if child is StaticBody2D and (child.has_method("take_damage") or "stump" in child.name.to_lower()):
				if child.global_position.distance_to(world_position) < min_tree_distance:
					too_close = true
					break
					
		if not too_close:
			var random_tree_scene = tree_variations.pick_random()
			var new_tree = random_tree_scene.instantiate()
			new_tree.current_stage = 0 # GrowthStage.SEED
			new_tree.global_position = world_position + Vector2(0, 8)
			add_child(new_tree)
			var env_id = FarmManager.register_env_object(random_tree_scene.resource_path, new_tree.global_position, 0)
			new_tree.set_meta("env_id", env_id)
			print("MapManager: Spawned new wild seed of type ", random_tree_scene.resource_path, " at ", world_position)
			break

func _spawn_random_rock() -> void:
	if not ground_layer or not rock_scene:
		return

	var used_cells = ground_layer.get_used_cells()
	if used_cells.is_empty():
		return

	# Try up to 10 random valid cells
	for attempt in range(10):
		var cell = used_cells.pick_random()

		# Skip cells covered by grass
		if has_node("Grass_layer") and $Grass_layer.get_cell_source_id(cell) != -1:
			continue

		# Não spawnar dentro do lago nem na margem de terra.
		if _is_water_or_shore(cell):
			continue

		var world_position = ground_layer.map_to_local(cell)

		# Prevent spawning too close to player or farmhouse
		if has_node("Player") and world_position.distance_to($Player.global_position) < 80.0:
			continue
		if has_node("PlayerHouse") and world_position.distance_to($PlayerHouse.global_position) < 140.0:
			continue

		# Enforce distance to other objects (trees, stumps and rocks)
		var too_close = false
		for child in get_children():
			if child is StaticBody2D and (child.has_method("take_damage") or "stump" in child.name.to_lower()):
				if child.global_position.distance_to(world_position) < min_tree_distance:
					too_close = true
					break

		if not too_close:
			var new_rock = rock_scene.instantiate()
			new_rock.global_position = world_position
			add_child(new_rock)
			var env_id = FarmManager.register_env_object(rock_scene.resource_path, world_position, -1)
			new_rock.set_meta("env_id", env_id)
			print("MapManager: Spawned new rock at ", world_position)
			break

func _restore_environment() -> void:
	# Remove do cache objetos que caiam dentro do lago ou na margem (compat. saves antigos).
	if (not lake_cells.is_empty() or not shore_cells.is_empty()) and ground_layer:
		var filtered: Array[Dictionary] = []
		for entry in FarmManager.env_objects:
			var cell := ground_layer.local_to_map(ground_layer.to_local(entry["pos"]))
			if not _is_water_or_shore(cell):
				filtered.append(entry)
		FarmManager.env_objects = filtered

	for entry in FarmManager.env_objects:
		var path: String = entry["scene_path"]
		var scene: PackedScene = _scene_lookup.get(path)
		if scene == null:
			scene = load(path)
			if scene:
				_scene_lookup[path] = scene
		if not scene:
			continue
		var obj = scene.instantiate()
		obj.set_meta("env_id", entry["id"])
		if "current_stage" in obj and entry["stage"] >= 0:
			obj.current_stage = entry["stage"]
		add_child(obj)
		obj.global_position = entry["pos"]
	print("MapManager: Restaurados ", FarmManager.env_objects.size(), " objetos do cache de sessão.")

# Updates the grass tile layer with the texture matching the current season
func _on_season_changed(new_season: int) -> void:
	_apply_season_tiles(new_season)

func _apply_season_tiles(season: int) -> void:
	var tex_spring = preload("res://assets/tiles/farm/Tileset Grass Spring.png")
	var tex_summer = preload("res://assets/tiles/farm/Tileset Grass Summer.png")
	var tex_fall = preload("res://assets/tiles/farm/Tileset Grass Fall.png")
	var tex_winter = preload("res://assets/tiles/farm/Tileset Grass Winter.png")

	var current_tex = tex_spring
	match season:
		1: current_tex = tex_summer
		2: current_tex = tex_fall
		3: current_tex = tex_winter

	# Update base ground layer (tileset_grama.tres, source id 3)
	if ground_layer and ground_layer.tile_set:
		var grama_source = ground_layer.tile_set.get_source(3) as TileSetAtlasSource
		if grama_source:
			grama_source.texture = current_tex

	# Update secondary grass layer (tileset_grass_layer.tres, source id 2)
	if has_node("Grass_layer"):
		var grass_layer: TileMapLayer = $Grass_layer
		if grass_layer.tile_set:
			var grass_source = grass_layer.tile_set.get_source(2) as TileSetAtlasSource
			if grass_source:
				grass_source.texture = current_tex

	# Atualiza as margens do lago para a estação atual.
	_apply_season_water(season)
