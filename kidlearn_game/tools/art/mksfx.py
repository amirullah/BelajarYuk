"""Generate cheerful, kid-friendly sound effects as 16-bit mono WAV.
No external audio tools needed — pure numpy + scipy.io.wavfile + scipy.signal."""
import numpy as np
from scipy.io import wavfile
from scipy import signal as sp
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

def kick(dur=0.16, vol=0.6):
    n=int(SR*dur); t=np.arange(n)/SR
    f=120*np.exp(-t*22)+50
    return np.sin(2*np.pi*np.cumsum(f)/SR)*np.exp(-t*9)*vol

def roll(dur=0.5, vol=0.35):
    n=int(SR*dur)
    return np.random.RandomState(3).randn(n)*np.linspace(0.2,1,n)*np.exp(-np.arange(n)/SR*2)*vol

# ── BENAR: "ta-da!" meriah — arpeggio 5 nada C5→E5→G5→C6→E6 + akor kuat + kilau ──
_arp = seq([(C5,0.06,0.55),(E5,0.06,0.62),(G5,0.07,0.65),(C6,0.08,0.72),(E6,0.06,0.78)])
_stab = chord([C6,E6,G6], 0.38, 0.90)
_stab[:len(kick(dur=0.14))] += kick(dur=0.14)  # pukulan perkusi saat akor masuk
_full = np.concatenate([_arp, _stab])
# Kilau panjang naik mulai dari awal sampai akhir
_sparkle = glide(1200, 3200, len(_full)/SR, 0.22)
_full[:len(_sparkle)] += _sparkle
# Kilau kedua lebih nyaring tepat saat akor masuk
_s2 = glide(2000, 3600, 0.10, 0.18)
_al = len(_arp)
_full[_al:_al+len(_s2)] += _s2
save('correct.wav', _full)

# ── SALAH: dua nada turun lembut (bukan kasar, biar tidak bikin sedih) ──
save('wrong.wav', seq([(392,0.12,0.5),(311,0.18,0.45)]))  # G4 -> Eb4

# ── TAP/pilih: klik pendek ──
save('tap.wav', tone(660, 0.05, 0.5, wave='tri'))

# ── BINTANG didapat: kilau naik ──
save('star.wav', glide(700, 1700, 0.28, 0.6) + 0.35*tone(C6,0.28,0.4))

# ── KOIN: dua ting cepat ──
save('coin.wav', seq([(A5,0.05,0.45),(E6,0.12,0.5)]))

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

# ── UKU: "bloop" lembut & lucu saat maskot disentuh (tidak mengganggu) ──
_ud = 0.20; _un = int(SR*_ud); _ut = np.arange(_un)/SR
_uf = 560 + 260*np.sin(np.pi*_ut/_ud)
_uph = 2*np.pi*np.cumsum(_uf)/SR
save('uku.wav', (np.sin(_uph) + 0.2*np.sin(2*_uph)) * env(_un) * 0.6)

# ── SORAK ANAK: yay1/2/3 — sintesis formant mirip suara anak ceria ──
# Sintesis sumber-filter: deret harmonik pada nada tinggi anak (F0 270–530 Hz)
# dilewatkan melalui filter bandpass resonan di frekuensi formant vokal.
# Ditambah sedikit napas (noise) dan jitter pitch untuk nuansa natural.
def voiced_exclaim(f0_pts, dur, formants, breathiness=0.12, vol=0.60, seed=42):
    """Sintesis formant suara seruan anak.
    f0_pts : float atau list[float] — titik pitch (Hz); list → diinterpolasi linier.
    formants: [(center_hz, bandwidth_hz, gain), ...]
    """
    n = int(SR * dur)
    rng = np.random.RandomState(seed)
    if isinstance(f0_pts, (int, float)):
        f0 = np.full(n, float(f0_pts))
    else:
        pts = np.asarray(f0_pts, dtype=float)
        f0 = np.interp(np.arange(n), np.linspace(0, n - 1, len(pts)), pts)
    # Jitter pitch ±1.2% untuk kesan natural
    f0 = np.abs(f0 + 0.012 * f0 * rng.randn(n))
    # Sumber vokal: deret harmonik rolloff 6 dB/oktav (mirip glottal pulse)
    phase = 2 * np.pi * np.cumsum(f0) / SR
    src = np.zeros(n)
    for h in range(1, 12):
        src += (0.82 ** (h - 1)) * np.sin(h * phase)
    src /= (np.max(np.abs(src)) + 1e-9)
    # Campurkan napas (breathiness)
    src = (1.0 - breathiness) * src + breathiness * rng.randn(n) * 0.8
    # Selubung: serangan cepat, peluruhan alami
    src *= env(n, attack=0.018, release=0.18)
    # Filter formant bandpass
    out = np.zeros(n, dtype=np.float64)
    for (fc, bw, gain) in formants:
        fc = float(min(max(fc, 40.0), SR / 2.0 - 40.0))
        half = min(bw / 2.0, fc * 0.45)
        lo, hi = max(fc - half, 20.0), min(fc + half, SR / 2.0 - 20.0)
        if hi <= lo + 5:
            out += gain * src
            continue
        try:
            sos = sp.butter(2, [lo, hi], btype='bandpass', fs=SR, output='sos')
            out += gain * sp.sosfilt(sos, src)
        except Exception:
            out += gain * src
    return out * vol

# yay1 — vokal "ii" cerah: seperti "Yee!" — pitch naik tajam (320→530 Hz)
save('yay1.wav', voiced_exclaim(
    [320, 530], 0.38,
    [(370, 85, 0.75), (2200, 140, 1.0), (2900, 110, 0.45)],
    breathiness=0.10, seed=11,
))

# yay2 — vokal "a" hangat & terbuka: seperti "Waah!" / "Yaaay!" (285→440 Hz)
save('yay2.wav', voiced_exclaim(
    [285, 440], 0.42,
    [(800, 115, 1.0), (1300, 130, 0.85), (2600, 100, 0.30)],
    breathiness=0.13, seed=22,
))

# yay3 — vokal "u" bulat & seru: seperti "Woo-hoo!" — pitch naik lalu turun (270→440→380 Hz)
save('yay3.wav', voiced_exclaim(
    [270, 440, 380], 0.46,
    [(310, 80, 0.85), (820, 105, 0.95), (2100, 80, 0.22)],
    breathiness=0.09, seed=33,
))

print('\nSelesai. SFX di', OUT)
