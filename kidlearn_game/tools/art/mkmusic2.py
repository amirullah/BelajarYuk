"""Musik latar berbeda-beda per mata pelajaran + beranda.
Semua disintesis sendiri (numpy): melodi + akor + bass + perkusi ringan,
tempo & nada dibuat ceria dan bersemangat. Output 22kHz WAV (<1MB, muat SoundPool)."""
import numpy as np
from scipy.io import wavfile
import os

SR = 22050

def semis(name):
    NAMES = {'C':-9,'C#':-8,'D':-7,'D#':-6,'E':-5,'F':-4,'F#':-3,'G':-2,'G#':-1,
             'A':0,'A#':1,'B':2}
    return NAMES[name]
def hz(name, octave):
    return 440.0 * 2 ** ((semis(name) + (octave-4)*12) / 12.0)

def adsr(n, a, d, s, r):
    a,d,r = max(int(a*SR),1), max(int(d*SR),1), max(int(r*SR),1)
    if a+d+r > n:
        a=max(n//8,1); d=max(n//8,1); r=max(n//4,1)
    sus=max(n-a-d-r,0)
    env=np.concatenate([np.linspace(0,1,a),np.linspace(1,s,d),np.full(sus,s),np.linspace(s,0,r)])
    if len(env)<n: env=np.pad(env,(0,n-len(env)))
    return env[:n]

def bell(freq,dur,vol=0.3):
    n=int(dur*SR); t=np.arange(n)/SR
    vib=1+0.004*np.sin(2*np.pi*5.5*t)
    y=(np.sin(2*np.pi*freq*t*vib)+0.5*np.sin(2*np.pi*2*freq*t)
       +0.25*np.sin(2*np.pi*3*freq*t)+0.1*np.sin(2*np.pi*4*freq*t))
    return y*adsr(n,0.004,0.18,0.2,0.28)*vol

def pluck(freq,dur,vol=0.28):
    """Petikan ceria (lebih 'nendang' dari bell) untuk melodi bersemangat."""
    n=int(dur*SR); t=np.arange(n)/SR
    y=np.sin(2*np.pi*freq*t)+0.4*np.sin(2*np.pi*2*freq*t)+0.2*np.sign(np.sin(2*np.pi*freq*t))
    return y*adsr(n,0.002,0.08,0.15,0.12)*vol

def pad(freq,dur,vol=0.10):
    n=int(dur*SR); t=np.arange(n)/SR
    y=2/np.pi*np.arcsin(np.sin(2*np.pi*freq*t))+0.3*np.sin(2*np.pi*freq*t)
    return y*adsr(n,0.06,0.2,0.7,0.35)*vol

def bass(freq,dur,vol=0.26):
    n=int(dur*SR); t=np.arange(n)/SR
    y=np.sin(2*np.pi*freq*t)+0.25*np.sin(2*np.pi*2*freq*t)
    return y*adsr(n,0.01,0.1,0.55,0.12)*vol

def kick(dur=0.16,vol=0.5):
    n=int(dur*SR); t=np.arange(n)/SR
    f=110*np.exp(-t*24)+45
    y=np.sin(2*np.pi*np.cumsum(f)/SR)
    return y*np.exp(-t*10)*vol

def hat(dur=0.05,vol=0.14):
    n=int(dur*SR)
    y=(np.random.RandomState(1).randn(n))
    return y*np.exp(-np.arange(n)/SR*90)*vol

def clap(dur=0.09,vol=0.22):
    n=int(dur*SR)
    y=np.random.RandomState(7).randn(n)
    return y*np.exp(-np.arange(n)/SR*45)*vol

def place(buf,snd,at):
    end=at+len(snd)
    if end>len(buf): snd=snd[:len(buf)-at]
    buf[at:at+len(snd)]+=snd
    return buf

# Progresi & melodi dasar (nama nada relatif, akan ditranspos per lagu)
BASE_PROG = [                       # (root, [nada akor], oktaf-akor)
    ('C',['C','E','G'],4),
    ('A',['A','C','E'],3),          # Am
    ('F',['F','A','C'],4),
    ('G',['G','B','D'],4),
]
MELODIES = {
    # pola: (indeks nada dari akor 0..2 atau nama, oktaf, mulai-ketuk, panjang)
    'bounce':[[('E',5,0,.5),('G',5,.5,.5),('C',6,1,1),('G',5,2,.5),('E',5,2.5,.5),('C',6,3,1)],
              [('E',5,0,.5),('A',5,.5,.5),('C',6,1,1),('A',5,2,1),('E',5,3,1)],
              [('F',5,0,.5),('A',5,.5,.5),('C',6,1,1),('A',5,2,1),('F',5,3,1)],
              [('D',5,0,.5),('G',5,.5,.5),('B',5,1,1),('D',6,2,1),('G',5,3,1)]],
    'march':[[('C',5,0,1),('E',5,1,1),('G',5,2,1),('C',6,3,1)],
             [('A',4,0,1),('C',5,1,1),('E',5,2,1),('A',5,3,1)],
             [('F',4,0,1),('A',4,1,1),('C',5,2,1),('F',5,3,1)],
             [('G',4,0,1),('B',4,1,1),('D',5,2,1),('G',5,3,1)]],
    'gentle':[[('G',5,0,1.5),('E',5,1.5,.5),('C',5,2,2)],
              [('E',5,0,1.5),('C',5,1.5,.5),('A',4,2,2)],
              [('A',5,0,1.5),('F',5,1.5,.5),('C',5,2,2)],
              [('B',5,0,1.5),('G',5,1.5,.5),('D',5,2,2)]],
    'sparkle':[[('C',6,0,.5),('E',6,.5,.5),('G',5,1,.5),('C',6,1.5,.5),('E',6,2,.5),('G',6,2.5,.5),('C',6,3,1)],
               [('A',5,0,.5),('C',6,.5,.5),('E',6,1,.5),('A',5,1.5,.5),('C',6,2,1),('E',6,3,1)],
               [('F',5,0,.5),('A',5,.5,.5),('C',6,1,.5),('F',6,1.5,.5),('A',5,2,1),('C',6,3,1)],
               [('G',5,0,.5),('B',5,.5,.5),('D',6,1,.5),('G',6,1.5,.5),('B',5,2,1),('D',6,3,1)]],
}

def transpose_name(name, octave, tsemi):
    base = semis(name) + (octave-4)*12 + tsemi
    return 440.0*2**(base/12.0)

def make_track(tempo, style, tsemi, bars=8, drums='full', bright=1.0):
    beat=60.0/tempo; bar=4*beat
    total=int(bar*bars*SR)+SR
    buf=np.zeros(total)
    mel=MELODIES[style]
    for b in range(bars):
        root,chord,coct=BASE_PROG[b%4]
        bs=int(b*bar*SR)
        # bass: root pola 0,1.5,2,3.5 ketuk (bouncy)
        for k in ([0,1.5,2,3.5] if drums!='none' else [0,2]):
            buf=place(buf,bass(transpose_name(root,2,tsemi),beat*1.0),bs+int(k*beat*SR))
        # pad akor
        for nm in chord:
            buf=place(buf,pad(transpose_name(nm,coct,tsemi),bar*0.98),bs)
        # melodi
        inst = pluck if style in ('bounce','march','sparkle') else bell
        for nm,octv,start,length in mel[b%4]:
            at=bs+int(start*beat*SR)
            buf=place(buf,inst(transpose_name(nm,octv,tsemi)*1.0,beat*length,0.26*bright),at)
        # perkusi
        if drums=='full':
            for k in [0,2]: buf=place(buf,kick(),bs+int(k*beat*SR))
            for k in [1,3]: buf=place(buf,clap(),bs+int(k*beat*SR))
            for k in [0,0.5,1,1.5,2,2.5,3,3.5]: buf=place(buf,hat(),bs+int(k*beat*SR))
        elif drums=='soft':
            for k in [0,2]: buf=place(buf,kick(vol=0.35),bs+int(k*beat*SR))
            for k in [0.5,1.5,2.5,3.5]: buf=place(buf,hat(vol=0.08),bs+int(k*beat*SR))
    buf=buf[:int(bar*bars*SR)]
    peak=np.max(np.abs(buf)) or 1
    return (buf/peak*0.9*32767).astype(np.int16)

# Konfigurasi per mata pelajaran (nama file = nilai enum Subject)
TRACKS = {
    'home':        dict(tempo=118, style='bounce',  tsemi=0,  drums='full'),
    'math':        dict(tempo=124, style='bounce',  tsemi=2,  drums='full'),   # D, bouncy
    'english':     dict(tempo=116, style='march',   tsemi=7,  drums='full'),   # G, marching
    'indonesian':  dict(tempo=108, style='gentle',  tsemi=5,  drums='soft'),   # F, hangat
    'science':     dict(tempo=126, style='sparkle', tsemi=9,  drums='full'),   # A, sparkly
    'religion':    dict(tempo=96,  style='gentle',  tsemi=-2, drums='soft', bright=0.9), # Bb, tenang
    'socialStudies':dict(tempo=112,style='march',   tsemi=4,  drums='full'),   # E, petualang
}

out = os.path.dirname(os.path.abspath(__file__))+'/sfx/'
os.makedirs(out, exist_ok=True)
for name,cfg in TRACKS.items():
    audio = make_track(**cfg)
    fn = out+f'music_{name}.wav'
    wavfile.write(fn, SR, audio)
    print(f'music_{name}.wav', round(len(audio)/SR,1),'dtk', os.path.getsize(fn)//1024,'KB')
