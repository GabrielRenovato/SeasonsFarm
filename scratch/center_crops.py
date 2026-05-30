import os
from PIL import Image

def center_all_crops():
    for season in ['Spring', 'Summer', 'Fall']:
        folder = f'c:/Users/ofici/OneDrive/Documentos/farm-gaming/assets/sprites/novosCrops/{season}'
        if not os.path.exists(folder): continue
        for f in os.listdir(folder):
            if not f.endswith('.png'): continue
            path = os.path.join(folder, f)
            try:
                img = Image.open(path).convert('RGBA')
            except Exception as e:
                print(f"Error opening {path}: {e}")
                continue
            
            frames = img.size[0] // 16
            height = img.size[1]
            
            # We will create a new blank image with the same size
            new_img = Image.new('RGBA', img.size, (0,0,0,0))
            modified = False
            
            for i in range(frames):
                box = (i*16, 0, i*16+16, height)
                frame = img.crop(box)
                b = frame.getbbox()
                
                if not b:
                    # Empty frame, just paste it back
                    new_img.paste(frame, box)
                    continue
                
                c_x = (b[0] + b[2]) / 2.0
                dx = int(round(8.0 - c_x))
                
                if dx == 0:
                    new_img.paste(frame, box)
                else:
                    modified = True
                    # Create a blank frame and paste the shifted pixels
                    new_frame = Image.new('RGBA', (16, height), (0,0,0,0))
                    # The pixels in 'frame' are shifted by dx
                    # We crop the original bounding box from the frame
                    content = frame.crop(b)
                    # And paste it at the new shifted position
                    new_frame.paste(content, (b[0] + dx, b[1]))
                    new_img.paste(new_frame, box)
                    
            if modified:
                new_img.save(path)
                print(f"Centered: {f}")

center_all_crops()
