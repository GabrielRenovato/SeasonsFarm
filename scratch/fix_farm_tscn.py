import os

def process_tscn():
    path = "levels/main_farm/Farm.tscn"
    with open(path, "r", encoding="utf-8") as f:
        lines = f.readlines()
        
    ext_resource_str = '[ext_resource type="Texture2D" uid="uid://crodh7rcibxwr" path="res://assets/tiles/Tilled Soil and wet soil.png" id="7_q7ato"]\n'
    
    atlas_source_lines = [
        '[sub_resource type="TileSetAtlasSource" id="TileSetAtlasSource_qcjwc"]\n',
        'texture = ExtResource("7_q7ato")\n'
    ]
    for y in range(8):
        for x in range(24):
            atlas_source_lines.append(f"{x}:{y}/0 = 0\n")
    atlas_source_lines.append("\n")
    
    new_lines = []
    ext_added = False
    
    i = 0
    while i < len(lines):
        line = lines[i]
        
        # 1. Add ext_resource at the end of ext_resource block
        if line.startswith("[ext_resource") and not ext_added:
            if i + 1 < len(lines) and not lines[i+1].startswith("[ext_resource"):
                new_lines.append(line)
                new_lines.append(ext_resource_str)
                ext_added = True
                i += 1
                continue
                
        # 2. Add Atlas Source before TileSet_ddsni
        if line.startswith('[sub_resource type="TileSet" id="TileSet_ddsni"]'):
            new_lines.extend(atlas_source_lines)
            new_lines.append(line)
            i += 1
            continue
            
        # 3. Add to TileSet_ddsni
        if line.startswith('sources/0 = SubResource("TileSetAtlasSource_6nokk")'):
            # Check if it's inside TileSet_ddsni context (which it uniquely is)
            new_lines.append(line)
            new_lines.append('sources/1 = SubResource("TileSetAtlasSource_qcjwc")\n')
            i += 1
            continue
            
        # 4. Add to TileSet_2i7y8
        if line.startswith('[sub_resource type="TileSet" id="TileSet_2i7y8"]'):
            new_lines.append(line)
            # The next line should be sources/0 = SubResource("TileSetAtlasSource_6pgyg")
            if i + 1 < len(lines) and lines[i+1].startswith('sources/0 = SubResource("TileSetAtlasSource_6pgyg")'):
                new_lines.append(lines[i+1])
                new_lines.append('sources/1 = SubResource("TileSetAtlasSource_qcjwc")\n')
                i += 2
                continue
            i += 1
            continue
            
        new_lines.append(line)
        i += 1
        
    with open(path, "w", encoding="utf-8") as f:
        f.writelines(new_lines)
    print("Done editing Farm.tscn")

if __name__ == "__main__":
    process_tscn()
