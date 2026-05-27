from PIL import Image
import os

def check():
    path = r"c:\Users\ofici\OneDrive\Documentos\farm-gaming\assets\sprites\ui\items.png"
    if not os.path.exists(path):
        print("items.png not found")
        return
        
    img = Image.open(path).convert("RGBA")
    w, h = img.size
    print(f"items.png size: {w}x{h}")
    
    # We don't know the exact tile size, let's assume 16x16
    size = 16
    total_cols = w // size
    total_rows = h // size
    print(f"Assuming {size}x{size} -> {total_cols}x{total_rows}")
    
    for r in range(min(total_rows, 10)):
        for c in range(min(total_cols, 10)):
            tile = img.crop((c*size, r*size, (c+1)*size, (r+1)*size))
            bbox = tile.getbbox()
            non_trans = 0
            if bbox:
                for y in range(size):
                    for x in range(size):
                        if tile.getpixel((x, y))[3] > 0:
                            non_trans += 1
            if non_trans > 0:
                # Save the non-empty tiles for visual inspection
                tile_big = tile.resize((64, 64), Image.NEAREST)
                tile_big.save(rf"c:\Users\ofici\OneDrive\Documentos\farm-gaming\scratch\item_r{r}_c{c}.png")

if __name__ == "__main__":
    check()
