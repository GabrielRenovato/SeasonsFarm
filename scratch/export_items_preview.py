from PIL import Image
import os

def export_grid():
    path = r"c:\Users\ofici\OneDrive\Documentos\farm-gaming\assets\sprites\ui\items.png"
    img = Image.open(path).convert("RGBA")
    
    # Scale it up x4
    img_big = img.resize((img.width * 4, img.height * 4), Image.NEAREST)
    img_big.save(r"c:\Users\ofici\OneDrive\Documentos\farm-gaming\scratch\items_preview.png")
    print("Saved items_preview.png")

if __name__ == "__main__":
    export_grid()
