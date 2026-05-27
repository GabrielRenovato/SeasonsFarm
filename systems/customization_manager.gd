extends Node

signal customization_changed

# These should match the prefixes in your asset folder (e.g. "bob_walk.png")
var available_hairstyles = ["bob", "spiky", "long"]
var available_clothes = ["basic", "overall"]
var available_bodies = ["light", "dark"]

var current_hair: String = "bob"
var current_clothes: String = "basic"
var current_body: String = "light"

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
