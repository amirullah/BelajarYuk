"""Musik latar ceria untuk anak — disintesis sendiri (numpy).
Progresi I–V–vi–IV (C–G–Am–F) yang riang, tempo ~100 BPM, nada lembut
seperti mainan/glockenspiel + bass empuk. Loop mulus (~19 detik)."""
import numpy as np
from scipy.io import wavfile
import os

SR = 22050  # cukup untuk musik latar lembut & muat di batas SoundPool (~1MB)
BPM = 100
BEAT = 60.0 / BPM          # detik per ketuk
BAR = 4 * BEAT             # 4 ketuk per bar

def note_hz(semitone_from_a4):
    return 440.0 * 2 ** (semitone_from_a4 / 12.0)

# Peta nama -> semitone relatif A4
NAMES = {'C':-9,'C#':-8,'D':-7,'D#':-6,'E':-5,'F':-4,'F#':-3,'G':-2,'G#':-1,
         'A':0,'A#':1,'B':2}
def hz(name, octave):
    return note_hz(NAMES[name] + (octave-4)*12)

def adsr(n, a=0.01, d=0.1, s=0.6, r=0.2):
    a,d,r = int(a*SR), int(d*SR), int(r*SR)
    a=max(a,1); d=max(d,1); r=max(r,1)
    if a+d+r > n:
        a=max(n//8,1); d=max(n//8,1); r=max(n//4,1)
    sus = max(n-a-d-r, 0)
    env = np.concatenate([
        np.linspace(0,1,a),
        np.linspace(1,s,d),
        np.full(sus, s),
        np.linspace(s,0,r),
    ])
    if len(env) < n: env = np.pad(env,(0,n-len(env)),constant_values=0)
    return env[:n]

def bell(freq, dur, vol=0.3):
    """Nada lembut seperti glockenspiel/mainan (sine + harmonik + sedikit vibrato)."""
    n = int(dur*SR); t = np.arange(n)/SR
    vib = 1 + 0.004*np.sin(2*np.pi*5*t)
    y = (np.sin(2*np.pi*freq*t*vib)
         + 0.5*np.sin(2*np.pi*2*freq*t)
         + 0.25*np.sin(2*np.pi*3*freq*t)
         + 0.12*np.sin(2*np.pi*4*freq*t))
    return y*adsr(n, a=0.005, d=0.25, s=0.25, r=0.35)*vol

def pad(freq, dur, vol=0.12):
    """Bantalan hangat (triangle-ish) untuk mengisi akor."""
    n = int(dur*SR); t = np.arange(n)/SR
    y = (2/np.pi*np.arcsin(np.sin(2*np.pi*freq*t))
         + 0.3*np.sin(2*np.pi*freq*t))
    return y*adsr(n, a=0.08, d=0.2, s=0.7, r=0.4)*vol

def bass(freq, dur, vol=0.22):
    n = int(dur*SR); t = np.arange(n)/SR
    y = np.sin(2*np.pi*freq*t) + 0.2*np.sin(2*np.pi*2*freq*t)
    return y*adsr(n, a=0.01, d=0.15, s=0.6, r=0.15)*vol

track = np.zeros(0)

def place(buf, sound, at):
    """Tempel `sound` ke `buf` pada sampel `at` (perpanjang bila perlu)."""
    end = at + len(sound)
    if end > len(buf):
        buf = np.pad(buf, (0, end-len(buf)))
    buf[at:end] += sound
    return buf

# Progresi akor: C, G, Am, F  (masing-masing 1 bar), diulang 4x = 16 bar
prog = [
    ('C', ['C','E','G'], 3),
    ('G', ['G','B','D'], 3),
    ('A', ['A','C','E'], 3),   # Am
    ('F', ['F','A','C'], 3),
]
# Melodi sederhana per bar (nama, oktaf, mulai-ketuk, panjang-ketuk)
melodies = [
    [('E',5,0,1),('G',5,1,1),('C',6,2,1.5),('G',5,3,1)],
    [('D',5,0,1),('G',5,1,1),('B',5,2,1.5),('D',6,3,1)],
    [('C',5,0,1),('E',5,1,1),('A',5,2,1.5),('E',5,3,1)],
    [('C',5,0,1),('F',5,1,1),('A',5,2,1.5),('C',6,3,1)],
]

total_bars = 8  # 8 bar = ~19 dtk, loop 2 putaran progresi
buf = np.zeros(int(BAR*total_bars*SR)+SR)

for bar in range(total_bars):
    root_name, chord_notes, chord_oct = prog[bar % 4]
    bar_start = int(bar*BAR*SR)
    # Bass: root tiap setengah bar
    for k in (0,2):
        buf = place(buf, bass(hz(root_name, 2), BEAT*2), bar_start+int(k*BEAT*SR))
    # Pad: akor ditahan sepanjang bar
    for nm in chord_notes:
        buf = place(buf, pad(hz(nm, chord_oct), BAR*0.98), bar_start)
    # Melodi glockenspiel
    for nm, octv, start, length in melodies[bar % 4]:
        at = bar_start + int(start*BEAT*SR)
        buf = place(buf, bell(hz(nm, octv), BEAT*length), at)

# Normalisasi & buat loop mulus (sedikit fade di ujung yang tumpang-tindih)
buf = buf[:int(BAR*total_bars*SR)]
peak = np.max(np.abs(buf)) or 1
buf = buf/peak*0.85
audio = (buf*32767).astype(np.int16)

out = os.path.dirname(os.path.abspath(__file__))+'/sfx/'
os.makedirs(out, exist_ok=True)
wavfile.write(out+'bg_music.wav', SR, audio)
print('bg_music.wav', round(len(buf)/SR,1),'dtk', os.path.getsize(out+'bg_music.wav'),'bytes')
