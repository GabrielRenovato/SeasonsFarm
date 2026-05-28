import sys
from PIL import Image

def get_alpha_map():
    img = Image.open('assets/tiles/Tilled Soil and wet soil.png').convert('RGBA')
    
    # We will analyze the first 12 columns (dry soil) and first 5 rows
    for ty in range(6):
        for tx in range(12):
            # Check the 4 edges of the tile (top, bottom, left, right)
            # We sample the middle of each edge
            top = img.getpixel((tx*16 + 8, ty*16 + 1))[3] > 128
            bottom = img.getpixel((tx*16 + 8, ty*16 + 14))[3] > 128
            left = img.getpixel((tx*16 + 1, ty*16 + 8))[3] > 128
            right = img.getpixel((tx*16 + 14, ty*16 + 8))[3] > 128
            
            # center pixel
            center = img.getpixel((tx*16 + 8, ty*16 + 8))[3] > 128
            
            if not center:
                sys.stdout.write("   |")
                continue
            
            # Map edge connectivity: U=Up, D=Down, L=Left, R=Right
            s = ""
            s += "U" if top else "-"
            s += "D" if bottom else "-"
            s += "L" if left else "-"
            s += "R" if right else "-"
            sys.stdout.write(f"{s}|")
        print()

if __name__ == "__main__":
    get_alpha_map()
