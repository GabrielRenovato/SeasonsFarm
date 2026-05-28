from PIL import Image

def analyze():
    path = r"c:\Users\ofici\OneDrive\Documentos\farm-gaming\assets\tiles\Tilled Soil and wet soil.png"
    img = Image.open(path).convert('RGBA')
    pixels = img.load()
    
    # Analyze dry soil block (2,1)
    tx, ty = 2, 1
    ts = 16
    
    print(f"Colors in tile ({tx},{ty}):")
    for y in range(ts):
        row = []
        for x in range(ts):
            px = pixels[tx*ts + x, ty*ts + y]
            # Print a rough map of darkness to see the hole
            brightness = sum(px[:3])/3
            if px[3] < 100:
                row.append(" ")
            elif brightness < 60:
                row.append("#") # Hole
            elif brightness < 100:
                row.append("+") # Edge
            else:
                row.append(".") # Soil
        print("".join(row))

if __name__ == "__main__":
    analyze()
