from PIL import Image
import os

def check():
    path = r"c:\Users\ofici\OneDrive\Documentos\farm-gaming\assets\tiles\farm\tiles.png"
    img = Image.open(path)
    print("tiles.png size:", img.size)

if __name__ == "__main__":
    check()
