import subprocess
from PIL import Image
import io
import os

def generate_preview():
    # Retrieve original tiles.png
    cmd = ["git", "show", "HEAD:assets/tiles/farm/tiles.png"]
    res = subprocess.run(cmd, capture_output=True, cwd=r"c:\Users\ofici\OneDrive\Documentos\farm-gaming")
    if res.returncode != 0:
        print("Error running git:", res.stderr)
        return
        
    img = Image.open(io.BytesIO(res.stdout)).convert("RGBA")
    tile_size = 16
    
    # Base wet tile at (10, 9)
    base_tile = img.crop((10*tile_size, 9*tile_size, 11*tile_size, 10*tile_size))
    
    # Dry dirt color: brightened (133+65, 84+50, 56+35) = (198, 134, 91)
    dry_color = (198, 134, 91, 255)
    
    # We will generate a 4x4 preview grid
    preview = Image.new("RGBA", (4*tile_size, 4*tile_size), (240, 240, 240, 255)) # light grey background to see shapes
    
    for mask in range(16):
        tile = Image.new("RGBA", (tile_size, tile_size), (0, 0, 0, 0))
        
        up = (mask & 1) != 0
        right = (mask & 2) != 0
        down = (mask & 4) != 0
        left = (mask & 8) != 0
        
        for y in range(tile_size):
            for x in range(tile_size):
                # Check base tile alpha
                base_alpha = base_tile.getpixel((x, y))[3]
                
                filled = False
                if base_alpha > 0:
                    filled = True
                else:
                    # Check orthogonal connections
                    if up and (2 <= x <= 13) and (y < 4):
                        filled = True
                    elif down and (2 <= x <= 13) and (y > 11):
                        filled = True
                    elif left and (2 <= y <= 13) and (x < 4):
                        filled = True
                    elif right and (2 <= y <= 13) and (x > 11):
                        filled = True
                    # Check corner / vertex connections
                    elif up and right and (x > 11) and (y < 4):
                        filled = True
                    elif up and left and (x < 2) and (y < 4):
                        filled = True
                    elif down and right and (x > 11) and (y > 11):
                        filled = True
                    elif down and left and (x < 2) and (y > 11):
                        filled = True
                        
                if filled:
                    tile.putpixel((x, y), dry_color)
                    
        col = mask % 4
        row = mask // 4
        preview.paste(tile, (col*tile_size, row*tile_size), tile)
        
    preview.save(r"c:\Users\ofici\OneDrive\Documentos\farm-gaming\scratch\autotiler_preview.png")
    print("Saved scratch/autotiler_preview.png")

if __name__ == "__main__":
    generate_preview()
