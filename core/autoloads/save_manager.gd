extends Node

const SAVE_PATH = "user://savegame.json"

var _inventory_data: InventoryData = null
var _session_loaded: bool = false

# Spawn pendente ao trocar de cena: ao voltar do interior da casa, o player
# reaparece NA PORTA de onde saiu, e não no spawn fixo da cena. Só é aplicado
# na cena cujo caminho casa com _pending_spawn_scene (ver Player._apply_pending_spawn).
var _pending_spawn_pos: Vector2 = Vector2.ZERO
var _pending_spawn_scene: String = ""

# Cena da fazenda "guardada" enquanto o player está dentro da casa. Em vez de
# destruir a fazenda ao entrar (e recriá-la inteira ao sair — o que causava uma
# travada ao reinstanciar árvores, lago, colisões e crops), nós apenas a TIRAMOS
# da árvore de cena mantendo o nó vivo em memória. Ao sair, recolocamos a mesma
# instância: nada é regenerado, então não há hitch.
var _stashed_farm: Node = null
const _FARM_SCENE_PATH := "res://levels/main_farm/farm.tscn"

signal save_completed
signal load_completed(success: bool)

# Inventário da sessão: criado UMA vez e compartilhado por todas as cenas.
# Sem isto, cada cena instanciava um player com um InventoryData próprio (default),
# fazendo os itens "resetarem" ao entrar/sair da casa.
func get_session_inventory() -> InventoryData:
	if _inventory_data == null:
		_inventory_data = InventoryData.new()
		_inventory_data.setup_default_inventory()
	return _inventory_data

# Registra a posição em que o player deve nascer na próxima vez que a cena
# indicada for carregada.
func set_pending_spawn(scene_path: String, pos: Vector2) -> void:
	_pending_spawn_scene = scene_path
	_pending_spawn_pos = pos

# Consome o spawn pendente se ele for para ESTA cena; senão retorna null.
func take_pending_spawn(scene_path: String) -> Variant:
	# Comparação case-insensitive: o scene_file_path do Godot pode vir com
	# capitalização diferente da string usada no change_scene.
	if _pending_spawn_scene != "" and _pending_spawn_scene.to_lower() == scene_path.to_lower():
		_pending_spawn_scene = ""
		return _pending_spawn_pos
	return null

# --- Transição casa <-> fazenda (sem recriar a fazenda) ---

# Transição genérica: guarda a cena atual em memória e troca para a nova.
# Usado tanto para entrar na casa quanto para ir à cidade (sem lag ao voltar).
func enter_stashed_scene(scene: PackedScene) -> void:
	if scene == null:
		return
	var tree := get_tree()
	var root := tree.root
	var current := tree.current_scene
	var new_scene := scene.instantiate()
	if current:
		root.remove_child(current)
	_stashed_farm = current
	root.add_child(new_scene)
	tree.current_scene = new_scene

# Entra na casa: guarda a fazenda atual (removida da árvore, mas NÃO destruída) e
# coloca o interior no lugar. Como a fazenda continua viva, seus nós (árvores,
# crops, lago) seguem reagindo aos sinais de TimeManager mesmo "fora de cena".
func enter_interior(interior_scene: PackedScene) -> void:
	enter_stashed_scene(interior_scene)

# Sai da casa: recoloca a MESMA instância da fazenda guardada e descarta o
# interior. Sem regeneração de árvores/lago/crops → sem travada.
func exit_to_farm() -> void:
	var tree := get_tree()
	# Rede de segurança: se por algum motivo não houver fazenda guardada, recai no
	# comportamento antigo (recarrega do disco). O player reaparece na porta via
	# _pending_spawn gravado pela farmhouse ao entrar.
	if _stashed_farm == null or not is_instance_valid(_stashed_farm):
		_stashed_farm = null
		tree.change_scene_to_file(_FARM_SCENE_PATH)
		return
	var interior := tree.current_scene
	var root := tree.root
	var farm := _stashed_farm
	_stashed_farm = null
	root.add_child(farm)
	tree.current_scene = farm
	if interior and is_instance_valid(interior):
		root.remove_child(interior)
		interior.queue_free()
	# Zera a interpolação de física do player (e descendentes) para não "deslizar"
	# ao retomar o controle na fazenda.
	farm.reset_physics_interpolation()
	# Reativa a câmera do player: ao sair da árvore ela deixou de ser a câmera
	# atual da viewport. Sem isto, a tela poderia ficar enquadrada errada.
	var cam := _find_camera(farm)
	if cam:
		cam.make_current()

