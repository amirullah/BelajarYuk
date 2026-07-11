"""Ilustrasi khas tiap mata pelajaran (transparan, flat, ceria).
Dibuat sendiri sebagai SVG -> PNG (cairosvg). Dipakai di kartu mapel & peta level."""
import cairosvg, os

# Warna mapel (samakan dg app_colors.dart)
C = dict(math='#FF6B6B', english='#4D96FF', indonesian='#4ECDC4',
         science='#9B72CF', religion='#2EA36B', socialStudies='#B5A72B')

def wrap(inner):
    return f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 240 240">{inner}</svg>'

# ── Matematika: papan angka + simbol ──
MATH = wrap(f'''
  <rect x="44" y="44" width="152" height="152" rx="28" fill="{C['math']}"/>
  <rect x="44" y="44" width="152" height="152" rx="28" fill="#FFFFFF" opacity="0.12"/>
  <text x="90" y="112" font-family="Arial" font-size="52" font-weight="bold" fill="#FFFFFF" text-anchor="middle">+</text>
  <text x="150" y="108" font-family="Arial" font-size="46" font-weight="bold" fill="#FFE08A" text-anchor="middle">×</text>
  <text x="88" y="176" font-family="Arial" font-size="46" font-weight="bold" fill="#FFE08A" text-anchor="middle">−</text>
  <text x="152" y="180" font-family="Arial" font-size="46" font-weight="bold" fill="#FFFFFF" text-anchor="middle">=</text>
  <circle cx="120" cy="120" r="6" fill="#FFFFFF" opacity="0.5"/>
''')

# ── Bahasa Inggris: balon "ABC" ──
ENGLISH = wrap(f'''
  <path d="M40,60 h160 a24,24 0 0 1 24,24 v56 a24,24 0 0 1 -24,24 h-96 l-34,30 v-30 h-30 a24,24 0 0 1 -24,-24 v-56 a24,24 0 0 1 24,-24 Z" fill="{C['english']}"/>
  <text x="120" y="130" font-family="Arial" font-size="58" font-weight="bold" fill="#FFFFFF" text-anchor="middle">ABC</text>
''')

# ── Bahasa Indonesia: buku terbuka + huruf ──
INDO = wrap(f'''
  <path d="M120,70 C96,54 60,54 40,64 L40,180 C60,170 96,170 120,186 C144,170 180,170 200,180 L200,64 C180,54 144,54 120,70 Z" fill="{C['indonesian']}"/>
  <path d="M120,70 L120,186" stroke="#FFFFFF" stroke-width="6" opacity="0.7"/>
  <text x="80" y="130" font-family="Arial" font-size="34" font-weight="bold" fill="#FFFFFF" text-anchor="middle">Aa</text>
  <text x="160" y="130" font-family="Arial" font-size="34" font-weight="bold" fill="#FFFFFF" text-anchor="middle">Bb</text>
''')

# ── Sains: tabung erlenmeyer + gelembung ──
SCIENCE = wrap(f'''
  <path d="M104,56 h32 v46 l40,74 a16,16 0 0 1 -14,24 h-84 a16,16 0 0 1 -14,-24 l40,-74 Z" fill="{C['science']}"/>
  <path d="M100,120 h40 l24,44 a10,10 0 0 1 -9,15 h-70 a10,10 0 0 1 -9,-15 Z" fill="#C9E7FF" opacity="0.9"/>
  <rect x="100" y="48" width="40" height="14" rx="7" fill="#7A56A6"/>
  <circle cx="110" cy="150" r="7" fill="#FFFFFF" opacity="0.9"/>
  <circle cx="132" cy="162" r="5" fill="#FFFFFF" opacity="0.9"/>
  <circle cx="150" cy="96" r="6" fill="{C['science']}"/>
  <circle cx="92" cy="86" r="5" fill="{C['science']}"/>
''')

# ── Agama Islam: masjid (kubah + menara + bulan sabit) ──
RELIGION = wrap(f'''
  <rect x="56" y="120" width="128" height="72" rx="8" fill="{C['religion']}"/>
  <path d="M120,66 C150,66 168,92 168,120 L72,120 C72,92 90,66 120,66 Z" fill="{C['religion']}"/>
  <path d="M120,44 a10,10 0 0 1 0,20 a8,8 0 0 0 0,-20 Z" fill="#FFC93C"/>
  <rect x="46" y="96" width="14" height="96" rx="6" fill="#25865A"/>
  <rect x="180" y="96" width="14" height="96" rx="6" fill="#25865A"/>
  <rect x="108" y="150" width="24" height="42" rx="12" fill="#FFFFFF" opacity="0.85"/>
''')

# ── IPS: bola dunia ──
SOCIAL = wrap(f'''
  <circle cx="120" cy="120" r="74" fill="{C['socialStudies']}"/>
  <ellipse cx="120" cy="120" rx="30" ry="74" fill="none" stroke="#FFFFFF" stroke-width="5" opacity="0.8"/>
  <line x1="46" y1="120" x2="194" y2="120" stroke="#FFFFFF" stroke-width="5" opacity="0.8"/>
  <path d="M92,90 q20,-14 40,-4 q-6,20 -30,22 q-14,-6 -10,-18 Z" fill="#EAF3C7"/>
  <path d="M132,140 q22,-6 30,10 q-10,16 -34,10 q-6,-14 4,-20 Z" fill="#EAF3C7"/>
''')

ART = dict(math=MATH, english=ENGLISH, indonesian=INDO, science=SCIENCE,
           religion=RELIGION, socialStudies=SOCIAL)

out = os.path.dirname(os.path.abspath(__file__)) + '/subjects/'
os.makedirs(out, exist_ok=True)
for name, svg in ART.items():
    cairosvg.svg2png(bytestring=svg.encode(), write_to=out+f'subj_{name}.png',
                     output_width=240, output_height=240)
    print(f'subj_{name}.png', os.path.getsize(out+f'subj_{name}.png'), 'bytes')
