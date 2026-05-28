from PIL import Image

def get_bbox(img, col):
    box = (col*32, 0, (col+1)*32, 48)
    cropped = img.crop(box)
    # Find bounding box of non-transparent pixels
    pixels = cropped.load()
    min_x, min_y = 32, 48
    max_x, max_y = -1, -1
    for y in range(48):
        for x in range(32):
            if pixels[x, y][3] > 0:
                min_x = min(min_x, x)
                min_y = min(min_y, y)
                max_x = max(max_x, x)
                max_y = max(max_y, y)
    if max_x == -1:
        return None
    return (min_x, min_y, max_x - min_x + 1, max_y - min_y + 1)

img = Image.open("assets/sprites/tree/Common/Shadow/Birch Tree.png").convert("RGBA")
for i in range(4):
    print(f"Col {i}: {get_bbox(img, i)}")
