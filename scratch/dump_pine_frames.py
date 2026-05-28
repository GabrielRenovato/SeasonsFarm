from PIL import Image

img = Image.open('assets/sprites/tree/Common/Shadow/Pine Tree Animation.png')
w, h = img.size

# hframes = 4, vframes = 4
for r in range(4):
    for c in range(4):
        frame = img.crop((c*32, r*48, c*32+32, r*48+48))
        density = sum(frame.getpixel((x,y))[3]>128 for y in range(48) for x in range(32))
        print(f"Row {r} Col {c} Frame {r*4+c} Density: {density}")
