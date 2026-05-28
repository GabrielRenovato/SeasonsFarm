import struct
for f in ['Birch', 'Mahogany', 'Maple', 'Pine']:
    file = f'assets/sprites/tree/Common/Shadow/{f} Tree Animation.png'
    with open(file, 'rb') as fp:
        fp.seek(16)
        w, h = struct.unpack('>LL', fp.read(8))
        print(f'{f}: {w}x{h}')
