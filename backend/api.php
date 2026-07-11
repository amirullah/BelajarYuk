<?php
// Router API tunggal BelajarYuk! 2.0 — endpoint via ?action=...
// Deploy: upload folder backend/ ke public_html/, akses /backend/api.php?action=ping
require __DIR__ . '/lib.php';
handle_options();

$action = $_GET['action'] ?? '';

try {
    switch ($action) {
        case 'ping':
            send_json(['ok' => true, 'service' => 'belajaryuk', 'time' => date('c')]);

        case 'register':      register(); break;
        case 'login':         login(); break;
        case 'google_login':  google_login(); break;
        case 'profiles':      profiles(); break;
        case 'create_profile':create_profile(); break;
        case 'sync':          sync(); break;
        case 'leaderboard':   leaderboard(); break;
        default:              fail('Aksi tidak dikenal: ' . $action, 404);
    }
} catch (Throwable $e) {
    fail('Kesalahan server', 500);
}

// ── Auth ──
function register(): void {
    $b = body();
    $email = trim(strtolower($b['email'] ?? ''));
    $pass = $b['password'] ?? '';
    if (!filter_var($email, FILTER_VALIDATE_EMAIL) || strlen($pass) < 6) {
        fail('Email tidak valid atau password terlalu pendek');
    }
    $hash = password_hash($pass, PASSWORD_DEFAULT);
    try {
        $st = db()->prepare('INSERT INTO users (email, password_hash, display_name) VALUES (?, ?, ?)');
        $st->execute([$email, $hash, $b['name'] ?? null]);
    } catch (PDOException $e) {
        fail('Email sudah terdaftar', 409);
    }
    $uid = (int) db()->lastInsertId();
    send_json(['ok' => true, 'token' => jwt_issue($uid)]);
}

function login(): void {
    $b = body();
    $email = trim(strtolower($b['email'] ?? ''));
    $st = db()->prepare('SELECT id, password_hash FROM users WHERE email = ?');
    $st->execute([$email]);
    $u = $st->fetch();
    if (!$u || !$u['password_hash'] || !password_verify($b['password'] ?? '', $u['password_hash'])) {
        fail('Email atau password salah', 401);
    }
    send_json(['ok' => true, 'token' => jwt_issue((int) $u['id'])]);
}

// Verifikasi ID token Google, lalu buat/temukan user.
function google_login(): void {
    $b = body();
    $idToken = $b['id_token'] ?? '';
    if (!$idToken) fail('id_token wajib');

    $url = 'https://oauth2.googleapis.com/tokeninfo?id_token=' . urlencode($idToken);
    $resp = false;
    // Utamakan cURL (lebih andal di shared hosting); jatuh ke file_get_contents.
    if (function_exists('curl_init')) {
        $ch = curl_init($url);
        curl_setopt_array($ch, [
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_TIMEOUT => 15,
            CURLOPT_SSL_VERIFYPEER => true,
        ]);
        $resp = curl_exec($ch);
        curl_close($ch);
    }
    if ($resp === false) {
        $resp = @file_get_contents($url);
    }
    $info = $resp ? json_decode($resp, true) : null;
    if (!is_array($info) || !isset($info['sub'])) {
        $reason = is_array($info) ? ($info['error_description'] ?? $info['error'] ?? '') : 'tidak ada respons';
        fail('Token Google tidak valid' . ($reason ? " ($reason)" : ''), 401);
    }

    // Terima audience dari Web Client ID maupun Android Client ID.
    $c = cfg();
    $allowed = array_filter([
        $c['google_client_id'] ?? '',
        $c['google_client_id_android'] ?? '',
    ]);
    if (!empty($allowed) && !in_array($info['aud'] ?? '', $allowed, true)) {
        fail('Client ID tidak cocok', 401);
    }

    $sub = $info['sub'];
    $email = strtolower($info['email'] ?? ($sub . '@google'));
    $name = $info['name'] ?? null;

    $st = db()->prepare('SELECT id FROM users WHERE google_sub = ? OR email = ? LIMIT 1');
    $st->execute([$sub, $email]);
    $row = $st->fetch();
    if ($row) {
        $uid = (int) $row['id'];
        db()->prepare('UPDATE users SET google_sub = ? WHERE id = ?')->execute([$sub, $uid]);
    } else {
        $st = db()->prepare('INSERT INTO users (email, google_sub, display_name) VALUES (?, ?, ?)');
        $st->execute([$email, $sub, $name]);
        $uid = (int) db()->lastInsertId();
    }
    send_json(['ok' => true, 'token' => jwt_issue($uid)]);
}

