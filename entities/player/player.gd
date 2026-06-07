extends CharacterBody2D

const HUD_SCENE = preload("res://ui/hud/hud.tscn")
const CUSTOMIZATION_COMPONENT = preload("res://entities/player/customization_component.gd")

@onready var movement_component: MovementComponent = $MovementComponent
@onready var tool_component: ToolComponent = $ToolComponent

@export var inventory_data: InventoryData

var lantern: PointLight2D = null

func _ready() -> void:
	# Inventário COMPARTILHADO da sessão (persiste entre cenas). Sem isto, cada
	# cena criava um player com inventário próprio e os itens "resetavam" ao
	# entrar/sair da casa.
	if SaveManager:
		inventory_data = SaveManager.get_session_inventory()
	if inventory_data == null:
		inventory_data = InventoryData.new()
		inventory_data.setup_default_inventory()

	# Interpolação de física (opt-in): o sistema é habilitado no project.godot,
	# mas só o player — e seus filhos (Camera2D, poeira, lanterna) — deve ser
	# interpolado, para movimento e câmera suaves sem trepidação ("judder").
	# Desligamos a interpolação na raiz da árvore: todos os demais objetos do
	# mundo são estáticos, animados por tween ou movidos em _process, e
	# "deslizariam" ao surgir (ou brigariam com seus tweens) se interpolados.
	get_tree().root.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
	physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_ON

	# Configura os limites da câmera baseado no tamanho real do mapa
	call_deferred("_setup_camera_limits")

	# Continuidade de posição entre cenas: ao voltar do interior da casa, reaparece
	# na porta de onde saiu. Deferred para que get_tree().current_scene já esteja pronto.
	call_deferred("_apply_pending_spawn")

	# Carrega o save uma única vez por sessão, no inventário compartilhado
	if SaveManager and SaveManager.has_save():
		SaveManager.load_game()

	# Pass inventory to ToolComponent
	if tool_component:
		tool_component.setup(inventory_data)
		
	# Instantiate HUD
	var hud_instance = HUD_SCENE.instantiate()
	hud_instance.name = "HUD"
	add_child(hud_instance)
	hud_instance.setup(inventory_data)

	# Initialize Customization Component
	var customization_instance = CUSTOMIZATION_COMPONENT.new()
	customization_instance.animation_player = $AnimationPlayer
	customization_instance.name = "CustomizationComponent"
	add_child(customization_instance)
	
	# Initialize Fishing Component
	var fishing_component = preload("res://entities/player/fishing_component.gd").new()
	fishing_component.actor = self
	fishing_component.animation_tree = $AnimationTree
	fishing_component.tool_component = tool_component
	fishing_component.name = "FishingComponent"
	add_child(fishing_component)
	
	# Setup Player Lantern (PointLight2D)
	lantern = PointLight2D.new()
	var texture_2d = GradientTexture2D.new()
	var gradient = Gradient.new()
	gradient.offsets = [0.0, 1.0]
	gradient.colors = [Color(1.0, 0.95, 0.7, 0.95), Color(1.0, 0.95, 0.7, 0.0)]
	texture_2d.gradient = gradient
	texture_2d.fill = GradientTexture2D.FILL_RADIAL
	texture_2d.fill_from = Vector2(0.5, 0.5)
	texture_2d.fill_to = Vector2(1.0, 0.5)
	texture_2d.width = 256
	texture_2d.height = 256
	
	lantern.texture = texture_2d
	lantern.texture_scale = 1.5
	lantern.energy = 0.0 # Start off during daytime
	lantern.blend_mode = Light2D.BLEND_MODE_ADD
	lantern.name = "Lantern"
	add_child(lantern)

func _process(delta: float) -> void:
	_update_lantern_energy(delta)

