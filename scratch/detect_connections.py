import os
from PIL import Image

def detect():
    src_path = "assets/tiles/Tilled Soil and wet soil.png"
    if not os.path.exists(src_path):
        print(f"{src_path} not found")
        return
        
    img = Image.open(src_path).convert("RGBA")
    tile_size = 16
    
    # We will analyze Quadrant 1 (cols 0-11, rows 0-3) which contains the 47 tiles for Dry Soil.
    # For each tile (c, r), let's determine if it connects to UP, RIGHT, DOWN, LEFT.
    # An edge connects if it has very few transparent pixels.
    # Let's count how many pixels are opaque (alpha > 0) along each edge of the 16x16 tile.
    
    detected_tiles = {} # mapping (connections) -> list of (c, r)
    
    for r in range(4):
        for c in range(12):
            tile = img.crop((c * tile_size, r * tile_size, (c + 1) * tile_size, (r + 1) * tile_size))
            
            # Check if tile is completely empty
            if tile.getbbox() is None:
                continue
                
            # Get edges
            # Top edge: y = 0
            top_opaque = sum(1 for x in range(tile_size) if tile.getpixel((x, 0))[3] > 128)
            # Bottom edge: y = 15
            bottom_opaque = sum(1 for x in range(tile_size) if tile.getpixel((x, 15))[3] > 128)
            # Left edge: x = 0
            left_opaque = sum(1 for y in range(tile_size) if tile.getpixel((0, y))[3] > 128)
            # Right edge: x = 15
            right_opaque = sum(1 for y in range(tile_size) if tile.getpixel((15, y))[3] > 128)
            
            # A connection exists if most edge pixels are opaque. Let's use a threshold of 8 pixels (half of 16).
            threshold = 8
            up = top_opaque >= threshold
            down = bottom_opaque >= threshold
            left = left_opaque >= threshold
            right = right_opaque >= threshold
            
            # Represent connection as neighbor bitmask: (UP=1, RIGHT=2, DOWN=4, LEFT=8)
            mask = (1 if up else 0) | (2 if right else 0) | (4 if down else 0) | (8 if left else 0)
            
            if mask not in detected_tiles:
                detected_tiles[mask] = []
            detected_tiles[mask].append((c, r, (top_opaque, right_opaque, bottom_opaque, left_opaque)))
            
    # Print the results
    print("Detected connection mappings for Dry Soil (Quadrant 1):")
    for mask in sorted(detected_tiles.keys()):
        connections = []
        if mask & 1: connections.append("UP")
        if mask & 2: connections.append("RIGHT")
        if mask & 4: connections.append("DOWN")
        if mask & 8: connections.append("LEFT")
        conn_str = "+".join(connections) if connections else "NONE (Isolated)"
        
        candidates = detected_tiles[mask]
        print(f"Mask {mask:2d} ({conn_str:18s}): candidates = {[ (c, r) for c, r, _ in candidates ]}")

if __name__ == "__main__":
    detect()
