extends SceneTree

func _init():
	var img = Image.load_from_file("c:/Users/ofici/OneDrive/Documentos/farm-gaming/assets/sprites/tree/Common/Shadow/Pine Tree Animation.png")
	if img:
		print("IMAGE SIZE: ", img.get_width(), "x", img.get_height())
		# Save cells to inspect
		var cell_w = img.get_width() / 4
		var cell_h = img.get_height() / 4 # assuming 4 seasons
		print("CELL SIZE: ", cell_w, "x", cell_h)
	else:
		print("FAILED TO LOAD IMAGE")
	quit()