func _physics_process(_delta: float) -> void:
	var hud = get_node_or_null("HUD")
	if hud and hud.inventory_menu_ui and hud.inventory_menu_ui.visible:
		movement_component.stop_movement()
		return
	# Enquanto sentado, só processamos movimento: qualquer input de direção
	# faz o player levantar (ver MovementComponent.handle_movement). Pular o
	# ToolComponent evita disparar ferramentas / re-sentar enquanto sentado.
	if movement_component.is_sitting:
		movement_component.handle_movement()
		return

	tool_component.update_target_preview(movement_component.last_direction)
	tool_component.handle_tool_switch()
	tool_component.handle_tool_use(movement_component.last_direction)

	if tool_component.is_using_tool:
		movement_component.stop_movement()
	else:
		movement_component.handle_movement()

	_handle_dust_particles()

var current_chair: Node2D = null
var current_sit_direction: String = ""

# Direção (string) -> vetor unitário, para manter last_direction coerente
const SIT_DIR_VECTORS := {
	"down": Vector2.DOWN,
	"up": Vector2.UP,
	"right": Vector2.RIGHT,
	"left": Vector2.LEFT,
}

# Offset do player em relação ao CENTRO da cadeira ao sentar (calibrado).
# Lembre que o sprite Body fica em (0,-10) do player.
const SIT_OFFSETS := {
	"down": Vector2(0, 8),
	"up": Vector2(0, 6),
	"right": Vector2(1, 8),
	"left": Vector2(-1, 8),
}

func sit_down(chair: Node2D, direction: String) -> void:
	if movement_component.is_sitting:
		return
	movement_component.is_sitting = true
	current_chair = chair
	current_sit_direction = direction

	# Posiciona o player sobre o assento
	global_position = chair.global_position + SIT_OFFSETS.get(direction, Vector2(0, 6))
	velocity = Vector2.ZERO
	# Teletransporte: zera a interpolação para o player não "deslizar" até a cadeira.
	reset_physics_interpolation()

	# Ordenação: o player fica sempre em z_index 0 (acima do piso, nunca some).
	# Para down/right/left o Y-sort já desenha o player na frente do encosto.
	# Para "up" (de costas), o encosto deve cobrir o corpo: elevamos o z_index
	# DA CADEIRA para que ela desenhe por cima, deixando só a cabeça à mostra.
	z_index = 0
	if direction == "up":
		chair.z_index = 1

	# Mantém a direção coerente para quando levantar
	movement_component.last_direction = SIT_DIR_VECTORS.get(direction, Vector2.DOWN)

	$AnimationTree.active = false
	$AnimationPlayer.play("sit_" + direction)

func stand_up() -> void:
	if not movement_component.is_sitting:
		return
	movement_component.is_sitting = false
	$AnimationTree.active = true
	z_index = 0
	# Restaura o z_index da cadeira (caso tenha sido elevado no sit "up").
	if current_chair and is_instance_valid(current_chair):
		current_chair.z_index = 0
	# O player levanta na própria posição do assento (fora da colisão da cadeira)
	# e o MovementComponent já o coloca em movimento no mesmo frame.
	current_chair = null
	current_sit_direction = ""

func _handle_dust_particles() -> void:
	var dust_particles = get_node_or_null("FloorEffects/DustParticles") as CPUParticles2D
	if not dust_particles:
		return
		
	if velocity.length() == 0:
		dust_particles.emitting = false
		return
		
	var current_scene = get_tree().current_scene
	var grass_layer = current_scene.get_node_or_null("Grass_layer") as TileMapLayer
	
	var is_on_dirt = true
	if grass_layer:
		var cell_pos = grass_layer.local_to_map(grass_layer.to_local(global_position))
		if grass_layer.get_cell_source_id(cell_pos) != -1:
			is_on_dirt = false
			
	dust_particles.emitting = is_on_dirt

