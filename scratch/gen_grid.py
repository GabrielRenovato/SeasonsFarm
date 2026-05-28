import os
from PIL import Image

try:
    img = Image.open(r'c:\Users\ofici\OneDrive\Documentos\farm-gaming\assets\tiles\Tilled Soil and wet soil.png').convert('RGBA')
    width, height = img.size
    
    html = '''
    <html>
    <head><style>
    .grid { display: grid; grid-template-columns: repeat(24, 32px); width: 768px; height: 256px; background: url(Tilled_Soil_and_wet_soil.png); background-size: 768px 256px; image-rendering: pixelated; }
    .cell { border: 1px solid rgba(255,255,255,0.5); box-sizing: border-box; width: 32px; height: 32px; color: white; font-size: 10px; text-shadow: 1px 1px 0 #000; display: flex; align-items: center; justify-content: center; }
    </style></head>
    <body style="background: #333;">
    <div class="grid">
    '''
    for y in range(height // 16):
        for x in range(width // 16):
            html += f'<div class="cell">{x},{y}</div>'
    html += '</div></body></html>'
    
    with open(r'c:\Users\ofici\OneDrive\Documentos\farm-gaming\scratch\grid.html', 'w') as f:
        f.write(html)
        
    img.save(r'c:\Users\ofici\OneDrive\Documentos\farm-gaming\scratch\Tilled_Soil_and_wet_soil.png')
    print('Created scratch/grid.html')
except Exception as e:
    print('Error:', e)
