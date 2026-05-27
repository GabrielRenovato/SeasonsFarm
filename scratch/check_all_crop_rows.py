from PIL import Image
import os

def check():
    path = r"c:\Users\ofici\OneDrive\Documentos\farm-gaming\assets\sprites\crops\crops.png"
    img = Image.open(path).convert("RGBA")
    tile_size = 16
    rows = img.height // tile_size
    
    # Export last stage of each row
    for r in range(min(rows, 15)):
        tile = img.crop((5*tile_size, r*tile_size, 6*tile_size, (r+1)*tile_size))
        tile_big = tile.resize((64, 64), Image.NEAREST)
        tile_big.save(rf"c:\Users\ofici\OneDrive\Documentos\farm-gaming\scratch\croprow_{r:02d}_last.png")
    print(f"Saved {min(rows,15)} crop row previews")

if __name__ == "__main__":
    check()
