from PIL import Image
import os

def check():
    path = r"c:\Users\ofici\OneDrive\Documentos\farm-gaming\assets\sprites\crops\crops.png"
    if not os.path.exists(path):
        print("crops.png not found")
        return
        
    img = Image.open(path).convert("RGBA")
    tile_size = 16
    
    # Check Tomato (row 0) frames 0 to 5
    print("Tomato (Row 0) Pixel Bounding Boxes and Offsets:")
    for f in range(6):
        tile = img.crop((f*tile_size, 0, (f+1)*tile_size, tile_size))
        bbox = tile.getbbox()
        if bbox:
            left, top, right, bottom = bbox
            # Bounding box width
            w = right - left
            # Center of bounding box
            center_x = (left + right) / 2.0
            # Offset from frame center (which is 8.0)
            offset_x = center_x - 8.0
            print(f"  Frame {f}: BBox={bbox}, Width={w}, CenterX={center_x:.2f}, OffsetX={offset_x:+.2f}")
        else:
            print(f"  Frame {f}: Empty")
            
    # Check Turnip (row 1) frames 0 to 5
    print("\nTurnip (Row 1) Pixel Bounding Boxes and Offsets:")
    for f in range(6):
        tile = img.crop((f*tile_size, tile_size, (f+1)*tile_size, 2*tile_size))
        bbox = tile.getbbox()
        if bbox:
            left, top, right, bottom = bbox
            w = right - left
            center_x = (left + right) / 2.0
            offset_x = center_x - 8.0
            print(f"  Frame {f}: BBox={bbox}, Width={w}, CenterX={center_x:.2f}, OffsetX={offset_x:+.2f}")
        else:
            print(f"  Frame {f}: Empty")

if __name__ == "__main__":
    check()
