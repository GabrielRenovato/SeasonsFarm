"""
Monta o tileset do lago a partir dos PIXELS REAIS do Farm RPG
(Water Ground animations tiles.png), removendo a terra laranja.

- 4 frames de animacao reais (periodo vertical 64px: y=0,64,128,192).
- Extrai a borda N e o canto NW do mini-lago retangular (bloco "4 pedras",
  metade direita = agua azul) e deriva S/E/W/cantos por espelho/rotacao.
- Centro = agua lisa (Water tile.png).
Sheet final 12x3 tiles (9 pecas x 4 frames) = 192x48, igual ao layout do .tres.
"""
from PIL import Image

SRC = Image.open("Farm RPG - Tiny Asset Pack - (All in One)/Tileset/Water Ground animations tiles.png").convert("RGBA")
WATERTILE = Image.open("Farm RPG - Tiny Asset Pack - (All in One)/Tileset/Water tile.png").convert("RGBA")
px = SRC.load()

AGUA = (0, 146, 221, 255)
FRAMES_Y = [0, 64, 128, 192]

# trecho reto da borda N (metade direita, agua azul) e quina NW
N_X = 218     # 16px retos do topo do bloco
NW_X = 207    # quina superior-esquerda do bloco


COAST_H = 6   # faixa fina da costa real (espuma); resto = agua lisa. Terra REMOVIDA
              # (a profundidade vem da camada de sombra ShoreLayer, sob a agua).


def is_stone(p):
    r, g, b, a = p
    return a > 0 and r > 120 and r < 205 and g < 120 and b < 120


def is_terra(p):
    # agua e espuma sempre tem azul > vermelho; o resto opaco e' terra -> remover.
    r, g, b, a = p
    return a == 0 or b <= r


def clean(img):
    o = img.load()
    for y in range(16):
        for x in range(16):
            p = o[x, y]
            if is_stone(p):
                o[x, y] = AGUA
            elif is_terra(p):
                o[x, y] = (0, 0, 0, 0)
    return img


def make_N(ybase):
    """Borda N: faixa fina da espuma real (terra removida) + agua lisa abaixo."""
    raw = clean(SRC.crop((N_X, ybase, N_X + 16, ybase + 16)).copy())
    o = raw.load()
    for y in range(COAST_H, 16):
        for x in range(16):
            o[x, y] = AGUA
    return raw


def make_NW(ybase):
    """Canto NW: quina da espuma em L (terra removida); miolo vira agua."""
    raw = clean(SRC.crop((NW_X, ybase, NW_X + 16, ybase + 16)).copy())
    o = raw.load()
    for y in range(16):
        for x in range(16):
            if x >= COAST_H and y >= COAST_H and o[x, y][3] == 0:
                o[x, y] = AGUA
    for y in range(COAST_H, 16):
        for x in range(COAST_H, 16):
            o[x, y] = AGUA
    return raw


def build_frame(ybase):
    N = make_N(ybase)
    NW = make_NW(ybase)
    NE = NW.transpose(Image.FLIP_LEFT_RIGHT)
    S = N.transpose(Image.FLIP_TOP_BOTTOM)
    SW = NW.transpose(Image.FLIP_TOP_BOTTOM)
    SE = NE.transpose(Image.FLIP_TOP_BOTTOM)
    W = N.transpose(Image.ROTATE_90)      # costa vai para a esquerda
    E = W.transpose(Image.FLIP_LEFT_RIGHT)
    C = WATERTILE.copy()
    return {"NW": NW, "N": N, "NE": NE, "W": W, "C": C, "E": E, "SW": SW, "S": S, "SE": SE}


POS = {"NW": (0, 0), "N": (4, 0), "NE": (8, 0),
       "W": (0, 1), "C": (4, 1), "E": (8, 1),
       "SW": (0, 2), "S": (4, 2), "SE": (8, 2)}


def main():
    sheet = Image.new("RGBA", (12 * 16, 3 * 16), (0, 0, 0, 0))
    frames = [build_frame(yb) for yb in FRAMES_Y]
    for name, (cb, row) in POS.items():
        for f in range(4):
            sheet.paste(frames[f][name], ((cb + f) * 16, row * 16))
    sheet.save("assets/tiles/water/water_lake.png")
    print("Salvo assets/tiles/water/water_lake.png", sheet.size)

    # preview lago 7x5 nos 4 frames + GIF
    layout = [["NW", "N", "N", "N", "N", "N", "NE"],
              ["W", "C", "C", "C", "C", "C", "E"],
              ["W", "C", "C", "C", "C", "C", "E"],
              ["W", "C", "C", "C", "C", "C", "E"],
              ["SW", "S", "S", "S", "S", "S", "SE"]]
    PV = 7
    gif = []
    cols = len(layout[0]); rows = len(layout)
    preview = Image.new("RGBA", ((cols * 16 + 6) * 4 * PV, rows * 16 * PV), (95, 150, 95, 255))
    for f in range(4):
        fr = Image.new("RGBA", (cols * 16, rows * 16), (95, 150, 95, 255))
        for ry, rowl in enumerate(layout):
            for cx, nm in enumerate(rowl):
                fr.alpha_composite(frames[f][nm], (cx * 16, ry * 16))
        big = fr.resize((cols * 16 * PV, rows * 16 * PV), Image.NEAREST)
        preview.alpha_composite(big, (f * (cols * 16 + 6) * PV, 0))
        gif.append(big.convert("RGB"))
    preview.convert("RGB").save("scratch/lake_pack_preview.png")
    gif[0].save("scratch/lake_pack.gif", save_all=True, append_images=gif[1:], duration=400, loop=0)
    print("Preview scratch/lake_pack_preview.png + scratch/lake_pack.gif")


if __name__ == "__main__":
    main()
