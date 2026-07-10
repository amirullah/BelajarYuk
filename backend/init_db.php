<?php
// Jalankan SEKALI untuk membuat semua tabel: akses /backend/init_db.php di browser.
// Hapus / rename file ini setelah selesai agar tidak dijalankan ulang orang lain.
require __DIR__ . '/lib.php';

try {
    $sql = file_get_contents(__DIR__ . '/schema.sql');
    db()->exec($sql);
    send_json(['ok' => true, 'message' => 'Tabel berhasil dibuat. Hapus init_db.php sekarang.']);
} catch (Throwable $e) {
    fail('Gagal membuat tabel: ' . $e->getMessage(), 500);
}
