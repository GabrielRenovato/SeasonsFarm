from PIL import Image

def is_brown(c):
    r, g, b, a = c
    if a == 0: return False
    # Brown usually has R > G > B, and some saturation
    if r > g * 1.1 and g > b * 0.9 and r > 50 and b < 120:
        return True
    return False

path = r"c:\Users\ofici\OneDrive\Documentos\farm-gaming\assets\tiles\farm\tiles.png"
img = Image.open(path).convert('RGBA')
ts = 16
res = []

for y in range(8):
    for x in range(16):
        tile = img.crop((x*ts, y*ts, (x+1)*ts, (y+1)*ts))
        colors = tile.getcolors(maxcolors=256)
        if not colors:
            continue
        
        brown_pixels = sum(cnt for cnt, col in colors if is_brown(col))
        if brown_pixels > 10:
            res.append(f"({x},{y}) b={brown_pixels}")

print("Brown tiles:", res)
