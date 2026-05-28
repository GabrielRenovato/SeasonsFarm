from PIL import Image

def analyze():
    img = Image.open("assets/tiles/Tilled Soil and wet soil.png")
    w, h = img.size
    print(f"Texture dimensions: {w}x{h}")
    tile_size = 16
    cols = w // tile_size
    rows = h // tile_size
    
    # We want to see how many non-empty 16x16 tiles we have in different parts.
    # Usually, a Sprout Lands autotile sheet has:
    # - A dry tilled soil layout of 12 columns x 4 rows (192x64) or similar?
    # Let's print the grid of non-empty tiles.
    grid = []
    for r in range(rows):
        row_cells = []
        for c in range(cols):
            tile = img.crop((c * tile_size, r * tile_size, (c + 1) * tile_size, (r + 1) * tile_size))
            if tile.getbbox() is not None:
                row_cells.append("X")
            else:
                row_cells.append(".")
        grid.append(row_cells)
        
    print("Grid of non-empty tiles (16x16):")
    for r, row in enumerate(grid):
        print(f"Row {r:02d}: " + " ".join(row))

if __name__ == "__main__":
    analyze()
