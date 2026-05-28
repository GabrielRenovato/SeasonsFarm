import os
from PIL import Image

def get_tile(img, x, y, tile_size=16):
    return img.crop((x*tile_size, y*tile_size, (x+1)*tile_size, (y+1)*tile_size))

def is_empty(tile):
    colors = tile.getcolors()
    if colors and len(colors) == 1 and colors[0][1][3] == 0:
        return True
    return False

def check():
    path = r"c:\Users\ofici\OneDrive\Documentos\farm-gaming\assets\tiles\farm\tiles.png"
    img = Image.open(path).convert("RGBA")
    
    t_10_1 = get_tile(img, 10, 1)
    print("Tile (10, 1) empty?:", is_empty(t_10_1))
    
    t_0_3 = get_tile(img, 0, 3)
    print("Tile (0, 3) empty?:", is_empty(t_0_3))
    
    t_15 = get_tile(img, 2, 1)
    print("Tile (2, 1) [Todos] empty?:", is_empty(t_15))
    
if __name__ == "__main__":
    check()
