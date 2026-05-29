extends PanelContainer
class_name SlotUI

@export var show_background: bool = true

# Referências para os elementos visuais do slot
@onready var item_icon: TextureRect = $MarginContainer/ItemIcon
@onready var quantity_label: Label = $MarginContainer/QuantityLabel
@onready var highlight_rect: ReferenceRect = $HighlightRect

# Índice desse slot no array do inventário
var slot_index: int = -1
# Referência aos dados do inventário completo
var inventory_data: InventoryData
# Dados específicos deste slot (item + quantidade)
var slot_data: SlotData

func _ready() -> void:
	if not show_background:
		# Hotbar: cria um quadradinho escuro semi-transparente para separar cada item
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color(0.0, 0.0, 0.0, 0.3)   # fundo escuro semi-transparente
		sb.border_width_left = 1
		sb.border_width_top = 1
		sb.border_width_right = 1
		sb.border_width_bottom = 1
		sb.border_color = Color(0.3, 0.15, 0.0, 0.8)  # borda marrom escura
		sb.corner_radius_top_left = 2
		sb.corner_radius_top_right = 2
		sb.corner_radius_bottom_right = 2
		sb.corner_radius_bottom_left = 2
		add_theme_stylebox_override("panel", sb)
		# Força todos os estados a usarem o mesmo estilo, evitando o risco branco do tema padrão da Godot
		add_theme_stylebox_override("hover", sb)
		add_theme_stylebox_override("pressed", sb)
		add_theme_stylebox_override("focus", sb)
		add_theme_stylebox_override("disabled", sb)
		custom_minimum_size = Vector2(20, 20)
		var mc = $MarginContainer
		mc.add_theme_constant_override("margin_left", 2)
		mc.add_theme_constant_override("margin_right", 2)
		mc.add_theme_constant_override("margin_top", 2)
		mc.add_theme_constant_override("margin_bottom", 2)
	
	highlight_rect.visible = false

	# Garante que o estilo atual (qualquer que seja) vai cobrir todos os estados
	# evitando o risco/borda branca que o tema padrão da Godot aplica
	var current_style = get_theme_stylebox("panel")
	add_theme_stylebox_override("hover", current_style)
	add_theme_stylebox_override("pressed", current_style)
	add_theme_stylebox_override("focus", current_style)
	add_theme_stylebox_override("disabled", current_style)

# Configura o slot com os dados do inventário e seu índice
func setup(p_inventory_data: InventoryData, p_slot_index: int) -> void:
	inventory_data = p_inventory_data
	slot_index = p_slot_index
	slot_data = inventory_data.slots[slot_index]
	update_ui()

# Atualiza o visual do slot baseado nos dados atuais
func update_ui() -> void:
	# Pega a referência atualizada caso os slots tenham sido trocados
	slot_data = inventory_data.slots[slot_index]
	
	# Se o slot está vazio, esconde ícone e quantidade
	if slot_data == null or slot_data.item == null or slot_data.quantity <= 0:
		item_icon.visible = false
		quantity_label.visible = false
		tooltip_text = ""
	else:
		item_icon.visible = true
		tooltip_text = slot_data.item.name
		
		# Mostra o ícone do item (textura real ou placeholder colorido)
		if slot_data.item.icon_texture != null:
			item_icon.texture = slot_data.item.icon_texture
			item_icon.self_modulate = Color.WHITE
		else:
			# Cria um placeholder colorido se não tiver textura
			var placeholder = PlaceholderTexture2D.new()
			placeholder.size = Vector2(14, 14)
			item_icon.texture = placeholder
			item_icon.self_modulate = slot_data.item.icon_color
		
		# Ferramentas não mostram quantidade (são únicas)
		if slot_data.item.is_tool:
			quantity_label.visible = false
		else:
			quantity_label.visible = true
			quantity_label.text = str(slot_data.quantity)


