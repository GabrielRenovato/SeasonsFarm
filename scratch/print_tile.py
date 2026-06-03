from PIL import Image
img = Image.open('c:/Users/ofici/OneDrive/Documentos/farm-gaming/assets/tiles/water/Tileset Grass Water Spring.png').convert('RGBA')
chars=' .:-=+*#%@'
for y in range(16):
    row = ''
    for x in range(16):
        px = img.getpixel((23*16+x, 3*16+y))
        if px[3] == 0:
            row += '  '
        else:
            brightness = int(sum(px[:3])/3.0)
            row += chars[brightness * 9 // 256] * 2
    print(row)
