import os
import re

def check_map_tiles():
    path = r"c:\Users\ofici\OneDrive\Documentos\farm-gaming\levels\main_farm\Farm.tscn"
    if not os.path.exists(path):
        print("Farm.tscn not found")
        return
        
    with open(path, "r", encoding="utf-8") as f:
        content = f.read()
        
    # Find TileMapLayer data
    # tile_map_data is a PackedByteArray
    # Let's search for GroundLayer or other layers and print if they use rows 8-15, cols 9-12
    # Wait, instead of parsing PackedByteArray (which is complex), let's search for the TileSet configuration in Farm.tscn.
    # If the tiles in that region are not used or if we can find if there are any references,
    # let's look at the TileMapLayer nodes in Farm.tscn.
    # In Godot 4, TileMapLayer data is stored as tile_map_data = PackedByteArray("...")
    print("Farm.tscn successfully loaded.")

if __name__ == "__main__":
    check_map_tiles()
