from PIL import Image

def fix_corners():
    path = r"c:\Users\ofici\OneDrive\Documentos\farm-gaming\assets\tiles\Tilled Soil and wet soil.png"
    img = Image.open(path).convert('RGBA')
    pixels = img.load()
    ts = 16
    
    # Bloco seco (2, 1) e Bloco molhado (14, 1)
    tiles_to_fix = [(2, 1), (14, 1)]
    
    modified = False
    for tx, ty in tiles_to_fix:
        # Cor de referência (uma área limpa no meio do tile)
        ref_color = pixels[tx*ts + 8, ty*ts + 8]
        
        # Limpar todos os pixels nos 4 cantos que são escuros
        for y in range(ts):
            for x in range(ts):
                cx, cy = tx*ts + x, ty*ts + y
                px = pixels[cx, cy]
                
                # Se for um pixel na área de 2x2 dos cantos e tiver brilho menor (que forma o buraco)
                if x < 3 or x > ts-4 or y < 3 or y > ts-4:
                    brightness = sum(px[:3]) / 3
                    if brightness < sum(ref_color[:3])/3 - 10:
                        pixels[cx, cy] = ref_color
                        modified = True

    if modified:
        img.save(path)
        print("Tiles fixed and image saved.")
    else:
        print("No tiles needed fixing.")

if __name__ == "__main__":
    fix_corners()
