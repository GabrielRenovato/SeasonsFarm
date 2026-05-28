from PIL import Image

img = Image.open('assets/sprites/tree/Common/Shadow/Pine Tree.png')
w, h = img.size

# Frame 6 is X=192 to 223, Y=0 to 47
frame = img.crop((192, 0, 224, 48))
print('\n'.join(''.join('X' if frame.getpixel((x,y))[3]>128 else ' ' for x in range(0,32,2)) for y in range(0,48,2)))
