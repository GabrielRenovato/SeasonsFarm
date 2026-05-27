extends CanvasLayer

@onready var body_preview: Sprite2D = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/PreviewArea/BodyPreview
@onready var legs_preview: Sprite2D = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/PreviewArea/BodyPreview/LagsPreview
@onready var clothes_preview: Sprite2D = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/PreviewArea/BodyPreview/ClothePreview
@onready var hair_preview: Sprite2D = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/PreviewArea/BodyPreview/HairPreview

@onready var body_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/CategoryContainer/BodyHBox/BodyLabel
@onready var hair_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/CategoryContainer/HairHBox/HairLabel
@onready var clothes_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/CategoryContainer/ClothesHBox/ClothesLabel
@onready var pants_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/CategoryContainer/PantsHBox/PantsLabel

@onready var color_grid: GridContainer = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ColorGrid

var preview_frame: int = 0
var animation_timer: Timer

# 10 premium curated colors for Stardew Valley-like hair customization
var preset_colors = [
	Color("#e6b800"), # Blonde
	Color("#5c3a21"), # Brown
	Color("#1c1c1c"), # Black
	Color("#c0392b"), # Red
	Color("#e67e22"), # Orange
	Color("#e91e63"), # Pink
	Color("#2980b9"), # Blue
	Color("#27ae60"), # Green
	Color("#8e44ad"), # Purple
	Color("#ecf0f1")  # White/Silver
]

func _ready() -> void:
	if CustomizationManager:
		CustomizationManager.customization_changed.connect(_update_ui)

	# Connect category buttons
	# Body/Skin
	$CenterContainer/PanelContainer/MarginContainer/VBoxContainer/CategoryContainer/BodyHBox/PrevBody.pressed.connect(func(): CustomizationManager.prev_body())
	$CenterContainer/PanelContainer/MarginContainer/VBoxContainer/CategoryContainer/BodyHBox/NextBody.pressed.connect(func(): CustomizationManager.next_body())
	# Hair
	$CenterContainer/PanelContainer/MarginContainer/VBoxContainer/CategoryContainer/HairHBox/PrevHair.pressed.connect(func(): CustomizationManager.prev_hair())
	$CenterContainer/PanelContainer/MarginContainer/VBoxContainer/CategoryContainer/HairHBox/NextHair.pressed.connect(func(): CustomizationManager.next_hair())
	# Clothes
	$CenterContainer/PanelContainer/MarginContainer/VBoxContainer/CategoryContainer/ClothesHBox/PrevClothes.pressed.connect(func(): CustomizationManager.prev_clothes())
	$CenterContainer/PanelContainer/MarginContainer/VBoxContainer/CategoryContainer/ClothesHBox/NextClothes.pressed.connect(func(): CustomizationManager.next_clothes())
	# Pants
	$CenterContainer/PanelContainer/MarginContainer/VBoxContainer/CategoryContainer/PantsHBox/PrevPants.pressed.connect(func(): CustomizationManager.prev_pants())
	$CenterContainer/PanelContainer/MarginContainer/VBoxContainer/CategoryContainer/PantsHBox/NextPants.pressed.connect(func(): CustomizationManager.next_pants())
	
	# Close button
	$CenterContainer/PanelContainer/MarginContainer/VBoxContainer/CloseButton.pressed.connect(_on_close)

	# Build premium color swatches dynamically
	_build_color_swatches()

	# Initial UI state load
	_update_ui()

	# Start Active Walk Cycle Preview at 8 FPS
	animation_timer = Timer.new()
	animation_timer.wait_time = 0.125
	animation_timer.autostart = true
	animation_timer.timeout.connect(_on_animation_tick)
	add_child(animation_timer)

func _on_animation_tick() -> void:
	# Front-facing walk animation has 8 columns/frames (0 to 7) on the first row
	preview_frame = (preview_frame + 1) % 8
	_update_preview_frames()