func _update_lantern_energy(delta: float) -> void:
	if not lantern or not is_instance_valid(lantern):
		return
		
	# Safe check if TimeManager is loaded
	var time_mgr = get_node_or_null("/root/TimeManager")
	if not time_mgr:
		return
		
	var hour = time_mgr.hour
	var minute = time_mgr.minute
	var time: float = hour + (minute / 60.0)
	
	var target_energy: float = 0.0
	
	# Night time (18:30 to 5:30) -> Lantern is fully active (0.95 energy)
	if time >= 18.5 or time < 5.5:
		target_energy = 0.95
	# Sunset transition (17:30 to 18:30) -> Fade in
	elif time >= 17.5 and time < 18.5:
		target_energy = (time - 17.5) * 0.95
	# Sunrise transition (5:30 to 6:30) -> Fade out
	elif time >= 5.5 and time < 6.5:
		target_energy = (1.0 - (time - 5.5)) * 0.95
	
	# Interpolação suave independente de frame rate (speed = 5.0 ≈ 0.2s de fade)
	lantern.energy = lerp(lantern.energy, target_energy, 1.0 - exp(-delta * 5.0))

func _setup_camera_limits() -> void:
	var camera = get_node_or_null("Camera2D") as Camera2D
	if not camera:
		return

	# Percorre todas as TileMapLayers da cena e calcula o bounding box total
	var all_tilemaps: Array = []
	_collect_tilemaps(get_tree().current_scene, all_tilemaps)

	var min_x = INF; var min_y = INF
	var max_x = -INF; var max_y = -INF

	for tm in all_tilemaps:
		var tilemap := tm as TileMapLayer
		if not tilemap.tile_set:
			continue
		var used := tilemap.get_used_rect()
		if used.size == Vector2i.ZERO:
			continue
		var ts := tilemap.tile_set.tile_size
		var lx = used.position.x * ts.x
		var ly = used.position.y * ts.y
		var rx = (used.position.x + used.size.x) * ts.x
		var ry = (used.position.y + used.size.y) * ts.y
		if lx < min_x: min_x = lx
		if ly < min_y: min_y = ly
		if rx > max_x: max_x = rx
		if ry > max_y: max_y = ry

	if min_x == INF:
		return

	var padding = 16

	camera.limit_left   = int(min_x) - padding
	camera.limit_top    = int(min_y) - padding
	camera.limit_right  = int(max_x) + padding
	camera.limit_bottom = int(max_y) + padding

	print("Camera limits set: L=%d T=%d R=%d B=%d" % [camera.limit_left, camera.limit_top, camera.limit_right, camera.limit_bottom])

func _collect_tilemaps(node: Node, result: Array) -> void:
	if node is TileMapLayer:
		result.append(node)
	for child in node.get_children():
		_collect_tilemaps(child, result)

# Reposiciona o player no ponto de retorno gravado para esta cena (ex.: a porta
# da casa ao voltar do interior). Se não houver spawn pendente para a cena atual,
# mantém o spawn fixo definido no .tscn (caso do início de jogo).
func _apply_pending_spawn() -> void:
	if not SaveManager:
		return
	var scene := get_tree().current_scene
	if scene == null:
		return
	var spawn = SaveManager.take_pending_spawn(scene.scene_file_path)
	if spawn != null:
		global_position = spawn
		# Zera a interpolação para não "deslizar" do spawn fixo até a porta.
		reset_physics_interpolation()

func _unhandled_input(event: InputEvent) -> void:
	# F5 para salvar o jogo
	if event is InputEventKey and event.pressed and event.keycode == KEY_F5:
		if SaveManager:
			SaveManager.save_game()
		get_viewport().set_input_as_handled()

	# Pressione 'C' para abrir o menu de personalização
	if event is InputEventKey and event.pressed and event.keycode == KEY_C:
		var cust_scene = load("res://ui/customization_menu/character_customization.tscn")
		if cust_scene:
			var cust_instance = cust_scene.instantiate()
			add_child(cust_instance)
			get_viewport().set_input_as_handled()
