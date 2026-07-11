# -*- coding: utf-8 -*-
"""Bangun landing page BelajarYuk! (satu file HTML mandiri, gambar di-embed).
Untuk diunggah ke hosting (mis. https://belajaryuk.mkz.my.id/index.html)."""
import base64, os

ART = os.path.dirname(os.path.abspath(__file__)) + '/'

def data_uri(path):
    with open(path, 'rb') as f:
        return 'data:image/png;base64,' + base64.b64encode(f.read()).decode()

mascot = data_uri(ART + 'mascot.png')
icon = data_uri(ART + 'icon.png')
subj = {k: data_uri(ART + f'subjects/subj_{k}.png') for k in
        ['math', 'english', 'indonesian', 'science', 'religion', 'socialStudies']}

SUBJECTS = [
    ('math', 'Matematika', '#FF6B6B', 'Berhitung, perkalian, pecahan'),
    ('english', 'Bahasa Inggris', '#4D96FF', 'Kosakata, menyimak, membaca'),
    ('indonesian', 'Bahasa Indonesia', '#2BB3A3', 'Kata, kalimat, cerita'),
    ('science', 'Sains', '#9B72CF', 'Alam, tubuh, percobaan'),
    ('religion', 'Agama Islam', '#2EA36B', 'Akhlak, ibadah, doa'),
    ('socialStudies', 'IPS', '#B5A72B', 'Lingkungan, profesi, Indonesia'),
]

FEATURES = [
    ('🎯', 'Kurikulum Cambridge', 'Materi selaras kerangka Cambridge Primary, dari Kelas 1 sampai 6.'),
    ('🧩', 'Beragam bentuk soal', 'Pilihan ganda, benar/salah, isian, pasangkan, pilih gambar, dan dengar.'),
    ('🏆', 'Bintang, koin & peringkat', 'Kumpulkan bintang, beli avatar, dan naik papan peringkat mingguan.'),
    ('🎵', 'Suara & musik ceria', 'Musik berbeda tiap pelajaran dan suara semangat yang ramah anak.'),
    ('🏅', 'Lencana & tantangan harian', 'Hadiah harian dan lencana pencapaian menjaga semangat belajar.'),
    ('🛡️', 'Aman & tanpa iklan', 'Gratis, tanpa iklan, progres tersimpan aman di perangkat & akun.'),
]

BENEFITS = [
    ('Belajar terasa seperti bermain', 'Animasi lucu, maskot Uku, dan perayaan tiap keberhasilan membuat anak betah belajar.'),
    ('Naik level bertahap', 'Anak mulai dari Kelas 1 dan naik hanya setelah menguasai materi — tidak terburu-buru.'),
    ('Pantau kemajuan anak', 'Mode orang tua menampilkan progres per mata pelajaran, streak, dan lencana.'),
    ('Bisa dimainkan di mana saja', 'Ringan, dan progres tetap tersimpan meski berpindah perangkat setelah login.'),
]

