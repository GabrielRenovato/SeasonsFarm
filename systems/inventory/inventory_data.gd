extends Resource
class_name InventoryData

signal inventory_updated
signal active_slot_changed(index: int)

@export var slots: Array[SlotData] = []
var active_slot_index: int = 0:
	set(value):
		active_slot_index = clamp(value, 0, 11) # 12 slots na hotbar
		active_slot_changed.emit(active_slot_index)

func get_active_item() -> ItemData:
	if slots.size() > active_slot_index and slots[active_slot_index] != null:
		return slots[active_slot_index].item
	return null

func setup_default_inventory() -> void:
	slots.clear()
	# Cria 36 slots (12 hotbar + 24 inventario) para bater com stardew
	for i in range(36):
		var sd = SlotData.new()
		sd.quantity = 0
		slots.append(sd)
	
	# Mapa de tiers para suas pastas na estrutura de icones
	# Cada tier mapeia para o nome exato da pasta em res://assets/sprites/icons/Weapons and Armor/
	
	# Add default tools (names in english for global launch)
	var hoe = ItemData.new()
	hoe.id = "hoe"
	hoe.name = "Hoe"
	hoe.is_tool = true
	hoe.tool_type = "Hoe"
	hoe.tier = "Wood"
	hoe.icon_texture = _get_tool_icon("Hoe", "Wood")
	
	var axe = ItemData.new()
	axe.id = "axe"
	axe.name = "Axe"
	axe.is_tool = true
	axe.tool_type = "Axe"
	axe.tier = "Wood"
	axe.icon_texture = _get_tool_icon("Axe", "Wood")
	
	var mining = ItemData.new()
	mining.id = "pickaxe"
	mining.name = "Pickaxe"
	mining.is_tool = true
	mining.tool_type = "Pickaxe"
	mining.tier = "Wood"
	mining.icon_texture = _get_tool_icon("Pickaxe", "Wood")
	
	var water = ItemData.new()
	water.id = "watering_can"
	water.name = "Watering Can"
	water.is_tool = true
	water.tool_type = "Water"
	water.tier = "Wood"
	water.icon_texture = _get_tool_icon("Watering Can", "Wood")
	
	slots[0].item = hoe
	slots[0].quantity = 1

	slots[1].item = axe
	slots[1].quantity = 1

	slots[2].item = mining
	slots[2].quantity = 1

	slots[3].item = water
	slots[3].quantity = 1

	# Adiciona todas as sementes disponíveis para teste (até o limite do inventário)
	var slot_index = 4
	for crop_id in FarmManager.CROP_CONFIGS.keys():
		if slot_index >= 36:
			break
		
		var config = FarmManager.CROP_CONFIGS[crop_id]
		var seed_item = ItemData.new()
		seed_item.id = crop_id + "_seeds"
		seed_item.name = config.get("name", crop_id) + " Seeds"
		seed_item.is_seed = true
		seed_item.crop_type = crop_id
		seed_item.icon_color = Color(1.0, 1.0, 1.0)
		seed_item.icon_texture = _get_seed_bag_icon(
			config.get("seed_x", 0),
			config.get("seed_y", 0)
		)
		
		slots[slot_index].item = seed_item
		slots[slot_index].quantity = 99
		slot_index += 1
	
	inventory_updated.emit()

