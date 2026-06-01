import os

file_path = r'c:\Users\ofici\OneDrive\Documentos\farm-gaming\entities\player\player.tscn'
with open(file_path, 'r', encoding='utf-8') as f:
    text = f.read()

# For sit_right, find its block and replace frame 2 with 3
idx_right = text.find('resource_name = "sit_right"')
end_right = text.find('resource_name = "sit_left"', idx_right)
if end_right == -1: end_right = text.find('[sub_resource', idx_right)

block_right = text[idx_right:end_right]
# We need to replace all "values": [2] with "values": [3] in this block
block_right = block_right.replace('"values": [2]', '"values": [3]')
text = text[:idx_right] + block_right + text[end_right:]

# For sit_left, replace frame 3 with 2
idx_left = text.find('resource_name = "sit_left"')
end_left = text.find('[sub_resource', idx_left)

block_left = text[idx_left:end_left]
block_left = block_left.replace('"values": [3]', '"values": [2]')
text = text[:idx_left] + block_left + text[end_left:]

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(text)

print("Frames swapped successfully.")
