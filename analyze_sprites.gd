extends SceneTree

func _init():
	var paths = [
		"c:/Users/ofici/OneDrive/Documentos/farm-gaming/assets/sprites/tree/Common/Shadow/Pine Tree Animation.png",
		"c:/Users/ofici/OneDrive/Documentos/farm-gaming/assets/sprites/tree/Common/Shadow/Birch Tree Animation.png",
		"c:/Users/ofici/OneDrive/Documentos/farm-gaming/assets/sprites/tree/Common/Shadow/Maple Tree Animation.png"
	]
	
	for path in paths:
		print("-------------------------")
		print("Analyzing: ", path.get_file())
		var img = Image.load_from_file(path)
		if not img:
			print("Failed to load")
			continue
			
		var w = img.get_width()
		var h = img.get_height()
		print("Size: ", w, "x", h)
		
		# hframes is 4 for all of them
		var cols = 4
		var rows = h / 48
		if w / 32 != 4:
			print("WARNING: width/32 is not 4! It is ", w/32)
			
		var cell_w = 32
		var cell_h = 48
		
		for r in range(rows):
			var row_str = "Row " + str(r) + ": "
			for c in range(cols):
				# count non-transparent pixels
				var pixels = 0
				var r_color = 0.0
				var g_color = 0.0
				var b_color = 0.0
				for y in range(cell_h):
					for x in range(cell_w):
						var px = img.get_pixel(c * cell_w + x, r * cell_h + y)
						if px.a > 0.1:
							pixels += 1
							r_color += px.r
							g_color += px.g
							b_color += px.b
				
				if pixels > 0:
					r_color /= pixels
					g_color /= pixels
					b_color /= pixels
				
				# classify size
				var size_str = "Empty"
				if pixels > 500:
					size_str = "BIG  "
				elif pixels > 200:
					size_str = "MED  "
				elif pixels > 0:
					size_str = "SMALL"
					
				# classify color
				var color_str = "None"
				if pixels > 0:
					if r_color > 0.6 and g_color > 0.6 and b_color > 0.6:
						color_str = "White" # winter
					elif g_color > r_color and g_color > b_color:
						color_str = "Green" # spring/summer
					elif r_color > g_color and r_color > 0.5:
						color_str = "Orange" # fall
					else:
						color_str = "Mixed"
						
				row_str += "[" + size_str + " " + color_str + " (" + str(pixels) + "px)] "
			print(row_str)
			
	quit()
