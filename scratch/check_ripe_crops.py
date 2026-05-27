from PIL import Image
import os

def check():
    path = r"c:\Users\ofici\OneDrive\Documentos\farm-gaming\assets\sprites\crops\crops.png"
    if not os.path.exists(path):
        print("crops.png not found")
        return
        
    img = Image.open(path).convert("RGBA")
    tile_size = 16
    
    # Save the last (ripe/mature) frame of tomato (row 0) and turnip (row 1)
    # Tomato: row 0, frame 5 (last)
    tomato_ripe = img.crop((5*tile_size, 0, 6*tile_size, tile_size))
    # Turnip: row 1, frame 5 (last)
    turnip_ripe = img.crop((5*tile_size, tile_size, 6*tile_size, 2*tile_size))
    
    tomato_ripe.save(r"c:\Users\ofici\OneDrive\Documentos\farm-gaming\scratch\tomato_ripe.png")
    turnip_ripe.save(r"c:\Users\ofici\OneDrive\Documentos\farm-gaming\scratch\turnip_ripe.png")
    
    # Also save first 4 rows of crops.png as a reference
    preview_rows = 4
    preview = img.crop((0, 0, img.width, preview_rows * tile_size))
    preview.save(r"c:\Users\ofici\OneDrive\Documentos\farm-gaming\scratch\crops_preview.png")
    
    print("Saved tomato_ripe.png, turnip_ripe.png and crops_preview.png")

if __name__ == "__main__":
    check()
