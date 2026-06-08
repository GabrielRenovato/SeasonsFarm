import os
from PIL import Image

PACK = r"C:\Users\ofici\OneDrive\Documentos\farm-gaming\Farm RPG - Tiny Asset Pack - (All in One)"
GRASS = r"C:\Users\ofici\OneDrive\Documentos\farm-gaming\assets\tiles\farm\Tileset Grass Spring.png"

def col_max_alpha(im, x, y0, y1):
    px = im.load()
    m = 0
    for y in range(y0, y1):
        a = px[x, y][3]
        if a > m: m = a
    return m

def gaps(rel, y0, y1, label):
    im = Image.open(os.path.join(PACK, rel)).convert("RGBA")
    w, h = im.size
    prof = [col_max_alpha(im, x, y0, min(y1, h)) for x in range(w)]
    # report runs of low alpha (<40) as gaps
    print(f"\n[{label}] {rel}  size=({w},{h}) band y={y0}..{y1}")
    runs = []
    x = 0
    while x < w:
        if prof[x] < 40:
            x0 = x
            while x < w and prof[x] < 40:
                x += 1
            runs.append((x0, x-1))
        else:
            x += 1
    print("  low-alpha gap columns:", runs)

gaps(r"Objects\Exterior\Houses\NPCS houses\Blacksmith.png", 0, 96, "blacksmith top row")
gaps(r"Objects\Exterior\Houses\NPCS houses\Fishman.png", 0, 112, "fishman top row")

# --- plain grass cell finder ---
im = Image.open(GRASS).convert("RGBA")
w, h = im.size
px = im.load()
cw, ch = w // 16, h // 16
best = []
for cy in range(ch):
    for cx in range(cw):
        rs=gs=bs=0; n=0; opaque=True
        vals=[]
        for y in range(cy*16, cy*16+16):
            for x in range(cx*16, cx*16+16):
                r,g,b,a = px[x,y]
                if a < 250: opaque=False
                vals.append((r,g,b)); rs+=r; gs+=g; bs+=b; n+=1
        if not opaque: continue
        mr,mg,mb = rs/n, gs/n, bs/n
        if not (mg > mr and mg > mb): continue   # green-ish
        var = sum((r-mr)**2+(g-mg)**2+(b-mb)**2 for r,g,b in vals)/n
        best.append((var, cx, cy, int(mr),int(mg),int(mb)))
best.sort()
print("\n[plain grass candidates] (lowest color-variance green, fully opaque):")
for var,cx,cy,r,g,b in best[:10]:
    print(f"  cell ({cx},{cy})  var={var:.0f}  rgb=({r},{g},{b})")
print("done")
