from PIL import Image

def show():
    path = r"c:\Users\ofici\OneDrive\Documentos\farm-gaming\assets\tiles\Tilled Soil and wet soil.png"
    img = Image.open(path).convert('RGBA')
    px = img.load()
    ts = 16
    tx, ty = 2, 1
    for y in range(ts):
        row = []
        for x in range(ts):
            c = px[tx*ts+x, ty*ts+y]
            brightness = sum(c[:3])//3
            if c[3] < 100:
                row.append("   ")
            else:
                row.append(f"{brightness:03d}")
        print(" ".join(row))

if __name__ == "__main__":
    show()
