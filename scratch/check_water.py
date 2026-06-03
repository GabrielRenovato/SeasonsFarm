from PIL import Image
img = Image.open('c:/Users/ofici/OneDrive/Documentos/farm-gaming/assets/tiles/water/Tileset Grass Water Spring.png').convert('RGBA')
transparent = 0
opaque_water = 0
for y in range(6*16, 7*16):
    for x in range(20*16, 21*16):
        px = img.getpixel((x,y))
        if px[3] == 0:
            transparent += 1
        elif px == (0, 146, 221, 255):
            opaque_water += 1
print(f"Transparent: {transparent}, Opaque Water (0,146,221): {opaque_water}")
