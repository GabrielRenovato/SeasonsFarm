extends CanvasLayer

@onready var hair_label = $CenterContainer/VBoxContainer/HairHBox/HairLabel
@onready var clothes_label = $CenterContainer/VBoxContainer/ClothesHBox/ClothesLabel

@onready var body_preview = $CenterContainer/VBoxContainer/PreviewArea/BodyPreview
@onready var legs_preview = $CenterContainer/VBoxContainer/PreviewArea/BodyPreview/LagsPreview
@onready var clothes_preview = $CenterContainer/VBoxContainer/PreviewArea/BodyPreview/ClothePreview
@onready var hair_preview = $CenterContainer/VBoxContainer/PreviewArea/BodyPreview/HairPreview

func _ready() -> void:
	if CustomizationManager:
		CustomizationManager.customization_changed.connect(_update_ui)
	
	# Load base static textures for preview
	body_preview.texture = load("res://assets/sprites/player/separate/walk/char1_walk.png")
	legs_preview.texture = load("res://assets/sprites/player/separate/walk/panths/pants_walk.png")
	
	_update_ui()
		
	$CenterContainer/VBoxContainer/HairHBox/PrevHair.pressed.connect(func(): CustomizationManager.prev_hair())
	$CenterContainer/VBoxContainer/HairHBox/NextHair.pressed.connect(func(): CustomizationManager.next_hair())
	
	$CenterContainer/VBoxContainer/ClothesHBox/PrevClothes.pressed.connect(func(): CustomizationManager.prev_clothes())
	$CenterContainer/VBoxContainer/ClothesHBox/NextClothes.pressed.connect(func(): CustomizationManager.next_clothes())
	
	$CenterContainer/VBoxContainer/CloseButton.pressed.connect(_on_close)

func _update_ui() -> void:
	if not CustomizationManager: return
	
	# Update Labels
	hair_label.text = " Cabelo: " + CustomizationManager.current_hair.capitalize() + " "
	clothes_label.text = " Roupa: " + CustomizationManager.current_clothes.capitalize() + " "
	
	# Update Preview Textures
	var hair_path = "res://assets/sprites/player/separate/walk/hair/" + CustomizationManager.current_hair + "_walk.png"
	if ResourceLoader.exists(hair_path):
		hair_preview.texture = load(hair_path)
		
	var clothes_path = "res://assets/sprites/player/separate/walk/clothes/" + CustomizationManager.current_clothes + "_walk.png"
	if ResourceLoader.exists(clothes_path):
		clothes_preview.texture = load(clothes_path)

func _on_close() -> void:
	queue_free()
