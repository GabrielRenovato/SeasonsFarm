from PIL import Image

def analyze_sheet(filepath):
    img = Image.open(filepath).convert("RGBA")
    w, h = img.size
    print(f"File: {filepath} is {w}x{h}")
    # Let's count non-transparent pixels in columns 3, 4, 5 (each of width 32, height 48)
    for col in range(8):
        box = (col*32, 0, (col+1)*32, 48)
        cropped = img.crop(box)
        non_transparent = sum(1 for p in cropped.getdata() if p[3] > 0)
        print(f"  Col {col} (Frame {col}): {non_transparent} active pixels")

analyze_sheet("assets/sprites/tree/Common/Shadow/Birch Tree.png")
analyze_sheet("assets/sprites/tree/Common/Shadow/Pine Tree.png")
