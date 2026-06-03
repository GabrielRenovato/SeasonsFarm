import os
import re
import sys

tscn_path = 'entities/player/player.tscn'
with open(tscn_path, 'r', encoding='utf-8') as f:
    content = f.read()

ext_resource_block_end = content.rfind('[ext_resource')
end_of_ext_line = content.find(']\n', ext_resource_block_end) + 2

ext_resources_str = ""
parts = ["Skin", "Eyes", "Hair", "Cloth", "Tool"]
types = {
    "Skin": "Skins/1.png",
    "Eyes": "Eyes/Male/Black.png",
    "Hair": "Hair's/Standard/Brown.png",
    "Cloth": "Clothers/Farm/Blue.png",
    "Tool": "Weapons/1.png"
}

states = {
    'wait': {'folder': '12.1. Fishing - Wait', 'hframes': 16, 'length': 0.48, 'frames': 4, 'loop': True},
    'bite': {'folder': '12.2. Fishing - Bite', 'hframes': 28, 'length': 0.56, 'frames': 7, 'loop': False},
    'reel': {'folder': '12.3. Fishing - Reel', 'hframes': 16, 'length': 0.48, 'frames': 4, 'loop': True},
    'catch': {'folder': '12.4. Fishing - Catch', 'hframes': 16, 'length': 0.48, 'frames': 4, 'loop': False}
}

for state_name, state_data in states.items():
    for p, path_end in types.items():
        res_path = f"res://assets/sprites/Character/PNG/{state_data['folder']}/{path_end}"
        res_id = f"fish_{state_name}_{p.lower()}"
        ext_resources_str += f'[ext_resource type="Texture2D" path="{res_path}" id="{res_id}"]\n'

blocks = re.split(r'(\n\[(?=sub_resource|ext_resource|node|connection))', content)

base_anims = {}
anim_library_index = -1
for i in range(1, len(blocks), 2):
    header = blocks[i]
    body = blocks[i+1]
    match = re.search(r'id="Animation_fish_cast_(down|left|right|up)"', header)
    if match:
        dir = match.group(1)
        base_anims[dir] = header + body
    if 'name="AnimationPlayer"' in header:
        anim_library_index = i + 1

if len(base_anims) != 4:
    print('Error: Could not find base animations.')
    sys.exit(1)

directions = ['down', 'left', 'right', 'up']
dir_offsets = {'down': 0, 'left': 1, 'right': 2, 'up': 3}

new_anims_str = ""
library_additions = ""

for state_name, state_data in states.items():
    for dir in directions:
        anim_text = base_anims[dir]
        
        anim_name = f'fish_{state_name}_{dir}'
        anim_text = re.sub(r'Animation_fish_cast_' + dir, 'Animation_' + anim_name, anim_text)
        anim_text = re.sub(r'resource_name = "fish_cast_' + dir + '"', f'resource_name = "{anim_name}"', anim_text)
        
        if state_data['loop']:
            anim_text = re.sub(r'length = .+', f'length = {state_data["length"]}\nloop_mode = 1', anim_text, count=1)
        else:
            anim_text = re.sub(r'length = .+', f'length = {state_data["length"]}', anim_text, count=1)
            
        anim_text = re.sub(r'ExtResource\("fish_cast_skin"\)', f'ExtResource("fish_{state_name}_skin")', anim_text)
        anim_text = re.sub(r'ExtResource\("fish_cast_eyes"\)', f'ExtResource("fish_{state_name}_eyes")', anim_text)
        anim_text = re.sub(r'ExtResource\("fish_cast_hair"\)', f'ExtResource("fish_{state_name}_hair")', anim_text)
        anim_text = re.sub(r'ExtResource\("fish_cast_cloth"\)', f'ExtResource("fish_{state_name}_cloth")', anim_text)
        anim_text = re.sub(r'ExtResource\("fish_cast_tool"\)', f'ExtResource("fish_{state_name}_tool")', anim_text)
        
        anim_text = re.sub(r'"values": \[60\]', f'"values": [{state_data["hframes"]}]', anim_text)
        
        start_frame = state_data["frames"] * dir_offsets[dir]
        frame_count = state_data["frames"]
        step = state_data["length"] / frame_count
        
        times_arr = [f"{i * step:g}" for i in range(frame_count)]
        trans_arr = ["1"] * frame_count
        vals_arr = [str(start_frame + i) for i in range(frame_count)]
        
        times_str = "PackedFloat32Array(" + ", ".join(times_arr) + ")"
        trans_str = "PackedFloat32Array(" + ", ".join(trans_arr) + ")"
        vals_str = "[" + ", ".join(vals_arr) + "]"
        
        def replace_frame_arrays(m):
            t = m.group(1)
            t = re.sub(r'"times": PackedFloat32Array\([^)]+\)', f'"times": {times_str}', t)
            t = re.sub(r'"transitions": PackedFloat32Array\([^)]+\)', f'"transitions": {trans_str}', t)
            t = re.sub(r'"values": \[[^\]]+\]', f'"values": {vals_str}', t)
            return t
        
        # We only want to replace the keys in tracks 16 to 20 (the frame tracks)
        # They look like: tracks/16/keys = {\n...}
        anim_text = re.sub(r'(tracks/1[6-9]/keys = \{.*?\})', replace_frame_arrays, anim_text, flags=re.DOTALL)
        anim_text = re.sub(r'(tracks/20/keys = \{.*?\})', replace_frame_arrays, anim_text, flags=re.DOTALL)
        
        new_anims_str += anim_text
        library_additions += f'&"{anim_name}": SubResource("Animation_{anim_name}"),\n'

# Find where to inject new_anims_str
# Best is right after the last sub_resource.
last_sub_res_index = content.rfind('\n[sub_resource')
end_of_last_sub_res = content.find('\n[', last_sub_res_index + 1)
if end_of_last_sub_res == -1: end_of_last_sub_res = len(content)

# Find where to inject library_additions
# In AnimationPlayer node, there is a list of animations:
# libraries = {
# "": SubResource("AnimationLibrary_xxxxx")
# }
# Wait! In Godot 4, the animations are part of an AnimationLibrary sub_resource!
# Let's check how AnimationLibrary is defined in player.tscn!
