import os

def update_tscn():
    tscn_path = "levels/main_farm/Farm.tscn"
    if not os.path.exists(tscn_path):
        print(f"{tscn_path} not found!")
        return False
        
    with open(tscn_path, "r", encoding="utf-8") as f:
        content = f.read()
        
    # 1. Insert [ext_resource] for the new soil texture
    new_ext_resource = '[ext_resource type="Texture2D" uid="uid://crodh7rcibxwr" path="res://assets/tiles/Tilled Soil and wet soil.png" id="8_soil"]'
    if new_ext_resource not in content:
        # Let's insert it below the last [ext_resource] we find
        lines = content.splitlines()
        last_ext_idx = -1
        for i, line in enumerate(lines):
            if line.startswith("[ext_resource"):
                last_ext_idx = i
        if last_ext_idx != -1:
            lines.insert(last_ext_idx + 1, new_ext_resource)
            content = "\n".join(lines)
            print("Successfully inserted ext_resource for the new soil texture.")
        else:
            print("Error: No ext_resource found to hook into!")
            return False
    else:
        print("ext_resource already present.")
        
    # 2. Build the new TileSetAtlasSource definition
    # Contains all 24 columns and 4 rows (0 to 23 x 0 to 3)
    atlas_source_lines = ['[sub_resource type="TileSetAtlasSource" id="TileSetAtlasSource_soil"]', 'texture = ExtResource("8_soil")']
    for r in range(4):
        for c in range(24):
            atlas_source_lines.append(f"{c}:{r}/0 = 0")
    atlas_source_str = "\n".join(atlas_source_lines) + "\n\n"
    
    # Let's insert this before [sub_resource type="TileSet" id="TileSet_khw3i"]
    target_landmark = '[sub_resource type="TileSet" id="TileSet_khw3i"]'
    if target_landmark in content and 'id="TileSetAtlasSource_soil"' not in content:
        content = content.replace(target_landmark, atlas_source_str + target_landmark)
        print("Successfully inserted sub_resource TileSetAtlasSource_soil.")
    elif 'id="TileSetAtlasSource_soil"' in content:
        print("TileSetAtlasSource_soil already present in sub_resources.")
    else:
        print(f"Error: Landmark {target_landmark} not found in TSCN!")
        return False
        
    # 3. Update TileSet_2i7y8 to include sources/2
    target_tileset_1 = '[sub_resource type="TileSet" id="TileSet_2i7y8"]\nsources/0 = SubResource("TileSetAtlasSource_6pgyg")'
    replacement_tileset_1 = '[sub_resource type="TileSet" id="TileSet_2i7y8"]\nsources/0 = SubResource("TileSetAtlasSource_6pgyg")\nsources/2 = SubResource("TileSetAtlasSource_soil")'
    if target_tileset_1 in content:
        content = content.replace(target_tileset_1, replacement_tileset_1)
        print("Successfully added sources/2 to TileSet_2i7y8.")
    elif replacement_tileset_1 in content:
        print("sources/2 already present in TileSet_2i7y8.")
    else:
        # Try matching with carriage returns or different spacing
        target_tileset_1_alt = '[sub_resource type="TileSet" id="TileSet_2i7y8"]\r\nsources/0 = SubResource("TileSetAtlasSource_6pgyg")'
        replacement_tileset_1_alt = '[sub_resource type="TileSet" id="TileSet_2i7y8"]\r\nsources/0 = SubResource("TileSetAtlasSource_6pgyg")\r\nsources/2 = SubResource("TileSetAtlasSource_soil")'
        if target_tileset_1_alt in content:
            content = content.replace(target_tileset_1_alt, replacement_tileset_1_alt)
            print("Successfully added sources/2 to TileSet_2i7y8 (alternative line endings).")
        else:
            print("Warning: TileSet_2i7y8 structure mismatch or already updated.")

    # 4. Update TileSet_ddsni to include sources/2
    target_tileset_2 = '[sub_resource type="TileSet" id="TileSet_ddsni"]\nsources/0 = SubResource("TileSetAtlasSource_6nokk")'
    replacement_tileset_2 = '[sub_resource type="TileSet" id="TileSet_ddsni"]\nsources/0 = SubResource("TileSetAtlasSource_6nokk")\nsources/2 = SubResource("TileSetAtlasSource_soil")'
    if target_tileset_2 in content:
        content = content.replace(target_tileset_2, replacement_tileset_2)
        print("Successfully added sources/2 to TileSet_ddsni.")
    elif replacement_tileset_2 in content:
        print("sources/2 already present in TileSet_ddsni.")
    else:
        target_tileset_2_alt = '[sub_resource type="TileSet" id="TileSet_ddsni"]\r\nsources/0 = SubResource("TileSetAtlasSource_6nokk")'
        replacement_tileset_2_alt = '[sub_resource type="TileSet" id="TileSet_ddsni"]\r\nsources/0 = SubResource("TileSetAtlasSource_6nokk")\r\nsources/2 = SubResource("TileSetAtlasSource_soil")'
        if target_tileset_2_alt in content:
            content = content.replace(target_tileset_2_alt, replacement_tileset_2_alt)
            print("Successfully added sources/2 to TileSet_ddsni (alternative line endings).")
        else:
            print("Warning: TileSet_ddsni structure mismatch or already updated.")

    # Write changes back
    with open(tscn_path, "w", encoding="utf-8", newline="\n") as f:
        f.write(content)
        
    print("Farm.tscn successfully updated!")
    return True

if __name__ == "__main__":
    update_tscn()
