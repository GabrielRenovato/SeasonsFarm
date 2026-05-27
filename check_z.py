import re

content = open('scenes/player/Player.tscn', 'r', encoding='utf-8').read()

lags_matches = re.findall(r'path = NodePath\("Lags:z_index"\).*?values": \[(.*?)\]', content, re.DOTALL)
print('Lags z_index values:', set(lags_matches))

tool_matches = re.findall(r'path = NodePath\("Tool:z_index"\).*?values": \[(.*?)\]', content, re.DOTALL)
print('Tool z_index values:', set(tool_matches))

har_matches = re.findall(r'path = NodePath\("har:z_index"\).*?values": \[(.*?)\]', content, re.DOTALL)
print('har z_index values:', set(har_matches))
