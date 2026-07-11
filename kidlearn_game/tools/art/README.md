# Aset (Ikon, Splash, Efek Suara)

Semua aset visual & suara BelajarYuk! dibuat sendiri (bukan dari layanan luar).

## Prasyarat
```
pip install cairosvg numpy scipy
```

## Menghasilkan ulang
- `python3 mkicon.py`   → ikon aplikasi (buku + bintang, adaptive icon)
- `python3 mksplash.py` → logo splash
- `python3 mksfx.py`    → efek suara WAV (benar/salah/bintang/koin/naik level)

Ikon & splash dipasang ke Android lewat `flutter_launcher_icons` &
`flutter_native_splash` (lihat konfigurasi di `pubspec.yaml`).
Efek suara ada di `assets/sfx/` dan diputar oleh `lib/services/sfx_service.dart`.
