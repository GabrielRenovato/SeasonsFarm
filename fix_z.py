import re

with open('scenes/player/Player.tscn', 'r', encoding='utf-8') as f:
    content = f.read()

# Add y_sort_enabled = true back to Player
content = re.sub(
    r'(\[node name="Player" type="CharacterBody2D" unique_id=1414943563\]\nz_index = 1\n)',
    r'\1y_sort_enabled = true\n',
    content
)

# Remove z_index from Lags, Tool, har
content = re.sub(r'(\[node name="Lags" type="Sprite2D".*?\n)z_index = 1\n', r'\1', content)
content = re.sub(r'(\[node name="Tool" type="Sprite2D".*?\n)z_index = 2\n', r'\1', content)
content = re.sub(r'(\[node name="har" type="Sprite2D".*?\n)z_index = 1\n', r'\1', content)

# Change all z_index track values to 0
# A track looks like:
# tracks/19/path = NodePath("Lags:z_index")
# tracks/19/interp = 1
# tracks/19/loop_wrap = true
# tracks/19/keys = {
# "times": PackedFloat32Array(0),
# "transitions": PackedFloat32Array(1),
# "update": 1,
# "values": [1]
# }

def replace_z_index_values(match):
    track_header = match.group(1)
    track_body = match.group(2)
    new_body = re.sub(r'"values": \[[^\]]+\]', '"values": [0]', track_body)
    return track_header + new_body

content = re.sub(r'(tracks/\d+/path = NodePath\("(?:Lags|Tool|har):z_index"\))(.*?^\})', replace_z_index_values, content, flags=re.MULTILINE|re.DOTALL)

with open('scenes/player/Player.tscn', 'w', encoding='utf-8') as f:
    f.write(content)

print("Fixed Player.tscn!")
