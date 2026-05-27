import subprocess
from PIL import Image
import io
import os

def crop_tilled():
    cmd = ["git", "show", "HEAD:assets/tiles/farm/tiles.png"]
    res = subprocess.run(cmd, capture_output=True, cwd=r"c:\Users\ofici\OneDrive\Documentos\farm-gaming")
    if res.returncode != 0:
        print("Error running git:", res.stderr)
        return
        
    img = Image.open(io.BytesIO(res.stdout)).convert("RGBA")
    tile_size = 16
    
    # Crop cols 9, 10, 11 and rows 8, 9, 10 (dry/wet?)
    tilled_region = Image.new("RGBA", (3*tile_size, 6*tile_size))
    for r in range(6):
        row = 8 + r
        for c in range(3):
            col = 9 + c
            tile = img.crop((col*tile_size, row*tile_size, (col+1)*tile_size, (row+1)*tile_size))
            tilled_region.paste(tile, (c*tile_size, r*tile_size))
            
    tilled_region.save(r"c:\Users\ofici\OneDrive\Documentos\farm-gaming\scratch\orig_tilled_region.png")
    print("Saved scratch/orig_tilled_region.png")

if __name__ == "__main__":
    crop_tilled()
