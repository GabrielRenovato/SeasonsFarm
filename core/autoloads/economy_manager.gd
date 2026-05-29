extends Node

var gold: int = 0
signal gold_changed(new_amount: int)

const RARITY_MULTIPLIER: Dictionary = {
	"common": 1.0,
	"silver": 1.5,
	"gold":   3.0,
}

func get_sell_price(crop_id: String, rarity: String) -> int:
	var base: int = FarmManager.CROP_CONFIGS.get(crop_id, {}).get("base_price", 10)
	return int(base * RARITY_MULTIPLIER.get(rarity, 1.0))

func add_gold(amount: int) -> void:
	gold += amount
	gold_changed.emit(gold)

func spend_gold(amount: int) -> bool:
	if gold < amount:
		return false
	gold -= amount
	gold_changed.emit(gold)
	return true
