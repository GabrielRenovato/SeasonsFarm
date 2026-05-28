from PIL import Image
img = Image.open('assets/sprites/tree/Common/Shadow/Maple Tree.png')
for c in range(2, 6):
    print(f'--- Col {c} ---')
    frame=img.crop((c*32, 0, c*32+32, 48))
    print('\n'.join(''.join('X' if frame.getpixel((x,y))[3]>128 else ' ' for x in range(0,32,2)) for y in range(0,48,2)))
