"""Ikon aplikasi BelajarYuk! — maskot burung hantu "Uku" yang lucu
di atas latar biru ceria. Semua dibuat sendiri (SVG -> PNG via cairosvg)."""
import cairosvg, os

# Maskot burung hantu (dipakai juga sebagai ikon) — versi ringkas & terpusat.
OWL = '''
  <!-- sayap -->
  <path d="M150,470 C110,500 110,590 170,610 C180,550 180,500 190,480 Z" fill="#1B6FE0"/>
  <path d="M562,470 C602,500 602,590 542,610 C532,550 532,500 522,480 Z" fill="#1B6FE0"/>
  <!-- badan -->
  <path d="M356,300 C250,300 205,395 205,485 C205,600 275,685 356,685
           C437,685 507,600 507,485 C507,395 462,300 356,300 Z" fill="url(#body)"/>
  <!-- perut -->
  <path d="M356,420 C300,420 272,465 272,525 C272,595 312,640 356,640
           C400,640 440,595 440,525 C440,465 412,420 356,420 Z" fill="#FFFFFF"/>
  <!-- jambul -->
  <path d="M262,330 C250,290 280,278 302,308 C290,320 274,330 262,330 Z" fill="#1B6FE0"/>
  <path d="M450,330 C462,290 432,278 410,308 C422,320 438,330 450,330 Z" fill="#1B6FE0"/>
  <!-- mata besar lucu -->
  <circle cx="300" cy="425" r="66" fill="#FFFFFF"/>
  <circle cx="412" cy="425" r="66" fill="#FFFFFF"/>
  <circle cx="304" cy="432" r="36" fill="#2D3A66"/>
  <circle cx="408" cy="432" r="36" fill="#2D3A66"/>
  <circle cx="316" cy="421" r="13" fill="#FFFFFF"/>
  <circle cx="420" cy="421" r="13" fill="#FFFFFF"/>
  <!-- paruh -->
  <path d="M356,458 L336,486 L376,486 Z" fill="#FFB43C" stroke="#F5992A" stroke-width="3" stroke-linejoin="round"/>
  <!-- pipi merona -->
  <circle cx="256" cy="500" r="17" fill="#FF8FB1" opacity="0.6"/>
  <circle cx="456" cy="500" r="17" fill="#FF8FB1" opacity="0.6"/>
  <!-- kaki -->
  <path d="M325,678 l-9,22 M335,682 l-2,22 M345,678 l6,22" stroke="#FFB43C" stroke-width="7" stroke-linecap="round" fill="none"/>
  <path d="M387,678 l9,22 M377,682 l2,22 M367,678 l-6,22" stroke="#FFB43C" stroke-width="7" stroke-linecap="round" fill="none"/>
  <!-- bintang & kilau -->
  <g transform="translate(520 330) scale(0.7)">
    <path d="M0,-30 L9,-9 L31,-9 L13,4 L20,26 L0,12 L-20,26 L-13,4 L-31,-9 L-9,-9 Z"
          fill="#FFC93C" stroke="#F5A623" stroke-width="3" stroke-linejoin="round"/>
  </g>
  <circle cx="205" cy="360" r="10" fill="#FFC93C"/>
  <circle cx="170" cy="300" r="7" fill="#FFFFFF" opacity="0.9"/>
'''

DEFS = '''<defs>
    <linearGradient id="bg" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0" stop-color="#5AA0FF"/><stop offset="1" stop-color="#1B5FD9"/>
    </linearGradient>
    <linearGradient id="body" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0" stop-color="#7FB4FF"/><stop offset="1" stop-color="#4D96FF"/>
    </linearGradient>
  </defs>'''

# Ikon penuh (legacy): latar biru membulat + owl
FULL = f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 712 712">
  {DEFS}
  <clipPath id="r"><rect width="712" height="712" rx="150"/></clipPath>
  <g clip-path="url(#r)">
    <rect width="712" height="712" fill="url(#bg)"/>
    <!-- cakram putih agar maskot kontras dengan latar biru -->
    <circle cx="356" cy="356" r="250" fill="#FFFFFF"/>
    <circle cx="356" cy="356" r="250" fill="none" stroke="#FFC93C" stroke-width="14"/>
    <g transform="translate(356 356) scale(0.82) translate(-356 -500)">
      {OWL}
    </g>
  </g>
</svg>'''

# Foreground adaptive: owl saja (tanpa latar) — diperkecil agar aman di zona aman
FG = f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 712 712">
  {DEFS}
  <circle cx="356" cy="356" r="205" fill="#FFFFFF"/>
  <circle cx="356" cy="356" r="205" fill="none" stroke="#FFC93C" stroke-width="12"/>
  <g transform="translate(356 356) scale(0.66) translate(-356 -500)">
    {OWL}
  </g>
</svg>'''

# Background adaptive: gradasi biru polos
BG = '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 712 712">
  <defs><linearGradient id="bg" x1="0" y1="0" x2="1" y2="1">
    <stop offset="0" stop-color="#5AA0FF"/><stop offset="1" stop-color="#1B5FD9"/>
  </linearGradient></defs>
  <rect width="712" height="712" fill="url(#bg)"/>
</svg>'''

out = os.path.dirname(os.path.abspath(__file__)) + '/'
cairosvg.svg2png(bytestring=FULL.encode(), write_to=out+'icon.png', output_width=1024, output_height=1024)
cairosvg.svg2png(bytestring=FG.encode(), write_to=out+'icon_fg.png', output_width=1024, output_height=1024)
cairosvg.svg2png(bytestring=BG.encode(), write_to=out+'icon_bg.png', output_width=1024, output_height=1024)
for f in ['icon.png','icon_fg.png','icon_bg.png']:
    print(f, os.path.getsize(out+f), 'bytes')
