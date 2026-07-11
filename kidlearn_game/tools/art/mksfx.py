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
    y = np.clip(y, -1, 1)
    # sedikit fade global agar tak ada klik
    audio = (y * 32767 * 0.9).astype(np.int16)
    wavfile.write(OUT+name, SR, audio)
    print(name, len(audio), 'samples', os.path.getsize(OUT+name), 'bytes')

# Nada C mayor (Hz)
C5, D5, E5, F5, G5, A5, B5, C6, E6, G6 = 523, 587, 659, 698, 784, 880, 988, 1047, 1319, 1568

# ── BENAR: arpeggio naik ceria (ting-ting-ting) ──
save('correct.wav', seq([(E5,0.09,0.5),(G5,0.09,0.5),(C6,0.16,0.55)]))

# ── SALAH: dua nada turun lembut (bukan kasar, biar tidak bikin sedih) ──
save('wrong.wav', seq([(392,0.12,0.4),(311,0.18,0.38)]))  # G4 -> Eb4

# ── TAP/pilih: klik pendek ──
save('tap.wav', tone(660, 0.05, 0.35, wave='tri'))

# ── BINTANG didapat: kilau naik ──
save('star.wav', glide(700, 1600, 0.28, 0.5) + 0.3*tone(C6,0.28,0.3))

# ── KOIN: dua ting cepat ──
save('coin.wav', seq([(A5,0.05,0.45),(E6,0.12,0.5)]))

# ── LEVEL SELESAI / naik level: fanfare pendek ──
fan = np.concatenate([
    seq([(C5,0.12,0.5),(E5,0.12,0.5),(G5,0.12,0.5)]),
    chord([C6,E6,G6],0.45,0.5),
])
save('levelup.wav', fan)

# ── SEMPURNA (3 bintang): fanfare lebih megah ──
perfect = np.concatenate([
    seq([(G5,0.1,0.5),(C6,0.1,0.5),(E6,0.1,0.5)]),
    chord([C6,E6,G6],0.3,0.45),
    chord([C6,E6,G6*1.0],0.5,0.5),
])
save('perfect.wav', perfect)

# ── NAIK KELAS (boss lulus): fanfare paling megah + drum ──
def _kick(dur=0.16, vol=0.6):
    n=int(SR*dur); t=np.arange(n)/SR
    f=120*np.exp(-t*22)+50
    return np.sin(2*np.pi*np.cumsum(f)/SR)*np.exp(-t*9)*vol
def _roll(dur=0.5, vol=0.3):
    n=int(SR*dur)
    return (np.random.RandomState(3).randn(n)*np.linspace(0.2,1,n)
            *np.exp(-np.arange(n)/SR*2)*vol)
C7 = 2093
_grad = [ _roll(0.5) ]
for f in [C5, E5, G5, C6, E6, G6]:
    _grad.append(tone(f, 0.13, 0.5))
_big = chord([C6,E6,G6], 0.4, 0.55); _big[:len(_kick())] += _kick()
_grad.append(_big)
_big2 = chord([C6,E6,G6,C7], 0.7, 0.6); _big2[:len(_kick())] += _kick()
_grad.append(_big2)
save('graduation.wav', np.concatenate(_grad))

print('\nSelesai. SFX di', OUT)
