/// Katalog avatar berjenjang. Harga 0 = gratis (bisa dipakai tanpa beli).
/// Semakin mahal, semakin istimewa — hewan biasa → fantasi → premium →
/// bergerak → legenda → dewa, agar anak termotivasi mengumpulkan koin.
class Avatars {
  static const Map<String, int> catalog = {
    // ── Gratis (untuk buat profil) ──
    '🐰': 0, '🐨': 0, '🐱': 0, '🐶': 0, '🐭': 0, '🐹': 0,
    // ── Teman: hewan populer ──
    '🦊': 200, '🐼': 200, '🐯': 200, '🦁': 200, '🐸': 200, '🐵': 200,
    // ── Fantasi: makhluk luar biasa ──
    '🦄': 600, '🐲': 600, '🦖': 600, '🤖': 600, '👽': 600,
    // ── Premium: simbol kehebatan ──
    '👑': 1500, '🚀': 1500, '🦸': 1500, '🧙': 1500, '🌟': 1500,
    // ── BERGERAK: avatar beranimasi hidup ──
    '🐉': 3000, '🦋': 3000, '🌈': 3000, '🔥': 3000, '💎': 3000, '🎇': 3000,
    // ── LEGENDA: untuk anak paling rajin ──
    '🏆': 6000, '⚡': 6000, '🌙': 6000, '🪄': 6000, '🔮': 6000, '🌌': 6000,
    // ── DEWA: koleksi paling eksklusif ──
    '🌠': 10000, '🦅': 10000, '🦚': 10000, '🌋': 10000, '🗝️': 10000, '🎭': 10000,
  };

  static const Set<String> animated = {'🐉', '🦋', '🌈', '🔥', '💎', '🎇'};
  static const Set<String> legenda   = {'🏆', '⚡', '🌙', '🪄', '🔮', '🌌'};
  static const Set<String> dewa      = {'🌠', '🦅', '🦚', '🌋', '🗝️', '🎭'};

  static bool isAnimated(String a) => animated.contains(a);
  static bool isLegenda(String a)  => legenda.contains(a);
  static bool isDewa(String a)     => dewa.contains(a);

  /// Label nama tier (untuk toko avatar).
  static String? tierLabel(String a) {
    if (isDewa(a))     return 'Sultan';
    if (isLegenda(a))  return 'Legenda';
    if (isAnimated(a)) return 'Bergerak';
    return null;
  }

  static List<String> get free =>
      catalog.entries.where((e) => e.value == 0).map((e) => e.key).toList();

  static int priceOf(String a) => catalog[a] ?? 0;
  static bool isFree(String a) => priceOf(a) == 0;
}
