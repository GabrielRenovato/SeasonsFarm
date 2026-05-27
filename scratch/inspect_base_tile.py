import subprocess
from PIL import Image
import io
import os

def inspect():
    cmd = ["git", "show", "HEAD:assets/tiles/farm/tiles.png"]
    res = subprocess.run(cmd, capture_output=True, cwd=r"c:\Users\ofici\OneDrive\Documentos\farm-gaming")
    if res.returncode != 0:
        print("Error running git:", res.stderr)
        return
        
    img = Image.open(io.BytesIO(res.stdout)).convert("RGBA")
    tile_size = 16
    x_dry = 10 * tile_size
    y_dry = 9 * tile_size
    
    tile = img.crop((x_dry, y_dry, x_dry + tile_size, y_dry + tile_size))
    
    print("Base Tile (10, 9) Pixels:")
    for y in range(tile_size):
        row_str = f"y={y:2d}: "
        for x in range(tile_size):
            r, g, b, a = tile.getpixel((x, y))
            if a == 0:
                row_str += " . "
            else:
                row_str += f"{a:02x}"
        print(row_str)

if __name__ == "__main__":
    inspect()
