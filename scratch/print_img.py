from PIL import Image
img = Image.open('c:/Users/ofici/OneDrive/Documentos/farm-gaming/Farm RPG - Tiny Asset Pack - (All in One)/Tileset/Water Ground animations tiles.png').convert('RGBA')
chars=' .:-=+*#%@'
for ty in range(3):
    for y in range(16):
        row = ''
        for tx in range(3):
            for x in range(16):
                px = img.getpixel((tx*16+x, ty*16+y))
                brightness = int(sum(px[:3])/3.0) if px[3] > 0 else 0
                row += chars[brightness * 9 // 256] * 2
            row += '|'
        print(row)
    print('-'*100)
