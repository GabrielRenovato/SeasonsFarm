with open('c:/Users/ofici/OneDrive/Documentos/farm-gaming/entities/player/player.tscn', 'r', encoding='utf-8') as f:
    text = f.read()

for anim in ['idle_down', 'idle_up', 'idle_right', 'idle_left']:
    idx = text.find('resource_name = "' + anim + '"')
    frame_idx = text.find('NodePath("Body:frame")', idx)
    keys_idx = text.find('"values": [', frame_idx)
    end_idx = text.find(']', keys_idx)
    print(anim, text[keys_idx:end_idx+1])
