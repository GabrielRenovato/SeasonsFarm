extends Resource
class_name CropConfig

## Dados de configuração de uma cultura plantável.
## Crie um .tres por cultura no editor e popule via inspector.

@export var crop_id: String = ""
@export var display_name: String = ""

@export_enum("spring", "summer", "fall", "winter") var season: String = "spring"

@export_range(1, 12) var growth_stages: int = 6
@export var frame_size: int = 16

## Índices de frame para cada estágio de crescimento (tamanho deve bater com growth_stages)
@export var frame_map: Array[int] = []

@export_range(1, 500) var base_price: int = 20

## Textura do sprite de crescimento (animation strip)
@export var growth_texture: Texture2D

## Posição X do seed bag em All Crops.png (Spring=0, Summer=144, Fall=288)
@export var seed_x: int = 0
## Posição Y do seed bag em All Crops.png (linha do cultivo × 16)
@export var seed_y: int = 0
