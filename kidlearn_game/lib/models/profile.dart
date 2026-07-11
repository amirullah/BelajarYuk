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

  /// Koin virtual (dari menyelesaikan level) — untuk kustomisasi avatar.
  int coins;

  /// Avatar yang sudah dimiliki (bisa dibeli dengan koin di toko).
  final List<String> ownedAvatars;

  /// Streak harian (jumlah hari beruntun bermain) & tanggal main terakhir.
  int streak;
  String? lastPlayedDate;

  ChildProfile({
    required this.id,
    required this.name,
    this.avatar = '🦊',
    Map<String, int>? stars,
    this.unlockedGrade = 1,
    this.coins = 0,
    List<String>? ownedAvatars,
    this.streak = 0,
    this.lastPlayedDate,
  })  : stars = stars ?? {},
        ownedAvatars = ownedAvatars ?? [avatar];

  bool ownsAvatar(String a) => ownedAvatars.contains(a);

  /// Beli avatar bila koin cukup & belum dimiliki. Return true bila sukses.
  bool buyAvatar(String a, int cost) {
    if (ownsAvatar(a) || coins < cost) return false;
    coins -= cost;
    ownedAvatars.add(a);
    return true;
  }

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
        'ownedAvatars': ownedAvatars,
        'streak': streak,
        'lastPlayedDate': lastPlayedDate,
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
        ownedAvatars: (j['ownedAvatars'] as List?)?.cast<String>(),
        streak: (j['streak'] as num?)?.toInt() ?? 0,
        lastPlayedDate: j['lastPlayedDate'] as String?,
      );
}
