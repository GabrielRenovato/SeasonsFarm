import os, re
from PIL import Image

d = 'C:/Users/ofici/OneDrive/Documentos/farm-gaming/assets/sprites/novosCrops/'
fm_path = 'C:/Users/ofici/OneDrive/Documentos/farm-gaming/core/autoloads/farm_manager.gd'

with open(fm_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Map crop names to their y coordinate in All Crops.png
# Spring (x=0)
spring_y = {
    'Strawberry': 32, 'Spring Onion': 48, 'Potato': 64, 'Onion': 80,
    'Carrot': 96, 'Blueberry': 112, 'Parsnip': 128, 'Cabbage': 144,
    'Cauliflower': 160, 'Rice': 176, 'Broccoli': 192, 'Asparagus': 208
}
# Summer (x=144)
summer_y = {
    'Tomato': 64, 'Corn': 80, 'Hot Pepper': 96, 'Bell Pepper': 112,
    'Melon': 160, 'Watermelon': 176, 'Cucumber': 192, 'Green Beans': 208,
    'Pineapple': 224, 'Sunflower': 240, 'Blackberry': 256, 'Wheat': 272
}
# Fall (x=288)
fall_y = {
    'Beetroot': 16, 'Pumpkin': 32, 'Grapes': 48, 'Eggplant': 80, 'Aloe': 96
}

season_offsets = {'Spring': 0, 'Summer': 144, 'Fall': 288}
season_names = {'Spring': 'spring', 'Summer': 'summer', 'Fall': 'fall'}
mappings = {'Spring': spring_y, 'Summer': summer_y, 'Fall': fall_y}

new_configs = ['const CROP_CONFIGS = {']

for season in ['Spring', 'Summer', 'Fall']:
    new_configs.append(f'\t# {season.upper()} CROPS')
    p = os.path.join(d, season)
    
    for name, y in mappings[season].items():
        # Check if file exists
        f = f"{name}.png"
        path = os.path.join(p, f)
        if not os.path.exists(path): continue
        
        img = Image.open(path)
        frames = img.size[0] // 16
        crop_id = name.lower().replace(' ', '_')
        frame_map = list(range(frames))
        
        price = 20
        if name in ['Strawberry', 'Melon', 'Pumpkin', 'Pineapple']: price = 35
        
        seed_x = season_offsets[season]
        
        # Build the line
        line = f'\t"{crop_id}": {{"name": "{name}", "texture_path": "res://assets/sprites/novosCrops/{season}/{f}", "season": "{season_names[season]}", "stages": {frames}, "frame_size": 16, "frame_map": {frame_map}, "harvest_item": "{crop_id}", "base_price": {price}, "seed_x": {seed_x}, "seed_y": {y}}},'
        new_configs.append(line)
    new_configs.append('')
new_configs.append('}')

pattern = r'const CROP_CONFIGS = \{.*?\n\}(?=\n\n# State:)'
new_content = re.sub(pattern, '\n'.join(new_configs), content, flags=re.DOTALL)

with open(fm_path, 'w', encoding='utf-8') as f:
    f.write(new_content)

print('Updated CROP_CONFIGS in farm_manager.gd')
