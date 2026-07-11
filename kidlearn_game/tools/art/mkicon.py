import cairosvg

# Ikon: kotak membulat gradasi ungu + buku terbuka putih + bintang kuning + kilau.
FG = '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1024 1024">
  <!-- bintang di atas -->
  <g transform="translate(512 300)">
    <path d="M0,-120 L34,-38 L122,-38 L52,12 L78,96 L0,44 L-78,96 L-52,12 L-122,-38 L-34,-38 Z"
          fill="#FFC93C" stroke="#F5A623" stroke-width="6" stroke-linejoin="round"/>
  </g>
  <!-- kilau kecil -->
  <circle cx="660" cy="250" r="16" fill="#FFFFFF" opacity="0.9"/>
  <circle cx="360" cy="220" r="10" fill="#FFFFFF" opacity="0.8"/>
  <!-- buku terbuka -->
  <g transform="translate(512 640)">
    <path d="M-260,-40 C-160,-90 -40,-90 0,-50 C40,-90 160,-90 260,-40 L260,150 C160,110 40,110 0,150 C-40,110 -160,110 -260,150 Z"
          fill="#FFFFFF"/>
    <path d="M0,-50 L0,150" stroke="#E0DEF7" stroke-width="10"/>
    <path d="M-210,-20 C-140,-52 -60,-52 -20,-28" stroke="#C9C6EF" stroke-width="9" fill="none" stroke-linecap="round"/>
    <path d="M-210,20 C-140,-12 -60,-12 -20,12" stroke="#C9C6EF" stroke-width="9" fill="none" stroke-linecap="round"/>
    <path d="M-210,60 C-140,28 -60,28 -20,52" stroke="#C9C6EF" stroke-width="9" fill="none" stroke-linecap="round"/>
    <path d="M210,-20 C140,-52 60,-52 20,-28" stroke="#C9C6EF" stroke-width="9" fill="none" stroke-linecap="round"/>
    <path d="M210,20 C140,-12 60,-12 20,12" stroke="#C9C6EF" stroke-width="9" fill="none" stroke-linecap="round"/>
    <path d="M210,60 C140,28 60,28 20,52" stroke="#C9C6EF" stroke-width="9" fill="none" stroke-linecap="round"/>
  </g>
</svg>'''

BG = '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1024 1024">
  <defs><linearGradient id="g" x1="0" y1="0" x2="1" y2="1">
    <stop offset="0" stop-color="#6C63FF"/><stop offset="1" stop-color="#3B37C8"/>
  </linearGradient></defs>
  <rect width="1024" height="1024" fill="url(#g)"/>
</svg>'''

# Ikon penuh (legacy) = bg + fg dengan sudut membulat
FULL = '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1024 1024">
  <defs><linearGradient id="g" x1="0" y1="0" x2="1" y2="1">
    <stop offset="0" stop-color="#6C63FF"/><stop offset="1" stop-color="#3B37C8"/>
  </linearGradient>
  <clipPath id="r"><rect width="1024" height="1024" rx="220"/></clipPath></defs>
  <g clip-path="url(#r)"><rect width="1024" height="1024" fill="url(#g)"/>''' + FG.split('>',1)[1].rsplit('</svg>',1)[0] + '''</g>
</svg>'''

out = '/tmp/claude-0/-home-user-coba-code/6f97f542-f03f-5654-a5dd-14cf2e5f0e15/scratchpad/art/'
cairosvg.svg2png(bytestring=FULL.encode(), write_to=out+'icon.png', output_width=1024, output_height=1024)
cairosvg.svg2png(bytestring=FG.encode(), write_to=out+'icon_fg.png', output_width=1024, output_height=1024)
cairosvg.svg2png(bytestring=BG.encode(), write_to=out+'icon_bg.png', output_width=1024, output_height=1024)
import os
for f in ['icon.png','icon_fg.png','icon_bg.png']:
    print(f, os.path.getsize(out+f), 'bytes')
