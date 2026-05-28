from PIL import Image

def viz(filepath, frame_w, frame_h, target_frame):
    img = Image.open(filepath).convert("RGBA")
    w, h = img.size
    cols = w // frame_w
    row = target_frame // cols
    col = target_frame % cols
    box = (col*frame_w, row*frame_h, (col+1)*frame_w, (row+1)*frame_h)
    frame = img.crop(box)
    
    print(f"--- {filepath} Frame {target_frame} ---")
    for y in range(frame_h):
        line = ""
        for x in range(frame_w):
            p = frame.getpixel((x, y))
            line += "#" if p[3] > 128 else "."
        print(line)

viz(r"c:\Users\ofici\OneDrive\Documentos\farm-gaming\assets\sprites\tree\Common\Shadow\Mahogany Tree.png", 32, 48, 3)
