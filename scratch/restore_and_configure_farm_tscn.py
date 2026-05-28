import os

def restore_and_configure():
    tscn_path = "levels/main_farm/Farm.tscn"
    if not os.path.exists(tscn_path):
        print(f"{tscn_path} not found!")
        return False
        
    with open(tscn_path, "r", encoding="utf-8") as f:
        content = f.read()
        
    # 1. Insert [ext_resource] for the soil texture with ID 7_q7ato
    ext_resource_tag = '[ext_resource type="Texture2D" uid="uid://crodh7rcibxwr" path="res://assets/tiles/Tilled Soil and wet soil.png" id="7_q7ato"]'
    if ext_resource_tag not in content:
        lines = content.splitlines()
        last_ext_idx = -1
        for i, line in enumerate(lines):
            if line.startswith("[ext_resource"):
                last_ext_idx = i
        if last_ext_idx != -1:
            lines.insert(last_ext_idx + 1, ext_resource_tag)
            content = "\n".join(lines)
            print("Successfully restored ext_resource '7_q7ato'.")
        else:
            print("Error: No ext_resource found to hook into!")
            return False
    else:
        print("ext_resource '7_q7ato' already present.")
        
    # 2. Build the TileSetAtlasSource_qcjwc definition enabling all tiles (24 columns x 8 rows)
    atlas_source_lines = ['[sub_resource type="TileSetAtlasSource" id="TileSetAtlasSource_qcjwc"]', 'texture = ExtResource("7_q7ato")']
    for r in range(8):
        for c in range(24):
            atlas_source_lines.append(f"{c}:{r}/0 = 0")
    atlas_source_str = "\n".join(atlas_source_lines) + "\n\n"
    
    # Let's insert this before [sub_resource type="TileSetAtlasSource" id="TileSetAtlasSource_6pgyg"]
    target_landmark = '[sub_resource type="TileSetAtlasSource" id="TileSetAtlasSource_6pgyg"]'
    if target_landmark in content and 'id="TileSetAtlasSource_qcjwc"' not in content:
        content = content.replace(target_landmark, atlas_source_str + target_landmark)
        print("Successfully restored sub_resource TileSetAtlasSource_qcjwc.")
    elif 'id="TileSetAtlasSource_qcjwc"' in content:
        print("TileSetAtlasSource_qcjwc already present in sub_resources.")
    else:
        print(f"Error: Landmark {target_landmark} not found in TSCN!")
        return False
        
    # 3. Update TileSet_ddsni (Grass_layer) to include sources/1
    target_tileset_ddsni = '[sub_resource type="TileSet" id="TileSet_ddsni"]\nsources/0 = SubResource("TileSetAtlasSource_6nokk")'
    replacement_tileset_ddsni = '[sub_resource type="TileSet" id="TileSet_ddsni"]\nsources/0 = SubResource("TileSetAtlasSource_6nokk")\nsources/1 = SubResource("TileSetAtlasSource_qcjwc")'
    if target_tileset_ddsni in content:
        content = content.replace(target_tileset_ddsni, replacement_tileset_ddsni)
        print("Successfully added sources/1 to TileSet_ddsni.")
    else:
        target_tileset_ddsni_alt = '[sub_resource type="TileSet" id="TileSet_ddsni"]\r\nsources/0 = SubResource("TileSetAtlasSource_6nokk")'
        replacement_tileset_ddsni_alt = '[sub_resource type="TileSet" id="TileSet_ddsni"]\r\nsources/0 = SubResource("TileSetAtlasSource_6nokk")\r\nsources/1 = SubResource("TileSetAtlasSource_qcjwc")'
        if target_tileset_ddsni_alt in content:
            content = content.replace(target_tileset_ddsni_alt, replacement_tileset_ddsni_alt)
            print("Successfully added sources/1 to TileSet_ddsni (alternative line endings).")
        else:
            print("Warning: TileSet_ddsni structure mismatch or already updated.")

    # 4. Update TileSet_2i7y8 (DirtLayer) to include sources/1
    target_tileset_2i7y8 = '[sub_resource type="TileSet" id="TileSet_2i7y8"]\nsources/0 = SubResource("TileSetAtlasSource_6pgyg")'
    replacement_tileset_2i7y8 = '[sub_resource type="TileSet" id="TileSet_2i7y8"]\nsources/0 = SubResource("TileSetAtlasSource_6pgyg")\nsources/1 = SubResource("TileSetAtlasSource_qcjwc")'
    if target_tileset_2i7y8 in content:
        content = content.replace(target_tileset_2i7y8, replacement_tileset_2i7y8)
        print("Successfully added sources/1 to TileSet_2i7y8.")
    else:
        target_tileset_2i7y8_alt = '[sub_resource type="TileSet" id="TileSet_2i7y8"]\r\nsources/0 = SubResource("TileSetAtlasSource_6pgyg")'
        replacement_tileset_2i7y8_alt = '[sub_resource type="TileSet" id="TileSet_2i7y8"]\r\nsources/0 = SubResource("TileSetAtlasSource_6pgyg")\r\nsources/1 = SubResource("TileSetAtlasSource_qcjwc")'
        if target_tileset_2i7y8_alt in content:
            content = content.replace(target_tileset_2i7y8_alt, replacement_tileset_2i7y8_alt)
            print("Successfully added sources/1 to TileSet_2i7y8 (alternative line endings).")
        else:
            print("Warning: TileSet_2i7y8 structure mismatch or already updated.")

    # Write changes back
    with open(tscn_path, "w", encoding="utf-8", newline="\n") as f:
        f.write(content)
        
    print("Farm.tscn successfully restored and configured!")
    return True

if __name__ == "__main__":
    restore_and_configure()
