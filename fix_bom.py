import os

def main():
    tscn_path = "scenes/player/Player.tscn"
    if not os.path.exists(tscn_path):
        print("File not found")
        return
        
    with open(tscn_path, "rb") as f:
        content = f.read()

    # UTF-8 BOM is b'\xef\xbb\xbf'
    if content.startswith(b'\xef\xbb\xbf'):
        print("BOM found! Stripping BOM...")
        content = content[3:]
    else:
        print("No BOM found. Let's rewrite as clean UTF-8 anyway.")

    with open(tscn_path, "wb") as f:
        f.write(content)
    print("Rewritten Player.tscn as clean UTF-8 without BOM!")

if __name__ == "__main__":
    main()
