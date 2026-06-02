from PIL import Image

img = Image.open('C:/Users/ofici/OneDrive/Documentos/farm-gaming/Farm RPG - Tiny Asset Pack - (All in One)/Icons/RPG icons/Extras/Wood.png')
img = img.convert('RGBA')
pixels = img.load()

min_x, max_x = img.width, 0
min_y, max_y = img.height, 0

out = ""
chars = " .:-=+*#%@"
for y in range(img.height):
    line = ""
    for x in range(img.width):
        r,g,b,a = pixels[x,y]
        if a > 50:
            if x < min_x: min_x = x
            if x > max_x: max_x = x
            if y < min_y: min_y = y
            if y > max_y: max_y = y
            intensity = (r+g+b)/3.0 / 255.0
            line += chars[int(intensity * (len(chars)-1))]
        else:
            line += " "
    out += line + "\n"

print(f"Bounding box: x={min_x}, y={min_y}, w={max_x - min_x + 1}, h={max_y - min_y + 1}")
print("Image width:", img.width, "height:", img.height)
print(out)
