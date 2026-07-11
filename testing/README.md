# Uji Otomatis BelajarYuk!

Tiga lapis pengujian agar bug ketahuan **sebelum** APK sampai ke pengguna.
Tanpa perlu HP, kecuali lapis 3 (opsional, untuk audio/native).

## 1. Tes kode Dart asli (paling cepat, tiap perubahan)
Menguji logika & UI sungguhan: generator soal, tingkat kesulitan naik per level,
alur bermain (jawab benar → soal maju). Jalan headless, tanpa perangkat.

```bash
export PATH="$PATH:/home/user/flutter/bin"
cd kidlearn_game
flutter test
```

Berkas:
- `kidlearn_game/test/widget_test.dart` — validitas soal, kebenaran aritmatika,
  kesulitan naik, semua kelas/mapel menghasilkan level penuh.
- `kidlearn_game/test/play_flow_test.dart` — buka Level 1, jawab benar,
  pastikan soal maju (memakai `PlayScreen(seed: …)` agar deterministik).

## 2. Tes backend PRODUKSI (server & database asli)
Membuktikan **data tidak hilang saat pasang ulang**: daftar → simpan
progres+koin+lencana → login ulang (klien baru) → semua kembali; plus
uji merge `GREATEST` (progres tak boleh mundur). Membuat lalu menghapus
profil tes; akun tes tetap ada (tak ada endpoint hapus akun).

```bash
python3 testing/backend_smoke_test.py
# atau ke server lain:
BASE_URL=https://contoh/backend/api.php python3 testing/backend_smoke_test.py
```

## 3. Firebase Test Lab — APK asli di HP fisik (opsional, untuk audio/native)
Satu-satunya cara menguji perilaku **khusus Android**: pencampuran audio
(musik terputus saat sentuh maskot), Google Sign-In, splash/ikon native.
Mengembalikan video + rekaman audio + logcat.

Perlu otorisasi pemilik akun Google/Firebase satu kali (lihat komentar di
`firebase_testlab.sh`), lalu:

```bash
bash testing/firebase_testlab.sh robo            # crawl otomatis, tanpa kode
bash testing/firebase_testlab.sh instrumentation # jalankan integration_test di HP asli
```

### Catatan pengujian di headless (lingkungan pengembang)
Versi web dipakai untuk uji visual cepat via Chromium headless
(`flutter build web --web-renderer html`, lalu Playwright klik + screenshot).
Berguna untuk memeriksa alur & tata letak, tetapi **audio tidak terdengar**
dan render bukan native — untuk itu pakai Lapis 3.
