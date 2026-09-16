from PIL import Image
import numpy as np

im = Image.open('public/church_symbol_transparent.png')
arr = np.array(im)[:, :, 3] > 0

h, w = arr.shape

# Generate path data by tracing RLE segments
path_d = []
for y in range(h):
    row = arr[y, :]
    in_seg = False
    start_x = 0
    for x in range(w):
        if row[x] and not in_seg:
            in_seg = True
            start_x = x
        elif not row[x] and in_seg:
            in_seg = False
            path_d.append(f"M{start_x},{y}h{x-start_x}v1h{-(x-start_x)}z")
    if in_seg:
        path_d.append(f"M{start_x},{y}h{w-start_x}v1h{-(w-start_x)}z")

d_str = " ".join(path_d)

svg_content = f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {w} {h}" fill="currentColor">
  <path d="{d_str}" />
</svg>'''

with open('public/church_symbol.svg', 'w') as f:
    f.write(svg_content)

print(f"Generated public/church_symbol.svg ({len(svg_content)} bytes)")
