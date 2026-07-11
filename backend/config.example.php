<?php
// Salin file ini menjadi config.php lalu isi kredensial asli.
// config.php di-gitignore — JANGAN pernah commit kredensial asli.

return [
    'db_host' => 'localhost',        // di server Hostinger biasanya 'localhost'
    'db_name' => 'YOUR_DB_NAME',
    'db_user' => 'YOUR_DB_USER',
    'db_pass' => 'YOUR_DB_PASSWORD',

    // Client ID dari Google Cloud Console (untuk verifikasi token login Google)
    'google_client_id' => 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com',
    // Opsional: Android OAuth Client ID (audience token dari perangkat Android).
    'google_client_id_android' => 'YOUR_ANDROID_CLIENT_ID.apps.googleusercontent.com',

    // Kunci rahasia untuk menandatangani token sesi (JWT). Buat string acak panjang.
    'jwt_secret' => 'CHANGE_ME_TO_A_LONG_RANDOM_STRING',
];
