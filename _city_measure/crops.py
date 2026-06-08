import os
from PIL import Image

PACK = r"C:\Users\ofici\OneDrive\Documentos\farm-gaming\Farm RPG - Tiny Asset Pack - (All in One)"
OUT = r"C:\Users\ofici\OneDrive\Documentos\farm-gaming\_city_measure"

def crop(rel, box, name, scale=3):
    im = Image.open(os.path.join(PACK, rel)).convert("RGBA")
    c = im.crop((box[0], box[1], box[0]+box[2], box[1]+box[3]))
    c = c.resize((c.width*scale, c.height*scale), Image.NEAREST)
    # put on checkered bg to see transparency
    bg = Image.new("RGBA", c.size, (40,40,40,255))
    bg.alpha_composite(c)
    bg.save(os.path.join(OUT, name))
    print(name, "from", rel, box)

# Blacksmith: top row 508 wide ~ 4 stages. First complete building candidate.
crop(r"Objects\Exterior\Houses\NPCS houses\Blacksmith.png", (0,0,140,96), "crop_blacksmith_1.png")
# Fishman: top row, first complete shop candidate.
crop(r"Objects\Exterior\Houses\NPCS houses\Fishman.png", (0,0,170,112), "crop_fishman_1.png")
print("done")
