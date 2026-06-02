from PIL import Image

img = Image.open('C:/Users/ofici/OneDrive/Documentos/farm-gaming/Farm RPG - Tiny Asset Pack - (All in One)/Objects/Tree/TREE TRUNKS copiar.png')
img = img.convert('RGBA')
pixels = img.load()

# Let's find the bounding box of the top-left log
min_x, max_x = 32, 0
min_y, max_y = 16, 0

for y in range(16):
    for x in range(32):
        r,g,b,a = pixels[x,y]
        if a > 50:
            if x < min_x: min_x = x
            if x > max_x: max_x = x
            if y < min_y: min_y = y
            if y > max_y: max_y = y

print(f"Top-left log bounding box: x={min_x}, y={min_y}, w={max_x - min_x + 1}, h={max_y - min_y + 1}")

# Let's find the bounding box of the bottom-left log(s)
min_x2, max_x2 = 32, 0
min_y2, max_y2 = 32, 16

for y in range(16, 32):
    for x in range(32):
        r,g,b,a = pixels[x,y]
        if a > 50:
            if x < min_x2: min_x2 = x
            if x > max_x2: max_x2 = x
            if y < min_y2: min_y2 = y
            if y > max_y2: max_y2 = y

print(f"Bottom-left log(s) bounding box: x={min_x2}, y={min_y2}, w={max_x2 - min_x2 + 1}, h={max_y2 - min_y2 + 1}")

