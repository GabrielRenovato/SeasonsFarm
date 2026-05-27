from PIL import Image
import os

def check():
    path = r"c:\Users\ofici\OneDrive\Documentos\farm-gaming\assets\sprites\crops\crops.png"
    if not os.path.exists(path):
        print("crops.png not found")
        return
        
    img = Image.open(path).convert("RGBA")
    tile_size = 16
    
    # Save Tomato frame 0 and Turnip frame 0
    tomato_0 = img.crop((0, 0, tile_size, tile_size))
    turnip_0 = img.crop((0, tile_size, tile_size, 2*tile_size))
    
    tomato_0.save(r"c:\Users\ofici\OneDrive\Documentos\farm-gaming\scratch\tomato_frame_0.png")
    turnip_0.save(r"c:\Users\ofici\OneDrive\Documentos\farm-gaming\scratch\turnip_frame_0.png")
    
    print("Saved scratch/tomato_frame_0.png and scratch/turnip_frame_0.png")

if __name__ == "__main__":
    check()