html = f'''<div class="page">
<header class="nav">
  <a class="brand" href="#top">
    <img src="{icon}" alt="BelajarYuk" width="40" height="40"/>
    <span>BelajarYuk!</span>
  </a>
  <nav class="nav-links">
    <a href="#fitur">Fitur</a>
    <a href="#pelajaran">Pelajaran</a>
    <a href="#orangtua">Orang Tua</a>
    <a class="btn btn-sm" href="#unduh">Unduh</a>
  </nav>
</header>

<section class="hero" id="top">
  <div class="hero-copy">
    <span class="pill">Gratis · Tanpa Iklan · Kelas 1–6 SD</span>
    <h1>Belajar jadi <span class="hl">petualangan seru</span> bersama Uku!</h1>
    <p class="lead">Game edukasi untuk anak SD — 6 mata pelajaran selaras kurikulum
      Cambridge, dengan soal beragam, musik ceria, dan animasi lucu yang bikin
      anak semangat belajar setiap hari.</p>
    <div class="cta-row">
      <a class="btn btn-lg" href="#unduh">⬇️ Unduh APK Gratis</a>
      <a class="btn btn-ghost btn-lg" href="#fitur">Lihat Fitur</a>
    </div>
    <p class="note">Segera hadir di Google Play Store</p>
  </div>
  <div class="hero-art">
    <div class="blob"></div>
    <img class="mascot" src="{mascot}" alt="Maskot Uku si burung hantu" width="300" height="300"/>
    <img class="chip chip-1" src="{subj['math']}" alt="" width="64" height="64"/>
    <img class="chip chip-2" src="{subj['science']}" alt="" width="64" height="64"/>
    <img class="chip chip-3" src="{subj['english']}" alt="" width="64" height="64"/>
  </div>
</section>

<section class="strip">
  <div><b>6</b><span>Mata pelajaran</span></div>
  <div><b>72+</b><span>Level per kelas</span></div>
  <div><b>700+</b><span>Soal terverifikasi</span></div>
  <div><b>0</b><span>Iklan</span></div>
</section>

<section class="block" id="fitur">
  <h2>Kenapa anak suka BelajarYuk!</h2>
  <p class="sub">Dirancang agar belajar terasa menyenangkan, bukan beban.</p>
  <div class="grid feat">
    {''.join(f"""<div class="card"><div class="emoji">{e}</div>
      <h3>{t}</h3><p>{d}</p></div>""" for e, t, d in FEATURES)}
  </div>
</section>

<section class="block alt" id="pelajaran">
  <h2>Enam mata pelajaran, satu petualangan</h2>
  <p class="sub">Setiap pelajaran punya warna, ilustrasi, dan musiknya sendiri.</p>
  <div class="grid subj">
    {''.join(f"""<div class="subj-card" style="--c:{c}">
      <div class="subj-badge"><img src="{subj[k]}" alt="{n}" width="52" height="52"/></div>
      <div><h3>{n}</h3><p>{d}</p></div></div>""" for k, n, c, d in SUBJECTS)}
  </div>
</section>

<section class="block" id="orangtua">
  <h2>Dibuat dengan hati untuk anak & orang tua</h2>
  <div class="grid benefit">
    {''.join(f"""<div class="benefit-item"><h3>{t}</h3><p>{d}</p></div>"""
             for t, d in BENEFITS)}
  </div>
</section>

<section class="download" id="unduh">
  <img src="{icon}" alt="" width="88" height="88"/>
  <h2>Siap memulai petualangan belajar?</h2>
  <p>Unduh gratis dan mainkan di HP Android. Tanpa iklan, tanpa biaya tersembunyi.</p>
  <a class="btn btn-lg btn-light" href="BelajarYuk.apk">⬇️ Unduh APK (Android)</a>
  <p class="tiny">Buka file APK lalu izinkan "Instal dari sumber ini". Segera hadir di Google Play.</p>
</section>

<footer class="foot">
  <div class="foot-brand"><img src="{icon}" width="28" height="28" alt=""/> BelajarYuk!</div>
  <p>Game edukasi anak SD · Selaras kurikulum Cambridge Primary</p>
  <p class="tiny">Dikembangkan oleh <b>Amirullah</b> · © 2026 · v2.0</p>
</footer>
</div>'''

