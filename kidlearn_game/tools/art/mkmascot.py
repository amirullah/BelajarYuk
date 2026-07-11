"""Maskot BelajarYuk! — burung hantu ceria (lambang belajar) memegang pensil.
Disintesis sendiri sebagai SVG lalu dirender ke PNG transparan via cairosvg."""
import cairosvg, os

OWL = '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512">
  <defs>
    <linearGradient id="body" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0" stop-color="#5AA0FF"/><stop offset="1" stop-color="#2B7FFF"/>
    </linearGradient>
    <linearGradient id="belly" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0" stop-color="#FFFFFF"/><stop offset="1" stop-color="#E6F1FF"/>
    </linearGradient>
  </defs>

  <!-- bayangan lembut -->
  <ellipse cx="256" cy="470" rx="120" ry="20" fill="#000000" opacity="0.08"/>

  <!-- sayap kiri & kanan -->
  <path d="M120,240 C80,270 80,360 140,380 C150,320 150,270 160,250 Z" fill="#1B6FE0"/>
  <path d="M392,240 C432,270 432,360 372,380 C362,320 362,270 352,250 Z" fill="#1B6FE0"/>

  <!-- badan -->
  <path d="M256,110 C160,110 120,190 120,270 C120,370 180,440 256,440
           C332,440 392,370 392,270 C392,190 352,110 256,110 Z" fill="url(#body)"/>

  <!-- perut -->
  <path d="M256,220 C205,220 180,260 180,315 C180,375 215,415 256,415
           C297,415 332,375 332,315 C332,260 307,220 256,220 Z" fill="url(#belly)"/>

  <!-- jambul/telinga -->
  <path d="M170,140 C160,105 185,95 205,120 C195,130 180,140 170,140 Z" fill="#1B6FE0"/>
  <path d="M342,140 C352,105 327,95 307,120 C317,130 332,140 342,140 Z" fill="#1B6FE0"/>

  <!-- mata (piringan) -->
  <circle cx="205" cy="230" r="62" fill="#FFFFFF"/>
  <circle cx="307" cy="230" r="62" fill="#FFFFFF"/>
  <circle cx="205" cy="235" r="34" fill="#2D2A55"/>
  <circle cx="307" cy="235" r="34" fill="#2D2A55"/>
  <circle cx="216" cy="225" r="12" fill="#FFFFFF"/>
  <circle cx="318" cy="225" r="12" fill="#FFFFFF"/>
  <circle cx="198" cy="246" r="6" fill="#FFFFFF" opacity="0.8"/>
  <circle cx="300" cy="246" r="6" fill="#FFFFFF" opacity="0.8"/>

  <!-- paruh -->
  <path d="M256,258 L238,285 L274,285 Z" fill="#FFB43C" stroke="#F5992A" stroke-width="3" stroke-linejoin="round"/>

  <!-- pipi merona -->
  <circle cx="160" cy="300" r="16" fill="#FF8FB1" opacity="0.55"/>
  <circle cx="352" cy="300" r="16" fill="#FF8FB1" opacity="0.55"/>

  <!-- kaki -->
  <path d="M225,432 l-10,22 M235,436 l-2,22 M245,432 l6,22" stroke="#FFB43C" stroke-width="7" stroke-linecap="round" fill="none"/>
  <path d="M287,432 l10,22 M277,436 l2,22 M267,432 l-6,22" stroke="#FFB43C" stroke-width="7" stroke-linecap="round" fill="none"/>

  <!-- pensil di sayap kanan -->
  <g transform="rotate(28 372 340)">
    <rect x="352" y="300" width="26" height="120" rx="6" fill="#FFD24C"/>
    <rect x="352" y="300" width="26" height="16" fill="#FF7B54"/>
    <path d="M352,420 L365,448 L378,420 Z" fill="#F3E2C7"/>
    <path d="M359,438 L365,448 L371,438 Z" fill="#3A3A3A"/>
  </g>

  <!-- bintang kecil dekat kepala -->
  <g transform="translate(400 150) scale(0.5)">
    <path d="M0,-30 L9,-9 L31,-9 L13,4 L20,26 L0,12 L-20,26 L-13,4 L-31,-9 L-9,-9 Z" fill="#FFC93C"/>
  </g>
  <circle cx="110" cy="170" r="7" fill="#FFC93C"/>
</svg>'''

out = os.path.dirname(os.path.abspath(__file__)) + '/'
cairosvg.svg2png(bytestring=OWL.encode(), write_to=out+'mascot.png',
                 output_width=512, output_height=512)
print('mascot.png', os.path.getsize(out+'mascot.png'), 'bytes')
