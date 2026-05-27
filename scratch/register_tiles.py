import os

def register_tiles():
    path = r"c:\Users\ofici\OneDrive\Documentos\farm-gaming\levels\main_farm\Farm.tscn"
    if not os.path.exists(path):
        print("Farm.tscn not found")
        return
        
    with open(path, "r", encoding="utf-8") as f:
        content = f.read()
        
    # We want to find every sub_resource of type TileSetAtlasSource that has texture = ExtResource("2_6pgyg")
    # In Godot 4 .tscn files, a sub_resource starts with [sub_resource type="TileSetAtlasSource" ... ]
    # and ends before the next [sub_resource ... ] or [node ... ]
    
    # We can split by [sub_resource type="TileSetAtlasSource"
    blocks = content.split('[sub_resource type="TileSetAtlasSource"')
    new_blocks = [blocks[0]]
    
    tiles_to_register = []
    # Dry: cols 14-17, rows 40-43
    # Wet: cols 18-21, rows 40-43
    for row in range(40, 44):
        for col in range(14, 22):
            tiles_to_register.append(f"{col}:{row}/0 = 0")
            
    registered_count = 0
    for block in blocks[1:]:
        # Re-add the header
        # Let's check if it uses texture = ExtResource("2_6pgyg")
        if 'texture = ExtResource("2_6pgyg")' in block:
            lines = block.split('\n')
            # Let's find where 'texture = ExtResource("2_6pgyg")' is
            inserted = False
            for idx, line in enumerate(lines):
                if 'texture = ExtResource("2_6pgyg")' in line:
                    # Check if our tiles are already registered in this block
                    if "14:40/0 = 0" not in block:
                        # Insert them right after the texture line
                        for tile_str in reversed(tiles_to_register):
                            lines.insert(idx + 1, tile_str)
                        inserted = True
                        registered_count += 1
                    break
            block = '\n'.join(lines)
        new_blocks.append(block)
        
    new_content = '[sub_resource type="TileSetAtlasSource"'.join(new_blocks)
    
    with open(path, "w", encoding="utf-8") as f:
        f.write(new_content)
        
    print(f"Successfully registered tiles in {registered_count} TileSetAtlasSources inside Farm.tscn!")

if __name__ == "__main__":
    register_tiles()
