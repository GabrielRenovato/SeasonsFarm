from PIL import Image
import os

def check():
    path_custom = r"C:\Users\ofici\.gemini\antigravity\brain\68c66fc1-0e95-43b6-ac59-c16c87aaaa9c\custom_tilled_dirt_1779909340186.png"
    if not os.path.exists(path_custom):
        print("custom_tilled_dirt_1779909340186.png not found")
        return
        
    img = Image.open(path_custom).convert("RGBA")
    tile_size = 16
    
    print("Checking region (9,8) to (11,13) in custom_tilled_dirt_1779909340186.png:")
    for r in range(8, 14):
        row_str = f"Row {r:2d}: "
        for c in range(9, 12):
            tile = img.crop((c*tile_size, r*tile_size, (c+1)*tile_size, (r+1)*tile_size))
            # Calculate non-transparent pixels
            non_trans = 0
            for y in range(tile_size):
                for x in range(tile_size):
                    if tile.getpixel((x, y))[3] > 0:
                        non_trans += 1
            row_str += f"{non_trans:3d} "
        print(row_str)

if __name__ == "__main__":
    check()
