/// Katalog avatar berjenjang. Harga 0 = gratis (bisa dipakai tanpa beli).
/// Semakin mahal, semakin "keren" (hewan biasa → fantasi → premium) agar anak
/// termotivasi mengumpulkan koin.
class Avatars {
  static const Map<String, int> catalog = {
    // ── Gratis (untuk buat profil) ──
    '🐰': 0, '🐨': 0, '🐱': 0, '🐶': 0, '🐭': 0, '🐹': 0,
    // ── Murah: hewan populer ──
    '🦊': 80, '🐼': 80, '🐯': 80, '🦁': 80, '🐸': 80, '🐵': 80,
    // ── Keren: fantasi ──
    '🦄': 250, '🐲': 250, '🦖': 250, '🤖': 250, '👽': 250,
    // ── Premium: paling istimewa ──
    '👑': 500, '🚀': 500, '🦸': 500, '🧙': 500, '🌟': 500,
  };

  /// Avatar gratis (harga 0) — dipakai saat membuat profil.
  static List<String> get free =>
      catalog.entries.where((e) => e.value == 0).map((e) => e.key).toList();

  static int priceOf(String a) => catalog[a] ?? 0;
  static bool isFree(String a) => priceOf(a) == 0;
}
