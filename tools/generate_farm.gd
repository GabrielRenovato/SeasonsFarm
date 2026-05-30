@tool
extends EditorScript

# This script will procedurally generate a better layout for the main farm.
# To run this, just open this script in the Godot script editor and press File -> Run.

func _run():
	print("Iniciando a geração do Level Design da Fazenda...")
	var scene_path = "res://levels/main_farm/farm.tscn"
	var scene_pack = load(scene_path)
	if not scene_pack:
		print("Erro ao carregar farm.tscn")
		return
	
	var farm = scene_pack.instantiate()
	
	# Reference Layers
	var grama_layer = farm.get_node_or_null("Grama")
	var ground_layer = farm.get_node_or_null("GroundLayer")
	var dirt_layer = farm.get_node_or_null("DirtLayer")
	var fence_layer = farm.get_node_or_null("Fence_layer")
	var mountain_layer = farm.get_node_or_null("Mountain")
	var spawn_layer = farm.get_node_or_null("SpawnLayer")
	
	if not grama_layer:
		print("Camada Grama não encontrada!")
		return
	
	print("Limpando camadas antigas...")
	grama_layer.clear()
	if ground_layer: ground_layer.clear()
	if dirt_layer: dirt_layer.clear()
	if fence_layer: fence_layer.clear()
	
	# Define boundaries (in tiles)
	var min_x = -20
	var max_x = 55
	var min_y = -15
	var max_y = 50
	
	# House is roughly at Tile(24, 0)
	var house_x = 24
	var house_y = 0
	
	print("Plantando grama...")
	# 1. Fill entire base with grass
	# Grama uses tileset_grama.tres (source_id 0, atlas_coords: (0~23, 0))
	for x in range(min_x, max_x + 1):
		for y in range(min_y, max_y + 1):
			# Pick a random grass variation
			var grass_variant = randi() % 24
			grama_layer.set_cell(Vector2i(x, y), 0, Vector2i(grass_variant, 0))
	
	# 2. Draw Dirt Paths
	print("Criando caminhos...")
	# DirtLayer uses tileset_dirt_layer.tres 
	# Source 0 is regular dirt path, atlas coords: (14, 40)
	var dirt_source = 0
	var dirt_atlas = Vector2i(14, 40)
	
	# Main horizontal path from house
	for x in range(10, 40):
		for y in range(house_y + 3, house_y + 6):
			dirt_layer.set_cell(Vector2i(x, y), dirt_source, dirt_atlas)
			
	# Vertical path going down from house
	for y in range(house_y + 6, max_y - 10):
		for x in range(22, 26):
			dirt_layer.set_cell(Vector2i(x, y), dirt_source, dirt_atlas)
	
	# 3. Create Farming / Tilled Soil Area
	print("Criando área de plantio...")
	# Source 1 is Tilled Soil, atlas coords: (0, 0)
	var till_source = 1
	var till_atlas = Vector2i(0, 0)
	
	var farm_start_x = 28
	var farm_end_x = 45
	var farm_start_y = 10
	var farm_end_y = 25
	
	for x in range(farm_start_x, farm_end_x + 1):
		for y in range(farm_start_y, farm_end_y + 1):
			# Leave a gap between rows for walking
			if (y - farm_start_y) % 3 != 2:
				dirt_layer.set_cell(Vector2i(x, y), till_source, till_atlas)
				
	# 4. Create Fences
	print("Colocando cercas...")
	if fence_layer:
		# Fence uses tileset_fence_layer.tres
		# Source 1 is Wooden Fence. Let's use (0,0) as generic fence post or rail.
		# Godot 4 TileMap atlas coords, we assume (0,0) looks decent as a standalone fence segment if autotiling isn't configured correctly.
		var fence_source = 1
		var fence_atlas = Vector2i(0, 0)
		
		# Outline the farming area
		for x in range(farm_start_x - 1, farm_end_x + 2):
			fence_layer.set_cell(Vector2i(x, farm_start_y - 1), fence_source, fence_atlas)
			fence_layer.set_cell(Vector2i(x, farm_end_y + 1), fence_source, fence_atlas)
			
		for y in range(farm_start_y, farm_end_y + 1):
			fence_layer.set_cell(Vector2i(farm_start_x - 1, y), fence_source, fence_atlas)
			fence_layer.set_cell(Vector2i(farm_end_x + 1, y), fence_source, fence_atlas)
			
		# Entrance gap in the fence
		fence_layer.erase_cell(Vector2i(farm_start_x - 1, farm_start_y + 5))
		fence_layer.erase_cell(Vector2i(farm_start_x - 1, farm_start_y + 6))
	
	# 5. Pack and save
	print("Salvando mapa...")
	var new_pack = PackedScene.new()
	new_pack.pack(farm)
	var err = ResourceSaver.save(new_pack, scene_path)
	
	if err == OK:
		print("Fazenda recriada e salva com sucesso!")
		print("Abra 'farm.tscn' novamente (feche e abra) para ver as mudanças.")
	else:
		print("Erro ao salvar o arquivo: ", err)
