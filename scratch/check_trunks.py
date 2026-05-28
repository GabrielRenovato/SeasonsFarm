from PIL import Image

filepath = r"c:\Users\ofici\OneDrive\Documentos\farm-gaming\assets\sprites\tree\TREE TRUNKS copiar.png"
img = Image.open(filepath).convert("RGBA")
w, h = img.size
print(f"TREE TRUNKS copiar.png is {w}x{h}")
