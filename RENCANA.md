# BelajarYuk! — Dokumen Perencanaan & Status Proyek

> **Terakhir diperbarui:** 2026-07-12
> **Repo produksi:** `amirullah/belajaryuk` (remote `belajaryuk`)
> **Repo kerja Claude:** `amirullah/coba-code` (remote `origin`)

---

## Arsitektur Sistem

```
┌─────────────────────────────────────────────────────────────────┐
│  APK (Flutter Android)                                          │
│  kidlearn_game/  →  build →  BelajarYuk.apk                    │
│                                                                 │
│  Cek update: GET https://belajaryuk.mkz.my.id/version.json     │
│  Download APK: GET https://belajaryuk.mkz.my.id/BelajarYuk.apk │
│  Konten OTA:  GET https://belajaryuk.mkz.my.id/content.json    │
│  Backend API: https://belajaryuk.mkz.my.id/backend/api.php     │
└─────────────────────────────────────────────────────────────────┘
```

### File penting di repo
| File | Fungsi |
|---|---|
| `kidlearn_game/pubspec.yaml` | Versi APK (`version: X.Y.Z+BUILD`) |
| `kidlearn_game/lib/app_version.dart` | Mirror versi untuk logika in-app |
| `landing/version.json` | Metadata update yang dibaca app |
| `landing/content.json` | Bank soal OTA (content version, 30 banks) |
| `landing/BelajarYuk.apk` | APK lama untuk arsip (bukan yang diupload) |
| `landing/index.html` | Landing page |
| `backend/deploy.php` | Template script deploy (token belum diisi) |
| `.deploy.secret` | URL + token deploy (JANGAN COMMIT) |
| `backend/api.php` | Backend profil/skor (di-deploy ke hosting) |

### Deploy ke server
```bash
# Upload file apapun ke server:
export $(grep -v '^#' .deploy.secret | xargs)
curl -s -X POST "$DEPLOY_URL" \
  -H "X-Deploy-Token: $DEPLOY_TOKEN" \
  -d "action=put" \
  -d "path=NAMA_FILE" \
  --data-urlencode "content_b64=$(base64 -w0 FILE_LOKAL)"

# Upload APK besar (chunked tidak perlu — server bisa 26MB+):
curl -s -X POST "$DEPLOY_URL" \
  -H "X-Deploy-Token: $DEPLOY_TOKEN" \
  -d "action=put" \
  -d "path=BelajarYuk.apk" \
  --data-urlencode "content_b64=$(base64 -w0 kidlearn_game/build/app/outputs/flutter-apk/app-release.apk)"
```

> **Catatan penting deploy.php:**  
> Harus pakai `action=put` + `content_b64`. Tanpa `action`, endpoint hanya membalas ping `ok:true` tanpa menulis file apapun.

