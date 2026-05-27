extends Node

# Global Signals
signal soil_changed(pos: Vector2i, data: Dictionary)
signal crop_planted(pos: Vector2i, crop_id: String)
signal crop_harvested(pos: Vector2i, crop_id: String)

const TILLED_DIRT_SOURCE_ID = 0
const SEED_MOUND_COORDS = Vector2i(8, 9)

# 16-Tile Autotiler Map mapping neighbor bitmask (UP=1, RIGHT=2, DOWN=4, LEFT=8)
# to exact atlas coordinates in the Sprout Lands dry tilled dirt sheet.
const AUTO_TILE_MAP = {
	0: Vector2i(14, 40),  # Isolated single tile
	1: Vector2i(15, 40),  # Neighbor UP only (Bottom end tile)
	2: Vector2i(16, 40),  # Neighbor RIGHT only (Left end tile)
	3: Vector2i(17, 40),  # Neighbors UP and RIGHT (Bottom-Left corner)
	4: Vector2i(14, 41),  # Neighbor DOWN only (Top end tile)
	5: Vector2i(15, 41),  # Neighbors UP and DOWN (Vertical tunnel/straight)
	6: Vector2i(16, 41),  # Neighbors DOWN and RIGHT (Top-Left corner)
	7: Vector2i(17, 41),  # Neighbors UP, RIGHT, DOWN (Left T-junction)
	8: Vector2i(14, 42),  # Neighbor LEFT only (Right end tile)
	9: Vector2i(15, 42),  # Neighbors UP and LEFT (Bottom-Right corner)
	10: Vector2i(16, 42), # Neighbors LEFT and RIGHT (Horizontal tunnel/straight)
	11: Vector2i(17, 42), # Neighbors UP, LEFT, RIGHT (Bottom T-junction)
	12: Vector2i(14, 43), # Neighbors DOWN and LEFT (Top-Right corner)
	13: Vector2i(15, 43), # Neighbors UP, DOWN, LEFT (Right T-junction)
	14: Vector2i(16, 43), # Neighbors DOWN, LEFT, RIGHT (Top T-junction)
	15: Vector2i(17, 43), # All neighbors (Center)
}

# Crop configs specifying row index in spritesheet and max stages
const CROP_CONFIGS = {
	"tomato": {
		"name": "Tomate",
		"row": 1,
		"stages": 6,
		"harvest_item": "tomato"
	},
	"turnip": {
		"name": "Nabo",
		"row": 0,
		"stages": 6,
		"harvest_item": "turnip"
	}
}

# State: Dict of Vector2i -> Dict
# Dict keys:
# - "tilled": bool
# - "watered": bool
# - "crop_id": String ("" if empty)
# - "days_grown": int
# - "crop_node": Node2D
var farm_data: Dictionary = {}

var dirt_layer: TileMapLayer
var seed_layer: TileMapLayer

func _ready() -> void:
	# Connect to TimeManager signal
	if TimeManager:
		TimeManager.day_changed.connect(_on_day_changed)
		print("FarmManager: Connected to TimeManager.day_changed signal.")
	else:
		push_error("FarmManager: TimeManager autoload not found!")
	
	# Fetch dirt layer
	_find_dirt_layer()

func _find_dirt_layer() -> void:
	dirt_layer = get_tree().get_first_node_in_group("dirt_layer") as TileMapLayer
	if dirt_layer == null:
		push_warning("FarmManager: dirt_layer not found in group!")
		return
		
	if seed_layer == null:
		# Cria a SeedLayer dinamicamente para desenhar as covas de semente (8,9) por cima do solo arado
		seed_layer = TileMapLayer.new()
		seed_layer.name = "SeedLayer"
		seed_layer.tile_set = dirt_layer.tile_set
		seed_layer.y_sort_enabled = true
		# Adiciona como irmã da dirt_layer (logo acima dela na árvore para garantir o desenho sobreposto)
		dirt_layer.get_parent().add_child.call_deferred(seed_layer)
		print("FarmManager: SeedLayer dynamically created.")

func till_soil(pos: Vector2i) -> bool:
	_find_dirt_layer()
	if dirt_layer == null:
		return false
		
	# Can only till if not already tilled
	if not farm_data.has(pos):
		farm_data[pos] = {
			"tilled": true,
			"watered": false,
			"crop_id": "",
			"days_grown": 0,
			"crop_node": null
		}
		_update_tile_and_neighbors(pos)
		emit_signal("soil_changed", pos, farm_data[pos])
		print("FarmManager: Tilled soil at ", pos)
		return true
	return false

func water_soil(pos: Vector2i) -> bool:
	_find_dirt_layer()
	if dirt_layer == null:
		return false
		
	if farm_data.has(pos) and farm_data[pos].tilled:
		farm_data[pos].watered = true
		_update_tile_and_neighbors(pos)
		emit_signal("soil_changed", pos, farm_data[pos])
		print("FarmManager: Watered soil at ", pos)
		return true
	print("FarmManager: Failed to water soil at ", pos, ". Tilled = ", farm_data.has(pos))
	return false

