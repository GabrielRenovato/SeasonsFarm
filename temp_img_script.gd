extends SceneTree

func _init():
	var dir = DirAccess.open('res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Tree/Common/Effects')
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != '':
		if file_name.ends_with('.png'):
			var tex = Image.load_from_file('res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Tree/Common/Effects/' + file_name)
			print(file_name, ' size: ', tex.get_size())
		file_name = dir.get_next()
	quit()

