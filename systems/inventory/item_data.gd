extends Resource
class_name ItemData

@export_group("Identity")
@export var id: String = ""
@export var name: String = ""

@export_group("Economy")
## How many coins this item sells for
@export var sell_price: int = 0

@export_group("Tool")
@export var is_tool: bool = false
@export_enum("Hoe", "Axe", "Pickaxe", "Water", "Sickle", "FishCast") var tool_type: String = ""
@export_enum("Wood", "Cooper", "Iron", "Gold", "Platinum", "Crimson", "Frost", "Shadow", "Fairy", "Obsidian") var tier: String = "Wood"

@export_group("Seed / Crop")
@export var is_seed: bool = false
@export var crop_type: String = ""
@export_enum("common", "silver", "gold") var rarity: String = "common"

@export_group("Furniture")
@export var is_furniture: bool = false
@export var furniture_id: String = ""

@export_group("Fish")
## Is this item a fish?
@export var is_fish: bool = false
## Which season this fish can be caught in
@export_enum("Any", "Spring", "Summer", "Fall", "Winter") var fish_season: String = "Any"
## Rarity of the fish (affects catch rate)
@export_enum("Common", "Uncommon", "Rare", "Legendary") var fish_rarity: String = "Common"

@export_group("Visual")
@export var icon_color: Color = Color.WHITE
@export var icon_texture: Texture2D
