from PIL import Image

img = Image.open('C:/Users/ofici/OneDrive/Documentos/farm-gaming/Farm RPG - Tiny Asset Pack - (All in One)/Objects/Tree/TREE TRUNKS vertical.png')
img = img.convert('RGBA')
pixels = img.load()

out = ""
chars = " .:-=+*#%@"
for y in range(img.height):
    line = ""
    for x in range(img.width):
        r,g,b,a = pixels[x,y]
        if a > 50:
            intensity = (r+g+b)/3.0 / 255.0
            line += chars[int(intensity * (len(chars)-1))]
        else:
            line += " "
    out += line + "\n"

print("Image width:", img.width, "height:", img.height)
print(out)
