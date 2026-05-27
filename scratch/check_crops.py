from PIL import Image
import os

def check():
    path = r"c:\Users\ofici\OneDrive\Documentos\farm-gaming\assets\sprites\crops\crops.png"
    if not os.path.exists(path):
        print("crops.png not found")
        return
    img = Image.open(path)
    print("crops.png size:", img.size)
    w, h = img.size
    print(f"Frame width (w/6): {w / 6:.1f}")
    print(f"Frame height (h/37): {h / 37:.1f}")

if __name__ == "__main__":
    check()
