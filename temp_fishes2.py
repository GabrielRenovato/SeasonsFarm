import os

fish_data = [
    ('fish_sunfish', 'Sunfish', 15, 'Spring', 'Common', 'icon_sunfish.png'),
    ('fish_pike', 'Pike', 40, 'Spring', 'Uncommon', 'icon_pike.png'),
    ('fish_clownfish', 'Clownfish', 20, 'Summer', 'Common', 'icon_clownfish.png'),
    ('fish_pufferfish', 'Pufferfish', 100, 'Summer', 'Rare', 'icon_pufferfish.png'),
    ('fish_catfish', 'Catfish', 15, 'Fall', 'Common', 'icon_catfish.png'),
    ('fish_zombie', 'Zombie Fish', 50, 'Fall', 'Uncommon', 'icon_zombie.png'),
    ('fish_glacier', 'Glacier Fish', 150, 'Winter', 'Rare', 'icon_glacier.png'),
    ('fish_angler', 'Anglerfish', 300, 'Winter', 'Legendary', 'icon_angler.png')
]

out_dir = r'C:\Users\ofici\OneDrive\Documentos\farm-gaming\systems\inventory\items'

# Delete old broken resources
old_ids = ['trout', 'salmon', 'bass', 'pufferfish', 'carp', 'catfish', 'ice_pip', 'sturgeon']
for old_id in old_ids:
    p = os.path.join(out_dir, f'fish_{old_id}.tres')
    if os.path.exists(p): os.remove(p)

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

print('Done')
