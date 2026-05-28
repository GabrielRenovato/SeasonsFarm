from PIL import Image
import os

def find_stump_frame(filepath, frame_w, frame_h):
    if not os.path.exists(filepath):
        print(f"Not found: {filepath}")
        return
        
    img = Image.open(filepath).convert("RGBA")
    w, h = img.size
    cols = w // frame_w
    rows = h // frame_h
    
    print(f"--- {os.path.basename(filepath)} ---")
    
    for row in range(rows):
        for col in range(cols):
            frame_idx = row*cols + col
            
            box = (col*frame_w, row*frame_h, (col+1)*frame_w, (row+1)*frame_h)
            frame = img.crop(box)
            
            # Count opaque pixels
            opaque = sum(1 for p in frame.getdata() if p[3] > 128)
            # A stump is usually small, maybe between 20 and 150 opaque pixels, 
            # and located at the bottom center. Let's just print sizes.
            
            # check if it looks like a stump (short)
            bbox = frame.getbbox()
            if bbox:
                fw = bbox[2] - bbox[0]
                fh = bbox[3] - bbox[1]
                print(f"Frame {frame_idx}: opaque={opaque}, bbox_w={fw}, bbox_h={fh}")
            else:
                print(f"Frame {frame_idx}: empty")

base_path = r"c:\Users\ofici\OneDrive\Documentos\farm-gaming\assets\sprites\tree\Common\Shadow"
trees = [
    "Birch Tree.png",
    "Mahogany Tree.png",
    "Maple Tree.png",
    "Pine Tree.png"
]

for t in trees:
    find_stump_frame(os.path.join(base_path, t), 32, 48)
