from PIL import Image
from collections import Counter
img = Image.open('c:/Users/ofici/OneDrive/Documentos/farm-gaming/assets/tiles/water/Tileset Grass Water Spring.png').convert('RGBA')
colors = []
for y in range(6*16, 7*16):
    for x in range(20*16, 21*16):
        colors.append(img.getpixel((x,y)))
c = Counter(colors)
for color, count in c.most_common():
    print(f"Color {color}: {count} pixels")
