extends Node2D

# =====================================================================
# HOUSE INTERIOR - Interior da casa do player (estilo Stardew)
# =====================================================================
# - Faz o player nascer OLHANDO PARA CIMA (como se tivesse entrado pela
#   porta de baixo).
# - A porta de baixo (ExitDoor) leva de volta para a fazenda quando o
#   player pisa nela.
# =====================================================================

# Cena da fazenda para onde a porta de baixo retorna
const FARM_SCENE: String = "res://levels/main_farm/farm.tscn"

@onready var exit_door: Area2D = $ExitDoor

var _is_exiting: bool = false  # Evita disparar a troca de cena várias vezes

var FurnitureItemScene = preload("res://objects/furniture/furniture_item.tscn")

func _ready() -> void:
	# Conecta a porta de saída
	if exit_door:
		exit_door.body_entered.connect(_on_exit_door_body_entered)
	# Ajusta o player depois que a árvore estiver pronta
	call_deferred("_setup_player_spawn")
	
	# Create furniture container and UI
	var furniture_container = Node2D.new()
	furniture_container.name = "FurnitureContainer"
	furniture_container.y_sort_enabled = true
	add_child(furniture_container)
	

	# Load existing furniture
	# Mobília desativada temporariamente (FurnitureManager.enabled)
	if FurnitureManager.enabled:
		_load_existing_furniture(furniture_container)

func _load_existing_furniture(container: Node2D) -> void:
	for id in FurnitureManager.placed_furniture:
		var data = FurnitureManager.placed_furniture[id]
		var item_id = data["item_id"]
		if FurnitureManager.catalog.has(item_id):
			var item_data = FurnitureManager.catalog[item_id]
			
			var f_item = FurnitureItemScene.instantiate()
			f_item.instance_id = id
			f_item.item_id = item_id
			f_item.position = Vector2(data["position_x"], data["position_y"])
			
			# Map old rotation degrees to index if needed, otherwise use it directly
			var rot_val = data["rotation"]
			if rot_val >= 90: # Handle old saves where it was degrees
				f_item.current_rotation_index = int(rot_val / 90.0) % 4
			else:
				f_item.current_rotation_index = int(rot_val) % 4
				
			f_item.is_placed = true
			
			container.add_child(f_item)
			
			var tex = AtlasTexture.new()
			tex.atlas = load(item_data["texture_path"])
			f_item.set_texture(tex)
			f_item.update_visuals()



# Faz o player olhar para cima ao entrar pela porta
func _setup_player_spawn() -> void:
	var player := get_node_or_null("Player")
	if player == null:
		return
	var movement := player.get_node_or_null("MovementComponent")
	if movement:
		movement.last_direction = Vector2.UP
		# Atualiza imediatamente a pose/animação para a nova direção
		if movement.has_method("_update_blend_positions"):
			movement._update_blend_positions()

# Player pisou na porta de baixo -> volta para a fazenda
func _on_exit_door_body_entered(body: Node2D) -> void:
	if _is_exiting:
		return
	if body is CharacterBody2D:
		_is_exiting = true
		# Deferido para mexer na árvore de cena só após o término da física atual.
		if SaveManager:
			# Recoloca a fazenda guardada (sem recriá-la → sem travada).
			SaveManager.call_deferred("exit_to_farm")
		else:
			get_tree().call_deferred("change_scene_to_file", FARM_SCENE)
