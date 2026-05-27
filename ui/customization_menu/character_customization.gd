extends CanvasLayer

@onready var hair_label = $CenterContainer/VBoxContainer/HairHBox/HairLabel
@onready var clothes_label = $CenterContainer/VBoxContainer/ClothesHBox/ClothesLabel

func _ready() -> void:
	if CustomizationManager:
		CustomizationManager.customization_changed.connect(_update_ui)
		_update_ui()
		
	$CenterContainer/VBoxContainer/HairHBox/PrevHair.pressed.connect(func(): CustomizationManager.prev_hair())
	$CenterContainer/VBoxContainer/HairHBox/NextHair.pressed.connect(func(): CustomizationManager.next_hair())
	
	$CenterContainer/VBoxContainer/ClothesHBox/PrevClothes.pressed.connect(func(): CustomizationManager.prev_clothes())
	$CenterContainer/VBoxContainer/ClothesHBox/NextClothes.pressed.connect(func(): CustomizationManager.next_clothes())
	
	$CenterContainer/VBoxContainer/CloseButton.pressed.connect(_on_close)

func _update_ui() -> void:
	if not CustomizationManager: return
	hair_label.text = " Cabelo: " + CustomizationManager.current_hair.capitalize() + " "
	clothes_label.text = " Roupa: " + CustomizationManager.current_clothes.capitalize() + " "

func _on_close() -> void:
	queue_free()
