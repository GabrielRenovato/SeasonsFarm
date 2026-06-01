import re

file_path = r'c:\Users\ofici\OneDrive\Documentos\farm-gaming\entities\player\player.tscn'

with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Add ExtResources
ext_resources = """[ext_resource type="Texture2D" uid="uid://sitcloth001" path="res://assets/sprites/Character/PNG/18. Setting/Clothers/Farm/Blue.png" id="sit_cloth"]
[ext_resource type="Texture2D" uid="uid://siteyes0001" path="res://assets/sprites/Character/PNG/18. Setting/Eyes/Male/Black.png" id="sit_eyes"]
[ext_resource type="Texture2D" uid="uid://sithair0001" path="res://assets/sprites/Character/PNG/18. Setting/Hair's/Standard/Brown.png" id="sit_hair"]
[ext_resource type="Texture2D" uid="uid://sitskin0001" path="res://assets/sprites/Character/PNG/18. Setting/Skins/1.png" id="sit_skin"]
"""
last_ext_idx = content.rfind('[ext_resource')
end_of_last_ext = content.find('\n', last_ext_idx) + 1
if 'id="sit_skin"' not in content:
    content = content[:end_of_last_ext] + ext_resources + content[end_of_last_ext:]

# 2. Add Animations
animations = []
directions = ['down', 'up', 'right', 'left']
for i, dir in enumerate(directions):
    anim = f"""[sub_resource type="Animation" id="Animation_sit_{dir}"]
resource_name = "sit_{dir}"
length = 0.1
tracks/0/type = "value"
tracks/0/imported = false
tracks/0/enabled = true
tracks/0/path = NodePath("Body:texture")
tracks/0/interp = 1
tracks/0/loop_wrap = true
tracks/0/keys = {{
"times": PackedFloat32Array(0),
"transitions": PackedFloat32Array(1),
"update": 1,
"values": [ExtResource("sit_skin")]
}}
tracks/1/type = "value"
tracks/1/imported = false
tracks/1/enabled = true
tracks/1/path = NodePath("Eyes:texture")
tracks/1/interp = 1
tracks/1/loop_wrap = true
tracks/1/keys = {{
"times": PackedFloat32Array(0),
"transitions": PackedFloat32Array(1),
"update": 1,
"values": [ExtResource("sit_eyes")]
}}
tracks/2/type = "value"
tracks/2/imported = false
tracks/2/enabled = true
tracks/2/path = NodePath("Hair:texture")
tracks/2/interp = 1
tracks/2/loop_wrap = true
tracks/2/keys = {{
"times": PackedFloat32Array(0),
"transitions": PackedFloat32Array(1),
"update": 1,
"values": [ExtResource("sit_hair")]
}}
tracks/3/type = "value"
tracks/3/imported = false
tracks/3/enabled = true
tracks/3/path = NodePath("Clothes:texture")
tracks/3/interp = 1
tracks/3/loop_wrap = true
tracks/3/keys = {{
"times": PackedFloat32Array(0),
"transitions": PackedFloat32Array(1),
"update": 1,
"values": [ExtResource("sit_cloth")]
}}
tracks/4/type = "value"
tracks/4/imported = false
tracks/4/enabled = true
tracks/4/path = NodePath("Tool:visible")
tracks/4/interp = 1
tracks/4/loop_wrap = true
tracks/4/keys = {{
"times": PackedFloat32Array(0),
"transitions": PackedFloat32Array(1),
"update": 1,
"values": [false]
}}
tracks/5/type = "value"
tracks/5/imported = false
tracks/5/enabled = true
tracks/5/path = NodePath("Body:hframes")
tracks/5/interp = 1
tracks/5/loop_wrap = true
tracks/5/keys = {{
"times": PackedFloat32Array(0),
"transitions": PackedFloat32Array(1),
"update": 1,
"values": [4]
}}
tracks/6/type = "value"
tracks/6/imported = false
tracks/6/enabled = true
tracks/6/path = NodePath("Eyes:hframes")
tracks/6/interp = 1
tracks/6/loop_wrap = true
tracks/6/keys = {{
"times": PackedFloat32Array(0),
"transitions": PackedFloat32Array(1),
"update": 1,
"values": [4]
}}
tracks/7/type = "value"
tracks/7/imported = false
tracks/7/enabled = true
tracks/7/path = NodePath("Hair:hframes")
tracks/7/interp = 1
tracks/7/loop_wrap = true
tracks/7/keys = {{
"times": PackedFloat32Array(0),
"transitions": PackedFloat32Array(1),
"update": 1,
"values": [4]
}}
tracks/8/type = "value"
tracks/8/imported = false
tracks/8/enabled = true
tracks/8/path = NodePath("Clothes:hframes")
tracks/8/interp = 1
tracks/8/loop_wrap = true
tracks/8/keys = {{
"times": PackedFloat32Array(0),
"transitions": PackedFloat32Array(1),
"update": 1,
"values": [4]
}}
tracks/9/type = "value"
tracks/9/imported = false
tracks/9/enabled = true
tracks/9/path = NodePath("Body:frame")
tracks/9/interp = 1
tracks/9/loop_wrap = true
tracks/9/keys = {{
"times": PackedFloat32Array(0),
"transitions": PackedFloat32Array(1),
"update": 1,
"values": [{i}]
}}
tracks/10/type = "value"
tracks/10/imported = false
tracks/10/enabled = true
tracks/10/path = NodePath("Eyes:frame")
tracks/10/interp = 1
tracks/10/loop_wrap = true
tracks/10/keys = {{
"times": PackedFloat32Array(0),
"transitions": PackedFloat32Array(1),
"update": 1,
"values": [{i}]
}}
tracks/11/type = "value"
tracks/11/imported = false
tracks/11/enabled = true
tracks/11/path = NodePath("Hair:frame")
tracks/11/interp = 1
tracks/11/loop_wrap = true
tracks/11/keys = {{
"times": PackedFloat32Array(0),
"transitions": PackedFloat32Array(1),
"update": 1,
"values": [{i}]
}}
tracks/12/type = "value"
tracks/12/imported = false
tracks/12/enabled = true
tracks/12/path = NodePath("Clothes:frame")
tracks/12/interp = 1
tracks/12/loop_wrap = true
tracks/12/keys = {{
"times": PackedFloat32Array(0),
"transitions": PackedFloat32Array(1),
"update": 1,
"values": [{i}]
}}
"""
    animations.append(anim)

anim_block = "\n".join(animations)

if 'id="Animation_sit_down"' not in content:
    lib_idx = content.find('[sub_resource type="AnimationLibrary" id="AnimationLibrary_new"]')
    content = content[:lib_idx] + anim_block + content[lib_idx:]

    # 3. Add to _data
    lib_data_idx = content.find('_data = {', lib_idx) + 9
    new_data = ""
    for dir in directions:
        new_data += f'\n&"sit_{dir}": SubResource("Animation_sit_{dir}"),'
    content = content[:lib_data_idx] + new_data + content[lib_data_idx:]

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Animations added successfully.")
