from PIL import Image

def fix_all_corners_completely():
    path = r"c:\Users\ofici\OneDrive\Documentos\farm-gaming\assets\tiles\Tilled Soil and wet soil.png"
    img = Image.open(path).convert('RGBA')
    pixels = img.load()
    ts = 16
    
    auto_tile_map = {
        0: (0, 3),
        1: (0, 2),
        2: (1, 3),
        3: (1, 2),
        4: (0, 0),
        5: (0, 1),
        6: (1, 0),
        7: (1, 1),
        8: (3, 3),
        9: (3, 2),
        10: (2, 3),
        11: (2, 2),
        12: (3, 0),
        13: (3, 1),
        14: (2, 0),
        15: (2, 1),
    }

    modified = False

    for mask, (bx, by) in auto_tile_map.items():
        for offset_x in [0, 12]:
            tx, ty = bx + offset_x, by
            
            # Ponto de referência (terra contínua no meio do tile)
            ref_color = pixels[tx*ts + 8, ty*ts + 8]
            
            up = (mask & 1) != 0
            right = (mask & 2) != 0
            down = (mask & 4) != 0
            left = (mask & 8) != 0

            # Listar quinas que devem ser completamente limpas (sem cantos arredondados ou bordas laranjas invadindo)
            corners_to_clean = []
            if up and left:
                corners_to_clean.append((range(0, 3), range(0, 3)))
            if up and right:
                corners_to_clean.append((range(ts-3, ts), range(0, 3)))
            if down and left:
                corners_to_clean.append((range(0, 3), range(ts-3, ts)))
            if down and right:
                corners_to_clean.append((range(ts-3, ts), range(ts-3, ts)))

            for rx, ry in corners_to_clean:
                for y in ry:
                    for x in rx:
                        cx, cy = tx*ts + x, ty*ts + y
                        px = pixels[cx, cy]
                        
                        # Se não for borda transparente, pinta TUDO da cor de referência
                        if px[3] > 100:
                            # Removido o filtro de brightness. 
                            # Isso corrige os furos claros na terra molhada e cantos sobressalentes.
                            pixels[cx, cy] = ref_color
                            modified = True

    if modified:
        img.save(path)
        print("All interior corners fixed strictly and image saved.")
    else:
        print("No tiles needed fixing.")

if __name__ == "__main__":
    fix_all_corners_completely()
