import os
from PIL import Image, ImageDraw, ImageFont

def draw_grid():
    src_path = "assets/tiles/Tilled Soil and wet soil.png"
    if not os.path.exists(src_path):
        print(f"{src_path} not found")
        return
        
    img = Image.open(src_path).convert("RGBA")
    w, h = img.size
    tile_size = 16
    cols = w // tile_size
    rows = h // tile_size
    
    # Scale up the image by 2x so we can write text clearly on each 32x32 area
    scale = 3
    new_tile_size = tile_size * scale
    out_img = Image.new("RGBA", (cols * new_tile_size, rows * new_tile_size))
    
    for r in range(rows):
        for c in range(cols):
            # Crop 16x16 tile and resize to 48x48
            tile = img.crop((c * tile_size, r * tile_size, (c + 1) * tile_size, (r + 1) * tile_size))
            tile_scaled = tile.resize((new_tile_size, new_tile_size), Image.NEAREST)
            
            # Paste into output image
            out_img.paste(tile_scaled, (c * new_tile_size, r * new_tile_size))
            
            # Draw text showing coordinate (c, r)
            draw = ImageDraw.Draw(out_img)
            # Use default font or simple text
            text = f"{c},{r}"
            # Draw black background shadow for text
            draw.text((c * new_tile_size + 3, r * new_tile_size + 3), text, fill=(0, 0, 0))
            draw.text((c * new_tile_size + 2, r * new_tile_size + 2), text, fill=(255, 255, 255))
            
    out_img.save("scratch/soil_grid_visualized.png")
    print("Saved scratch/soil_grid_visualized.png")

if __name__ == "__main__":
    draw_grid()
