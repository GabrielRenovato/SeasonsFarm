import subprocess
from PIL import Image
import io
import os

def crop_orig():
    cmd = ["git", "show", "HEAD:assets/tiles/farm/tiles.png"]
    res = subprocess.run(cmd, capture_output=True, cwd=r"c:\Users\ofici\OneDrive\Documentos\farm-gaming")
    if res.returncode != 0:
        print("Error running git:", res.stderr)
        return
        
    img = Image.open(io.BytesIO(res.stdout)).convert("RGBA")
    tile_size = 16
    
    # Let's save a visual grid of a larger region: cols 5 to 15, rows 5 to 15
    large_grid = Image.new("RGBA", (11*tile_size, 11*tile_size))
    for r in range(11):
        for c in range(11):
            col = 5 + c
            row = 5 + r
            tile = img.crop((col*tile_size, row*tile_size, (col+1)*tile_size, (row+1)*tile_size))
            large_grid.paste(tile, (c*tile_size, r*tile_size))
            
    large_grid.save(r"c:\Users\ofici\OneDrive\Documentos\farm-gaming\scratch\large_grid.png")
    print("Saved scratch/large_grid.png")

if __name__ == "__main__":
    crop_orig()
