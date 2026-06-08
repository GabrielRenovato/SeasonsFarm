import os
from PIL import Image, ImageDraw
PACK = r"C:\Users\ofici\OneDrive\Documentos\farm-gaming\Farm RPG - Tiny Asset Pack - (All in One)"
OUT = r"C:\Users\ofici\OneDrive\Documentos\farm-gaming\_city_measure"
im = Image.open(os.path.join(PACK, r"Objects\Exterior\Houses\NPCS houses\Base houses.png")).convert("RGBA")
px = im.load(); w,h = im.size
print("size", (w,h))

def band_houses(y0,y1,label):
    # column occupancy by ~opaque pixels in band
    prof=[]
    for x in range(w):
        m=0
        for y in range(y0,y1):
            a=px[x,y][3]
            if a>m: m=a
        prof.append(m)
    runs=[]; x=0
    while x<w:
        if prof[x]>=60:
            x0=x
            while x<w and prof[x]>=60: x+=1
            runs.append((x0,x-1))
        else:
            x+=1
    # tight bbox (alpha>0) per run within band
    boxes=[]
    for (rx0,rx1) in runs:
        bx0,bx1,by0,by1=rx1,rx0,y1,y0
        for y in range(y0,y1):
            for x in range(rx0,rx1+1):
                if px[x,y][3]>0:
                    if x<bx0:bx0=x
                    if x+1>bx1:bx1=x+1
                    if y<by0:by0=y
                    if y+1>by1:by1=y+1
        if bx1>bx0:
            boxes.append((bx0,by0,bx1-bx0,by1-by0))
    print(f"\n[{label}] y={y0}..{y1}  -> {len(boxes)} houses")
    for i,b in enumerate(boxes):
        print(f"   {i}: x={b[0]} y={b[1]} w={b[2]} h={b[3]}")
    return boxes

top = band_houses(20,172,"TOP row")
bot = band_houses(180,352,"BOTTOM row")

# draw all
scale=2
dbg=im.resize((w*scale,h*scale),Image.NEAREST); d=ImageDraw.Draw(dbg)
for b in top+bot:
    d.rectangle([b[0]*scale,b[1]*scale,(b[0]+b[2])*scale-1,(b[1]+b[3])*scale-1],outline=(255,0,255,255))
dbg.save(os.path.join(OUT,"dbg_base_split.png"))
print("done")
