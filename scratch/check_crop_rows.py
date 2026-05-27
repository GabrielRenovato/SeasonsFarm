from PIL import Image
import os

def check():
    path = r"c:\Users\ofici\OneDrive\Documentos\farm-gaming\assets\sprites\crops\crops.png"
    img = Image.open(path).convert("RGBA")
    w, h = img.size
    tile_size = 16
    rows = h // tile_size
    cols = w // tile_size
    print(f"crops.png: {w}x{h} -> {cols}x{rows} grid (each tile {tile_size}x{tile_size})")
    
    # Export each row's stage 5 (last/ripe frame) scaled up for inspection
    for r in range(min(rows, 10)):
        for stage in [0, 5]:  # first and last stage
            if stage < cols:
                tile = img.crop((stage*tile_size, r*tile_size, (stage+1)*tile_size, (r+1)*tile_size))
                tile_big = tile.resize((64, 64), Image.NEAREST)
                tile_big.save(rf"c:\Users\ofici\OneDrive\Documentos\farm-gaming\scratch\crop_row{r}_stage{stage}.png")
    print("Saved crop frames")

if __name__ == "__main__":
    check()