// ── Profil ──
function profiles(): void {
    $uid = auth_user();
    $st = db()->prepare('SELECT id, name, avatar, unlocked_grade, total_stars FROM profiles WHERE user_id = ?');
    $st->execute([$uid]);
    send_json(['ok' => true, 'profiles' => $st->fetchAll()]);
}

function create_profile(): void {
    $uid = auth_user();
    $b = body();
    $name = trim($b['name'] ?? '');
    if ($name === '') fail('Nama wajib');
    // Batas 5 profil per akun.
    $cnt = db()->prepare('SELECT COUNT(*) FROM profiles WHERE user_id = ?');
    $cnt->execute([$uid]);
    if ((int) $cnt->fetchColumn() >= 5) fail('Maksimal 5 profil per akun', 409);
    $st = db()->prepare('INSERT INTO profiles (user_id, name, avatar) VALUES (?, ?, ?)');
    $st->execute([$uid, mb_substr($name, 0, 50), $b['avatar'] ?? '🦊']);
    send_json(['ok' => true, 'id' => (int) db()->lastInsertId()]);
}

// ── Sinkronisasi progres (pull-on-open) ──
function sync(): void {
    $uid = auth_user();
    $b = body();
    $profileId = (int) ($b['profile_id'] ?? 0);
    // Pastikan profil milik user ini.
    $chk = db()->prepare('SELECT id FROM profiles WHERE id = ? AND user_id = ?');
    $chk->execute([$profileId, $uid]);
    if (!$chk->fetch()) fail('Profil tidak ditemukan', 404);

    // Upsert progres yang dikirim app.
    if (!empty($b['progress']) && is_array($b['progress'])) {
        $up = db()->prepare(
            'INSERT INTO progress (profile_id, level_id, stars, best_pct) VALUES (?, ?, ?, ?)
             ON DUPLICATE KEY UPDATE stars = GREATEST(stars, VALUES(stars)),
             best_pct = GREATEST(best_pct, VALUES(best_pct))'
        );
        foreach ($b['progress'] as $p) {
            $up->execute([
                $profileId, (string) ($p['level_id'] ?? ''),
                (int) ($p['stars'] ?? 0), (int) ($p['best_pct'] ?? 0),
            ]);
        }
    }
    if (isset($b['unlocked_grade'])) {
        db()->prepare('UPDATE profiles SET unlocked_grade = GREATEST(unlocked_grade, ?) WHERE id = ?')
            ->execute([(int) $b['unlocked_grade'], $profileId]);
    }

    // Perbarui total bintang di profil + skor leaderboard minggu ini.
    $sum = db()->prepare('SELECT COALESCE(SUM(stars),0) FROM progress WHERE profile_id = ?');
    $sum->execute([$profileId]);
    $totalStars = (int) $sum->fetchColumn();
    db()->prepare('UPDATE profiles SET total_stars = ? WHERE id = ?')
        ->execute([$totalStars, $profileId]);

    $gr = db()->prepare('SELECT unlocked_grade FROM profiles WHERE id = ?');
    $gr->execute([$profileId]);
    $grade = (int) $gr->fetchColumn();
    $week = date('o-W'); // tahun-minggu ISO
    db()->prepare(
        'INSERT INTO leaderboard (profile_id, grade, week, score) VALUES (?, ?, ?, ?)
         ON DUPLICATE KEY UPDATE score = GREATEST(score, VALUES(score))'
    )->execute([$profileId, $grade, $week, $totalStars]);

    // Kembalikan progres terbaru dari server.
    $st = db()->prepare('SELECT level_id, stars, best_pct FROM progress WHERE profile_id = ?');
    $st->execute([$profileId]);
    send_json(['ok' => true, 'progress' => $st->fetchAll()]);
}

// ── Leaderboard per kelas per minggu ──
function leaderboard(): void {
    $grade = (int) ($_GET['grade'] ?? 1);
    $week = $_GET['week'] ?? date('o-W');
    $st = db()->prepare(
        'SELECT p.name, p.avatar, l.score FROM leaderboard l
         JOIN profiles p ON p.id = l.profile_id
         WHERE l.grade = ? AND l.week = ? ORDER BY l.score DESC LIMIT 50'
    );
    $st->execute([$grade, $week]);
    send_json(['ok' => true, 'grade' => $grade, 'week' => $week, 'top' => $st->fetchAll()]);
}
