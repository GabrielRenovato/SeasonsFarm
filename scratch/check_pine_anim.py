from PIL import Image

filepath = r"c:\Users\ofici\OneDrive\Documentos\farm-gaming\assets\sprites\tree\Common\Shadow\Pine Tree Animation.png"
img = Image.open(filepath).convert("RGBA")
w, h = img.size
print(f"Pine Tree Animation.png is {w}x{h}")
