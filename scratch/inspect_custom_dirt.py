from PIL import Image
import os

def check():
    path = r"c:\Users\ofici\OneDrive\Documentos\farm-gaming\assets\tiles\farm\custom_tilled_dirt.png"
    if not os.path.exists(path):
        print("custom_tilled_dirt.png not found")
        return
    img = Image.open(path).convert("RGBA")
    w, h = img.size
    print(f"Size: {w}x{h}")
    # Let's see if it has non-transparent pixels in the first few rows
    tile_size = 16
    for r in range(min(h // tile_size, 10)):
        row_str = f"Row {r:2d}: "
        for c in range(min(w // tile_size, 10)):
            tile = img.crop((c*tile_size, r*tile_size, (c+1)*tile_size, (r+1)*tile_size))
            bbox = tile.getbbox()
            if bbox:
                row_str += "X "
            else:
                row_str += ". "
        print(row_str)

if __name__ == "__main__":
    check()
