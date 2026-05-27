import subprocess
from PIL import Image
import io
import os

def check():
    path = r"c:\Users\ofici\OneDrive\Documentos\farm-gaming\assets\tiles\farm\custom_tilled_dirt.png"
    if not os.path.exists(path):
        print("custom_tilled_dirt.png not found")
        return
    img = Image.open(path).convert("RGBA")
    w, h = img.size
    print(f"custom_tilled_dirt.png size: {w}x{h}")
    tile_size = 16
    cols = w // tile_size
    rows = h // tile_size
    print(f"Grid: {cols}x{rows}")
    
    # Check rows around 8-13 and cols 8-12
    for r in range(0, rows):
        row_str = f"Row {r:2d}: "
        for c in range(0, cols):
            # Check if tile has any non-transparent pixels
            tile = img.crop((c*tile_size, r*tile_size, (c+1)*tile_size, (r+1)*tile_size))
            bbox = tile.getbbox()
            if bbox:
                # Count non-transparent pixels
                non_trans = 0
                for y in range(tile_size):
                    for x in range(tile_size):
                        if tile.getpixel((x, y))[3] > 0:
                            non_trans += 1
                if non_trans > 10:
                    row_str += f"{c:02d} "
                else:
                    row_str += ".. "
            else:
                row_str += ".. "
        # Print only rows that have something
        if "01" in row_str or "05" in row_str or "10" in row_str:
            print(row_str)

if __name__ == "__main__":
    check()
