import subprocess
from PIL import Image
import io
import os

def generate_connected():
    # 1. Retrieve original tiles.png to get the clean base tile
    image_path = r"c:\Users\ofici\OneDrive\Documentos\farm-gaming\assets\tiles\farm\tiles.png"
    if not os.path.exists(image_path):
        print(f"Error: Image not found at {image_path}")
        return
        
    cmd = ["git", "show", "HEAD:assets/tiles/farm/tiles.png"]
    res = subprocess.run(cmd, capture_output=True, cwd=r"c:\Users\ofici\OneDrive\Documentos\farm-gaming")
    if res.returncode != 0:
        print("Error running git show:", res.stderr)
        return
        
    # Open both modified (to keep other modifications if any, but wait, let's checkout tiles.png first so we work on a clean slate!)
    os.system('git checkout assets/tiles/farm/tiles.png')
    img = Image.open(image_path).convert("RGBA")
    
    # Original image to extract the base tile
    orig_img = Image.open(io.BytesIO(res.stdout)).convert("RGBA")
    tile_size = 16
    
    # Base wet tile at (10, 9) in original
    base_tile = orig_img.crop((10*tile_size, 9*tile_size, 11*tile_size, 10*tile_size))
    
    # Colors
    wet_color = (133, 84, 56, 255)
    dry_color = (198, 134, 91, 255) # Brightened: 133+65, 84+50, 56+35
    
    def generate_mask_tile(mask, color):
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
                    tile.putpixel((x, y), color)
        return tile

    # Start coordinates for Dry: Columns 14 to 17, Rows 40 to 43
    dry_start_col = 14
    dry_start_row = 40
    
    # Start coordinates for Wet: Columns 18 to 21, Rows 40 to 43
    wet_start_col = 18
    wet_start_row = 40
    
    for mask in range(16):
        # Generate and paste dry tile
        dry_tile = generate_mask_tile(mask, dry_color)
        col_d = dry_start_col + (mask % 4)
        row_d = dry_start_row + (mask // 4)
        img.paste(dry_tile, (col_d*tile_size, row_d*tile_size), dry_tile)
        
        # Generate and paste wet tile
        wet_tile = generate_mask_tile(mask, wet_color)
        col_w = wet_start_col + (mask % 4)
        row_w = wet_start_row + (mask // 4)
        img.paste(wet_tile, (col_w*tile_size, row_w*tile_size), wet_tile)
        
    img.save(image_path)
    print("Successfully generated all 16 dry and 16 wet connected tiles in assets/tiles/farm/tiles.png!")

if __name__ == "__main__":
    generate_connected()
