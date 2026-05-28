from PIL import Image

img = Image.open('assets/sprites/tree/Common/Shadow/Maple Tree.png')
w, h = img.size

cols = [x for x in range(w) if any(img.getpixel((x,y))[3] > 128 for y in range(96, 144))]
ranges = []
for c in cols:
    if not ranges or c > ranges[-1][1] + 1:
        ranges.append([c, c])
    else:
        ranges[-1][1] = c

print("Ranges for y in [96, 144):", ranges)

for i, (startX, endX) in enumerate(ranges):
    ys = [y for y in range(96, 144) for x in range(startX, endX+1) if img.getpixel((x,y))[3] > 128]
    if ys:
        print(f"Object {i}: X={startX}-{endX}, Y={min(ys)}-{max(ys)}")
