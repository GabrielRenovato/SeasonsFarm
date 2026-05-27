from PIL import Image
import os

def check():
    path = r"c:\Users\ofici\OneDrive\Documentos\farm-gaming\assets\sprites\seeds\seeds.png"
    if not os.path.exists(path):
        print("seeds.png not found")
        return
        
    img = Image.open(path)
    w, h = img.size
    print(f"seeds.png size: {w}x{h}")
    
    cols = 7
    size = 16
    total_cols = w // size
    total_rows = h // size
    print(f"Grid: {total_cols}x{total_rows} (using cols=7 per row)")
    
    # Export each frame to see what they are
    img_rgba = img.convert("RGBA")
    for frame_idx in range(total_cols * total_rows):
        col = frame_idx % cols
        row = frame_idx // cols
        tile = img_rgba.crop((col*size, row*size, (col+1)*size, (row+1)*size))
        bbox = tile.getbbox()
        non_trans = 0
        if bbox:
            for y in range(size):
                for x in range(size):
                    if tile.getpixel((x, y))[3] > 0:
                        non_trans += 1
        print(f"Frame {frame_idx:2d} (col={col}, row={row}): non-transparent={non_trans}")
        
    # Save a grid view
    grid = Image.new("RGBA", (total_cols * size, total_rows * size), (200, 200, 200, 255))
    for r in range(total_rows):
        for c in range(total_cols):
            tile = img_rgba.crop((c*size, r*size, (c+1)*size, (r+1)*size))
            grid.paste(tile, (c*size, r*size), tile)
    grid.save(r"c:\Users\ofici\OneDrive\Documentos\farm-gaming\scratch\seeds_grid.png")
    print("Saved scratch/seeds_grid.png")

if __name__ == "__main__":
    check()
