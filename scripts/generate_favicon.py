import re

with open('public/church_symbol.svg', 'r') as f:
    content = f.read()

match = re.search(r'path d="([^"]+)"', content)
if match:
    path_d = match.group(1)

    favicon_svg = f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" fill="currentColor">
  <style>
    :root {{ color: #1b4332; }}
    @media (prefers-color-scheme: dark) {{ :root {{ color: #86efac; }} }}
  </style>
  <g transform="translate(36, 180.5) scale(0.5116279)">
    <path d="{path_d}" />
  </g>
</svg>'''

    with open('public/favicon.svg', 'w') as f:
        f.write(favicon_svg)

    print("Generated public/favicon.svg with dynamic dark/light CSS support!")
