"""
Gera a SOMBRA DE PROFUNDIDADE da margem do lago (sem grama).
Tons de terra molhada escura colados na agua, clareando ate sumir no chao.
Semi-transparente -> funde com o chao de terra (sem emenda de cor).

dirt_depth.png = N tiles 16x16 em linha (nivel 0 = mais perto da agua/escuro
... nivel N-1 = mais longe/leve). O map_manager pinta cada celula do anel com
o nivel = (distancia a agua - 1).
"""
from PIL import Image

LEVELS = 4
SHADOW = (48, 24, 26)                 # marrom muito escuro (terra molhada)
ALPHAS = [165, 116, 70, 32]           # por nivel: forte perto da agua -> leve
CHAO = (238, 157, 81, 255)            # cor do chao de terra (so p/ preview)


def make_tile(level):
    a = ALPHAS[level]
    t = Image.new("RGBA", (16, 16), (SHADOW[0], SHADOW[1], SHADOW[2], a))
    o = t.load()
    # leve variacao p/ nao ficar chapado (alguns pixels +escuros/+claros)
    for y in range(16):
        for x in range(16):
            if (x * 7 + y * 5) % 13 == 0:
                o[x, y] = (SHADOW[0], SHADOW[1], SHADOW[2], min(255, a + 30))
            elif (x * 3 + y * 11) % 17 == 0:
                o[x, y] = (SHADOW[0], SHADOW[1], SHADOW[2], max(0, a - 25))
    return t


def main():
    sheet = Image.new("RGBA", (LEVELS * 16, 16), (0, 0, 0, 0))
    for lv in range(LEVELS):
        sheet.paste(make_tile(lv), (lv * 16, 0))
    sheet.save("assets/tiles/water/dirt_depth.png")
    print("Salvo assets/tiles/water/dirt_depth.png", sheet.size)

    # preview: agua (quadrado) + aneis de profundidade sobre fundo de chao de terra
    PV = 10
    grid = 13
    water_r = 3   # "raio" da agua em tiles (Chebyshev)
    img = Image.new("RGBA", (grid * 16, grid * 16), CHAO)
    cx = cy = grid // 2
    tiles = [make_tile(lv) for lv in range(LEVELS)]
    for gy in range(grid):
        for gx in range(grid):
            cheb = max(abs(gx - cx), abs(gy - cy))
            dist = cheb - water_r          # 1.. = anel; <=0 = agua
            if dist >= 1 and dist <= LEVELS:
                img.alpha_composite(tiles[dist - 1], (gx * 16, gy * 16))
            elif dist <= 0:
                # agua simples (so p/ referencia visual do preview)
                img.alpha_composite(Image.new("RGBA", (16, 16), (0, 146, 221, 255)), (gx * 16, gy * 16))
    big = img.resize((grid * 16 * PV, grid * 16 * PV), Image.NEAREST)
    big.convert("RGB").save("scratch/dirt_depth_preview.png")
    print("Preview scratch/dirt_depth_preview.png")


if __name__ == "__main__":
    main()
