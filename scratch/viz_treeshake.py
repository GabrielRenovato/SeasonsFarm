from PIL import Image

filepath = r"c:\Users\ofici\OneDrive\Documentos\farm-gaming\assets\sprites\tree\tree_shake.png"
img = Image.open(filepath).convert("RGBA")
w, h = img.size
print(f"tree_shake.png is {w}x{h}")

frame_w = w // 4
frame_h = h // 8
box = (0, 0, frame_w, frame_h)
frame = img.crop(box)

print(f"Frame 0 is {frame_w}x{frame_h}")
for y in range(frame_h):
    line = ""
    for x in range(frame_w):
        p = frame.getpixel((x, y))
        line += "#" if p[3] > 128 else "."
    print(line)
