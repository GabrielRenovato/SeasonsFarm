extends Node
## Base de dados de peixes disponíveis no jogo.
## Autoload: acessível globalmente como FishDatabase.
## Cada peixe tem id, nome, raridade e peso min/max.

# Sinal emitido quando um peixe é pescado (para estatísticas futuras)
signal fish_caught(fish_id: String, rarity: String)

# Definição de raridades com suas cores e chances
# "weight" é o peso relativo na roleta de sorteio
const RARITIES = {
	"common": {
		"color": Color(0.8, 0.8, 0.8),       # Cinza claro
		"label": "Common",
		"weight": 50,                          # 50% de chance
	},
	"uncommon": {
		"color": Color(0.3, 0.9, 0.3),        # Verde
		"label": "Uncommon",
		"weight": 30,                          # 30% de chance
	},
	"rare": {
		"color": Color(0.3, 0.5, 1.0),        # Azul
		"label": "Rare",
		"weight": 15,                          # 15% de chance
	},
	"legendary": {
		"color": Color(1.0, 0.84, 0.0),       # Dourado
		"label": "Legendary",
		"weight": 5,                           # 5% de chance
	},
}

# Catálogo de peixes do jogo
# Cada peixe tem: nome visível, raridade base, faixa de peso, e comportamento (behavior)
const FISH_CATALOG = {
	"bluegill": {
		"name": "Bluegill",
		"base_rarity": "common",
		"min_weight": 0.2,
		"max_weight": 1.5,
		"description": "A small, common freshwater fish.",
		"behavior": "smooth",
		"difficulty": 20,
	},
	"catfish": {
		"name": "Catfish",
		"base_rarity": "common",
		"min_weight": 0.5,
		"max_weight": 3.0,
		"description": "A whiskered bottom-feeder.",
		"behavior": "sinker",
		"difficulty": 35,
	},
	"bass": {
		"name": "Bass",
		"base_rarity": "uncommon",
		"min_weight": 0.8,
		"max_weight": 4.0,
		"description": "A popular sport fish with a strong bite.",
		"behavior": "mixed",
		"difficulty": 50,
	},
	"trout": {
		"name": "Trout",
		"base_rarity": "uncommon",
		"min_weight": 0.5,
		"max_weight": 3.5,
		"description": "A beautiful spotted fish from cold waters.",
		"behavior": "dart",
		"difficulty": 65,
	},
	"salmon": {
		"name": "Salmon",
		"base_rarity": "rare",
		"min_weight": 1.0,
		"max_weight": 6.0,
		"description": "A prized fish known for swimming upstream.",
		"behavior": "floater",
		"difficulty": 80,
	},
	"golden_koi": {
		"name": "Golden Koi",
		"base_rarity": "legendary",
		"min_weight": 2.0,
		"max_weight": 8.0,
		"description": "A mythical golden fish said to bring fortune.",
		"behavior": "mixed",
		"difficulty": 95,
	},
}

## Sorteia um peixe aleatório baseado nas raridades.
## Retorna um dicionário com: id, name, rarity, weight, description
func roll_fish() -> Dictionary:
	# Primeiro sorteia a raridade
	var rarity = _roll_rarity()
	
	# Filtra peixes que combinam com essa raridade
	var matching_fish: Array = []
	for fish_id in FISH_CATALOG:
		if FISH_CATALOG[fish_id]["base_rarity"] == rarity:
			matching_fish.append(fish_id)
	
	# Se não encontrou nenhum peixe dessa raridade, pega qualquer um
	if matching_fish.is_empty():
		matching_fish = FISH_CATALOG.keys()
	
	# Escolhe um peixe aleatório entre os que combinam
	var chosen_id = matching_fish[randi() % matching_fish.size()]
	var fish_data = FISH_CATALOG[chosen_id]
	
	# Gera um peso aleatório dentro da faixa do peixe
	var weight = randf_range(fish_data["min_weight"], fish_data["max_weight"])
	weight = snapped(weight, 0.1)  # Arredonda para 1 casa decimal
	
	# Emite sinal para sistemas de estatísticas
	fish_caught.emit(chosen_id, rarity)
	
	return {
		"id": chosen_id,
		"name": fish_data["name"],
		"rarity": rarity,
		"weight": weight,
		"description": fish_data["description"],
		"color": RARITIES[rarity]["color"],
		"rarity_label": RARITIES[rarity]["label"],
	}

## Sorteia uma raridade baseada nos pesos definidos em RARITIES
func _roll_rarity() -> String:
	var total_weight: int = 0
	for rarity_key in RARITIES:
		total_weight += RARITIES[rarity_key]["weight"]
	
	var roll = randi() % total_weight
	var accumulated: int = 0
	
	for rarity_key in RARITIES:
		accumulated += RARITIES[rarity_key]["weight"]
		if roll < accumulated:
			return rarity_key
	
	# Fallback (nunca deve chegar aqui)
	return "common"
