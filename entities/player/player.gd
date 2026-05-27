extends CharacterBody2D

@onready var movement_component: MovementComponent = $MovementComponent
@onready var tool_component: ToolComponent = $ToolComponent

@export var inventory_data: InventoryData

var lantern: PointLight2D = null

func _ready() -> void:
	if inventory_data == null:
		inventory_data = InventoryData.new()
		inventory_data.setup_default_inventory()
		
	# Pass inventory to ToolComponent
	if tool_component:
		tool_component.setup(inventory_data)
		
	# Instantiate HUD
	var hud_scene = load("res://ui/hud/hud.tscn")
	if hud_scene:
		var hud_instance = hud_scene.instantiate()
		add_child(hud_instance)
		hud_instance.setup(inventory_data)
		
	# Initialize Customization Component
	var customization_script = load("res://entities/player/customization_component.gd")
	if customization_script:
		var customization_instance = customization_script.new()
		customization_instance.animation_player = $AnimationPlayer
		customization_instance.name = "CustomizationComponent"
		add_child(customization_instance)
	
	# Setup Player Lantern (PointLight2D)
	lantern = PointLight2D.new()
	var texture_2d = GradientTexture2D.new()
	var gradient = Gradient.new()
	gradient.offsets = [0.0, 1.0]
	gradient.colors = [Color(1.0, 0.95, 0.7, 0.95), Color(1.0, 0.95, 0.7, 0.0)]
	texture_2d.gradient = gradient
	texture_2d.fill = GradientTexture2D.FILL_RADIAL
	texture_2d.fill_from = Vector2(0.5, 0.5)
	texture_2d.fill_to = Vector2(1.0, 0.5)
	texture_2d.width = 256
	texture_2d.height = 256
	
	lantern.texture = texture_2d
	lantern.texture_scale = 1.5
	lantern.energy = 0.0 # Start off during daytime
	lantern.blend_mode = Light2D.BLEND_MODE_ADD
	lantern.name = "Lantern"
	add_child(lantern)

func _process(delta: float) -> void:
	_update_lantern_energy(delta)

func _physics_process(_delta: float) -> void:
	tool_component.update_target_preview(movement_component.last_direction)
	tool_component.handle_tool_switch()
	tool_component.handle_tool_use(movement_component.last_direction)

	if tool_component.is_using_tool:
		movement_component.stop_movement()
	else:
		movement_component.handle_movement()
		
	_handle_dust_particles()

func _handle_dust_particles() -> void:
	var dust_particles = get_node_or_null("FloorEffects/DustParticles") as CPUParticles2D
	if not dust_particles:
		return
		
	if velocity.length() == 0:
		dust_particles.emitting = false
		return
		
	var current_scene = get_tree().current_scene
	var grass_layer = current_scene.get_node_or_null("Grass_layer") as TileMapLayer
	
	var is_on_dirt = true
	if grass_layer:
		var cell_pos = grass_layer.local_to_map(grass_layer.to_local(global_position))
		if grass_layer.get_cell_source_id(cell_pos) != -1:
			is_on_dirt = false
			
	dust_particles.emitting = is_on_dirt

func _update_lantern_energy(_delta: float) -> void:
	if not lantern or not is_instance_valid(lantern):
		return
		
	# Safe check if TimeManager is loaded
	var time_mgr = get_node_or_null("/root/TimeManager")
	if not time_mgr:
		return
		
	var hour = time_mgr.hour
	var minute = time_mgr.minute
	var time: float = hour + (minute / 60.0)
	
	var target_energy: float = 0.0
	
	# Night time (18:30 to 5:30) -> Lantern is fully active (0.95 energy)
	if time >= 18.5 or time < 5.5:
		target_energy = 0.95
	# Sunset transition (17:30 to 18:30) -> Fade in
	elif time >= 17.5 and time < 18.5:
		target_energy = (time - 17.5) * 0.95
	# Sunrise transition (5:30 to 6:30) -> Fade out
	elif time >= 5.5 and time < 6.5:
		target_energy = (1.0 - (time - 5.5)) * 0.95
	
	# Smoothly interpolate energy to feel organic
	lantern.energy = lerp(lantern.energy, target_energy, 0.1)
