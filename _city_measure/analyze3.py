import os
from PIL import Image

PACK = r"C:\Users\ofici\OneDrive\Documentos\farm-gaming\Farm RPG - Tiny Asset Pack - (All in One)"
OUT = r"C:\Users\ofici\OneDrive\Documentos\farm-gaming\_city_measure"

def crop(rel, box, name, scale=3):
    im = Image.open(os.path.join(PACK, rel)).convert("RGBA")
    c = im.crop((box[0], box[1], box[0]+box[2], box[1]+box[3]))
    c = c.resize((c.width*scale, c.height*scale), Image.NEAREST)
    bg = Image.new("RGBA", c.size, (40,40,40,255))
    bg.alpha_composite(c)
    bg.save(os.path.join(OUT, name)); print("saved", name, box)

crop(r"Objects\Exterior\Houses\NPCS houses\Blacksmith.png", (4,7,72,88), "v_blacksmith.png")
crop(r"Objects\Exterior\Houses\NPCS houses\Fishman.png", (2,7,76,102), "v_fishman.png")

# Path tiles: per-cell opaque fraction for top rows to find 3x3 transition block
im = Image.open(os.path.join(PACK, r"Tileset\Path tiles.png")).convert("RGBA")
px = im.load(); w,h = im.size
print(f"\nPath tiles opaque-fraction per cell (16px). size=({w},{h})")
for cy in range(0, 4):
    row=[]
    for cx in range(0, 12):
        op=0
        for y in range(cy*16, cy*16+16):
            for x in range(cx*16, cx*16+16):
                if px[x,y][3] >= 250: op+=1
        row.append(f"{op/256:.2f}")
    print(f" row{cy}: " + " ".join(f"({cx}){row[cx]}" for cx in range(12)))
print("done")
