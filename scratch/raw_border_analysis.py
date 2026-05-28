import os
from PIL import Image

def analyze_raw():
    src_path = "assets/tiles/Tilled Soil and wet soil.png"
    if not os.path.exists(src_path):
        print(f"{src_path} not found")
        return
        
    img = Image.open(src_path).convert("RGBA")
    tile_size = 16
    
    print("Raw edge opacity analysis (out of 16 pixels per edge):")
    for r in range(4):
        for c in range(12):
            tile = img.crop((c * tile_size, r * tile_size, (c + 1) * tile_size, (r + 1) * tile_size))
            if tile.getbbox() is None:
                continue
                
            top = sum(1 for x in range(tile_size) if tile.getpixel((x, 0))[3] > 50)
            bottom = sum(1 for x in range(tile_size) if tile.getpixel((x, 15))[3] > 50)
            left = sum(1 for y in range(tile_size) if tile.getpixel((0, y))[3] > 50)
            right = sum(1 for y in range(tile_size) if tile.getpixel((15, y))[3] > 50)
            
            print(f"Tile ({c}, {r}): Top={top:2d}, Right={right:2d}, Bottom={bottom:2d}, Left={left:2d}")

if __name__ == "__main__":
    analyze_raw()
