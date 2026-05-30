extends CanvasLayer

const ROOT := "CenterContainer/Root"
const LEFT := ROOT + "/LeftPage"
const RIGHT := ROOT + "/RightPage"
const CATS := RIGHT + "/CategoryContainer"

@onready var body_preview: Sprite2D = get_node(LEFT + "/PreviewArea/BodyPreview")
@onready var legs_preview: Sprite2D = get_node(LEFT + "/PreviewArea/BodyPreview/LagsPreview")
@onready var eyes_preview: Sprite2D = get_node(LEFT + "/PreviewArea/BodyPreview/EyesPreview")
@onready var clothes_preview: Sprite2D = get_node(LEFT + "/PreviewArea/BodyPreview/ClothePreview")
@onready var hair_preview: Sprite2D = get_node(LEFT + "/PreviewArea/BodyPreview/HairPreview")

@onready var body_label: Label = get_node(CATS + "/BodyHBox/BodyLabel")
@onready var eyes_label: Label = get_node(CATS + "/EyesHBox/EyesLabel")
@onready var hair_label: Label = get_node(CATS + "/HairHBox/HairLabel")
@onready var clothes_label: Label = get_node(CATS + "/ClothesHBox/ClothesLabel")

@onready var color_grid: GridContainer = get_node(RIGHT + "/ColorGrid")
@onready var clouds_layer: Control = $CloudsLayer

const CLOUD_SPEEDS := {
	"CloudShadow1": 6.0,
	"CloudShadow2": 8.0,
	"Cloud1": 12.0,
	"Cloud2": 16.0,
	"Cloud3": 10.0,
	"Cloud4": 14.0,
}

# Paleta de cabelo no estilo Stardew Valley
var preset_colors = [
	Color("#e6b800"),
	Color("#5c3a21"),
	Color("#1c1c1c"),
	Color("#c0392b"),
	Color("#e67e22"),
	Color("#e91e63"),
	Color("#2980b9"),
	Color("#27ae60"),
	Color("#8e44ad"),
	Color("#ecf0f1")
]

func _ready() -> void:
	if CustomizationManager:
		CustomizationManager.customization_changed.connect(_update_ui)

	get_node(CATS + "/BodyHBox/PrevBody").pressed.connect(func(): CustomizationManager.prev_body())
	get_node(CATS + "/BodyHBox/NextBody").pressed.connect(func(): CustomizationManager.next_body())
	get_node(CATS + "/EyesHBox/PrevEyes").pressed.connect(func(): CustomizationManager.prev_eyes())
	get_node(CATS + "/EyesHBox/NextEyes").pressed.connect(func(): CustomizationManager.next_eyes())
	get_node(CATS + "/HairHBox/PrevHair").pressed.connect(func(): CustomizationManager.prev_hair())
	get_node(CATS + "/HairHBox/NextHair").pressed.connect(func(): CustomizationManager.next_hair())
	get_node(CATS + "/ClothesHBox/PrevClothes").pressed.connect(func(): CustomizationManager.prev_clothes())
	get_node(CATS + "/ClothesHBox/NextClothes").pressed.connect(func(): CustomizationManager.next_clothes())

	get_node(LEFT + "/CloseButton").pressed.connect(_on_close)

	_build_color_swatches()
	_update_ui()

func _process(delta: float) -> void:
	if clouds_layer == null:
		return
	var viewport_w := get_viewport().get_visible_rect().size.x
	for child in clouds_layer.get_children():
		var tr := child as TextureRect
		if tr == null:
			continue
		var speed: float = CLOUD_SPEEDS.get(tr.name, 10.0)
		var pos := tr.position
		pos.x += speed * delta
		if pos.x > viewport_w:
			pos.x = -tr.size.x
		tr.position = pos

func _update_preview_frames() -> void:
	body_preview.frame = 0
	if legs_preview.texture != null: legs_preview.frame = 0
	if clothes_preview.texture != null: clothes_preview.frame = 0
	if hair_preview.texture != null: hair_preview.frame = 0
	if eyes_preview.texture != null: eyes_preview.frame = 0

func _build_color_swatches() -> void:
	for child in color_grid.get_children():
		child.queue_free()

	for col in preset_colors:
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(10, 10)
		btn.focus_mode = Control.FOCUS_NONE

		var sb = StyleBoxFlat.new()
		sb.bg_color = col
		sb.corner_radius_top_left = 5
		sb.corner_radius_top_right = 5
		sb.corner_radius_bottom_left = 5
		sb.corner_radius_bottom_right = 5
		sb.border_width_left = 1
		sb.border_width_top = 1
		sb.border_width_right = 1
		sb.border_width_bottom = 1

		if CustomizationManager.hair_color.is_equal_approx(col):
			sb.border_color = Color("#ffffff")
		else:
			sb.border_color = Color("#2a1408")

		btn.add_theme_stylebox_override("normal", sb)
		btn.add_theme_stylebox_override("hover", sb)
		btn.add_theme_stylebox_override("pressed", sb)

		btn.pressed.connect(func():
			CustomizationManager.set_hair_color(col)
		)
		color_grid.add_child(btn)

func _update_ui() -> void:
	if not CustomizationManager: return

	var body_idx = CustomizationManager.available_bodies.find(CustomizationManager.current_body)
	body_label.text = "Pele " + str(body_idx + 1)

	eyes_label.text = CustomizationManager.current_eyes.capitalize()
	hair_label.text = CustomizationManager.current_hair.capitalize()
	clothes_label.text = CustomizationManager.current_clothes.capitalize()

	_build_color_swatches()

	var body_path = "res://assets/sprites/Character/PNG/1. Idle/Skins/" + CustomizationManager.current_body + ".png"
	if ResourceLoader.exists(body_path):
		var tex = load(body_path)
		body_preview.texture = tex
		body_preview.hframes = int(max(1, tex.get_width() / 32.0))
		body_preview.vframes = int(max(1, tex.get_height() / 32.0))

	var eyes_path = "res://assets/sprites/Character/PNG/1. Idle/Eyes/Male/" + CustomizationManager.current_eyes + ".png"
	if ResourceLoader.exists(eyes_path):
		var tex = load(eyes_path)
		eyes_preview.texture = tex
		eyes_preview.hframes = int(max(1, tex.get_width() / 32.0))
		eyes_preview.vframes = int(max(1, tex.get_height() / 32.0))

	legs_preview.texture = null

	var clothes_path = "res://assets/sprites/Character/PNG/1. Idle/Clothers/Farm/" + CustomizationManager.current_clothes + ".png"
	if ResourceLoader.exists(clothes_path):
		var tex = load(clothes_path)
		clothes_preview.texture = tex
		clothes_preview.hframes = int(max(1, tex.get_width() / 32.0))
		clothes_preview.vframes = int(max(1, tex.get_height() / 32.0))

	var hair_path = "res://assets/sprites/Character/PNG/1. Idle/Hair's/" + CustomizationManager.current_hair + "/Brown.png"
	if ResourceLoader.exists(hair_path):
		var tex = load(hair_path)
		hair_preview.texture = tex
		hair_preview.hframes = int(max(1, tex.get_width() / 32.0))
		hair_preview.vframes = int(max(1, tex.get_height() / 32.0))

	hair_preview.modulate = CustomizationManager.hair_color

	_update_preview_frames()

func _on_close() -> void:
	if get_tree().current_scene == self:
		get_tree().change_scene_to_file("res://levels/main_farm/farm.tscn")
	else:
		queue_free()
