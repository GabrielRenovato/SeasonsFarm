import re

with open('levels/main_farm/tilesets/tileset_water.tres', 'r') as f:
    content = f.read()

# Add physics layer definition
content = re.sub(
    r'(\[gd_resource type="TileSet" format=3 uid="[^"]+"\])',
    r'\1\nphysics_layer_0/collision_layer = 1\nphysics_layer_0/collision_mask = 0',
    content
)

# Add polygon to each tile
content = re.sub(
    r'(\d+:\d+/0 = 0)',
    r'\1\n\1/physics_layer_0/polygon_0/points = PackedVector2Array(-8, -8, 8, -8, 8, 8, -8, 8)',
    content
)

with open('levels/main_farm/tilesets/tileset_water.tres', 'w') as f:
    f.write(content)

print("Modificacao concluida!")