func _find_camera(node: Node) -> Camera2D:
	if node is Camera2D:
		return node
	for child in node.get_children():
		var found := _find_camera(child)
		if found:
			return found
	return null

func save_game() -> void:
	if _inventory_data == null:
		push_warning("SaveManager: inventory_data not set, cannot save.")
		return

	var data: Dictionary = {
		"gold": EconomyManager.gold,
		"day": TimeManager.day,
		"energy": PlayerStatsManager.energy if PlayerStatsManager else 270.0,
		"max_energy": PlayerStatsManager.max_energy if PlayerStatsManager else 270.0,
		"inventory": _serialize_inventory(),
		"farm": _serialize_farm(),
	}

	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("SaveManager: failed to open save file for writing.")
		return
	file.store_string(JSON.stringify(data, "\t"))
	file.close()
	print("SaveManager: game saved.")
	save_completed.emit()

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func load_game() -> void:
	# Evita recarregar quando o Player é reinstanciado em outras cenas (ex: interior da casa)
	if _session_loaded:
		load_completed.emit(true)
		return
	if not has_save():
		load_completed.emit(false)
		return
	if _inventory_data == null:
		push_warning("SaveManager: inventory_data not set, cannot load.")
		load_completed.emit(false)
		return

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_error("SaveManager: failed to open save file for reading.")
		load_completed.emit(false)
		return

	var raw = file.get_as_text()
	file.close()

	var data = JSON.parse_string(raw)
	if data == null:
		push_error("SaveManager: failed to parse save file.")
		load_completed.emit(false)
		return

	EconomyManager.gold = int(data.get("gold", 0))
	EconomyManager.gold_changed.emit(EconomyManager.gold)
	TimeManager.day = int(data.get("day", 1))
	if PlayerStatsManager:
		PlayerStatsManager.max_energy = float(data.get("max_energy", PlayerStatsManager.max_energy))
		var loaded_energy := float(data.get("energy", PlayerStatsManager.max_energy))
		# Evita soft-lock: não há cama/sono e a energia só recarrega ao virar o dia (T).
		# Carregar um save com energia zerada deixava o player sem conseguir usar
		# ferramentas. Nesse caso, o player começa "descansado" com energia cheia.
		if loaded_energy <= 0.0:
			loaded_energy = PlayerStatsManager.max_energy
		PlayerStatsManager.energy = clampf(loaded_energy, 0.0, PlayerStatsManager.max_energy)
		PlayerStatsManager.energy_changed.emit(PlayerStatsManager.energy, PlayerStatsManager.max_energy)

	_deserialize_inventory(data.get("inventory", []))
	# Farm restore needs the scene tree ready — defer so FarmManager can find dirt_layer
	_session_loaded = true
	call_deferred("_deserialize_farm", data.get("farm", []))

	print("SaveManager: game loaded.")
	load_completed.emit(true)

# --- Serialization helpers ---

func _serialize_inventory() -> Array:
	var result: Array = []
	for i in range(_inventory_data.slots.size()):
		var slot: SlotData = _inventory_data.slots[i]
		if slot == null or slot.item == null or slot.quantity <= 0:
			continue
		result.append({
			"slot": i,
			"id": slot.item.id,
			"rarity": slot.item.rarity,
			"quantity": slot.quantity,
			"is_tool": slot.item.is_tool,
			"tool_type": slot.item.tool_type,
			"is_seed": slot.item.is_seed,
			"crop_type": slot.item.crop_type,
			"is_furniture": slot.item.is_furniture,
			"furniture_id": slot.item.furniture_id,
			"tier": slot.item.tier,
			"name": slot.item.name,
		})
	return result

func _serialize_farm() -> Array:
	var result: Array = []
	for pos in FarmManager.farm_data.keys():
		var d = FarmManager.farm_data[pos]
		if not d.tilled and d.crop_id == "":
			continue
		result.append({
			"x": pos.x,
			"y": pos.y,
			"tilled": d.tilled,
			"watered": d.watered,
			"crop_id": d.crop_id,
			"days_grown": d.days_grown,
		})
	return result

# --- Deserialization helpers ---