func plant_seed(pos: Vector2i, crop_id: String, crop_node: Node2D) -> bool:
	_find_dirt_layer()
	if farm_data.has(pos) and farm_data[pos].tilled and farm_data[pos].crop_id == "":
		farm_data[pos].crop_id = crop_id
		farm_data[pos].crop_node = crop_node
		farm_data[pos].days_grown = 0
		
		_update_tile_and_neighbors(pos)
		
		# Sincroniza o crop com o seu estado inicial
		if crop_node and crop_node.has_method("setup_crop"):
			var config = CROP_CONFIGS.get(crop_id, {"row": 0, "stages": 6})
			crop_node.setup_crop(crop_id, config.row, config.stages, 0, pos)
			
		emit_signal("crop_planted", pos, crop_id)
		emit_signal("soil_changed", pos, farm_data[pos])
		print("FarmManager: Planted seed ", crop_id, " at ", pos)
		return true
	print("FarmManager: Failed to plant seed ", crop_id, " at ", pos)
	return false

func harvest_crop(pos: Vector2i) -> String:
	_find_dirt_layer()
	if farm_data.has(pos) and farm_data[pos].crop_id != "":
		var crop_node = farm_data[pos].crop_node
		if crop_node and crop_node.has_method("is_fully_grown") and crop_node.is_fully_grown():
			var crop_id = farm_data[pos].crop_id
			
			# Clean up crop node
			if is_instance_valid(crop_node):
				crop_node.queue_free()
				
			farm_data[pos].crop_id = ""
			farm_data[pos].crop_node = null
			farm_data[pos].days_grown = 0
			
			_update_tile_and_neighbors(pos)
			
			emit_signal("crop_harvested", pos, crop_id)
			emit_signal("soil_changed", pos, farm_data[pos])
			print("FarmManager: Harvested ", crop_id, " from ", pos)
			return crop_id
	return ""

# Manually updates a tile and all its 4 orthogonal neighbors to auto-connect borders
func _update_tile_and_neighbors(pos: Vector2i) -> void:
	_update_soil_visuals(pos)
	_update_soil_visuals(pos + Vector2i.UP)
	_update_soil_visuals(pos + Vector2i.DOWN)
	_update_soil_visuals(pos + Vector2i.LEFT)
	_update_soil_visuals(pos + Vector2i.RIGHT)

# Calculates and sets the correct connected tile visual based on neighbor configuration
func _update_soil_visuals(pos: Vector2i) -> void:
	_find_dirt_layer()
	if dirt_layer == null:
		return
		
	if not farm_data.has(pos) or not farm_data[pos].tilled:
		# Se não estiver arado, limpa a célula na dirt_layer e na seed_layer
		dirt_layer.set_cell(pos, -1)
		if seed_layer:
			seed_layer.set_cell(pos, -1)
		return
		
	var data = farm_data[pos]
	
	# Checa vizinhos arados (UP=1, RIGHT=2, DOWN=4, LEFT=8)
	var up = _is_soil_tilled(pos + Vector2i.UP)
	var right = _is_soil_tilled(pos + Vector2i.RIGHT)
	var down = _is_soil_tilled(pos + Vector2i.DOWN)
	var left = _is_soil_tilled(pos + Vector2i.LEFT)
	
	var mask = (1 if up else 0) | (2 if right else 0) | (4 if down else 0) | (8 if left else 0)
	var base_coords = AUTO_TILE_MAP.get(mask, Vector2i(14, 40))
	
	if data.watered:
		# A terra molhada equivalente está exatamente 4 colunas à direita (+4 em X)
		var wet_coords = base_coords + Vector2i(4, 0)
		dirt_layer.set_cell(pos, TILLED_DIRT_SOURCE_ID, wet_coords)
	else:
		dirt_layer.set_cell(pos, TILLED_DIRT_SOURCE_ID, base_coords)
		
	# Não desenhamos mais a cova redundante na SeedLayer, pois o sprite da própria planta (Crop) já possui sua base visual de terra.
	if seed_layer:
		seed_layer.set_cell(pos, -1)

func _is_soil_tilled(pos: Vector2i) -> bool:
	return farm_data.has(pos) and farm_data[pos].tilled

func _on_day_changed(day: int) -> void:
	_find_dirt_layer()
	print("FarmManager: _on_day_changed called for day ", day)
	if dirt_layer == null:
		return
		
	var keys = farm_data.keys()
	for pos in keys:
		var data = farm_data[pos]
		if data.tilled:
			if data.watered:
				# Solo regado! Cresce a planta e seca a terra para o dia seguinte
				if data.crop_id != "":
					data.days_grown += 1
					var crop_node = data.crop_node
					if is_instance_valid(crop_node) and crop_node.has_method("grow"):
						crop_node.grow()
						print("FarmManager: Crop ", data.crop_id, " at ", pos, " grew to stage ", crop_node.current_stage, " (Days: ", data.days_grown, ")")
					else:
						print("FarmManager: Crop node at ", pos, " is not valid or lacks grow() method!")
				
				# Seca o solo (volta para terra seca arada)
				data.watered = false
				_update_tile_and_neighbors(pos)
				print("FarmManager: Dry soil reset at ", pos)
			else:
				# Solo seco! Se não houver planta, tem 50% de chance de reverter para terra comum
				if data.crop_id == "":
					if randf() < 0.5:
						# Reverte terra arada (limpa a célula na dirt_layer e na seed_layer)
						farm_data.erase(pos)
						_update_tile_and_neighbors(pos)
						print("FarmManager: Reverted empty dry soil at ", pos)
						continue
				else:
					print("FarmManager: Crop ", data.crop_id, " at ", pos, " did not grow because soil is dry.")
			
			emit_signal("soil_changed", pos, farm_data[pos])
