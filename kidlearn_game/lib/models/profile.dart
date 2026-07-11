/// Profil satu anak. Satu akun bisa punya beberapa profil (kakak-adik).
/// Semua anak mulai dari Kelas 1 agar merasakan perjalanan dari awal.
class ChildProfile {
  final String id;
  String name;
  String avatar; // emoji avatar

  /// Bintang per level: key = GameLevel.id, value = bintang tertinggi (0..3).
  final Map<String, int> stars;

  /// Persentase terbaik per level (0..100), untuk statistik server.
  final Map<String, int> bestPct;

  /// Kelas tertinggi yang sudah terbuka (mulai dari 1).
  int unlockedGrade;

  /// Koin virtual (dari menyelesaikan level) — untuk kustomisasi avatar.
  int coins;

  /// Total koin yang PERNAH dibelanjakan (monoton naik). Dipakai agar
  /// penggabungan state lintas-perangkat tidak me-refund belanja: koin bersih
  /// = (koin yang pernah didapat) − (koin yang pernah dibelanjakan), kedua sisi
  /// digabung dengan max sehingga saldo konvergen dengan benar.
  int coinsSpent;

  /// Avatar yang sudah dimiliki (bisa dibeli dengan koin di toko).
  final List<String> ownedAvatars;

  /// Streak harian (jumlah hari beruntun bermain) & tanggal main terakhir.
  int streak;
  String? lastPlayedDate;

  /// Lencana/achievement yang sudah diraih (id).
  final List<String> badges;

  /// Tanggal terakhir klaim hadiah harian (yyyy-mm-dd).
  String? lastRewardDate;

  /// Tantangan harian: tanggal & jumlah level selesai hari itu.
  String? dailyDate;
  int dailyCount;
  bool dailyClaimed;

  ChildProfile({
    required this.id,
    required this.name,
    this.avatar = '🦊',
    Map<String, int>? stars,
    Map<String, int>? bestPct,
    this.unlockedGrade = 1,
    this.coins = 0,
    this.coinsSpent = 0,
    List<String>? ownedAvatars,
    this.streak = 0,
    this.lastPlayedDate,
    List<String>? badges,
    this.lastRewardDate,
    this.dailyDate,
    this.dailyCount = 0,
    this.dailyClaimed = false,
  })  : stars = stars ?? {},
        bestPct = bestPct ?? {},
        badges = badges ?? [],
        ownedAvatars = ownedAvatars ?? [avatar];

  /// Jumlah level yang sudah lulus (bintang > 0).
  int get levelsCompleted =>
      stars.values.where((s) => s > 0).length;

  bool ownsAvatar(String a) => ownedAvatars.contains(a);

  /// Beli avatar bila koin cukup & belum dimiliki. Return true bila sukses.
  bool buyAvatar(String a, int cost) {
    if (ownsAvatar(a) || coins < cost) return false;
    coins -= cost;
    coinsSpent += cost; // catat belanja (monoton) untuk merge anti-refund
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
        'coinsSpent': coinsSpent,
        'bestPct': bestPct,
        'ownedAvatars': ownedAvatars,
        'streak': streak,
        'lastPlayedDate': lastPlayedDate,
        'badges': badges,
        'lastRewardDate': lastRewardDate,
        'dailyDate': dailyDate,
        'dailyCount': dailyCount,
        'dailyClaimed': dailyClaimed,
      };

  factory ChildProfile.fromJson(Map<String, dynamic> j) => ChildProfile(
        // Toleran: entri tanpa id/name jangan sampai membuat SELURUH daftar
        // profil gagal di-decode (pemicu klasik "profil hilang").
        id: (j['id'] as String?) ?? 'local-0',
        name: (j['name'] as String?)?.trim().isNotEmpty == true
            ? j['name'] as String
            : 'Pemain',
        avatar: (j['avatar'] as String?) ?? '🦊',
        stars: (j['stars'] as Map?)?.map(
              (k, v) => MapEntry(k as String, (v is num ? v.toInt() : 0)),
            ) ??
            {},
        bestPct: (j['bestPct'] as Map?)?.map(
              (k, v) => MapEntry(k as String, (v is num ? v.toInt() : 0)),
            ) ??
            {},
        unlockedGrade: (j['unlockedGrade'] as num?)?.toInt() ?? 1,
        coins: (j['coins'] as num?)?.toInt() ?? 0,
        coinsSpent: (j['coinsSpent'] as num?)?.toInt() ?? 0,
        ownedAvatars: (j['ownedAvatars'] as List?)?.cast<String>(),
        streak: (j['streak'] as num?)?.toInt() ?? 0,
        lastPlayedDate: j['lastPlayedDate'] as String?,
        badges: (j['badges'] as List?)?.cast<String>(),
        lastRewardDate: j['lastRewardDate'] as String?,
        dailyDate: j['dailyDate'] as String?,
        dailyCount: (j['dailyCount'] as num?)?.toInt() ?? 0,
        dailyClaimed: j['dailyClaimed'] as bool? ?? false,
      );
}
