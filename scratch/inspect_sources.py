import os
import re

def inspect_sources():
    path = r"c:\Users\ofici\OneDrive\Documentos\farm-gaming\levels\main_farm\Farm.tscn"
    if not os.path.exists(path):
        print("Farm.tscn not found")
        return
        
    with open(path, "r", encoding="utf-8") as f:
        lines = f.readlines()
        
    # Let's find all TileSet definitions and their sources
    for i, line in enumerate(lines):
        if 'type="TileSet"' in line:
            print(f"\nTileSet definition at line {i+1}:")
            # Print lines following it
            for j in range(i, min(i+10, len(lines))):
                print(f"  {j+1}: {lines[j].strip()}")
        elif 'type="TileSetAtlasSource"' in line:
            print(f"\nTileSetAtlasSource definition at line {i+1}:")
            for j in range(i, min(i+5, len(lines))):
                print(f"  {j+1}: {lines[j].strip()}")

if __name__ == "__main__":
    inspect_sources()
