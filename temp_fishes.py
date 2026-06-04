import os

fish_data = [
    ('fish_trout', 'Trout', 15, 'Spring', 'Common', 'icon_trout.png'),
    ('fish_salmon', 'Salmon', 40, 'Spring', 'Uncommon', 'icon_salmon.png'),
    ('fish_bass', 'Bass', 20, 'Summer', 'Common', 'icon_bass.png'),
    ('fish_pufferfish', 'Pufferfish', 100, 'Summer', 'Rare', 'icon_pufferfish.png'),
    ('fish_carp', 'Carp', 15, 'Fall', 'Common', 'icon_carp.png'),
    ('fish_catfish', 'Catfish', 50, 'Fall', 'Uncommon', 'icon_catfish.png'),
    ('fish_ice_pip', 'Ice Pip', 150, 'Winter', 'Rare', 'icon_ice_pip.png'),
    ('fish_sturgeon', 'Sturgeon', 300, 'Winter', 'Legendary', 'icon_sturgeon.png')
]

out_dir = r'C:\Users\ofici\OneDrive\Documentos\farm-gaming\systems\inventory\items'
template = '''[gd_resource type="Resource" script_class="ItemData" load_steps=3 format=3]

[ext_resource type="Script" uid="uid://cmtdsh2fay4r3" path="res://systems/inventory/item_data.gd" id="1_script"]
[ext_resource type="Texture2D" path="res://assets/sprites/fishing/{icon}" id="2_icon"]

[resource]
script = ExtResource("1_script")
id = "{id}"
name = "{name}"
sell_price = {price}
is_tool = false
tool_type = ""
tier = "Wood"
is_seed = false
crop_type = ""
rarity = "common"
is_furniture = false
furniture_id = ""
is_fish = true
fish_season = "{season}"
fish_rarity = "{rarity}"
icon_color = Color(1, 1, 1, 1)
icon_texture = ExtResource("2_icon")
'''

for d in fish_data:
    content = template.format(id=d[0], name=d[1], price=d[2], season=d[3], rarity=d[4], icon=d[5])
    with open(os.path.join(out_dir, d[0] + '.tres'), 'w', encoding='utf-8') as f:
        f.write(content)

print('Created 8 fish resources')
