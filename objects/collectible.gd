extends Area2D
class_name Collectible

# ==============================================================================
# SISTEMA DE COLETA MAGNÉTICA (COLLECTIBLE SYSTEM)
# ==============================================================================
# Este script gerencia itens jogados no chão que são atraídos magneticamente
# para o jogador quando ele se aproxima, adicionando o item ao inventário.

# Identificador único do item no inventário (sempre em inglês)
@export var item_id: String = ""

# Nome do item que aparecerá na tela/tooltip (sempre em inglês)
@export var item_name: String = ""

# Velocidade de atração em pixels por segundo
@export var attraction_speed: float = 200.0

# Distância mínima a partir da qual a atração começa
@export var attraction_radius: float = 40.0

# Armazena se o item está atualmente voando para o jogador
var _is_flying: bool = false

# Referência ao jogador que está puxando o item
var _target_player: Node2D = null

# Referência ao nó de Sprite2D filho
@onready var _sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	# Ativa o processamento apenas se necessário
	set_physics_process(false)
	
	# Desativa detecção temporariamente para o item quicar no chão primeiro sem interferência
	monitoring = false
	
	# Cria uma forma de colisão dinamicamente se nenhuma for definida
	_setup_collision()
	
	# Aguarda o tempo do quique (0.6s) antes de permitir que o jogador colete o item
	await get_tree().create_timer(0.6).timeout
	monitoring = true

func _setup_collision() -> void:
	# Cria uma área de detecção baseada no raio configurado
	var shape_owner = create_shape_owner(self)
	var circle_shape = CircleShape2D.new()
	circle_shape.radius = attraction_radius
	shape_owner_add_shape(shape_owner, circle_shape)
	
	# Conecta o sinal para detectar quando o jogador entra no raio
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	# Se estiver voando, move-se em direção ao jogador
	if _is_flying and _target_player:
		var direction = (_target_player.global_position - global_position).normalized()
		global_position += direction * attraction_speed * delta
		
		# Acelera ligeiramente à medida que se aproxima, dando um efeito visual premium
		attraction_speed += 10.0
		
		# Verifica se está perto o suficiente para ser coletado
		if global_position.distance_to(_target_player.global_position) < 8.0:
			_collect()

func _on_body_entered(body: Node2D) -> void:
	# Detecta se é o jogador (checando se ele possui a propriedade do inventário)
	if "inventory_data" in body and not _is_flying:
		_target_player = body
		_is_flying = true
		set_physics_process(true)
		
		# Pequeno efeito visual de subida/pulo antes de voar em direção ao jogador
		var jump_tween = create_tween()
		jump_tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.1)
		jump_tween.tween_property(self, "scale", Vector2(0.8, 0.8), 0.1)
		jump_tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)

func _collect() -> void:
	# Evita múltiplas chamadas de coleta
	set_physics_process(false)
	_is_flying = false
	
	if _target_player and _target_player.inventory_data:
		var item = ItemData.new()
		item.id = item_id
		item.name = item_name
		item.is_tool = false
		item.is_seed = false
		item.rarity = "common"
		
		# Configura o ícone do inventário baseando-se no próprio Sprite2D do item
		if _sprite and _sprite.texture:
			if _sprite.region_enabled:
				# Se usar AtlasTexture via recorte de região (ex: madeira)
				var atlas_tex = AtlasTexture.new()
				atlas_tex.atlas = _sprite.texture
				atlas_tex.region = _sprite.region_rect
				item.icon_texture = atlas_tex
			else:
				# Se a própria textura já for um Atlas ou imagem direta (ex: pedra)
				item.icon_texture = _sprite.texture
		
		# Adiciona o item ao inventário
		var added = _target_player.inventory_data.add_item(item, 1)
		
		if added:
			# Se quiser futuramente adicionar efeitos sonoros, este é o local
			queue_free()
		else:
			# Se o inventário estiver cheio, o item volta a cair no chão
			_target_player = null
			var bounce_tween = create_tween()
			var target_pos = global_position + Vector2(randf_range(-15, 15), randf_range(5, 15))
			bounce_tween.tween_property(self, "global_position", target_pos, 0.3).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
			# Reativa a detecção após um pequeno atraso
			await get_tree().create_timer(1.5).timeout
			# Apenas reativa se o jogador já não estiver em cima
			var overlapping = get_overlapping_bodies()
			var still_overlapping = false
			for b in overlapping:
				if "inventory_data" in b:
					still_overlapping = true
					_on_body_entered(b)
					break
			if not still_overlapping:
				monitoring = true
