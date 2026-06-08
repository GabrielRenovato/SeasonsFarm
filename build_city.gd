extends SceneTree

func _init():
    var city = Node2D.new()
    city.name = "City"
    city.y_sort_enabled = true

    # Ground layer
    var ground = TileMapLayer.new()
    ground.name = "GroundLayer"
    ground.y_sort_enabled = true
    ground.z_index = -1
    
    # Try to load existing grass tileset from farm
    var ts = load("res://levels/main_farm/tilesets/tileset_grama.tres")
    if ts:
        ground.tile_set = ts
    city.add_child(ground)
    ground.owner = city

    var buildings_to_add = [
        {"name": "Blacksmith", "path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Exterior/Houses/NPCS houses/Blacksmith.png", "pos": Vector2(-200, -100)},
        {"name": "School", "path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Exterior/Houses/NPCS houses/School.png", "pos": Vector2(200, -100)},
        {"name": "WizardsHouse", "path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Exterior/Houses/NPCS houses/wizard's house.png", "pos": Vector2(-400, 150)},
        {"name": "Temple", "path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Exterior/Houses/NPCS houses/temple.png", "pos": Vector2(0, 200)},
        {"name": "Fishman", "path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Exterior/Houses/NPCS houses/Fishman.png", "pos": Vector2(400, 200)},
        {"name": "TrainStation", "path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Exterior/Houses/NPCS houses/train station.png", "pos": Vector2(0, -300)}
    ]

    var y_sort_group = Node2D.new()
    y_sort_group.name = "Buildings"
    y_sort_group.y_sort_enabled = true
    city.add_child(y_sort_group)
    y_sort_group.owner = city

    for b in buildings_to_add:
        var body = StaticBody2D.new()
        body.name = b["name"]
        body.position = b["pos"]
        y_sort_group.add_child(body)
        body.owner = city

        var sprite = Sprite2D.new()
        sprite.name = "Sprite2D"
        var tex = load(b["path"])
        if tex:
            sprite.texture = tex
            # offset so bottom is near position
            sprite.offset = Vector2(0, -tex.get_height() / 2.0 + 20)
        body.add_child(sprite)
        sprite.owner = city

        var col = CollisionShape2D.new()
        col.name = "CollisionShape2D"
        var shape = RectangleShape2D.new()
        if tex:
            shape.size = Vector2(tex.get_width() * 0.8, tex.get_height() * 0.3)
        else:
            shape.size = Vector2(100, 50)
        col.shape = shape
        # Move collision to bottom
        col.position = Vector2(0, -shape.size.y / 2.0)
        body.add_child(col)
        col.owner = city

    # Farm Transition
    var transition_area = Area2D.new()
    transition_area.name = "FarmTransition"
    transition_area.position = Vector2(0, 400)
    city.add_child(transition_area)
    transition_area.owner = city

    var t_col = CollisionShape2D.new()
    t_col.name = "CollisionShape2D"
    var t_shape = RectangleShape2D.new()
    t_shape.size = Vector2(200, 50)
    t_col.shape = t_shape
    transition_area.add_child(t_col)
    t_col.owner = city

    # Save scene
    var packed = PackedScene.new()
    packed.pack(city)
    var err = ResourceSaver.save(packed, "res://levels/city/city.tscn")
    if err == OK:
        print("Scene levels/city/city.tscn created successfully!")
    else:
        print("Error saving scene: ", err)
    
    quit()
