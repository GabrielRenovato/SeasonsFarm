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
	
	# Usando items.png como placeholder para as ferramentas enquanto os sprites reais estão ausentes
	var items_sheet = load("res://assets/sprites/ui/items.png")
	
	# Add default tools (nomes em ingles para global launch)
	var hoe = ItemData.new()
	hoe.id = "hoe"
	hoe.name = "Hoe"
	hoe.is_tool = true
	hoe.tool_type = "Hoe"
	hoe.icon_texture = _get_item_frame(items_sheet, 27) # Espada (como placeholder de enxada)
	
	var axe = ItemData.new()
	axe.id = "axe"
	axe.name = "Axe"
	axe.is_tool = true
	axe.tool_type = "Axe"
	axe.icon_texture = _get_item_frame(items_sheet, 28) # Espada de madeira (placeholder)
	
	var mining = ItemData.new()
	mining.id = "pickaxe"
	mining.name = "Pickaxe"
	mining.is_tool = true
	mining.tool_type = "Pickaxe"
	mining.icon_texture = _get_item_frame(items_sheet, 41) # Pedra (placeholder)
	
	var water = ItemData.new()
	water.id = "watering_can"
	water.name = "Watering Can"
	water.is_tool = true
	water.tool_type = "Water"
	water.icon_texture = _get_item_frame(items_sheet, 20) # Garrafa (placeholder)
	
	var carrot_seeds = ItemData.new()
	carrot_seeds.id = "carrot_seeds"
	carrot_seeds.name = "Carrot Seeds"
	carrot_seeds.is_seed = true
	carrot_seeds.crop_type = "carrot"
	carrot_seeds.icon_color = Color(1.0, 1.0, 1.0)
	carrot_seeds.icon_texture = _get_seed_bag_icon(0, 96)      # Spring row 6

	var strawberry_seeds = ItemData.new()
	strawberry_seeds.id = "strawberry_seeds"
	strawberry_seeds.name = "Strawberry Seeds"
	strawberry_seeds.is_seed = true
	strawberry_seeds.crop_type = "strawberry"
	strawberry_seeds.icon_color = Color(1.0, 1.0, 1.0)
	strawberry_seeds.icon_texture = _get_seed_bag_icon(0, 32)  # Spring row 2

	var tomato_seeds = ItemData.new()
	tomato_seeds.id = "tomato_seeds"
	tomato_seeds.name = "Tomato Seeds"
	tomato_seeds.is_seed = true
	tomato_seeds.crop_type = "tomato"
	tomato_seeds.icon_color = Color(1.0, 1.0, 1.0)
	tomato_seeds.icon_texture = _get_seed_bag_icon(146, 64)    # Summer row 4

	var melon_seeds = ItemData.new()
	melon_seeds.id = "melon_seeds"
	melon_seeds.name = "Melon Seeds"
	melon_seeds.is_seed = true
	melon_seeds.crop_type = "melon"
	melon_seeds.icon_color = Color(1.0, 1.0, 1.0)
	melon_seeds.icon_texture = _get_seed_bag_icon(146, 144)    # Summer row 9

	var pumpkin_seeds = ItemData.new()
	pumpkin_seeds.id = "pumpkin_seeds"
	pumpkin_seeds.name = "Pumpkin Seeds"
	pumpkin_seeds.is_seed = true
	pumpkin_seeds.crop_type = "pumpkin"
	pumpkin_seeds.icon_color = Color(1.0, 1.0, 1.0)
	pumpkin_seeds.icon_texture = _get_seed_bag_icon(290, 32)   # Fall row 2

	var beetroot_seeds = ItemData.new()
	beetroot_seeds.id = "beetroot_seeds"
	beetroot_seeds.name = "Beetroot Seeds"
	beetroot_seeds.is_seed = true
	beetroot_seeds.crop_type = "beetroot"
	beetroot_seeds.icon_color = Color(1.0, 1.0, 1.0)
	beetroot_seeds.icon_texture = _get_seed_bag_icon(290, 16)  # Fall row 1

	slots[0].item = hoe
	slots[0].quantity = 1

	slots[1].item = axe
	slots[1].quantity = 1

	slots[2].item = mining
	slots[2].quantity = 1

	slots[3].item = water
	slots[3].quantity = 1

	slots[4].item = carrot_seeds
	slots[4].quantity = 5

	slots[5].item = strawberry_seeds
	slots[5].quantity = 5

	slots[6].item = tomato_seeds
	slots[6].quantity = 5

	slots[7].item = melon_seeds
	slots[7].quantity = 5

	slots[8].item = pumpkin_seeds
	slots[8].quantity = 5

	slots[9].item = beetroot_seeds
	slots[9].quantity = 5
	
	inventory_updated.emit()

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
	# Margem de 1px para cortar pixels brancos/claros da borda do sprite sheet
	tex.margin = Rect2(1, 1, -2, -2)
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
			if slot.item and slot.item.id == item.id:
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
