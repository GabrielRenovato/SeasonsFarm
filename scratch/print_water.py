from PIL import Image
img = Image.open('c:/Users/ofici/OneDrive/Documentos/farm-gaming/assets/tiles/water/water_anim.png').convert('RGBA')
chars=' .:-=+*#%@'
for y in range(16):
    row = ''
    for x in range(16):
        px = img.getpixel((x, y))
        brightness = int(sum(px[:3])/3.0)
        row += chars[brightness * 9 // 256] * 2
    print(row)
