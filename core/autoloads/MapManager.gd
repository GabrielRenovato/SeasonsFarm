extends Node2D

@export var tree_scene: PackedScene
@export var stump_scene: PackedScene = preload("res://objects/nature/stump.tscn")

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

@onready var ground_layer: TileMapLayer = $GroundLayer

func _ready() -> void:
	# Clean up SpawnLayer if it exists in the scene
	if has_node("SpawnLayer"):
		$SpawnLayer.queue_free()
		
	if spawn_trees or spawn_stumps:
		generate_environment_procedurally()

	# Dynamic Day/Night Cycle CanvasModulate
	var day_night_script = load("res://core/autoloads/day_night_cycle.gd")
	if day_night_script:
		var canvas_modulate = CanvasModulate.new()
		canvas_modulate.set_script(day_night_script)
		canvas_modulate.name = "DayNightCycle"
		add_child(canvas_modulate)


func generate_environment_procedurally() -> void:
	if not tree_scene:
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
	if has_node("Farmhouse"):
		farmhouse_pos = $Farmhouse.global_position
		check_farmhouse = true

	# Keep track of spawned positions to enforce minimum distance between trees/stumps
	var spawned_positions: Array[Vector2] = []
	var spawned_trees_count := 0
	var spawned_stumps_count := 0

	for cell in used_cells:
		# Check if there is grass on top of this dirt. If so, skip spawning here.
		if has_node("Grass_layer") and $Grass_layer.get_cell_source_id(cell) != -1:
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
					var new_tree = tree_scene.instantiate()
					new_tree.global_position = world_position
					add_child(new_tree)
					spawned_positions.append(world_position)
					spawned_trees_count += 1
					continue # Skip stump check if tree is spawned

		# 2. Attempt stump spawn (outside forest noise patches, more scattered)
		if spawn_stumps and stump_scene and noise_val <= spawn_threshold:
			if rng.randf() < stump_spawn_chance:
				var too_close := false
				for pos in spawned_positions:
					if world_position.distance_to(pos) < min_tree_distance:
						too_close = true
						break
				
				if not too_close:
					var new_stump = stump_scene.instantiate()
					new_stump.global_position = world_position
					add_child(new_stump)
					spawned_positions.append(world_position)
					spawned_stumps_count += 1
				
	print("MapManager: Procedurally generated ", spawned_trees_count, " trees and ", spawned_stumps_count, " stumps using seed ", noise.seed)
