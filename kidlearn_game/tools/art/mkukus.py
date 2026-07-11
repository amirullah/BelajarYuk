# -*- coding: utf-8 -*-
"""Varian ekspresi maskot Uku (burung hantu) — untuk maskot interaktif.
happy / wink / cheer / surprised / love. Transparan, dibuat sendiri (SVG->PNG)."""
import cairosvg, os

DEFS = '''<defs>
  <linearGradient id="body" x1="0" y1="0" x2="0" y2="1">
    <stop offset="0" stop-color="#5AA0FF"/><stop offset="1" stop-color="#2B7FFF"/>
  </linearGradient>
  <linearGradient id="belly" x1="0" y1="0" x2="0" y2="1">
    <stop offset="0" stop-color="#FFFFFF"/><stop offset="1" stop-color="#E6F1FF"/>
  </linearGradient>
</defs>'''

# Bagian dasar (tanpa mata/paruh/ekstra) — dipakai semua ekspresi.
def base(wings_up=False):
    if wings_up:
        wl = '<path d="M120,210 C70,180 60,120 110,120 C120,170 140,200 160,235 Z" fill="#1B6FE0"/>'
        wr = '<path d="M392,210 C442,180 452,120 402,120 C392,170 372,200 352,235 Z" fill="#1B6FE0"/>'
    else:
        wl = '<path d="M120,240 C80,270 80,360 140,380 C150,320 150,270 160,250 Z" fill="#1B6FE0"/>'
        wr = '<path d="M392,240 C432,270 432,360 372,380 C362,320 362,270 352,250 Z" fill="#1B6FE0"/>'
    return f'''
  <ellipse cx="256" cy="470" rx="120" ry="20" fill="#000000" opacity="0.08"/>
  {wl}{wr}
  <path d="M256,110 C160,110 120,190 120,270 C120,370 180,440 256,440
           C332,440 392,370 392,270 C392,190 352,110 256,110 Z" fill="url(#body)"/>
  <path d="M256,220 C205,220 180,260 180,315 C180,375 215,415 256,415
           C297,415 332,375 332,315 C332,260 307,220 256,220 Z" fill="url(#belly)"/>
  <path d="M170,140 C160,105 185,95 205,120 C195,130 180,140 170,140 Z" fill="#1B6FE0"/>
  <path d="M342,140 C352,105 327,95 307,120 C317,130 332,140 342,140 Z" fill="#1B6FE0"/>
  <circle cx="160" cy="300" r="16" fill="#FF8FB1" opacity="0.55"/>
  <circle cx="352" cy="300" r="16" fill="#FF8FB1" opacity="0.55"/>
  <path d="M225,432 l-10,22 M235,436 l-2,22 M245,432 l6,22" stroke="#FFB43C" stroke-width="7" stroke-linecap="round" fill="none"/>
  <path d="M287,432 l10,22 M277,436 l2,22 M267,432 l-6,22" stroke="#FFB43C" stroke-width="7" stroke-linecap="round" fill="none"/>'''

EYES = {
  'happy': '''
    <circle cx="205" cy="230" r="62" fill="#FFFFFF"/><circle cx="307" cy="230" r="62" fill="#FFFFFF"/>
    <circle cx="205" cy="235" r="34" fill="#2D2A55"/><circle cx="307" cy="235" r="34" fill="#2D2A55"/>
    <circle cx="216" cy="225" r="12" fill="#FFFFFF"/><circle cx="318" cy="225" r="12" fill="#FFFFFF"/>
    <path d="M256,258 L238,285 L274,285 Z" fill="#FFB43C" stroke="#F5992A" stroke-width="3" stroke-linejoin="round"/>''',
  'wink': '''
    <circle cx="205" cy="230" r="62" fill="#FFFFFF"/><circle cx="307" cy="230" r="62" fill="#FFFFFF"/>
    <circle cx="205" cy="235" r="34" fill="#2D2A55"/><circle cx="216" cy="225" r="12" fill="#FFFFFF"/>
    <path d="M280,232 Q307,210 334,232" stroke="#2D2A55" stroke-width="10" fill="none" stroke-linecap="round"/>
    <path d="M256,258 L238,285 L274,285 Z" fill="#FFB43C" stroke="#F5992A" stroke-width="3" stroke-linejoin="round"/>''',
  'cheer': '''
    <path d="M178,242 Q205,206 232,242" stroke="#2D2A55" stroke-width="11" fill="none" stroke-linecap="round"/>
    <path d="M280,242 Q307,206 334,242" stroke="#2D2A55" stroke-width="11" fill="none" stroke-linecap="round"/>
    <ellipse cx="256" cy="278" rx="18" ry="22" fill="#E96A6A"/>
    <path d="M238,268 Q256,258 274,268" fill="#FFB43C"/>''',
  'surprised': '''
    <circle cx="205" cy="228" r="64" fill="#FFFFFF"/><circle cx="307" cy="228" r="64" fill="#FFFFFF"/>
    <circle cx="205" cy="230" r="22" fill="#2D2A55"/><circle cx="307" cy="230" r="22" fill="#2D2A55"/>
    <circle cx="212" cy="222" r="7" fill="#FFFFFF"/><circle cx="314" cy="222" r="7" fill="#FFFFFF"/>
    <ellipse cx="256" cy="280" rx="15" ry="18" fill="#E96A6A"/>''',
  'love': '''
    <path d="M205,210 c-16,-18 -44,-4 -30,18 c8,14 30,26 30,26 c0,0 22,-12 30,-26 c14,-22 -14,-36 -30,-18 Z" fill="#FF6B8A"/>
    <path d="M307,210 c-16,-18 -44,-4 -30,18 c8,14 30,26 30,26 c0,0 22,-12 30,-26 c14,-22 -14,-36 -30,-18 Z" fill="#FF6B8A"/>
    <path d="M256,262 L240,286 L272,286 Z" fill="#FFB43C" stroke="#F5992A" stroke-width="3" stroke-linejoin="round"/>''',
}
EXTRA = {
  'cheer': '<g transform="translate(410 150) scale(0.7)"><path d="M0,-30 L9,-9 L31,-9 L13,4 L20,26 L0,12 L-20,26 L-13,4 L-31,-9 L-9,-9 Z" fill="#FFC93C" stroke="#F5A623" stroke-width="3" stroke-linejoin="round"/></g><circle cx="110" cy="170" r="8" fill="#FFC93C"/>',
}
WINGS_UP = {'cheer'}

def build(expr):
    return (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512">{DEFS}'
            + base(expr in WINGS_UP) + EYES[expr] + EXTRA.get(expr, '') + '</svg>')

out = os.path.dirname(os.path.abspath(__file__)) + '/ukus/'
os.makedirs(out, exist_ok=True)
for e in EYES:
    cairosvg.svg2png(bytestring=build(e).encode(), write_to=out+f'uku_{e}.png',
                     output_width=400, output_height=400)
    print(f'uku_{e}.png', os.path.getsize(out+f'uku_{e}.png'), 'bytes')
