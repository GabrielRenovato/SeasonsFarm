from PIL import Image

# Open the tree trunks
img = Image.open('C:/Users/ofici/OneDrive/Documentos/farm-gaming/Farm RPG - Tiny Asset Pack - (All in One)/Objects/Tree/TREE TRUNKS copiar.png')
img = img.convert('RGBA')

# Crop the top-left trunk
trunk = img.crop((0, 0, 32, 16))

# Rotate 45 degrees (italic/diagonal) using NEAREST to keep pixel art crisp
diagonal_trunk = trunk.rotate(45, expand=True, resample=Image.NEAREST)

# Save the new diagonal trunk
save_path = 'C:/Users/ofici/OneDrive/Documentos/farm-gaming/Farm RPG - Tiny Asset Pack - (All in One)/Objects/Tree/TREE TRUNKS diagonal.png'
diagonal_trunk.save(save_path)
print("Diagonal image saved to", save_path)
