import os
from PIL import Image

def analyze():
    path = "assets/tiles/Tilled Soil and wet soil.png"
    if not os.path.exists(path):
        print(f"{path} not found")
        return
    img = Image.open(path)
    w, h = img.size
    print(f"Image loaded: {w}x{h}")
    tile_size = 16
    cols = w // tile_size
    rows = h // tile_size
    
    # Let's check which 16x16 tiles are not completely transparent
    for r in range(rows):
        row_str = ""
        for c in range(cols):
            tile = img.crop((c * tile_size, r * tile_size, (c + 1) * tile_size, (r + 1) * tile_size))
            # Get bounding box of non-zero alpha
            bbox = tile.getbbox()
            if bbox:
                row_str += "X"
            else:
                row_str += "."
        print(f"Row {r:02d}: {row_str}")

if __name__ == "__main__":
    analyze()