### Build APK
```bash
export PATH="/home/user/flutter/bin:$PATH"
export JAVA_HOME=/home/user/jdk17
export ANDROID_HOME=/home/user/android-sdk
cd kidlearn_game
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

---

## Versi Saat Ini

| Komponen | Versi | Build | Status |
|---|---|---|---|
| Kode `belajaryuk/main` | 2.3.2 | 47 | ✅ commit `88c2f86` |
| `version.json` di server | 2.3.2 | 47 | ✅ (diupdate 2026-07-12) |
| APK di server | **2.3.1** | **46** | ⚠️ belum di-replace v2.3.2 |
| `content.json` di server | content v2 | — | ✅ 5716 soal, 30 bank |
| App terinstall user | 2.3.0 | ≤43 | ⏳ menunggu update |

> **Pending:** Build v2.3.2 APK sedang berjalan. Setelah selesai, upload dengan perintah di atas lalu verifikasi dengan `action=get&path=BelajarYuk.apk`.

---

## Riwayat Versi

| Versi | Build | Fitur Utama |
|---|---|---|
| **2.3.2** | 47 | Fix: pujian B.Inggris kembali berbunyi; pujian tidak terpotong (awaitSpeakCompletion + timer 7s/5s) |
| 2.3.1 | 46 | Pujian diucapkan penuh sebelum lanjut ke soal berikutnya |
| 2.3.0 | — | Pujian langsung saat benar; TTS dihentikan saat pindah soal |
| 2.2.9 | — | Musik di-duck saat feedback; pujian 450ms setelah yay |
| 2.2.8 | — | Pujian B.Inggris lebih jelas; suara Uku tidak bertumpuk |
| 2.2.7 | — | Pujian mapel B.Inggris dalam bahasa Inggris |
| 2.2.6 | — | Kunci Anak: tombol Batal besar, back tanpa PIN, Update buka browser |
| 2.2.5 | — | Kunci Anak: tidak perlu PIN saat buka; PIN hanya dari beranda |
| 2.2.4 | — | Kunci Anak: blokir home gesture via Android Lock Task Mode |
| 2.2.3 | — | Kunci Anak: blokir keluar bukan masuk |
| 2.2.2 | — | Uku selalu dalam frame; Kunci Anak via Overlay |
| 2.2.1 | — | Uku terlihat dari semua arah; Kunci Anak lebih andal |
| 2.2.0 | — | Uku animasi 8 arah + Kunci Anak dengan PIN |
| 2.1.9 | 33 | Perluas bank soal ke 5716 soal (2× lebih banyak) |
| 2.1.8 | — | content.json jadi aset bundel; hilangkan layar biru lama |
| 2.1.7 | — | Semua mapel: selang-seling jenis soal per level |
| 2.1.6 | — | Matematika: kurikulum topik bertahap |
| 2.1.5 | — | Lantai kesulitan Matematika Kelas 4-6 |
| 2.1.4 | — | Bug level & Uku, tanjakan Mat, update soal tanpa APK |
| 2.1.3 | — | Soal disjoin antar-level, pujian Islami, Uku intip, deteksi update |
| 2.1.2 | — | Misi Harian ×3 & Target Mingguan |
| 2.1.1 | — | Pujian TTS kembali + APK lebih kecil (musik OGG) |
| 2.1.0 | — | Bank soal 3× (+2340) format menantang & bertingkat |
| 2.0.9 | — | Umpan balik ekspresif + Uku peek besar + navigasi peta level |
| 2.0.8 | — | Suara KHAS Uku disintesis (bukan TTS) |
| 2.0.7 | — | Kenalan Uku + avatar bergerak + Peti Kejutan |
| 2.0.6 | — | Uku lebih hidup + avatar sinkron + mode review |
| 2.0.5 | — | Kesulitan non-math bertingkat (tag multi-agen) |
| 2.0.x | — | Tanjakan kesulitan, bank soal diperluas, sistem profil |
| 2.0.0 | — | Sistem login, profil, sinkron server, backend api.php |

---

## Alur Deploy Lengkap (Checklist)

Setiap rilis baru ikuti urutan ini:

1. **Bump versi** di `pubspec.yaml` (`version: X.Y.Z+BUILD`) dan `app_version.dart`
2. **Build APK**: `flutter build apk --release`
3. **Verifikasi versionCode**: `aapt2 dump badging build/.../app-release.apk | grep version`
4. **Upload APK** ke server (via `deploy.php action=put`)
5. **Update `version.json`** di server dengan build baru, notes, mandatory flag
6. **Commit & push** ke `belajaryuk/main`
7. **Verifikasi di server**: `action=get&path=version.json` + cek size APK
8. **Test update** di device: buka app → harus muncul notifikasi update

---

## Bank Soal (content.json)

- **Format:** `{ "content": 2, "banks": { "KELAS|MAPEL": [...soal] } }`
- **30 bank:** 6 kelas × 5 mapel (english, indonesian, science, religion, socialStudies)
- **Total:** 5716 soal (dihasilkan via workflow multi-agen)
- **Content version:** 2 (app mengambil versi tertinggi antara bundel & OTA)
- **Matematika** tidak ada di content.json — soal dihasilkan prosedural oleh `MathGenerator`

### Tipe soal yang tersedia
| Tipe | Keterangan |
|---|---|
| `multipleChoice` | 4 pilihan, 1 benar |
| `trueFalse` | Benar/Salah |
| `fillBlank` | Isi teks |
| `matching` | Pasangkan kolom kiri-kanan |
| `sequence` | Susun urutan |
| `imageChoice` | Pilih emoji/gambar |
| `listening` | Dengar lalu jawab |

---

## Tugas Tertunda

### Prioritas Tinggi
- [ ] **Upload APK v2.3.2** ke server setelah build selesai (sedang berjalan)
- [ ] **Verifikasi** user mendapat notifikasi update dan bisa install

### Tugas Panjang (belum dimulai)
- [ ] **#38** Workflow: generate ~72 soal berpikir/variatif per (kelas×mapel)  
  → Untuk semua 5 mapel non-Math × 6 kelas = 30 kombinasi × 72 soal = ~2160 soal baru  
  → Format harus variatif: berpikir kritis, kontekstual, tidak sekedar hafalan  
  → Pakai workflow multi-agen seperti dulu (task #19/#22)

- [ ] **#40** Merge hasil → content.json v3, dedup, tes, deploy OTA + APK  
  → Setelah #38 selesai: merge ke content.json, set `"content": 3`  
  → Upload ke server, bump versi app minor

---

## TTS — Catatan Teknis Penting

### Bug yang sudah diperbaiki di v2.3.2
1. **`awaitSpeakCompletion` direset** oleh `setLanguage()`/`setVoice()` pada beberapa engine Android
   - Fix: tambah `await _tts.awaitSpeakCompletion(true)` di akhir `_configure()`
   - Fix: tambah di path Arab di `praise()` (yang tidak lewat `_configure()`)
2. **Timer terlalu pendek** untuk frasa panjang ("You are so smart!" ≈ 4-5 dtk)
   - Fix: safety timer `3000 → 7000ms` (benar), `2000 → 5000ms` (salah)
   - `duckMusic` juga diperpanjang sesuai

### Arsitektur TTS
- `TtsService.praise(subject:)` → pujian spesifik per mapel
  - `Subject.english` → frasa Inggris, voice `en-US`, pitch 1.85–2.0
  - `Subject.religion` → frasa Arab (voice Arab bila ada), fallback Latin
  - Lainnya → frasa Indonesia, pitch acak 1.68–1.86
- `TtsService.encourage()` → semangat saat salah
- `TtsService.ukuSay()` → celoteh Uku (pitch 2.0, lucu)
- `TtsService.cheer()` → sorak naik level
- `PlayScreen._feedback()` → orchestrator: panggil praise/encourage, pasang timer 7s/5s sebagai jaring pengaman, `.then()` untuk maju segera setelah TTS selesai

---

## Konfigurasi & Kredensial

| Item | Lokasi | Catatan |
|---|---|---|
| Deploy token | `.deploy.secret` | Jangan commit, jangan print |
| Backend DB | `backend/config.php` di server | Jangan commit |
| Google Sign-In | `android/app/google-services.json` | Sudah ada di repo |
| Keystore APK | Tidak ada keystore di repo | APK debug-signed atau perlu setup |

---

## Checklist Sinkronisasi (cek berkala)

```
[ ] belajaryuk/main = versi terbaru kode
[ ] version.json di server = build terbaru
[ ] APK di server = versionCode cocok dengan version.json.build
[ ] content.json di server = "content" terbaru
[ ] content.json di assets/ (bundled) = sama dengan server
[ ] landing/index.html = fitur terkini terdokumentasi
[ ] app_version.dart = cocok dengan pubspec.yaml
```

---

## Referensi URL

| | URL |
|---|---|
| Landing page | https://belajaryuk.mkz.my.id/ |
| APK download | https://belajaryuk.mkz.my.id/BelajarYuk.apk |
| version.json | https://belajaryuk.mkz.my.id/version.json |
| content.json | https://belajaryuk.mkz.my.id/content.json |
| Backend API | https://belajaryuk.mkz.my.id/backend/api.php |
| Repo produksi | https://github.com/amirullah/belajaryuk |
| Repo kerja | https://github.com/amirullah/coba-code |
