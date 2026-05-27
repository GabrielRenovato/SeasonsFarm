extends Node

signal customization_changed

# Complete lists matching the real game assets in walk directories
var available_hairstyles = [
	"bob", "braids", "buzzcut", "curly", "emo", "extra_long", 
	"french_curl", "gentleman", "long_straight", "midiwave", 
	"ponytail", "spacebuns", "wavy"
]

var available_clothes = [
	"basic", "clown", "dress", "floral", "overalls", 
	"sailor_bow", "sailor", "shoes", "skirt", "skull", "spaghetti", 
	"sporty", "stripe", "suit"
]

var available_bodies = [
	"char1", "char2", "char3", "char4", "char5", "char6", "char7", "char8"
]

var available_pants = [
	"pants", "pants_suit"
]

var current_hair: String = "bob"
var current_clothes: String = "basic"
var current_body: String = "char1"
var current_pants: String = "pants"
var hair_color: Color = Color(1.0, 1.0, 1.0, 1.0) # Modulate color for hair

func set_hair(hair_name: String) -> void:
	if hair_name in available_hairstyles and current_hair != hair_name:
		current_hair = hair_name
		customization_changed.emit()

func set_clothes(clothes_name: String) -> void:
	if clothes_name in available_clothes and current_clothes != clothes_name:
		current_clothes = clothes_name
		customization_changed.emit()

func set_body(body_name: String) -> void:
	if body_name in available_bodies and current_body != body_name:
		current_body = body_name
		customization_changed.emit()

func set_pants(pants_name: String) -> void:
	if pants_name in available_pants and current_pants != pants_name:
		current_pants = pants_name
		customization_changed.emit()

func set_hair_color(color: Color) -> void:
	if hair_color != color:
		hair_color = color
		customization_changed.emit()

func next_hair() -> void:
	var idx = available_hairstyles.find(current_hair)
	idx = (idx + 1) % available_hairstyles.size()
	set_hair(available_hairstyles[idx])

func prev_hair() -> void:
	var idx = available_hairstyles.find(current_hair)
	idx = (idx - 1 + available_hairstyles.size()) % available_hairstyles.size()
	set_hair(available_hairstyles[idx])

func next_clothes() -> void:
	var idx = available_clothes.find(current_clothes)
	idx = (idx + 1) % available_clothes.size()
	set_clothes(available_clothes[idx])

func prev_clothes() -> void:
	var idx = available_clothes.find(current_clothes)
	idx = (idx - 1 + available_clothes.size()) % available_clothes.size()
	set_clothes(available_clothes[idx])

func next_body() -> void:
	var idx = available_bodies.find(current_body)
	idx = (idx + 1) % available_bodies.size()
	set_body(available_bodies[idx])

func prev_body() -> void:
	var idx = available_bodies.find(current_body)
	idx = (idx - 1 + available_bodies.size()) % available_bodies.size()
	set_body(available_bodies[idx])

func next_pants() -> void:
	var idx = available_pants.find(current_pants)
	idx = (idx + 1) % available_pants.size()
	set_pants(available_pants[idx])

func prev_pants() -> void:
	var idx = available_pants.find(current_pants)
	idx = (idx - 1 + available_pants.size()) % available_pants.size()
	set_pants(available_pants[idx])

