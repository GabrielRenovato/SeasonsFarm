extends StaticBody2D

# =====================================================================
# FARMHOUSE - Casa Principal do Player
# =====================================================================
# IMPORTANTE SOBRE Y-SORT:
# O nó raiz (StaticBody2D) tem sua origem no CHÃO da casa (pé da porta).
# Isso é essencial para o Y-sort funcionar corretamente:
#   - Se o player está ABAIXO da origem Y da casa → passa na FRENTE
#   - Se o player está ACIMA da origem Y da casa → passa ATRÁS
# Nunca mova a origem do StaticBody2D para longe do chão da casa!
# =====================================================================

@export var interior_scene: PackedScene  # Cena do interior carregada ao entrar

@onready var door_area: Area2D = $DoorArea           # Área de detecção da porta
@onready var animation_player: AnimationPlayer = $AnimationPlayer  # Controla animação da porta

var window_light: PointLight2D = null  # Luz da janela (acende à noite)

var _player_in_range: bool = false  # Player está perto da porta?
var _is_opening: bool = false       # Evita acionar a porta várias vezes
var _player_body: Node2D = null     # Player perto da porta (p/ gravar posição de retorno)

func _ready() -> void:
	# Detecta quando o player entra/sai do alcance da porta
	door_area.body_entered.connect(_on_door_area_body_entered)
	door_area.body_exited.connect(_on_door_area_body_exited)
	# Cria a luz dinâmica da janela em código (sem precisar de nó na cena)
	_setup_window_light()
	# A fazenda é guardada (não destruída) ao entrar na casa e recolocada na árvore
	# ao voltar. Quando ela reentra, reseta o estado da porta para permitir entrar
	# de novo. Conectado aqui DEPOIS da 1ª emissão de tree_entered (que ocorre antes
	# de _ready), então só dispara nas reentradas — não na carga inicial.
	tree_entered.connect(_on_re_entered_tree)

# Chamado quando a fazenda volta à árvore (player saiu da casa).
func _on_re_entered_tree() -> void:
	_is_opening = false
	# Fecha a porta (RESET) caso tenha ficado aberta ao trocar de cena.
	if animation_player and animation_player.has_animation("RESET"):
		animation_player.play("RESET")

func _setup_window_light() -> void:
	# Cria uma luz radial suave cor laranja/quente para simular luz interna
	window_light = PointLight2D.new()
	var texture_2d = GradientTexture2D.new()
	var gradient = Gradient.new()
	gradient.offsets = [0.0, 1.0]
	gradient.colors = [Color(1.0, 0.8, 0.4, 0.95), Color(1.0, 0.8, 0.4, 0.0)]
	texture_2d.gradient = gradient
	texture_2d.fill = GradientTexture2D.FILL_RADIAL
	texture_2d.fill_from = Vector2(0.5, 0.5)
	texture_2d.fill_to = Vector2(1.0, 0.5)
	texture_2d.width = 128
	texture_2d.height = 128
	
	window_light.texture = texture_2d
	window_light.texture_scale = 2.0
	window_light.energy = 0.0  # Começa apagada durante o dia
	# Posição relativa ao pivot do nó (que é o chão da casa)
	# -38 em Y coloca a luz na altura da janela
	window_light.position = Vector2(0, -38)
	window_light.blend_mode = Light2D.BLEND_MODE_ADD
	window_light.name = "WindowLight"
	add_child(window_light)

func _process(delta: float) -> void:
	# Abre a porta se o player estiver perto e apertar o botão da ferramenta
	if _player_in_range and not _is_opening and Input.is_action_just_pressed("use_tool"):
		_open_door()

	# Atualiza a energia da luz da janela baseado no horário do jogo
	if not window_light or not is_instance_valid(window_light):
		return
		
	var time_mgr = get_node_or_null("/root/TimeManager")
	if not time_mgr:
		return
		
	var hour = time_mgr.hour
	var minute = time_mgr.minute
	var time: float = hour + (minute / 60.0)
	
	var target_energy: float = 0.0
	
	# Entre 18h e 6h: luz acesa totalmente
	if time >= 18.0 or time < 6.0:
		target_energy = 1.0
	# Transição pôr do sol (17h→18h): fade in
	elif time >= 17.0 and time < 18.0:
		target_energy = (time - 17.0) * 1.0
	# Transição amanhecer (6h→7h): fade out
	elif time >= 6.0 and time < 7.0:
		target_energy = (1.0 - (time - 6.0)) * 1.0
		
	# Interpolação suave independente de frame rate
	window_light.energy = lerp(window_light.energy, target_energy, 1.0 - exp(-delta * 5.0))


# Player entrou no alcance da porta: agora ele pode abri-la com o botão da ferramenta
func _on_door_area_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		_player_in_range = true
		_player_body = body

# Player saiu do alcance da porta
func _on_door_area_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D:
		_player_in_range = false

# Abre a porta e troca para o interior da casa
# O Y-sort está configurado corretamente: o nó raiz (StaticBody2D)
# fica no "pé" da construção, permitindo que o player passe na frente
# ou atrás da casa dependendo de sua posição Y relativa
func _open_door() -> void:
	if interior_scene == null:
		print("FALHOU: interior_scene é NULO")
		return
	if animation_player == null:
		print("FALHOU: animation_player é NULO")
		return

	_is_opening = true
	# Anima a abertura da porta e aguarda terminar antes de trocar de cena
	animation_player.play("open_door")
	await animation_player.animation_finished
	# Auto-save ao entrar na casa para preservar plantações, inventário e estado do solo
	if SaveManager:
		# Rede de segurança para o fallback de exit_to_farm (recarregar do disco):
		# nesse caso o player reaparece NA FRENTE desta porta. No caminho normal
		# (fazenda guardada), o player nem se move, então isto fica sem efeito.
		if _player_body and is_instance_valid(_player_body):
			SaveManager.set_pending_spawn("res://levels/main_farm/farm.tscn", _player_body.global_position)
		SaveManager.save_game()
		# Guarda a fazenda viva e abre o interior (sem destruir/recriar a fazenda).
		# Deferido para só mexer na árvore de cena fora de callbacks de física.
		SaveManager.call_deferred("enter_interior", interior_scene)
	else:
		get_tree().change_scene_to_packed(interior_scene)
