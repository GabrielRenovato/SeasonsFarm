"""
Gera o tileset do ANEL DE TERRA ao redor do lago, a partir dos pixels reais do
Farm RPG (Tileset Grass Spring.png, faixa de terra y=128..256).

Truque do tom: removemos so a GRAMA DE FUNDO (verde longe da terra) -> transparente,
mantendo os TUFOS (verde que encosta na terra). Assim a grama do GroundLayer aparece
por baixo (qualquer tom) e os tufos de transicao terra->grama ficam por cima.

Sheet 3x3 tiles = 48x48 (estatico, sem animacao): 9 pecas terra-no-centro / grama-na-borda.
"""
from PIL import Image

SRC = Image.open("Farm RPG - Tiny Asset Pack - (All in One)/Tileset/Tileset Grass Spring.png").convert("RGBA")
px = SRC.load()

TERRA = (238, 157, 81, 255)
TERRA_SOMBRA = (190, 109, 71, 255)

BASE_Y = 128       # inicio da faixa de terra
N_X = 26           # borda N reta do bloco "4 pedras de terra" (metade esq)
NW_X = 16          # canto NW do bloco
KEEP = 8           # linhas/colunas reais mantidas no topo (grama+tufos); resto = terra


def is_grass(p):
    r, g, b, a = p
    return a > 0 and g > r and g >= b  # verde domina


def is_terra(p):
    r, g, b, a = p
    return a > 0 and r >= g and b <= r


def near_terra(o, x, y, rad=2):
    for dy in range(-rad, rad + 1):
        for dx in range(-rad, rad + 1):
            xx, yy = x + dx, y + dy
            if 0 <= xx < 16 and 0 <= yy < 16 and is_terra(o[xx, yy]):
                return True
    return False


def process(tile):
    """grama de fundo -> transparente; tufo (grama perto de terra) -> mantem; pedra -> terra."""
    o = tile.load()
    # 1) pedras/decoracoes escuras viram terra
    for y in range(16):
        for x in range(16):
            r, g, b, a = o[x, y]
            if a > 0 and r > 120 and r < 205 and g < 120 and b < 120:
                o[x, y] = TERRA
    # 2) grama de fundo -> transparente (snapshot antes de alterar)
    snap = tile.copy().load()
    for y in range(16):
        for x in range(16):
            if is_grass(snap[x, y]) and not near_terra(snap, x, y):
                o[x, y] = (0, 0, 0, 0)
    return tile


def make_N(by):
    raw = SRC.crop((N_X, by, N_X + 16, by + 16)).copy()
    raw = process(raw)
    o = raw.load()
    for y in range(KEEP, 16):
        for x in range(16):
            o[x, y] = TERRA if (x * 7 + y * 5) % 13 else TERRA_SOMBRA
    return raw


def make_NW(by):
    raw = SRC.crop((NW_X, by, NW_X + 16, by + 16)).copy()
    raw = process(raw)
    o = raw.load()
    for y in range(KEEP, 16):
        for x in range(KEEP, 16):
            o[x, y] = TERRA if (x * 7 + y * 5) % 13 else TERRA_SOMBRA
    return raw


def make_center():
    t = Image.new("RGBA", (16, 16), TERRA)
    o = t.load()
    for y in range(16):
        for x in range(16):
            if (x * 5 + y * 3) % 11 == 0:
                o[x, y] = TERRA_SOMBRA
    return t


def build():
    N = make_N(BASE_Y)
    NW = make_NW(BASE_Y)
    NE = NW.transpose(Image.FLIP_LEFT_RIGHT)
    S = N.transpose(Image.FLIP_TOP_BOTTOM)
    SW = NW.transpose(Image.FLIP_TOP_BOTTOM)
    SE = NE.transpose(Image.FLIP_TOP_BOTTOM)
    W = N.transpose(Image.ROTATE_90)
    E = W.transpose(Image.FLIP_LEFT_RIGHT)
    C = make_center()
    return {"NW": NW, "N": N, "NE": NE, "W": W, "C": C, "E": E, "SW": SW, "S": S, "SE": SE}


POS = {"NW": (0, 0), "N": (1, 0), "NE": (2, 0),
       "W": (0, 1), "C": (1, 1), "E": (2, 1),
       "SW": (0, 2), "S": (1, 2), "SE": (2, 2)}


def main():
    pieces = build()
    sheet = Image.new("RGBA", (3 * 16, 3 * 16), (0, 0, 0, 0))
    for name, (cx, cy) in POS.items():
        sheet.paste(pieces[name], (cx * 16, cy * 16))
    sheet.save("assets/tiles/water/dirt_grass.png")
    print("Salvo assets/tiles/water/dirt_grass.png", sheet.size)

    # preview: anel de terra (oco) sobre 2 tons de grama
    layout = [["NW", "N", "N", "N", "N", "NE"],
              ["W", "C", "C", "C", "C", "E"],
              ["W", "C", "C", "C", "C", "E"],
              ["SW", "S", "S", "S", "S", "SE"]]
    PV = 8
    cols = len(layout[0]); rows = len(layout)
    out = Image.new("RGBA", (cols * 16 * PV * 2 + 20, rows * 16 * PV), (0, 0, 0, 255))
    for i, gcol in enumerate([(121, 191, 86, 255), (50, 173, 83, 255)]):
        fr = Image.new("RGBA", (cols * 16, rows * 16), gcol)
        for ry, rowl in enumerate(layout):
            for cxi, nm in enumerate(rowl):
                fr.alpha_composite(pieces[nm], (cxi * 16, ry * 16))
        big = fr.resize((cols * 16 * PV, rows * 16 * PV), Image.NEAREST)
        out.alpha_composite(big, (i * (cols * 16 * PV + 20), 0))
    out.convert("RGB").save("scratch/dirt_ring_preview.png")
    print("Preview scratch/dirt_ring_preview.png")


if __name__ == "__main__":
    main()