func _update_preview_frames() -> void:
	body_preview.frame = preview_frame
	legs_preview.frame = preview_frame
	clothes_preview.frame = preview_frame
	hair_preview.frame = preview_frame

func _build_color_swatches() -> void:
	# Clear any previous children (safety precaution)
	for child in color_grid.get_children():
		child.queue_free()

	for col in preset_colors:
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(28, 28)
		btn.focus_mode = Control.FOCUS_NONE

		# Setup styleboxes to draw circular buttons
		var sb = StyleBoxFlat.new()
		sb.bg_color = col
		sb.corner_radius_top_left = 14
		sb.corner_radius_top_right = 14
		sb.corner_radius_bottom_left = 14
		sb.corner_radius_bottom_right = 14
		sb.border_width_left = 2
		sb.border_width_top = 2
		sb.border_width_right = 2
		sb.border_width_bottom = 2

		# White border if selected, otherwise dark gray border
		if CustomizationManager.hair_color.is_equal_approx(col):
			sb.border_color = Color("#ffffff")
		else:
			sb.border_color = Color("#222222")

		btn.add_theme_stylebox_override("normal", sb)
		btn.add_theme_stylebox_override("hover", sb)
		btn.add_theme_stylebox_override("pressed", sb)

		btn.pressed.connect(func():
			CustomizationManager.set_hair_color(col)
		)
		color_grid.add_child(btn)

func _update_ui() -> void:
	if not CustomizationManager: return

	# 1. Update text labels in customization list
	var body_idx = CustomizationManager.available_bodies.find(CustomizationManager.current_body)
	body_label.text = " Pele: Pele " + str(body_idx + 1) + " "
	
	hair_label.text = " Cabelo: " + CustomizationManager.current_hair.capitalize() + " "
	clothes_label.text = " Roupa: " + CustomizationManager.current_clothes.capitalize() + " "
	
	var pants_type = "Normal" if CustomizationManager.current_pants == "pants" else "Terno"
	pants_label.text = " Calça: " + pants_type + " "

	# 2. Re-render dynamic color swatches to reflect border highlights
	_build_color_swatches()

	# 3. Dynamic Textures & Frames for bug-free previews
	# Body/Skin Preview
	var body_path = "res://assets/sprites/player/separate/walk/" + CustomizationManager.current_body + "_walk.png"
	if ResourceLoader.exists(body_path):
		var tex = load(body_path)
		body_preview.texture = tex
		body_preview.hframes = int(tex.get_width() / 32)
		body_preview.vframes = int(tex.get_height() / 32)

	# Legs/Pants Preview
	var legs_path = "res://assets/sprites/player/separate/walk/panths/" + CustomizationManager.current_pants + "_walk.png"
	if ResourceLoader.exists(legs_path):
		var tex = load(legs_path)
		legs_preview.texture = tex
		legs_preview.hframes = int(tex.get_width() / 32)
		legs_preview.vframes = int(tex.get_height() / 32)

	# Clothes Preview
	var clothes_path = "res://assets/sprites/player/separate/walk/clothes/" + CustomizationManager.current_clothes + "_walk.png"
	if ResourceLoader.exists(clothes_path):
		var tex = load(clothes_path)
		clothes_preview.texture = tex
		clothes_preview.hframes = int(tex.get_width() / 32)
		clothes_preview.vframes = int(tex.get_height() / 32)

	# Hair Preview
	var hair_path = "res://assets/sprites/player/separate/walk/hair/" + CustomizationManager.current_hair + "_walk.png"
	if ResourceLoader.exists(hair_path):
		var tex = load(hair_path)
		hair_preview.texture = tex
		hair_preview.hframes = int(tex.get_width() / 32)
		hair_preview.vframes = int(tex.get_height() / 32)
		
	# Apply Hair Modulate Color in Preview
	hair_preview.modulate = CustomizationManager.hair_color

	# Ensure frames are drawn correctly after texture updates
	_update_preview_frames()

func _on_close() -> void:
	queue_free()
