/// Parse angka dari data yang tipenya tak pasti.
///
/// PENTING: backend PHP/PDO+MySQL sering mengembalikan kolom angka sebagai
/// **String** dalam JSON (mis. `"unlocked_grade": "1"`). Cast langsung
/// `value as num` pada String akan MELEMPAR TypeError — dan bila terjadi di
/// dalam blok try/catch, kegagalannya diam-diam (profil/progres tak muncul).
/// Helper ini menerima int, double, num, atau String dengan aman.
int asInt(dynamic v, [int fallback = 0]) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) {
    return int.tryParse(v) ?? double.tryParse(v)?.toInt() ?? fallback;
  }
  return fallback;
}