func _make_custom_tooltip(for_text: String) -> Object:
	if slot_data == null or slot_data.item == null:
		return null

	var item = slot_data.item

	var panel := PanelContainer.new()

	# Remove o fundo do PopupPanel e reposiciona acima do slot
	panel.tree_entered.connect(func():
		var popup = panel.get_parent()
		if not popup:
			return
		popup.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
		(func():
			var slot_rect = get_global_rect()
			var tip_size = popup.size
			var vp_size = get_viewport().get_visible_rect().size
			var px = int(slot_rect.position.x + slot_rect.size.x * 0.5 - tip_size.x * 0.5)
			var py = int(slot_rect.position.y - tip_size.y - 6)
			px = clampi(px, 0, int(vp_size.x - tip_size.x))
			py = clampi(py, 0, int(vp_size.y - tip_size.y))
			popup.position = Vector2i(px, py)
		).call_deferred()
	)

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.10, 0.07, 0.04, 0.95)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = Color(0.55, 0.38, 0.12, 0.9)
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_right = 4
	style.corner_radius_bottom_left = 4
	style.content_margin_left = 7
	style.content_margin_right = 7
	style.content_margin_top = 4
	style.content_margin_bottom = 4
	panel.add_theme_stylebox_override("panel", style)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 1)
	panel.add_child(vbox)

	var name_label := Label.new()
	name_label.text = item.name
	name_label.add_theme_font_size_override("font_size", 10)
	name_label.add_theme_color_override("font_color", Color(0.97, 0.93, 0.80, 1.0))
	name_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.5))
	name_label.add_theme_constant_override("shadow_offset_x", 1)
	name_label.add_theme_constant_override("shadow_offset_y", 1)
	vbox.add_child(name_label)

	var subtitle := ""
	var sub_color := Color(0.60, 0.60, 0.60, 1.0)
	if item.is_tool:
		subtitle = item.tier + " " + item.tool_type
		sub_color = Color(0.80, 0.65, 0.25, 1.0)
	elif item.is_seed:
		subtitle = "Semente"
		sub_color = Color(0.40, 0.80, 0.40, 1.0)
	else:
		match item.rarity:
			"silver":
				subtitle = "Prata ✦"
				sub_color = Color(0.70, 0.82, 0.88, 1.0)
			"gold":
				subtitle = "Ouro ★"
				sub_color = Color(1.0, 0.82, 0.22, 1.0)
			_:
				subtitle = "Colheita"
				sub_color = Color(0.60, 0.60, 0.60, 1.0)

	var sub_label := Label.new()
	sub_label.text = subtitle
	sub_label.add_theme_font_size_override("font_size", 8)
	sub_label.add_theme_color_override("font_color", sub_color)
	vbox.add_child(sub_label)

	return panel


# Define se este slot é o slot ativo/selecionado na hotbar
func set_active(is_active: bool) -> void:
	highlight_rect.visible = is_active

# === DRAG & DROP ===
# Permite arrastar itens entre slots

# Cria os dados de arrasto quando o jogador clica e arrasta
func _get_drag_data(_at_position: Vector2) -> Variant:
	# Não permite arrastar slot vazio
	if slot_data == null or slot_data.item == null:
		return null
		
	var drag_data = {
		"slot_index": slot_index,
		"inventory_data": inventory_data
	}
	
	# Cria uma previa visual do item sendo arrastado
	var preview = PanelContainer.new()
	preview.custom_minimum_size = Vector2(16, 16)
	
	# Copia o estilo visual do slot pro preview
	var style_box = get_theme_stylebox("panel").duplicate()
	preview.add_theme_stylebox_override("panel", style_box)
	
	# Adiciona o ícone do item no preview
	var preview_icon = TextureRect.new()
	preview_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	preview_icon.custom_minimum_size = Vector2(14, 14)
	preview_icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	preview_icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	
	if slot_data.item.icon_texture != null:
		preview_icon.texture = slot_data.item.icon_texture
	else:
		var placeholder = PlaceholderTexture2D.new()
		placeholder.size = Vector2(14, 14)
		preview_icon.texture = placeholder
		preview_icon.self_modulate = slot_data.item.icon_color
		
	preview.add_child(preview_icon)
	
	set_drag_preview(preview)
	return drag_data

# Verifica se esse slot pode receber um item arrastado
func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return data is Dictionary and data.has("slot_index") and data.has("inventory_data")

# Executa a troca quando um item é solto neste slot
func _drop_data(_at_position: Vector2, data: Variant) -> void:
	var from_index = data.slot_index
	var from_inventory = data.inventory_data
	
	# Só troca se for do mesmo inventário
	if from_inventory == inventory_data:
		inventory_data.swap_slots(from_index, slot_index)
