from PIL import Image

def get_min_y(img, frame_idx):
    box = (frame_idx*32, 0, (frame_idx+1)*32, 128)
    cropped = img.crop(box)
    pixels = cropped.getdata()
    for y in range(128):
        for x in range(32):
            if pixels[y*32 + x][3] > 0:
                return y
    return 999

def main():
    img1 = Image.open('c:/Users/ofici/OneDrive/Documentos/farm-gaming/assets/sprites/player/separate/carry/clothes/basic_carry.png')
    img2 = Image.open('c:/Users/ofici/OneDrive/Documentos/farm-gaming/assets/sprites/player/separate/walk/clothes/basic_walk.png')
    
    diffs = []
    for i in range(80):
        y1 = get_min_y(img1, i)
        y2 = get_min_y(img2, i)
        if y1 != y2:
            diffs.append((i, y1, y2))
            
    print("Frames where min_y differs:", diffs)

if __name__ == "__main__":
    main()
