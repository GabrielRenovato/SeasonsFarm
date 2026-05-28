import os
from PIL import Image

def analyze():
    img = Image.open("assets/tiles/Tilled Soil and wet soil.png")
    w, h = img.size
    tile_size = 16
    
    quadrants = {
        "Q1 (Top-Left, cols 0-11, rows 0-3)": (0, 12, 0, 4),
        "Q2 (Top-Right, cols 12-23, rows 0-3)": (12, 24, 0, 4),
        "Q3 (Bottom-Left, cols 0-11, rows 4-7)": (0, 12, 4, 8),
        "Q4 (Bottom-Right, cols 12-23, rows 4-7)": (12, 24, 4, 8),
    }
    
    for name, (c_start, c_end, r_start, r_end) in quadrants.items():
        crop_box = (c_start * tile_size, r_start * tile_size, c_end * tile_size, r_end * tile_size)
        crop_img = img.crop(crop_box)
        
        # Pure Python pixel extraction
        pixels = list(crop_img.getdata())
        # Filter opaque pixels (A > 0)
        opaque_rgbs = [p[:3] for p in pixels if p[3] > 0]
        
        if len(opaque_rgbs) > 0:
            avg_r = sum(p[0] for p in opaque_rgbs) / len(opaque_rgbs)
            avg_g = sum(p[1] for p in opaque_rgbs) / len(opaque_rgbs)
            avg_b = sum(p[2] for p in opaque_rgbs) / len(opaque_rgbs)
            print(f"{name}: Avg RGB = ({avg_r:.1f}, {avg_g:.1f}, {avg_b:.1f}), Count = {len(opaque_rgbs)}")
        else:
            print(f"{name}: Empty")

if __name__ == "__main__":
    analyze()
