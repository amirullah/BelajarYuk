#!/usr/bin/env bash
# Uji APK ASLI di HP Android FISIK (cloud) via Firebase Test Lab.
# Menghasilkan: video, rekaman audio, logcat, screenshot, laporan crash.
# Ini menangkap bug KHUSUS NATIVE yang tak terlihat di versi web
# (mis. musik terputus saat sentuh maskot, Google Sign-In, splash/ikon).
#
# PRASYARAT (dilakukan SATU KALI oleh pemilik akun Google/Firebase):
#   1. Buat/ pilih project di https://console.firebase.google.com
#   2. Aktifkan "Test Lab" (paket Blaze; ada kuota harian gratis)
#   3. Install gcloud CLI, lalu:
#        gcloud auth login
#        gcloud config set project <PROJECT_ID>
#        gcloud services enable testing.googleapis.com toolresults.googleapis.com
#
# Pemakaian:
#   bash testing/firebase_testlab.sh robo      # crawl otomatis (tanpa kode)
#   bash testing/firebase_testlab.sh instrumentation  # jalankan integration_test kita
set -euo pipefail

MODE="${1:-robo}"
APP_DIR="$(cd "$(dirname "$0")/../kidlearn_game" && pwd)"
export PATH="$PATH:/home/user/flutter/bin"

# Perangkat uji (ubah sesuai kebutuhan). Lihat daftar: gcloud firebase test android models list
DEVICES=(
  "--device model=redfin,version=30,locale=id,orientation=portrait"   # Pixel 5, Android 11
  "--device model=a10,version=29,locale=id,orientation=portrait"      # Galaxy A10 (kelas bawah)
)

cd "$APP_DIR"

if [ "$MODE" = "robo" ]; then
  echo ">> Build APK rilis…"
  flutter build apk --release
  APK="build/app/outputs/flutter-apk/app-release.apk"
  echo ">> Menjalankan Robo test di HP fisik cloud…"
  gcloud firebase test android run \
    --type robo \
    --app "$APK" \
    "${DEVICES[@]}" \
    --timeout 5m \
    --record-video

elif [ "$MODE" = "instrumentation" ]; then
  # Menjalankan integration_test kita di perangkat asli.
  # Butuh berkas test di integration_test/ (lihat catatan di README).
  echo ">> Build APK debug + androidTest…"
  flutter build apk --debug
  pushd android >/dev/null
  ./gradlew app:assembleDebug app:assembleDebugAndroidTest
  popd >/dev/null
  gcloud firebase test android run \
    --type instrumentation \
    --app build/app/outputs/flutter-apk/app-debug.apk \
    --test build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk \
    "${DEVICES[@]}" \
    --timeout 8m \
    --record-video
else
  echo "Mode tidak dikenal: $MODE (pakai: robo | instrumentation)"; exit 1
fi

echo ">> Selesai. Buka Firebase Console → Test Lab untuk video/audio/logcat."
