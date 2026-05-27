import re

def main():
    with open('c:/Users/ofici/OneDrive/Documentos/farm-gaming/entities/player/Player.tscn', 'r', encoding='utf-8') as f:
        content = f.read()
    
    anims = ["carry_down", "carry_right", "carry_up", "carry_left", "carry_idle_down", "carry_idle_up", "carry_idle_left", "carry_idle_right"]
    for a in anims:
        match = re.search(f'resource_name = "{a}".*?path = NodePath\("Body/har:frame"\).*?values": \[(.*?)\]', content, re.DOTALL)
        if match:
            print(a, "har:frame", match.group(1).replace('\n', ''))

if __name__ == "__main__":
    main()
