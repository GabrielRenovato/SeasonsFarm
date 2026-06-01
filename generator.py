import json
import os

base_path = 'res://Farm RPG - Tiny Asset Pack - (All in One)/Objects/Interior/'
catalog = {}

def add_item(id, name, texture, regions, collision_sizes, collision_offsets):
    catalog[id] = {
        'name': name,
        'texture_path': base_path + texture,
        'regions': [{'x': r[0], 'y': r[1], 'w': r[2], 'h': r[3]} for r in regions],
        'collision_sizes': [{'x': c[0], 'y': c[1]} for c in collision_sizes],
        'collision_offsets': [{'x': c[0], 'y': c[1]} for c in collision_offsets]
    }

# 1. Chairs
chair_idx = 1
for row in range(7):
    for c in range(4):
        x = c * 64
        y = row * 32
        regions = [(x, y, 16, 32), (x+48, y, 16, 32), (x+16, y, 16, 32), (x+32, y, 16, 32)]
        c_sizes = [(14, 16)] * 4
        c_offsets = [(0, 8)] * 4
        add_item(f'chair_{chair_idx}', f'Chair {chair_idx}', 'Chairs.png', regions, c_sizes, c_offsets)
        chair_idx += 1

# 2. Beds (Singles)
bed_idx = 1
for row in range(3):
    for col in range(12):
        x = col * 32
        y = row * 48
        regions = [(x, y, 32, 48)] * 4
        c_sizes = [(32, 48)] * 4
        c_offsets = [(0, 0)] * 4
        add_item(f'bed_single_{bed_idx}', f'Single Bed {bed_idx}', 'Beds.png', regions, c_sizes, c_offsets)
        bed_idx += 1

# 3. Beds (Doubles)
bed_d_idx = 1
for row in range(3):
    for col in range(8):
        x = col * 48
        y = 256 + (row * 48)
        regions = [(x, y, 48, 48)] * 4
        c_sizes = [(32, 48)] * 4
        c_offsets = [(0, 0)] * 4
        add_item(f'bed_double_{bed_d_idx}', f'Double Bed {bed_d_idx}', 'Beds.png', regions, c_sizes, c_offsets)
        bed_d_idx += 1

# 4. Tables and desks
table_idx = 1
for row in range(4):
    for col in range(16):
        x = col * 32
        y = row * 32
        regions = [(x, y, 32, 32)] * 4
        c_sizes = [(32, 32)] * 4
        c_offsets = [(0, 0)] * 4
        add_item(f'desk_{table_idx}', f'Desk {table_idx}', 'Tables and desks.png', regions, c_sizes, c_offsets)
        table_idx += 1

out_lines = []
out_lines.append('extends Node')
out_lines.append('')
out_lines.append('var data: Dictionary = {')
for key, val in catalog.items():
    out_lines.append(f'\t"{key}": {{')
    out_lines.append(f'\t\t"name": "{val["name"]}",')
    out_lines.append(f'\t\t"texture_path": "{val["texture_path"]}",')
    r_str = ', '.join([f'Rect2({r["x"]}, {r["y"]}, {r["w"]}, {r["h"]})' for r in val['regions']])
    out_lines.append(f'\t\t"regions": [{r_str}],')
    cs_str = ', '.join([f'Vector2({c["x"]}, {c["y"]})' for c in val['collision_sizes']])
    out_lines.append(f'\t\t"collision_sizes": [{cs_str}],')
    co_str = ', '.join([f'Vector2({c["x"]}, {c["y"]})' for c in val['collision_offsets']])
    out_lines.append(f'\t\t"collision_offsets": [{co_str}]')
    out_lines.append('\t},')
out_lines.append('}')

with open(r'c:\Users\ofici\OneDrive\Documentos\farm-gaming\systems\furniture\furniture_catalog_data.gd', 'w') as f:
    f.write('\n'.join(out_lines))

print(f'Generated {len(catalog)} items.')
