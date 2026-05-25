extends Node2D

@export var tree_scene: PackedScene
@onready var spawn_layer: TileMapLayer = $SpawnLayer

func _ready() -> void:
	replace_markers_with_trees()

func replace_markers_with_trees() -> void:
	# Obtém todas as células que possuem o tile de marcação (usando um ID de exemplo)
	var used_cells = spawn_layer.get_used_cells()
	
	for cell in used_cells:
		# Pega a posição central do tile
		var world_position = spawn_layer.map_to_local(cell)
		
		# Instancia a árvore
		var new_tree = tree_scene.instantiate()
		new_tree.global_position = world_position
		
		# Adiciona ao nó pai (preferencialmente um nó com Y-Sort)
		add_child(new_tree)
		
	# Apaga a camada de marcação após instanciar tudo
	spawn_layer.queue_free()
