import os
from PIL import Image, ImageDraw
PACK = r"C:\Users\ofici\OneDrive\Documentos\farm-gaming\Farm RPG - Tiny Asset Pack - (All in One)"
OUT = r"C:\Users\ofici\OneDrive\Documentos\farm-gaming\_city_measure"

def grid(rel, name, scale=8, gw=16, gh=16):
    im = Image.open(os.path.join(PACK, rel)).convert("RGBA")
    w,h = im.size
    bg = Image.new("RGBA",(w*scale,h*scale),(45,45,55,255))
    up = im.resize((w*scale,h*scale),Image.NEAREST)
    bg.alpha_composite(up)
    d=ImageDraw.Draw(bg)
    for cx in range(0,w//gw+1):
        d.line([(cx*gw*scale,0),(cx*gw*scale,h*scale)],fill=(0,255,0,140))
    for cy in range(0,h//gh+1):
        d.line([(0,cy*gh*scale),(w*scale,cy*gh*scale)],fill=(0,255,0,140))
    for cy in range(h//gh):
        for cx in range(w//gw):
            d.text((cx*gw*scale+1,cy*gh*scale+1),f"{cx},{cy}",fill=(255,255,0,255))
    bg.save(os.path.join(OUT,name))
    print(name,"size",(w,h),"grid",(w//gw,h//gh))

grid(r"Tileset\ALL props seasons.png","grid_props.png", scale=8)
grid(r"Objects\Exterior\Houses\NPCS houses\Fence and Bridge\White Fence.png".replace("Houses\\","").replace("NPCS houses\\",""),"grid_whitefence.png", scale=10) if False else None
grid(r"Objects\Exterior\Fence and Bridge\White Fence.png","grid_whitefence.png", scale=10)
grid(r"Objects\Exterior\Fence and Bridge\Fence Wood.png","grid_woodfence.png", scale=10)
grid(r"Objects\Exterior\Houses\NPCS houses\Houses.png","grid_houses_parts.png", scale=4)
print("done")
