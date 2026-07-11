"""Generate cheerful, kid-friendly sound effects as 16-bit mono WAV.
No external audio tools needed — pure numpy + scipy.io.wavfile."""
import numpy as np
from scipy.io import wavfile
import os

SR = 44100
OUT = os.path.dirname(os.path.abspath(__file__)) + '/sfx/'
os.makedirs(OUT, exist_ok=True)

def env(n, attack=0.01, release=0.08):
    """Simple attack/decay envelope over n samples."""
    e = np.ones(n)
    a = int(SR * attack)
    r = int(SR * release)
    if a + r > n:  # sound pendek: bagi rata
        a = min(a, n // 2)
        r = n - a
    if a > 0:
        e[:a] = np.linspace(0, 1, a)
    if r > 0:
        e[-r:] = np.linspace(1, 0, r)
    return e

def tone(freq, dur, vol=0.5, wave='sine', harmonics=True):
    n = int(SR * dur)
    t = np.arange(n) / SR
    if wave == 'sine':
        y = np.sin(2*np.pi*freq*t)
        if harmonics:  # sedikit harmonik → lebih "lonceng"
            y += 0.25*np.sin(2*np.pi*2*freq*t) + 0.12*np.sin(2*np.pi*3*freq*t)
    elif wave == 'square':
        y = np.sign(np.sin(2*np.pi*freq*t))
    elif wave == 'tri':
        y = 2/np.pi*np.arcsin(np.sin(2*np.pi*freq*t))
    y *= env(n) * vol
    return y

def glide(f0, f1, dur, vol=0.5):
    n = int(SR*dur); t = np.arange(n)/SR
    freq = np.linspace(f0, f1, n)
    phase = 2*np.pi*np.cumsum(freq)/SR
    return np.sin(phase)*env(n)*vol

def seq(notes):
    """notes: list of (freq, dur, vol). Concatenate."""
    return np.concatenate([tone(f, d, v) for f, d, v in notes])

def chord(freqs, dur, vol=0.4):
    return sum(tone(f, dur, vol/len(freqs)) for f in freqs)

def save(name, y):
    # Normalisasi ke puncak agar setiap efek nyaring & bersemangat (tidak "lemas").
    peak = np.max(np.abs(y)) or 1
    y = y / peak
    audio = (y * 32767 * 0.97).astype(np.int16)
    wavfile.write(OUT+name, SR, audio)
    print(name, len(audio), 'samples', os.path.getsize(OUT+name), 'bytes')

# Nada C mayor (Hz)
C5, D5, E5, F5, G5, A5, B5, C6, E6, G6 = 523, 587, 659, 698, 784, 880, 988, 1047, 1319, 1568

# ── BENAR: "ta-da!" ceria & nyaring (arpeggio cepat + stab akor + kilau) ──
_c = seq([(E5,0.07,0.6),(G5,0.07,0.6),(C6,0.10,0.7)])
_c = np.concatenate([_c, chord([C6,E6,G6],0.22,0.8)])
_c[:len(glide(1200,2200,0.10,0.25))] += glide(1200,2200,0.10,0.25)  # sparkle di awal
save('correct.wav', _c)

# ── SALAH: dua nada turun lembut (bukan kasar, biar tidak bikin sedih) ──
save('wrong.wav', seq([(392,0.12,0.5),(311,0.18,0.45)]))  # G4 -> Eb4

# ── TAP/pilih: klik pendek ──
save('tap.wav', tone(660, 0.05, 0.5, wave='tri'))

# ── BINTANG didapat: kilau naik ──
save('star.wav', glide(700, 1700, 0.28, 0.6) + 0.35*tone(C6,0.28,0.4))

# ── KOIN: dua ting cepat ──
save('coin.wav', seq([(A5,0.05,0.45),(E6,0.12,0.5)]))

def kick(dur=0.16, vol=0.6):
    n=int(SR*dur); t=np.arange(n)/SR
    f=120*np.exp(-t*22)+50
    return np.sin(2*np.pi*np.cumsum(f)/SR)*np.exp(-t*9)*vol
def roll(dur=0.5, vol=0.35):
    n=int(SR*dur)
    return np.random.RandomState(3).randn(n)*np.linspace(0.2,1,n)*np.exp(-np.arange(n)/SR*2)*vol

# ── LEVEL SELESAI / naik level: fanfare pendek + kick ──
fan = np.concatenate([
    seq([(C5,0.11,0.6),(E5,0.11,0.6),(G5,0.11,0.6)]),
    chord([C6,E6,G6],0.45,0.7),
])
fan[:len(kick())] += kick()
save('levelup.wav', fan)

# ── SEMPURNA (3 bintang): fanfare lebih megah ──
perfect = np.concatenate([
    seq([(G5,0.1,0.6),(C6,0.1,0.6),(E6,0.1,0.6)]),
    chord([C6,E6,G6],0.3,0.6),
    chord([C6,E6,G6],0.55,0.75),
])
perfect[:len(kick())] += kick()
save('perfect.wav', perfect)

# ── NAIK KELAS: fanfare paling megah (drumroll + tangga naik + akor besar) ──
C7 = 2093
_grad = [roll(0.45)]
for f in [C5, E5, G5, C6, E6, G6]:
    _grad.append(tone(f, 0.12, 0.6))
_b1 = chord([C6,E6,G6], 0.4, 0.75); _b1[:len(kick())] += kick()
_grad.append(_b1)
_b2 = chord([C6,E6,G6,C7], 0.7, 0.85); _b2[:len(kick())] += kick()
_grad.append(_b2)
save('graduation.wav', np.concatenate(_grad))

print('\nSelesai. SFX di', OUT)
