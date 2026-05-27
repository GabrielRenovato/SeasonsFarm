from PIL import Image
import os

def check():
    path = r"c:\Users\ofici\OneDrive\Documentos\farm-gaming\assets\sprites\seeds\seeds.png"
    img = Image.open(path).convert("RGBA")
    
    cols = 7
    size = 16
    
    # Export each frame individually with its index labeled
    for frame_idx in range(11):  # First 11 (only non-empty)
        col = frame_idx % cols
        row = frame_idx // cols
        tile = img.crop((col*size, row*size, (col+1)*size, (row+1)*size))
        tile_big = tile.resize((64, 64), Image.NEAREST)
        tile_big.save(rf"c:\Users\ofici\OneDrive\Documentos\farm-gaming\scratch\seed_frame_{frame_idx:02d}.png")
    print("Saved individual seed frames 0 to 10")

if __name__ == "__main__":
    check()
