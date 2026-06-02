from PIL import Image

# Open the tree trunks
img = Image.open('C:/Users/ofici/OneDrive/Documentos/farm-gaming/Farm RPG - Tiny Asset Pack - (All in One)/Objects/Tree/TREE TRUNKS copiar.png')
img = img.convert('RGBA')

# Crop the top-left trunk (x=0, y=0, w=32, h=16)
trunk = img.crop((0, 0, 32, 16))

# Rotate 90 degrees to make it vertical (expand=True ensures it becomes 16x32)
vertical_trunk = trunk.rotate(90, expand=True)

# Save the new vertical trunk
vertical_trunk.save('C:/Users/ofici/OneDrive/Documentos/farm-gaming/Farm RPG - Tiny Asset Pack - (All in One)/Objects/Tree/TREE TRUNKS vertical.png')
print("Rotated image saved.")
