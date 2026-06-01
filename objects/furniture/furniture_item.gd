extends StaticBody2D

# The unique id for this placed instance
var instance_id: String = ""

# The id of the furniture type (e.g. "bed_1")
@export var item_id: String = ""

@onready var sprite = $Sprite2D
@onready var collision_shape = $CollisionShape2D

# We use an Area2D to detect if we can place the object
@onready var placement_area = $PlacementArea
@onready var placement_collision = $PlacementArea/CollisionShape2D

var is_placed: bool = false
var can_place: bool = true

# We'll store rotation as an index: 0=Down, 1=Right, 2=Up, 3=Left
var current_rotation_index: int = 0

func _ready() -> void:
	input_pickable = true
	
	# If we are in edit mode, but haven't placed it yet
	if not is_placed:
		modulate = Color(1, 1, 1, 0.5)
		collision_shape.disabled = true
	else:
		modulate = Color(1, 1, 1, 1)
		collision_shape.disabled = false
		
func _input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if FurnitureManager.is_edit_mode and is_placed:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			pickup()
			FurnitureManager.furniture_picked_up.emit(self)
			get_viewport().set_input_as_handled()

func _process(_delta: float) -> void:
	if not is_placed:
		check_placement_validity()

# Rotates the furniture by swapping its sprite region
func rotate_item() -> void:
	current_rotation_index = (current_rotation_index + 1) % 4
	update_visuals()

# Updates the sprite region and collision size based on current rotation
func update_visuals() -> void:
	if not FurnitureManager.catalog.has(item_id): return

	var data = FurnitureManager.catalog[item_id]
	if data.has("regions"):
		var region: Rect2 = data["regions"][current_rotation_index]
		var tex = sprite.texture as AtlasTexture
		if tex:
			tex.region = region

		# A colisão é derivada do tamanho do sprite (centrado) + política por
		# categoria, garantindo navegação top-down natural e corrigindo móveis
		# como a cama de casal (sprite 48 mas colisão antiga de 32).
		var footprint := _compute_footprint(region.size)
		set_collision_size(footprint[0], footprint[1])

# Retorna [size, offset] da colisão para um sprite centrado de tamanho dado,
# conforme a categoria do móvel (prefixo do item_id).
func _compute_footprint(region_size: Vector2) -> Array:
	var w := region_size.x
	var h := region_size.y
	if item_id.begins_with("chair"):
		# Só a base da cadeira colide: dá pra encostar e sentar, e o
		# encosto/assento fica sobreponível (profundidade top-down).
		var sz := Vector2(w - 4.0, 8.0)
		return [sz, Vector2(0, h / 2.0 - sz.y / 2.0)]
	elif item_id.begins_with("desk"):
		# Mesa/escrivaninha: base sólida, topo sobreponível.
		var sz := Vector2(w - 2.0, h * 0.7)
		return [sz, Vector2(0, h / 2.0 - sz.y / 2.0)]
	elif item_id.begins_with("bed"):
		# Cama: sólida quase inteira, com pequena folga no topo.
		return [Vector2(w - 2.0, h - 4.0), Vector2(0, 1)]
	# Fallback: sprite inteiro
	return [region_size, Vector2.ZERO]

# Checks if the placement area is overlapping anything
func check_placement_validity() -> void:
	var overlaps = placement_area.get_overlapping_bodies()
	# Remove self from overlaps if it's there somehow
	var valid = true
	for body in overlaps:
		# If we hit a TileMap or another StaticBody2D, we can't place here
		if body != self and not body.is_in_group("player"):
			valid = false
			break
			
	can_place = valid
	
	if can_place:
		modulate = Color(0, 1, 0, 0.5) # Green
	else:
		modulate = Color(1, 0, 0, 0.5) # Red

# Called when the player finalizes placement
func place() -> void:
	is_placed = true
	modulate = Color(1, 1, 1, 1)
	collision_shape.disabled = false
	
	if instance_id == "":
		instance_id = str(Time.get_unix_time_from_system()) + str(randi())
		
	FurnitureManager.add_furniture(instance_id, item_id, position, current_rotation_index)

# Call this if the player picks it up again
func pickup() -> void:
	is_placed = false
	collision_shape.disabled = true
	FurnitureManager.remove_furniture(instance_id)

func set_texture(tex: Texture2D) -> void:
	sprite.texture = tex

func set_collision_size(size: Vector2, offset: Vector2 = Vector2.ZERO) -> void:
	var rect = RectangleShape2D.new()
	rect.size = size
	collision_shape.shape = rect
	collision_shape.position = offset
	
	var prect = RectangleShape2D.new()
	prect.size = size
	placement_collision.shape = prect
	placement_collision.position = offset
