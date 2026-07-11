/// Profil satu anak. Satu akun bisa punya beberapa profil (kakak-adik).
/// Semua anak mulai dari Kelas 1 agar merasakan perjalanan dari awal.
class ChildProfile {
  final String id;
  String name;
  String avatar; // emoji avatar

  /// Bintang per level: key = GameLevel.id, value = bintang tertinggi (0..3).
  final Map<String, int> stars;

  /// Kelas tertinggi yang sudah terbuka (mulai dari 1).
  int unlockedGrade;

  /// Koin virtual (dari menyelesaikan level) — untuk kustomisasi avatar nanti.
  int coins;

  ChildProfile({
    required this.id,
    required this.name,
    this.avatar = '🦊',
    Map<String, int>? stars,
    this.unlockedGrade = 1,
    this.coins = 0,
  }) : stars = stars ?? {};

  int starsFor(String levelId) => stars[levelId] ?? 0;
  bool isPassed(String levelId) => (stars[levelId] ?? 0) > 0;

  /// Catat hasil bila lebih baik dari sebelumnya. Return true bila rekor baru.
  bool recordStars(String levelId, int newStars) {
    final prev = stars[levelId] ?? 0;
    if (newStars > prev) {
      stars[levelId] = newStars;
      return true;
    }
    return false;
  }

  int totalStars() => stars.values.fold(0, (a, b) => a + b);

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'avatar': avatar,
        'stars': stars,
        'unlockedGrade': unlockedGrade,
        'coins': coins,
      };

  factory ChildProfile.fromJson(Map<String, dynamic> j) => ChildProfile(
        id: j['id'] as String,
        name: j['name'] as String,
        avatar: (j['avatar'] as String?) ?? '🦊',
        stars: (j['stars'] as Map?)?.map(
              (k, v) => MapEntry(k as String, (v as num).toInt()),
            ) ??
            {},
        unlockedGrade: (j['unlockedGrade'] as num?)?.toInt() ?? 1,
        coins: (j['coins'] as num?)?.toInt() ?? 0,
      );
}
