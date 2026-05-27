extends Resource
class_name SlotData

@export var item: ItemData
@export var quantity: int = 0:
	set(value):
		quantity = value
		if quantity <= 0:
			item = null
			quantity = 0