CSS = '''
:root{
  --blue:#2B7FFF; --blue-d:#1B5FD9; --blue-l:#5AA0FF;
  --bg:#EFF5FF; --surface:#FFFFFF; --ink:#17233F; --muted:#5C6B87;
  --star:#FFC93C; --line:#DCE7FA;
}
@media (prefers-color-scheme:dark){:root{
  --bg:#0E1524; --surface:#16203A; --ink:#EAF1FF; --muted:#9DB0D0; --line:#26324F;
}}
:root[data-theme="light"]{--bg:#EFF5FF;--surface:#FFFFFF;--ink:#17233F;--muted:#5C6B87;--line:#DCE7FA;}
:root[data-theme="dark"]{--bg:#0E1524;--surface:#16203A;--ink:#EAF1FF;--muted:#9DB0D0;--line:#26324F;}

*{box-sizing:border-box;margin:0;padding:0}
body{background:var(--bg);color:var(--ink);
  font-family:ui-rounded,"Nunito","Segoe UI",system-ui,-apple-system,sans-serif;
  line-height:1.55;-webkit-font-smoothing:antialiased}
img{max-width:100%;display:block}
a{color:inherit;text-decoration:none}
.page{overflow-x:hidden}
h1,h2,h3{text-wrap:balance;line-height:1.12;letter-spacing:-.02em}
section{padding:64px 24px}
.block{max-width:1080px;margin:0 auto}
.block>h2,.download h2{font-size:clamp(1.6rem,4vw,2.4rem);font-weight:900;text-align:center}
.sub{text-align:center;color:var(--muted);margin:10px auto 0;max-width:52ch;font-weight:600}

/* nav */
.nav{position:sticky;top:0;z-index:20;display:flex;align-items:center;justify-content:space-between;
  padding:14px 24px;background:color-mix(in srgb,var(--bg) 82%,transparent);
  backdrop-filter:blur(10px);border-bottom:1px solid var(--line)}
.brand{display:flex;align-items:center;gap:10px;font-weight:900;font-size:1.15rem}
.brand img{border-radius:10px}
.nav-links{display:flex;align-items:center;gap:22px;font-weight:700}
.nav-links a:not(.btn){color:var(--muted)}
.nav-links a:not(.btn):hover{color:var(--ink)}
@media(max-width:640px){.nav-links a:not(.btn){display:none}}

/* buttons */
.btn{display:inline-flex;align-items:center;gap:8px;background:var(--blue);color:#fff;
  font-weight:800;padding:12px 20px;border-radius:14px;border:0;cursor:pointer;
  box-shadow:0 8px 20px -8px var(--blue);transition:transform .15s,box-shadow .15s}
.btn:hover{transform:translateY(-2px);box-shadow:0 12px 26px -8px var(--blue)}
.btn-sm{padding:9px 16px;border-radius:11px;font-size:.92rem}
.btn-lg{padding:15px 26px;font-size:1.05rem;border-radius:16px}
.btn-ghost{background:transparent;color:var(--blue);box-shadow:none;border:2px solid var(--line)}
.btn-ghost:hover{border-color:var(--blue)}
.btn-light{background:#fff;color:var(--blue-d);box-shadow:0 10px 30px -10px rgba(0,0,0,.35)}

/* hero */
.hero{max-width:1120px;margin:0 auto;display:grid;grid-template-columns:1.1fr .9fr;
  gap:36px;align-items:center;padding-top:56px;padding-bottom:40px}
@media(max-width:860px){.hero{grid-template-columns:1fr;text-align:center}}
.pill{display:inline-block;background:color-mix(in srgb,var(--blue) 14%,transparent);
  color:var(--blue-d);font-weight:800;font-size:.8rem;padding:7px 14px;border-radius:999px;
  letter-spacing:.02em}
:root[data-theme="dark"] .pill,@media(prefers-color-scheme:dark){.pill{color:var(--blue-l)}}
.hero h1{font-size:clamp(2.1rem,5.5vw,3.5rem);font-weight:900;margin:18px 0}
.hl{color:var(--blue);position:relative}
.hl::after{content:"";position:absolute;left:0;right:0;bottom:.06em;height:.28em;
  background:color-mix(in srgb,var(--star) 70%,transparent);z-index:-1;border-radius:4px}
.lead{color:var(--muted);font-size:1.1rem;font-weight:600;max-width:52ch}
@media(max-width:860px){.lead{margin:0 auto}}
.cta-row{display:flex;gap:14px;flex-wrap:wrap;margin:26px 0 10px}
@media(max-width:860px){.cta-row{justify-content:center}}
.note{color:var(--muted);font-size:.86rem;font-weight:700}

/* hero art */
.hero-art{position:relative;display:grid;place-items:center;min-height:340px}
.blob{position:absolute;width:min(360px,80%);aspect-ratio:1;border-radius:46% 54% 60% 40%;
  background:linear-gradient(150deg,var(--blue-l),var(--blue-d));filter:blur(2px);opacity:.95;
  animation:morph 9s ease-in-out infinite}
.mascot{position:relative;width:min(300px,72%);filter:drop-shadow(0 20px 30px rgba(20,50,120,.35));
  animation:float 4s ease-in-out infinite}
.chip{position:absolute;background:#fff;padding:8px;border-radius:16px;
  box-shadow:0 12px 24px -10px rgba(20,50,120,.5);animation:float 5s ease-in-out infinite}
.chip-1{top:6%;left:4%;animation-delay:.2s}
.chip-2{bottom:10%;left:0;animation-delay:1s}
.chip-3{top:14%;right:4%;animation-delay:1.6s}
@keyframes float{50%{transform:translateY(-14px)}}
@keyframes morph{50%{border-radius:58% 42% 40% 60%;transform:rotate(8deg) scale(1.03)}}
@media(prefers-reduced-motion:reduce){.mascot,.chip,.blob{animation:none}}

/* strip */
.strip{max-width:900px;margin:0 auto;display:grid;grid-template-columns:repeat(4,1fr);
  gap:14px;padding:28px 24px}
.strip div{background:var(--surface);border:1px solid var(--line);border-radius:18px;
  padding:18px 10px;text-align:center}
.strip b{display:block;font-size:1.7rem;font-weight:900;color:var(--blue)}
.strip span{font-size:.82rem;color:var(--muted);font-weight:700}
@media(max-width:560px){.strip{grid-template-columns:repeat(2,1fr)}}

.alt{background:var(--surface);border-top:1px solid var(--line);border-bottom:1px solid var(--line)}
.grid{display:grid;gap:18px;margin-top:34px}
.feat{grid-template-columns:repeat(3,1fr)}
.subj{grid-template-columns:repeat(3,1fr)}
.benefit{grid-template-columns:repeat(2,1fr)}
@media(max-width:820px){.feat,.subj{grid-template-columns:repeat(2,1fr)}}
@media(max-width:560px){.feat,.subj,.benefit{grid-template-columns:1fr}}

.card{background:var(--surface);border:1px solid var(--line);border-radius:20px;padding:24px}
.alt .card{background:var(--bg)}
.card .emoji{font-size:2rem}
.card h3{font-size:1.12rem;font-weight:800;margin:12px 0 6px}
.card p{color:var(--muted);font-weight:600;font-size:.95rem}

.subj-card{display:flex;gap:14px;align-items:center;background:var(--bg);
  border:1px solid var(--line);border-radius:20px;padding:16px;
  border-left:6px solid var(--c)}
.subj-badge{flex:0 0 auto;width:70px;height:70px;border-radius:50%;background:var(--surface);
  display:grid;place-items:center;box-shadow:0 6px 14px -8px rgba(20,50,120,.5)}
.subj-card h3{font-size:1.05rem;font-weight:900}
.subj-card p{color:var(--muted);font-weight:600;font-size:.9rem}

.benefit-item{background:var(--surface);border:1px solid var(--line);border-radius:20px;padding:24px;
  border-top:5px solid var(--blue)}
.benefit-item h3{font-size:1.15rem;font-weight:800;margin-bottom:6px}
.benefit-item p{color:var(--muted);font-weight:600}

.download{max-width:760px;margin:24px auto;text-align:center;background:linear-gradient(150deg,var(--blue),var(--blue-d));
  color:#fff;border-radius:32px;padding:56px 28px;display:grid;justify-items:center;gap:14px}
.download img{border-radius:20px;box-shadow:0 16px 30px -12px rgba(0,0,0,.4)}
.download h2{color:#fff}
.download p{color:rgba(255,255,255,.92);font-weight:600;max-width:44ch}
.download .tiny{color:rgba(255,255,255,.75);font-size:.8rem}

.foot{text-align:center;padding:40px 24px 60px;color:var(--muted)}
.foot-brand{display:inline-flex;gap:8px;align-items:center;font-weight:900;color:var(--ink);font-size:1.1rem}
.foot p{font-weight:600;margin-top:6px}
.tiny{font-size:.8rem}
.foot-brand img{border-radius:8px}
'''

doc = f'''<!doctype html>
<html lang="id">
<head>
<meta charset="utf-8"/>
<meta name="viewport" content="width=device-width,initial-scale=1"/>
<title>BelajarYuk! — Game Edukasi Anak SD (Gratis)</title>
<meta name="description" content="Game edukasi gratis untuk anak SD Kelas 1-6, selaras kurikulum Cambridge. 6 mata pelajaran, tanpa iklan. Unduh APK Android."/>
<style>{CSS}</style>
</head>
<body>
{html}
</body>
</html>'''

out = ART + 'landing/index.html'
os.makedirs(os.path.dirname(out), exist_ok=True)
with open(out, 'w', encoding='utf-8') as f:
    f.write(doc)
print('index.html', os.path.getsize(out) // 1024, 'KB')
