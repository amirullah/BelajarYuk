# Backend BelajarYuk! 2.0 (PHP + MySQL untuk Hostinger)

API ringan untuk auth, profil anak, sinkronisasi progres, dan leaderboard.
Berjalan di shared hosting biasa — tidak butuh Node.js, Composer, atau WebSocket.

## Isi
- `api.php` — router API tunggal (semua endpoint via `?action=`)
- `lib.php` — koneksi DB (PDO), respons JSON, token sesi (JWT), CORS
- `schema.sql` — definisi tabel MySQL
- `init_db.php` — buat tabel sekali-jalan (hapus setelah dipakai)
- `config.example.php` — contoh konfigurasi (salin jadi `config.php`, isi kredensial)

> **`config.php` berisi kredensial asli dan TIDAK di-commit** (ada di `.gitignore`).

## Cara Deploy (via hPanel Hostinger)

1. **Upload** folder `backend/` ke `public_html/` lewat **File Manager** hPanel
   (atau FTP client seperti FileZilla). Hasil: `public_html/backend/...`
2. **Buat `config.php`** di server: salin `config.example.php` → `config.php`,
   isi kredensial database & (nanti) Google Client ID. Di server, `db_host`
   biasanya `localhost`.
3. **Buat tabel**: buka `https://belajaryuk.mkz.my.id/backend/init_db.php` di
   browser sekali. Bila sukses muncul `{"ok":true,...}` → lalu **hapus
   `init_db.php`**. (Alternatif: import `schema.sql` lewat phpMyAdmin.)
4. **Tes**: buka `https://belajaryuk.mkz.my.id/backend/api.php?action=ping` →
   harus muncul `{"ok":true,"service":"belajaryuk",...}`.

## Endpoint

| Aksi | Method | Keterangan |
|------|--------|-----------|
| `?action=ping` | GET | Cek server hidup |
| `?action=register` | POST | `{email, password, name}` → `{token}` |
| `?action=login` | POST | `{email, password}` → `{token}` |
| `?action=google_login` | POST | `{id_token}` → `{token}` |
| `?action=profiles` | GET | (Bearer token) daftar profil |
| `?action=create_profile` | POST | (Bearer) `{name, avatar}` |
| `?action=sync` | POST | (Bearer) `{profile_id, progress[], unlocked_grade}` |
| `?action=leaderboard&grade=1&week=2026-28` | GET | Top 50 per kelas/minggu |

Autentikasi: kirim header `Authorization: Bearer <token>` untuk endpoint privat.

## Keamanan
- Password di-hash `password_hash()` (bcrypt).
- Token sesi JWT HS256 (kadaluarsa 90 hari), `jwt_secret` acak di `config.php`.
- Login Google diverifikasi ke `oauth2.googleapis.com/tokeninfo`.
- Pakai HTTPS (SSL gratis Hostinger/Let's Encrypt).
