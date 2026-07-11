<?php
/**
 * BelajarYuk! — Deploy endpoint (kelola file hosting via HTTPS).
 *
 * FTP & MySQL diblokir dari lingkungan build, tetapi HTTPS bisa. File ini
 * memungkinkan pengelolaan file di hosting (unggah/perbarui/hapus/daftar)
 * dengan aman melalui satu endpoint terproteksi token.
 *
 * KEAMANAN:
 *  - Semua operasi WAJIB menyertakan token rahasia yang benar.
 *  - Semua path dikurung di dalam folder tempat file ini berada (web root).
 *    Percobaan keluar folder (path traversal) ditolak.
 *  - Hapus file ini (action=selfdestruct) bila sudah selesai memakainya.
 *
 * GANTI nilai $SECRET di bawah dengan token acak Anda sendiri sebelum unggah.
 */

$SECRET = 'REPLACE_WITH_A_LONG_RANDOM_TOKEN';

// ── Util ──
header('Content-Type: application/json');

function out($data, int $code = 200): void {
    http_response_code($code);
    echo json_encode($data);
    exit;
}

function provided_token(): string {
    $h = $_SERVER['HTTP_X_DEPLOY_TOKEN'] ?? '';
    if ($h !== '') return $h;
    return $_POST['token'] ?? ($_GET['token'] ?? '');
}

// ── Autentikasi (bandingkan waktu-konstan) ──
if (!hash_equals($SECRET, provided_token())) {
    out(['ok' => false, 'error' => 'Unauthorized'], 401);
}
if ($SECRET === 'REPLACE_WITH_A_LONG_RANDOM_TOKEN') {
    out(['ok' => false, 'error' => 'Set $SECRET terlebih dahulu'], 500);
}

$BASE = realpath(__DIR__);

/** Kurung path agar tetap di dalam $BASE; tolak traversal. Return path absolut
 *  atau null bila tidak valid. Untuk file baru, folder induk harus sudah ada. */
function safe_path(string $rel): ?string {
    global $BASE;
    $rel = str_replace('\\', '/', $rel);
    if ($rel === '' || strpos($rel, '..') !== false) return null;
    $rel = ltrim($rel, '/');
    $full = $BASE . '/' . $rel;
    $parent = realpath(dirname($full));
    if ($parent === false) return null;
    if ($parent !== $BASE && strpos($parent, $BASE . '/') !== 0) return null;
    return $parent . '/' . basename($full);
}

$action = $_GET['action'] ?? $_POST['action'] ?? 'ping';

switch ($action) {
    case 'ping':
        out(['ok' => true, 'version' => 1, 'base' => $BASE,
             'php' => PHP_VERSION,
             'post_max' => ini_get('post_max_size'),
             'upload_max' => ini_get('upload_max_filesize')]);

    case 'list': {
        $p = safe_path($_GET['path'] ?? $_POST['path'] ?? '.');
        if ($p === null || !is_dir($p)) out(['ok' => false, 'error' => 'Folder tak valid'], 400);
        $items = [];
        foreach (scandir($p) as $f) {
            if ($f === '.' || $f === '..') continue;
            $fp = $p . '/' . $f;
            $items[] = ['name' => $f, 'dir' => is_dir($fp),
                        'size' => is_file($fp) ? filesize($fp) : null,
                        'mtime' => filemtime($fp)];
        }
        out(['ok' => true, 'path' => $p, 'items' => $items]);
    }

    case 'get': {
        $p = safe_path($_GET['path'] ?? $_POST['path'] ?? '');
        if ($p === null || !is_file($p)) out(['ok' => false, 'error' => 'File tak ada'], 404);
        out(['ok' => true, 'size' => filesize($p),
             'content_b64' => base64_encode(file_get_contents($p)),
             'sha256' => hash_file('sha256', $p)]);
    }

    case 'mkdir': {
        $p = safe_path($_POST['path'] ?? '');
        if ($p === null) out(['ok' => false, 'error' => 'Path tak valid'], 400);
        if (!is_dir($p) && !mkdir($p, 0755, true)) out(['ok' => false, 'error' => 'Gagal buat folder'], 500);
        out(['ok' => true, 'path' => $p]);
    }

    case 'put': {
        // mode: 'w' (tulis/timpa, default) atau 'a' (tambah — untuk unggah bertahap)
        $p = safe_path($_POST['path'] ?? '');
        if ($p === null) out(['ok' => false, 'error' => 'Path tak valid'], 400);
        $mode = ($_POST['mode'] ?? 'w') === 'a' ? 'a' : 'w';
        $data = base64_decode($_POST['content_b64'] ?? '', true);
        if ($data === false) out(['ok' => false, 'error' => 'content_b64 tak valid'], 400);
        $bytes = file_put_contents($p, $data, $mode === 'a' ? FILE_APPEND : 0);
        if ($bytes === false) out(['ok' => false, 'error' => 'Gagal menulis (izin?)'], 500);
        out(['ok' => true, 'path' => $p, 'written' => strlen($data),
             'size' => filesize($p), 'sha256' => hash_file('sha256', $p)]);
    }

    case 'delete': {
        $p = safe_path($_POST['path'] ?? '');
        if ($p === null) out(['ok' => false, 'error' => 'Path tak valid'], 400);
        if (is_dir($p)) { @rmdir($p); }
        elseif (is_file($p)) { @unlink($p); }
        out(['ok' => true, 'path' => $p, 'exists' => file_exists($p)]);
    }

    case 'selfdestruct':
        @unlink(__FILE__);
        out(['ok' => true, 'deleted' => !file_exists(__FILE__)]);

    default:
        out(['ok' => false, 'error' => 'Aksi tak dikenal'], 400);
}
