import os
import struct

def get_png_size(file_path):
    with open(file_path, 'rb') as f:
        data = f.read(24)
        if data[:8] == b'\x89PNG\r\n\x1a\n':
            w, h = struct.unpack('>II', data[16:24])
            return w, h
    return None

base_path = r"c:\Users\ofici\OneDrive\Documentos\farm-gaming\assets\sprites\tree"
paths_to_check = [
    r"tree_shake.png",
    r"Common\Shadow\Birch Tree Animation.png",
    r"Common\Shadow\Birch Tree.png",
    r"Common\Shadow\Maple Tree Animation.png",
    r"Common\Shadow\Maple Tree.png",
    r"Deep Forest\Tree.png",
]

for p in paths_to_check:
    full_path = os.path.join(base_path, p)
    if os.path.exists(full_path):
        size = get_png_size(full_path)
        print(f"{p}: {size}")
    else:
        print(f"{p}: NOT FOUND")