func _deserialize_inventory(slots_data: Array) -> void:
	# Reset inventory to empty first
	for slot in _inventory_data.slots:
		slot.item = null
		slot.quantity = 0

	var inv_ui_helper := _inventory_data  # for icon helpers

	for entry in slots_data:
		var idx: int = int(entry.get("slot", -1))
		if idx < 0 or idx >= _inventory_data.slots.size():
			continue

		var item := ItemData.new()
		item.id = entry.get("id", "")
		item.name = entry.get("name", item.id)
		item.rarity = entry.get("rarity", "common")
		item.is_tool = entry.get("is_tool", false)
		item.tool_type = entry.get("tool_type", "")
		item.is_seed = entry.get("is_seed", false)
		item.crop_type = entry.get("crop_type", "")
		item.is_furniture = entry.get("is_furniture", false)
		item.furniture_id = entry.get("furniture_id", "")
		item.tier = entry.get("tier", "Wood")
		
		# Fallback for old saves that didn't save furniture_id
		if not item.is_furniture and item.id.begins_with("furniture_"):
			item.is_furniture = true
			item.furniture_id = item.id.replace("furniture_", "")

		# Sistema de móveis desativado: ignora itens de mobília ao carregar
		if item.is_furniture and not FurnitureManager.enabled:
			continue

		# Restore icon
		if item.is_tool:
			var tool_name = item.name if item.name != "" else item.id.capitalize()
			item.icon_texture = inv_ui_helper._get_tool_icon(tool_name, item.tier)
		elif item.is_seed:
			var cfg = FarmManager.CROP_CONFIGS.get(item.crop_type, {})
			if not cfg.is_empty():
				item.icon_texture = inv_ui_helper._get_seed_bag_icon(cfg.get("seed_x", 0), cfg.get("seed_y", 0))
		elif item.is_furniture:
			if FurnitureManager.catalog.has(item.furniture_id):
				var fdata = FurnitureManager.catalog[item.furniture_id]
				var tex = AtlasTexture.new()
				tex.atlas = load(fdata["texture_path"])
				tex.region = fdata["regions"][0]
				item.icon_texture = tex
		else:
			# Harvested crop — ícone do All Crops.png (mesmo offset do seed, +2/3/4 por raridade)
			var cfg = FarmManager.CROP_CONFIGS.get(item.id, {})
			if not cfg.is_empty():
				var all_crops := load("res://assets/sprites/crops/All Crops.png") as Texture2D
				if all_crops:
					var rarity_col: int = {"common": 2, "silver": 3, "gold": 4}.get(item.rarity, 2)
					var atlas := AtlasTexture.new()
					atlas.atlas = all_crops
					atlas.region = Rect2(cfg.get("seed_x", 0) + rarity_col * 16, cfg.get("seed_y", 0), 16, 16)
					item.icon_texture = atlas
			elif item.id == "wood":
				# Restaura o ícone da madeira a partir do novo sprite vertical
				var wood_tex = load("res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Tree/TREE TRUNKS diagonal.png") as Texture2D
				if wood_tex:
					item.icon_texture = wood_tex
			elif item.id == "stone":
				# Restaura o ícone da pedra a partir de Ground stones.png
				var stones_png = load("res://assets/sprites/Props/Spring/Ground stones.png") as Texture2D
				if stones_png:
					var atlas := AtlasTexture.new()
					atlas.atlas = stones_png
					atlas.region = Rect2(0, 16, 16, 16)
					item.icon_texture = atlas

		_inventory_data.slots[idx].item = item
		_inventory_data.slots[idx].quantity = int(entry.get("quantity", 1))

	_inventory_data.inventory_updated.emit()

func _deserialize_farm(farm_data: Array) -> void:
	# Limpa entradas antigas para garantir estado limpo ao recarregar a cena da fazenda
	FarmManager.farm_data.clear()

	var dirt_layer := get_tree().get_first_node_in_group("dirt_layer") as TileMapLayer
	if dirt_layer == null:
		push_error("SaveManager: cannot restore farm — dirt_layer not found.")
		return

	var crop_scene_path := "res://objects/crops/crop.tscn"
	var crop_scene := load(crop_scene_path) as PackedScene

	for entry in farm_data:
		var pos := Vector2i(int(entry.get("x", 0)), int(entry.get("y", 0)))

		# Restore tilled soil
		FarmManager.till_soil(pos)

		if entry.get("watered", false):
			FarmManager.water_soil(pos)

		var crop_id: String = entry.get("crop_id", "")
		if crop_id != "" and crop_scene:
			var days_grown: int = int(entry.get("days_grown", 0))
			var crop_instance := crop_scene.instantiate()
			dirt_layer.get_parent().add_child(crop_instance)
			var tile_center := dirt_layer.map_to_local(pos)
			crop_instance.global_position = dirt_layer.to_global(tile_center)

			FarmManager.plant_seed(pos, crop_id, crop_instance)

			# Advance growth manually to match saved state
			for _i in range(days_grown):
				if is_instance_valid(crop_instance) and crop_instance.has_method("grow"):
					crop_instance.grow()
			FarmManager.farm_data[pos].days_grown = days_grown
