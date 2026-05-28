from PIL import Image

def visualize_frames(filepath, frame_w, frame_h):
    img = Image.open(filepath).convert("RGBA")
    w, h = img.size
    cols = w // frame_w
    rows = h // frame_h
    
    print(f"Visualizing {filepath} ({cols}x{rows} frames of {frame_w}x{frame_h})")
    
    for row in range(rows):
        for col in range(cols):
            print(f"--- Frame {row*cols + col} ({col}, {row}) ---")
            
            # Crop frame
            box = (col*frame_w, row*frame_h, (col+1)*frame_w, (row+1)*frame_h)
            frame = img.crop(box)
            
            # Shrink it to console size (e.g., 32x48 -> 16x12)
            frame.thumbnail((16, 24))
            fw, fh = frame.size
            
            for y in range(fh):
                line = ""
                for x in range(fw):
                    r, g, b, a = frame.getpixel((x, y))
                    if a > 128:
                        line += "#"
                    else:
                        line += "."
                print(line)
            print("")

visualize_frames(r"c:\Users\ofici\OneDrive\Documentos\farm-gaming\assets\sprites\tree\Common\Shadow\Birch Tree.png", 32, 48)
