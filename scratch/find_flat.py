from PIL import Image

def find_flat():
    path = r"c:\Users\ofici\OneDrive\Documentos\farm-gaming\assets\tiles\Tilled Soil and wet soil.png"
    img = Image.open(path).convert('RGBA')
    w, h = img.size
    ts = 16
    
    for ty in range(h // ts):
        for tx in range(w // ts):
            pixels = []
            for y in range(ts):
                for x in range(ts):
                    pixels.append(sum(img.getpixel((tx*ts+x, ty*ts+y))[:3])//3)
                    
            if max(pixels) - min(pixels) < 10 and pixels[0] == 123:
                print(f"Flat tile found at ({tx}, {ty})")
            
            # Print corner brightness for all tiles that have 123 in the center
            if sum(img.getpixel((tx*ts+8, ty*ts+8))[:3])//3 == 123:
                tl = pixels[0]
                tr = pixels[15]
                bl = pixels[15*ts]
                br = pixels[15*ts+15]
                if tl > 110 and tr > 110 and bl > 110 and br > 110:
                    print(f"Candidate smooth tile at ({tx}, {ty}): corners {tl}, {tr}, {bl}, {br}")

if __name__ == "__main__":
    find_flat()
