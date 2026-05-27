import subprocess
from PIL import Image
import io
import os

def find_empty():
    cmd = ["git", "show", "HEAD:assets/tiles/farm/tiles.png"]
    res = subprocess.run(cmd, capture_output=True, cwd=r"c:\Users\ofici\OneDrive\Documentos\farm-gaming")
    if res.returncode != 0:
        print("Error running git:", res.stderr)
        return
        
    img = Image.open(io.BytesIO(res.stdout)).convert("RGBA")
    w, h = img.size
    tile_size = 16
    cols = w // tile_size
    rows = h // tile_size
    
    # Let's find blocks of empty tiles
    # We will represent empty as 1, occupied as 0
    grid = [[0 for _ in range(cols)] for _ in range(rows)]
    for r in range(rows):
        for c in range(cols):
            tile = img.crop((c*tile_size, r*tile_size, (c+1)*tile_size, (r+1)*tile_size))
            bbox = tile.getbbox()
            if bbox:
                # Count non-transparent pixels
                non_trans = 0
                for y in range(tile_size):
                    for x in range(tile_size):
                        if tile.getpixel((x, y))[3] > 0:
                            non_trans += 1
                if non_trans > 5:
                    grid[r][c] = 0 # Occupied
                else:
                    grid[r][c] = 1 # Empty
            else:
                grid[r][c] = 1 # Empty
                
    # Search for contiguous empty blocks of size (height, width)
    # We want two 4x4 blocks, or one 4x8 block, or one 8x4 block
    # Let's find all rectangles of size 4x8 (4 rows, 8 cols)
    print("Found 4x8 empty blocks (row, col):")
    for r in range(rows - 3):
        for c in range(cols - 7):
            all_empty = True
            for dr in range(4):
                for dc in range(8):
                    if grid[r+dr][c+dc] == 0:
                        all_empty = False
                        break
                if not all_empty:
                    break
            if all_empty:
                print(f"Row {r} to {r+3}, Col {c} to {c+7}")
                
    # Let's check if rows 8-15, cols 9-12 have any occupied tiles originally
    print("\nOriginal occupancy for rows 8-13, cols 9-11:")
    for r in range(8, 14):
        row_str = f"Row {r:2d}: "
        for c in range(9, 12):
            row_str += "Empty " if grid[r][c] == 1 else "Occupied "
        print(row_str)

if __name__ == "__main__":
    find_empty()
