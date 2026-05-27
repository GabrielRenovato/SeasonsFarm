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
    
    # Save the 3x3 grid from cols 9-11, rows 8-10
    grid_img = Image.new("RGBA", (3*tile_size, 3*tile_size))
    for r in range(3):
        for c in range(3):
            col = 9 + c
            row = 8 + r
            tile = img.crop((col*tile_size, row*tile_size, (col+1)*tile_size, (row+1)*tile_size))
            grid_img.paste(tile, (c*tile_size, r*tile_size))
            
            # Check transparency of each tile
            bbox = tile.getbbox()
            non_trans = 0
            if bbox:
                for y in range(tile_size):
                    for x in range(tile_size):
                        if tile.getpixel((x, y))[3] > 0:
                            non_trans += 1
            print(f"Tile ({col}, {row}): Non-transparent pixels = {non_trans}")
            
    grid_img.save(r"c:\Users\ofici\OneDrive\Documentos\farm-gaming\scratch\orig_grid.png")
    print("Saved scratch/orig_grid.png")

if __name__ == "__main__":
    inspect()
