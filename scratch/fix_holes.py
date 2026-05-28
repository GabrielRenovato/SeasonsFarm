from PIL import Image

def fix_holes():
    path = r"c:\Users\ofici\OneDrive\Documentos\farm-gaming\assets\tiles\Tilled Soil and wet soil.png"
    img = Image.open(path).convert('RGBA')
    pixels = img.load()
    w, h = img.size
    ts = 16
    
    modified = False
    # Iterar por cada bloco de 16x16
    for ty in range(h // ts):
        for tx in range(w // ts):
            # Verifica se é bloco de terra
            # Pega a cor de fundo em um ponto seguro como (2, 2)
            bg_px = pixels[tx*ts + 2, ty*ts + 2]
            
            # Checa o brilho
            bg_brightness = sum(bg_px[:3]) / 3
            if bg_px[3] < 200:
                continue # Não é solo opaco
            
            # Olha os pixels centrais de 6 a 9
            for y in range(6, 10):
                for x in range(6, 10):
                    cx = tx*ts + x
                    cy = ty*ts + y
                    px = pixels[cx, cy]
                    brightness = sum(px[:3]) / 3
                    # Se for consideravelmente mais escuro que a terra e não transparente
                    if px[3] > 200 and brightness < bg_brightness - 20:
                        pixels[cx, cy] = bg_px
                        modified = True

    if modified:
        img.save(path)
        print("Holes fixed and image saved.")
    else:
        print("No holes found or fixed.")

if __name__ == "__main__":
    fix_holes()
