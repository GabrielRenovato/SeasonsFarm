extends SceneTree
func _init():
    var img = Image.load_from_file("res://assets/sprites/tree/Common/Shadow/Pine Tree Animation.png")
    print("FULL TREE: ", img.get_width(), "x", img.get_height())
    var img2 = Image.load_from_file("res://assets/sprites/tree/Common/Shadow/Pine Tree.png")
    print("SMALL TREE: ", img2.get_width(), "x", img2.get_height())
    quit()
