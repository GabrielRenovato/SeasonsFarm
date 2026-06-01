import os

template = """[gd_resource type="Resource" script_class="ItemData" load_steps=4 format=3]

[ext_resource type="Script" path="res://systems/inventory/item_data.gd" id="1_xxx"]
[ext_resource type="Texture2D" path="{path}" id="2_yyy"]

[sub_resource type="AtlasTexture" id="AtlasTexture_zzz"]
atlas = ExtResource("2_yyy")
region = Rect2({x}, {y}, {w}, {h})

[resource]
script = ExtResource("1_xxx")
id = "{id}"
name = "{name}"
is_tool = false
tool_type = ""
is_seed = false
crop_type = ""
icon_color = Color(1, 1, 1, 1)
icon_texture = SubResource("AtlasTexture_zzz")
tier = "Wood"
rarity = "common"
is_furniture = true
furniture_id = "{fid}"
"""

items = [
    ('furniture_chair_2', 'Wooden Chair 1', 'res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Chairs.png', 128, 0, 16, 32, 'chair_3'),
    ('furniture_chair_3', 'Wooden Chair 2', 'res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Chairs.png', 128, 32, 16, 32, 'chair_7'),
    ('furniture_chair_4', 'Wooden Chair 3', 'res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Chairs.png', 192, 32, 16, 32, 'chair_8'),
    ('furniture_bed_single_1', 'Wooden Bed', 'res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Beds.png', 0, 0, 32, 48, 'bed_single_1'),
    ('furniture_bed_double_2', 'Wooden Double Bed', 'res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Beds.png', 0, 304, 48, 48, 'bed_double_9'),
    ('furniture_desk_2', 'Wooden Desk', 'res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Tables and desks.png', 0, 192, 32, 32, 'desk_97'),
    ('furniture_desk_3', 'Wooden Desk 2', 'res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/Tables and desks.png', 32, 192, 32, 32, 'desk_98'),
]

base_dir = r'c:\Users\ofici\OneDrive\Documentos\farm-gaming\systems\inventory\items'
for it in items:
    content = template.format(id=it[0], name=it[1], path=it[2], x=it[3], y=it[4], w=it[5], h=it[6], fid=it[7])
    with open(os.path.join(base_dir, it[0] + '.tres'), 'w') as f:
        f.write(content)
