<?php
// Helper bersama: koneksi DB, respons JSON, token sesi, CORS.

function cfg(): array {
    static $c = null;
    if ($c === null) {
        $path = __DIR__ . '/config.php';
        $c = file_exists($path) ? require $path : require __DIR__ . '/config.example.php';
    }
    return $c;
}

function db(): PDO {
    static $pdo = null;
    if ($pdo === null) {
        $c = cfg();
        $dsn = "mysql:host={$c['db_host']};dbname={$c['db_name']};charset=utf8mb4";
        $pdo = new PDO($dsn, $c['db_user'], $c['db_pass'], [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        ]);
    }
    return $pdo;
}

function send_json($data, int $status = 200): void {
    http_response_code($status);
    header('Content-Type: application/json; charset=utf-8');
    header('Access-Control-Allow-Origin: *');
    header('Access-Control-Allow-Headers: Content-Type, Authorization');
    header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
    echo json_encode($data, JSON_UNESCAPED_UNICODE);
    exit;
}

function fail(string $msg, int $status = 400): void {
    send_json(['ok' => false, 'error' => $msg], $status);
}

function body(): array {
    $raw = file_get_contents('php://input');
    $j = json_decode($raw, true);
    return is_array($j) ? $j : [];
}

// Tangani preflight CORS.
function handle_options(): void {
    if (($_SERVER['REQUEST_METHOD'] ?? '') === 'OPTIONS') {
        send_json(['ok' => true]);
    }
}

// ── Token sesi ringan (JWT HS256) ──
function jwt_issue(int $userId): string {
    $c = cfg();
    $header = rtrim(strtr(base64_encode(json_encode(['alg' => 'HS256', 'typ' => 'JWT'])), '+/', '-_'), '=');
    $payload = rtrim(strtr(base64_encode(json_encode([
        'uid' => $userId,
        'iat' => time(),
        'exp' => time() + 60 * 60 * 24 * 90, // 90 hari
    ])), '+/', '-_'), '=');
    $sig = rtrim(strtr(base64_encode(hash_hmac('sha256', "$header.$payload", $c['jwt_secret'], true)), '+/', '-_'), '=');
    return "$header.$payload.$sig";
}

function jwt_verify(?string $token): ?int {
    if (!$token) return null;
    $parts = explode('.', $token);
    if (count($parts) !== 3) return null;
    [$h, $p, $s] = $parts;
    $c = cfg();
    $expected = rtrim(strtr(base64_encode(hash_hmac('sha256', "$h.$p", $c['jwt_secret'], true)), '+/', '-_'), '=');
    if (!hash_equals($expected, $s)) return null;
    $payload = json_decode(base64_decode(strtr($p, '-_', '+/')), true);
    if (!is_array($payload) || ($payload['exp'] ?? 0) < time()) return null;
    return (int) ($payload['uid'] ?? 0) ?: null;
}

// Ambil user id dari header Authorization: Bearer <token>.
function auth_user(): int {
    $hdr = $_SERVER['HTTP_AUTHORIZATION'] ?? '';
    if (stripos($hdr, 'Bearer ') === 0) {
        $uid = jwt_verify(trim(substr($hdr, 7)));
        if ($uid) return $uid;
    }
    fail('Tidak terautentikasi', 401);
}