## Retorna o icone correto de ferramenta baseado no tipo e tier.
## Busca o arquivo em:
##   res://assets/sprites/icons/Weapons and Armor/[N]. [Tier]/[ToolName].png
## O tier "Wood" fica na pasta "1. Wood", "Cooper" em "2. Cooper", etc.
##
## Cada PNG tem 32x16 com DOIS icones lado a lado:
##   - Esquerda (0,0,16,16)  = icone limpo, sem contorno branco  <-- usamos este
##   - Direita  (16,0,16,16) = icone com contorno branco
func _get_tool_icon(tool_name: String, tier: String) -> AtlasTexture:
	# Mapa de tier para o numero da pasta (ex: "Wood" -> "1. Wood")
	var tier_folder_map: Dictionary = {
		"Wood":     "1. Wood",
		"Cooper":   "2. Cooper",
		"Iron":     "3. Iron",
		"Gold":     "4. Gold",
		"Platinum": "5. Platinum",
		"Crimson":  "6. Crimson",
		"Frost":    "7. Frost",
		"Shadow":   "8. Shadow",
		"Fairy":    "9. Fairy",
		"Obsidian": "9. Obsidian",
	}
	
	var folder = tier_folder_map.get(tier, "1. Wood")
	
	# Monta o caminho base para o icone
	var base_path = "res://assets/sprites/icons/Weapons and Armor/%s/%s.png" % [folder, tool_name]
	
	var texture = load(base_path) as Texture2D
	
	# Fallback: tier Wood tem "Watering can" (c minusculo), outros tiers tem "Watering Can"
	if texture == null and tool_name == "Watering Can":
		var alt_path = "res://assets/sprites/icons/Weapons and Armor/%s/Watering can.png" % folder
		texture = load(alt_path) as Texture2D
	
	if texture == null:
		push_warning("[InventoryData] Tool icon not found: " + base_path)
		return null
	
	# Recorta so a metade ESQUERDA do PNG (16x16 sem contorno branco).
	# O PNG tem 32x16: coluna 0 = sem outline, coluna 1 = com outline branco.
	var atlas = AtlasTexture.new()
	atlas.atlas = texture
	atlas.region = Rect2(0, 0, 16, 16)  # metade esquerda = icone limpo
	return atlas

## Extracts a single 32x32 frame from a tool spritesheet (5 columns x 4 rows)
func _get_tool_frame(sheet: Texture2D, frame_index: int) -> AtlasTexture:
	if sheet == null:
		return null
	var cols = 5
	var frame_w = 32
	var frame_h = 32
	var col = frame_index % cols
	var row = int(frame_index / float(cols))
	var tex = AtlasTexture.new()
	tex.atlas = sheet
	# Crop a 20x20 area adjusted for where the tools actually are in the 32x32 frame
	var crop_size = 20
	var offset_x = 2
	var offset_y = 8
	tex.region = Rect2((col * frame_w) + offset_x, (row * frame_h) + offset_y, crop_size, crop_size)
	return tex

## Extracts a single 16x16 frame from a seeds spritesheet (7 columns x 6 rows)
func _get_seed_frame(sheet: Texture2D, frame_index: int) -> AtlasTexture:
	if sheet == null:
		return null
	var cols = 7
	var size = 16
	var col = frame_index % cols
	var row = int(frame_index / float(cols))
	var tex = AtlasTexture.new()
	tex.atlas = sheet
	tex.region = Rect2(col * size, row * size, size, size)
	return tex

## Extracts a single 16x16 frame from an items spritesheet (10 columns)
func _get_item_frame(sheet: Texture2D, frame_index: int) -> AtlasTexture:
	if sheet == null:
		return null
	var cols = 10
	var size = 16
	var col = frame_index % cols
	var row = int(frame_index / float(cols))
	var tex = AtlasTexture.new()
	tex.atlas = sheet
	tex.region = Rect2(col * size, row * size, size, size)
	return tex

## Extracts a seed bag icon from All Crops.png using direct pixel coordinates.
## All Crops.png: Spring panel x=0, Summer panel x=146, Fall panel x=290.
## Crop N in a panel is at y = N * 16. Use seed_x and seed_y from CROP_CONFIGS.
func _get_seed_bag_icon(seed_x: int, seed_y: int) -> AtlasTexture:
	var texture = load("res://assets/sprites/crops/All Crops.png") as Texture2D
	if texture == null:
		return null
	var tex = AtlasTexture.new()
	tex.atlas = texture
	tex.region = Rect2(seed_x, seed_y, 16, 16)
	return tex

func swap_slots(index_a: int, index_b: int) -> void:
	if index_a < 0 or index_a >= slots.size() or index_b < 0 or index_b >= slots.size():
		return
	var temp = slots[index_a]
	slots[index_a] = slots[index_b]
	slots[index_b] = temp
	inventory_updated.emit()

func add_item(item: ItemData, quantity: int = 1) -> bool:
	if item == null or quantity <= 0:
		return false
		
	# 1. Tenta empilhar em um slot existente com o mesmo item.id (se não for ferramenta)
	if not item.is_tool:
		for slot in slots:
			if slot.item and slot.item.id == item.id and slot.item.rarity == item.rarity:
				slot.quantity += quantity
				inventory_updated.emit()
				return true
				
	# 2. Se não achou slot empilhável, procura o primeiro slot vazio
	for slot in slots:
		if slot.item == null or slot.quantity == 0:
			slot.item = item
			slot.quantity = quantity
			inventory_updated.emit()
			return true
			
	return false
