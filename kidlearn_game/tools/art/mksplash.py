import cairosvg, os

# Logo splash: mark (bintang kuning + buku putih) di atas latar transparan,
# untuk ditaruh di tengah splash ungu oleh flutter_native_splash.
SPLASH = '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512">
  <!-- bintang -->
  <g transform="translate(256 150)">
    <path d="M0,-92 L26,-29 L94,-29 L40,9 L60,74 L0,34 L-60,74 L-40,9 L-94,-29 L-26,-29 Z"
          fill="#FFC93C" stroke="#F5A623" stroke-width="5" stroke-linejoin="round"/>
  </g>
  <circle cx="356" cy="120" r="11" fill="#FFFFFF" opacity="0.9"/>
  <circle cx="168" cy="100" r="7" fill="#FFFFFF" opacity="0.8"/>
  <!-- buku terbuka -->
  <g transform="translate(256 330)">
    <path d="M-200,-30 C-124,-70 -30,-70 0,-38 C30,-70 124,-70 200,-30 L200,116 C124,84 30,84 0,116 C-30,84 -124,84 -200,116 Z"
          fill="#FFFFFF"/>
    <path d="M0,-38 L0,116" stroke="#D8D5F5" stroke-width="8"/>
    <path d="M-160,-14 C-108,-40 -46,-40 -16,-22" stroke="#B9B5EC" stroke-width="7" fill="none" stroke-linecap="round"/>
    <path d="M-160,20 C-108,-6 -46,-6 -16,12" stroke="#B9B5EC" stroke-width="7" fill="none" stroke-linecap="round"/>
    <path d="M-160,54 C-108,28 -46,28 -16,46" stroke="#B9B5EC" stroke-width="7" fill="none" stroke-linecap="round"/>
    <path d="M160,-14 C108,-40 46,-40 16,-22" stroke="#B9B5EC" stroke-width="7" fill="none" stroke-linecap="round"/>
    <path d="M160,20 C108,-6 46,-6 16,12" stroke="#B9B5EC" stroke-width="7" fill="none" stroke-linecap="round"/>
    <path d="M160,54 C108,28 46,28 16,46" stroke="#B9B5EC" stroke-width="7" fill="none" stroke-linecap="round"/>
  </g>
</svg>'''

out = os.path.dirname(__file__) + '/'
cairosvg.svg2png(bytestring=SPLASH.encode(), write_to=out+'splash.png', output_width=1024, output_height=1024)
print('splash.png', os.path.getsize(out+'splash.png'), 'bytes')
