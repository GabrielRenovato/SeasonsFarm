import re

def main():
    with open('c:/Users/ofici/OneDrive/Documentos/farm-gaming/entities/player/Player.tscn', 'r', encoding='utf-8') as f:
        content = f.read()
    
    anims = ["carry_idle_down", "carry_idle_up", "carry_idle_left", "carry_idle_right"]
    for a in anims:
        match = re.search(f'resource_name = "{a}".*?(?=\[sub_resource type="Animation"|$)', content, re.DOTALL)
        if match:
            anim = match.group(0)
            tracks = re.findall(r'path = NodePath\("(.*?)"\)', anim)
            print(a, tracks)

if __name__ == "__main__":
    main()
