import os
import random

uid = f"uid://{''.join(random.choices('abcdefghijklmnopqrstuvwxyz0123456789', k=12))}"
import_content = f"""[remap]

importer="texture"
type="CompressedTexture2D"
uid="{uid}"
path="res://.godot/imported/water_anim_edges.png-ba9bc371ff26d287c9eb647d91560e05.ctex"
metadata={{
"vram_texture": false
}}

[deps]

source_file="res://assets/tiles/water/water_anim_edges.png"
dest_files=["res://.godot/imported/water_anim_edges.png-ba9bc371ff26d287c9eb647d91560e05.ctex"]

[params]

compress/mode=0
compress/high_quality=false
compress/lossy_quality=0.7
compress/uastc_level=0
compress/rdo_quality_loss=0.0
compress/hdr_compression=1
compress/normal_map=0
compress/channel_pack=0
mipmaps/generate=false
mipmaps/limit=-1
roughness/mode=0
roughness/src_normal=""
process/channel_remap/red=0
process/channel_remap/green=1
process/channel_remap/blue=2
process/channel_remap/alpha=3
process/fix_alpha_border=true
process/premult_alpha=false
process/normal_map_invert_y=false
process/hdr_as_srgb=false
process/hdr_clamp_exposure=false
process/size_limit=0
detect_3d/compress_to=1
"""

with open('c:/Users/ofici/OneDrive/Documentos/farm-gaming/assets/tiles/water/water_anim_edges.png.import', 'w') as f:
    f.write(import_content)

print(f"Generated import file with UID: {uid}")
