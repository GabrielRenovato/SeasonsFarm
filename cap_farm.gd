extends Node2D

func _ready() -> void:
	var sv := SubViewport.new()
	sv.size = Vector2i(360, 220)
	sv.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(sv)
	var farm: Node = load("res://levels/main_farm/farm.tscn").instantiate()
	sv.add_child(farm)
	for i in range(10):
		await get_tree().process_frame
	var layer: Node = farm.find_child("ShoreLayer", true, false)
	if layer == null:
		layer = farm.find_child("WaterLayer", true, false)
	var cam := Camera2D.new()
	sv.add_child(cam)
	cam.zoom = Vector2(2.6, 2.6)
	if layer:
		var cells: Array = layer.get_used_cells()
		if cells.size() > 0:
			var s := Vector2.ZERO
			for c in cells:
				s += layer.map_to_local(c)
			cam.global_position = layer.to_global(s / cells.size())
	cam.make_current()
	for i in range(6):
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	sv.get_texture().get_image().save_png("res://scratch/farm_lake.png")
	print("CAP OK layer=", layer)
	get_tree().quit()
