import os, json
from PIL import Image, ImageDraw

PACK = r"C:\Users\ofici\OneDrive\Documentos\farm-gaming\Farm RPG - Tiny Asset Pack - (All in One)"
OUT = r"C:\Users\ofici\OneDrive\Documentos\farm-gaming\_city_measure"
os.makedirs(OUT, exist_ok=True)

# Files to segment into islands (separated by transparent gaps)
SEG = {
    "base_houses":   r"Objects\Exterior\Houses\NPCS houses\Base houses.png",
    "blacksmith":    r"Objects\Exterior\Houses\NPCS houses\Blacksmith.png",
    "fishman":       r"Objects\Exterior\Houses\NPCS houses\Fishman.png",
    "school":        r"Objects\Exterior\Houses\NPCS houses\School.png",
    "wizard":        r"Objects\Exterior\Houses\NPCS houses\wizard's house.png",
    "train_station": r"Objects\Exterior\Houses\NPCS houses\train station.png",
    "temple":        r"Objects\Exterior\Houses\NPCS houses\temple.png",
    "trailer":       r"Objects\Exterior\Houses\NPCS houses\trailer.png",
    "three":         r"Objects\Exterior\Houses\NPCS houses\3.png",
    "extra_village": r"Tileset\Extra Village Tilesets.png",
}

# Files to just report size + 16-grid info
SIZE_ONLY = {
    "path_tiles":  r"Tileset\Path tiles.png",
    "grass_spring":r"assets\tiles\farm\Tileset Grass Spring.png".replace("assets", "..\\assets"),  # placeholder, fixed below
}

def col_nonempty(mask, x, h, thr):
    for y in range(h):
        if mask[y][x] >= thr:
            return True
    return False

# sep_thr: occupancy threshold used to FIND gaps (high => only ~opaque pixels
# count, so faint shadows that bridge two sprites are ignored).
# bbox_thr: threshold used to TIGHTEN the bounding box (low => include shadow).
def segment(path, sep_thr=128, bbox_thr=1):
    im = Image.open(path).convert("RGBA")
    w, h = im.size
    px = im.load()
    mask = [[px[x, y][3] for x in range(w)] for y in range(h)]
    # vertical strips: ranges of columns that contain any ~opaque pixel
    strips = []
    x = 0
    while x < w:
        if col_nonempty(mask, x, h, sep_thr):
            x0 = x
            while x < w and col_nonempty(mask, x, h, sep_thr):
                x += 1
            strips.append((x0, x))  # [x0, x)
        else:
            x += 1
    boxes = []
    for (sx0, sx1) in strips:
        # within strip, find row ranges occupied (by ~opaque pixels)
        def row_nonempty(y):
            for xx in range(sx0, sx1):
                if mask[y][xx] >= sep_thr:
                    return True
            return False
        y = 0
        while y < h:
            if row_nonempty(y):
                y0 = y
                while y < h and row_nonempty(y):
                    y += 1
                # tighten x within this row-band
                bx0, bx1 = sx1, sx0
                by0, by1 = y, y0
                for yy in range(y0, y):
                    for xx in range(sx0, sx1):
                        if mask[yy][xx] >= bbox_thr:
                            if xx < bx0: bx0 = xx
                            if xx+1 > bx1: bx1 = xx+1
                            if yy < by0: by0 = yy
                            if yy+1 > by1: by1 = yy+1
                boxes.append((bx0, by0, bx1-bx0, by1-by0))
            else:
                y += 1
    return im, (w, h), boxes

results = {}
for key, rel in SEG.items():
    p = os.path.join(PACK, rel)
    if not os.path.exists(p):
        print("MISSING", key, p); continue
    im, size, boxes = segment(p)
    results[key] = {"size": size, "boxes": boxes}
    # debug image: upscale 2x, draw boxes + index
    scale = 2
    dbg = im.convert("RGBA").resize((size[0]*scale, size[1]*scale), Image.NEAREST)
    d = ImageDraw.Draw(dbg)
    for i, (bx, by, bw, bh) in enumerate(boxes):
        d.rectangle([bx*scale, by*scale, (bx+bw)*scale-1, (by+bh)*scale-1], outline=(255,0,255,255))
        d.text((bx*scale+1, by*scale+1), str(i), fill=(255,255,0,255))
    dbg.save(os.path.join(OUT, f"dbg_{key}.png"))
    print(f"\n== {key}  size={size}  ({len(boxes)} boxes) ==")
    for i, b in enumerate(boxes):
        print(f"  [{i}] x={b[0]} y={b[1]} w={b[2]} h={b[3]}")

# size-only / grid files
for key, rel in {"path_tiles": r"Tileset\Path tiles.png",
                 "grass_spring": r"..\assets\tiles\farm\Tileset Grass Spring.png"}.items():
    if key == "grass_spring":
        p = r"C:\Users\ofici\OneDrive\Documentos\farm-gaming\assets\tiles\farm\Tileset Grass Spring.png"
    else:
        p = os.path.join(PACK, rel)
    if not os.path.exists(p):
        print("MISSING", key, p); continue
    im = Image.open(p).convert("RGBA")
    w, h = im.size
    print(f"\n== {key}  size=({w},{h})  grid16=({w//16}x{h//16}) ==")
    # save a 6x upscaled grid-annotated version for visual cell picking
    scale = 6
    up = im.resize((w*scale, h*scale), Image.NEAREST)
    d = ImageDraw.Draw(up)
    for cx in range(0, w//16):
        for cy in range(0, h//16):
            d.rectangle([cx*16*scale, cy*16*scale, (cx+1)*16*scale-1, (cy+1)*16*scale-1], outline=(0,255,0,120))
    up.save(os.path.join(OUT, f"grid_{key}.png"))

with open(os.path.join(OUT, "rects.json"), "w") as f:
    json.dump(results, f, indent=1)
print("\nDONE -> ", OUT)
