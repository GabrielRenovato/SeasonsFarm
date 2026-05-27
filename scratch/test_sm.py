import re

def main():
    with open('c:/Users/ofici/OneDrive/Documentos/farm-gaming/entities/player/Player.tscn', 'r', encoding='utf-8') as f:
        content = f.read()
    
    match = re.search(r'\[sub_resource type="AnimationNodeStateMachine".*?(?=\[sub_resource)', content, re.DOTALL)
    if match:
        print(match.group(0))

if __name__ == "__main__":
    main()
