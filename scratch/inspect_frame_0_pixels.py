from PIL import Image
import os

def check():
    path = r"c:\Users\ofici\OneDrive\Documentos\farm-gaming\scratch\tomato_frame_0.png"
    img = Image.open(path).convert("RGBA")
    w, h = img.size
    print("Tomato Frame 0 Pixels:")
    for y in range(h):
        row_str = f"y={y:2d}: "
        for x in range(w):
            r, g, b, a = img.getpixel((x, y))
            if a == 0:
                row_str += " . "
            else:
                row_str += " X "
        print(row_str)

if __name__ == "__main__":
    check()
