from PIL import Image
from collections import Counter
img = Image.open('c:/Users/ofici/OneDrive/Documentos/farm-gaming/assets/tiles/water/water_ground_anim.png').convert('RGBA')
colors = []
for y in range(img.height):
    for x in range(img.width):
        colors.append(img.getpixel((x,y)))
c = Counter(colors)
for color, count in c.most_common():
    print(f"Color {color}: {count} pixels")
