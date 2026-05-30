import os, re
from PIL import Image

d = 'C:/Users/ofici/OneDrive/Documentos/farm-gaming/Farm RPG - Tiny Asset Pack - (All in One)/Crops/'
fm_path = 'C:/Users/ofici/OneDrive/Documentos/farm-gaming/core/autoloads/farm_manager.gd'

with open(fm_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Generate new CROP_CONFIGS
new_configs = ['const CROP_CONFIGS = {']

categories = [('Spring', 'spring'), ('Summer', 'summer'), ('Fall', 'fall')]
for cat_dir, season_name in categories:
    new_configs.append(f'\t# {cat_dir.upper()} CROPS')
    p = os.path.join(d, cat_dir)
    if os.path.exists(p):
        for f in os.listdir(p):
            if f.endswith('.png'):
                img = Image.open(os.path.join(p, f))
                frames = img.size[0] // 16
                name = f.replace('.png', '')
                crop_id = name.lower().replace(' ', '_')
                frame_map = list(range(frames))
                
                # Base price based on season and some randomness
                price = 20
                if name in ['Strawberry', 'Melon', 'Pumpkin', 'Pineapple']: price = 35
                
                line = f'\t"{crop_id}": {{"name": "{name}", "texture_path": "res://Farm RPG - Tiny Asset Pack - (All in One)/Crops/{cat_dir}/{f}", "season": "{season_name}", "stages": {frames}, "frame_size": 16, "frame_map": {frame_map}, "harvest_item": "{crop_id}", "base_price": {price}, "seed_x": 0, "seed_y": 0}},'
                new_configs.append(line)
    new_configs.append('')
new_configs.append('}')

# Replace in content
pattern = r'const CROP_CONFIGS = \{.*?\n\}(?=\n\n# State:)'
new_content = re.sub(pattern, '\n'.join(new_configs), content, flags=re.DOTALL)

with open(fm_path, 'w', encoding='utf-8') as f:
    f.write(new_content)

print('Updated CROP_CONFIGS in farm_manager.gd')
