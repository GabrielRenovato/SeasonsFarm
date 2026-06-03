from PIL import Image
img = Image.open('c:/Users/ofici/OneDrive/Documentos/farm-gaming/assets/tiles/water/water_ground_anim.png').convert('RGBA')

DIRT_COLORS = {
    (238, 157, 81, 255),
    (157, 76, 70, 255),
    (232, 149, 77, 255),
    (240, 162, 84, 255),
    (110, 53, 57, 255),
    (190, 109, 71, 255)
}

pixels = img.load()
for y in range(img.height):
    for x in range(img.width):
        if pixels[x, y] in DIRT_COLORS:
            pixels[x, y] = (0, 0, 0, 0)

img.save('c:/Users/ofici/OneDrive/Documentos/farm-gaming/assets/tiles/water/water_anim_edges.png')
print("Saved water_anim_edges.png")
