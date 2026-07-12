import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/profile.dart';
import '../utils/num_parse.dart';
import 'api_service.dart';

/// Penyimpanan lokal offline-first. Progres selalu tersimpan di HP;
/// disinkronkan ke backend saat ada koneksi (pull-on-open).
class StorageService {
  static const _kToken = 'auth_token';
  static const _kProfiles = 'profiles';
  static const _kCurrent = 'current_profile';
  static const _kEmail = 'account_email';

  final ApiService api;
  StorageService({ApiService? api}) : api = api ?? ApiService();

  /// Id profil yang state-nya sudah berhasil ditarik dari server (per sesi).
  /// Selama sebuah profil belum ada di sini, JANGAN dorong state-nya agar tak
  /// menimpa data server dengan state lokal yang mungkin masih kosong (mis.
  /// tepat setelah pasang ulang). Per-profil, bukan global, agar aman multi-anak.
  static final Set<String> _pulledIds = {};

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  // ── Token sesi ──
  Future<String?> getToken() async => (await _prefs).getString(_kToken);
  Future<void> setToken(String token) async =>
      (await _prefs).setString(_kToken, token);
  Future<void> clearToken() async => (await _prefs).remove(_kToken);
  Future<bool> get isLoggedIn async => (await getToken()) != null;

  // ── Email akun (cache agar tampil walau offline) ──
  Future<String?> cachedEmail() async => (await _prefs).getString(_kEmail);
  Future<void> cacheEmail(String email) async =>
      (await _prefs).setString(_kEmail, email);

  // ── Profil (cache lokal) ──
  Future<List<ChildProfile>> loadProfiles() async {
    final raw = (await _prefs).getString(_kProfiles);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      final out = <ChildProfile>[];
      for (final e in list) {
        // Satu entri rusak tak boleh menghapus seluruh daftar profil.
        try {
          out.add(ChildProfile.fromJson(e as Map<String, dynamic>));
        } catch (_) {}
      }
      return out;
    } catch (_) {
      return [];
    }
  }

  Future<void> saveProfiles(List<ChildProfile> profiles) async {
    final raw = jsonEncode(profiles.map((p) => p.toJson()).toList());
    await (await _prefs).setString(_kProfiles, raw);
  }

  Future<void> upsertProfile(ChildProfile profile) async {
    final list = await loadProfiles();
    final i = list.indexWhere((p) => p.id == profile.id);
    if (i >= 0) {
      list[i] = profile;
    } else {
      list.add(profile);
    }
    await saveProfiles(list);
  }

  /// Hapus profil dari cache lokal; bila itu profil aktif, alihkan/hapus.
  Future<void> removeProfile(String id) async {
    final list = await loadProfiles();
    list.removeWhere((p) => p.id == id);
    await saveProfiles(list);
    final p = await _prefs;
    if (p.getString(_kCurrent) == id) {
      if (list.isNotEmpty) {
        await p.setString(_kCurrent, list.first.id);
      } else {
        await p.remove(_kCurrent);
      }
    }
  }

  /// Perkenalan Uku hanya sekali (per perangkat).
  Future<bool> ukuIntroSeen() async =>
      (await _prefs).getBool('uku_intro_seen') ?? false;
  Future<void> markUkuIntroSeen() async =>
      (await _prefs).setBool('uku_intro_seen', true);

  Future<String?> getCurrentProfileId() async =>
      (await _prefs).getString(_kCurrent);
  Future<void> setCurrentProfileId(String id) async =>
      (await _prefs).setString(_kCurrent, id);

  Future<ChildProfile?> currentProfile() async {
    final id = await getCurrentProfileId();
    if (id == null) return null;
    final list = await loadProfiles();
    for (final p in list) {
      if (p.id == id) return p;
    }
    return null;
  }

  /// Pastikan ada profil aktif. Bila belum login, buat profil tamu lokal
  /// agar progres tetap tersimpan (id non-numerik → sync backend dilewati).
  Future<ChildProfile> ensureLocalProfile() async {
    final loggedIn = await isLoggedIn;
    final list = await loadProfiles();
    bool isServer(ChildProfile p) => int.tryParse(p.id) != null;

    final existing = await currentProfile();
    if (existing != null) {
      // Saat login, jangan biarkan gameplay di profil tamu 'local-*' (tak
      // sinkron). Alihkan ke profil server bila ada.
      if (loggedIn && !isServer(existing)) {
        final server = list.where(isServer).toList();
        if (server.isNotEmpty) {
          await setCurrentProfileId(server.first.id);
          return server.first;
        }
      }
      return existing;
    }

    if (loggedIn) {
      final server = list.where(isServer).toList();
      if (server.isNotEmpty) {
        await setCurrentProfileId(server.first.id);
        return server.first;
      }
    }
    if (list.isNotEmpty) {
      await setCurrentProfileId(list.first.id);
      return list.first;
    }
    // Mode tamu: profil lokal.
    final p = ChildProfile(id: 'local-1', name: 'Pemain', avatar: '🦊');
    await upsertProfile(p);
    await setCurrentProfileId(p.id);
    return p;
  }

  /// Catat hasil level pada profil lokal & simpan. Return true bila rekor baru.
  Future<bool> recordLevelResult(
      ChildProfile profile, String levelId, int stars, int pct) async {
    // Bintang BARU (di atas rekor level ini) → untuk misi harian & target mingguan.
    final gained = stars > (profile.stars[levelId] ?? 0)
        ? stars - (profile.stars[levelId] ?? 0)
        : 0;
    final isRecord = profile.recordStars(levelId, stars);
    if (pct > (profile.bestPct[levelId] ?? 0)) profile.bestPct[levelId] = pct;
    // Reset penghitung harian bila ganti hari.
    final today = dayKey();
    if (profile.dailyDate != today) {
      profile.dailyDate = today;
      profile.dailyCount = 0;
      profile.dailyClaimed = false;
      profile.dailyStars = 0;
      profile.dailyPerfect = false;
    }
    profile.dailyStars += gained;
    if (stars >= 3) profile.dailyPerfect = true;
    // Reset target mingguan bila ganti minggu.
    final wk = weekKey();
    if (profile.weekKey != wk) {
      profile.weekKey = wk;
      profile.weekStars = 0;
      profile.weekClaimed = false;
    }
    profile.weekStars += gained;
    await upsertProfile(profile);
    return isRecord;
  }

  /// Kunci minggu (bucket 7-harian) untuk target mingguan.
  static String weekKey([DateTime? d]) {
    final x = d ?? DateTime.now();
    return 'W${x.difference(DateTime(2020)).inDays ~/ 7}';
  }

  /// Klaim hadiah Target Mingguan bila bintang minggu ini ≥ [target].
  /// Return koin yang diberikan (0 bila belum layak / sudah diklaim).
  static const weeklyTarget = 40;
  Future<int> claimWeeklyTarget(ChildProfile p) async {
    if (p.weekKey != weekKey()) return 0; // minggu sudah berganti
    if (p.weekClaimed || p.weekStars < weeklyTarget) return 0;
    p.weekClaimed = true;
    p.coins += 50;
    await upsertProfile(p);
    syncProfile(p);
    return 50;
  }

  // ── Sinkronisasi ke backend ──
  /// Kirim progres lokal ke server & tarik progres terbaru (merge ambil maksimum).
  ///
  /// [pushState] = kirim state (koin/lencana/streak/avatar). Saat MEMBUKA app
  /// (pull-on-open) set FALSE agar state kosong (mis. setelah pasang ulang)
  /// TIDAK menimpa data di server; state hanya dikirim setelah benar-benar
  /// berubah (selesai level, beli avatar). Progres bintang selalu aman dikirim
  /// (server pakai GREATEST).
  Future<void> syncProfile(ChildProfile profile, {bool pushState = true}) async {
    final token = await getToken();
    if (token == null) return; // mode offline / belum login
    final int? serverId = int.tryParse(profile.id);
    if (serverId == null) return;

    final progressList = profile.stars.entries
        .map((e) => {
              'level_id': e.key,
              'stars': e.value,
              'best_pct': profile.bestPct[e.key] ?? 0,
            })
        .toList();

    // Kirim state penuh HANYA saat benar-benar berubah (pushState) DAN sudah
    // pernah menarik state server (agar tak menimpa data server dgn state kosong
    // setelah pasang ulang).
    final Map<String, dynamic>? state = (pushState && _pulledIds.contains(profile.id))
        ? <String, dynamic>{
            'coins': profile.coins,
            'coinsSpent': profile.coinsSpent,
            'streak': profile.streak,
            'lastPlayedDate': profile.lastPlayedDate,
            'badges': profile.badges,
            'ownedAvatars': profile.ownedAvatars,
            'avatar': profile.avatar,
            'lastRewardDate': profile.lastRewardDate,
            'dailyDate': profile.dailyDate,
            'dailyCount': profile.dailyCount,
            'dailyClaimed': profile.dailyClaimed,
          }
        : null;

    try {
      final res = await api.sync(token, serverId,
          progress: progressList,
          unlockedGrade: profile.unlockedGrade,
          state: state);
      if (res['ok'] == true) {
        _pulledIds.add(profile.id); // state profil ini sudah ditarik sesi ini
        // Terapkan ke instansi pemanggil (untuk UI) DAN ke profil tersimpan
        // terbaru (agar tulisan lokal yang terjadi bersamaan tak tertimpa oleh
        // instansi basi). Semua penggabungan monoton/idempoten.
        _applyServer(profile, res);
        final list = await loadProfiles();
        final i = list.indexWhere((p) => p.id == profile.id);
        if (i >= 0) {
          _applyServer(list[i], res);
          list[i].avatar = profile.avatar; // avatar mengikuti hasil merge
          await saveProfiles(list);
        } else {
          await upsertProfile(profile);
        }
      }
    } catch (_) {
      // Diam saja bila offline — progres lokal tetap aman.
    }
  }

  /// Terapkan hasil sync server (progress bintang + state) ke sebuah profil.
  /// Idempoten & monoton, jadi aman dipanggil untuk beberapa instansi.
  void _applyServer(ChildProfile p, Map<String, dynamic> res) {
    if (res['progress'] is List) {
      for (final row in res['progress'] as List) {
        final lid = row['level_id'] as String;
        final s = asInt(row['stars']);
        if (s > (p.stars[lid] ?? 0)) p.stars[lid] = s;
        final bp = asInt(row['best_pct']);
        if (bp > (p.bestPct[lid] ?? 0)) p.bestPct[lid] = bp;
      }
    }
    if (res['state'] is Map) {
      _mergeState(p, (res['state'] as Map).cast<String, dynamic>());
    }
  }

  /// Gabungkan saldo koin dua sumber tanpa me-refund belanja. Kembalikan
  /// (coins, coinsSpent). earned = coins + spent (monoton di kedua sisi);
  /// ambil max earned & max spent, saldo = earned − spent.
  static (int, int) mergeCoins({
    required int localCoins,
    required int localSpent,
    required int srvCoins,
    required int srvSpent,
  }) {
    final earned = (localCoins + localSpent) > (srvCoins + srvSpent)
        ? (localCoins + localSpent)
        : (srvCoins + srvSpent);
    final spent = localSpent > srvSpent ? localSpent : srvSpent;
    final coins = earned - spent;
    return (coins < 0 ? 0 : coins, spent);
  }

  void _mergeState(ChildProfile p, Map<String, dynamic> s) {
    int mx(int a, dynamic b) => asInt(b) > a ? asInt(b) : a;
    // Koin: gabung lewat (earned, spent) yang keduanya monoton, lalu
    // saldo = earned − spent. Ini me-restore koin saat pasang ulang TAPI tak
    // me-refund belanja yang dilakukan saat offline.
    final merged = mergeCoins(
      localCoins: p.coins,
      localSpent: p.coinsSpent,
      srvCoins: asInt(s['coins']),
      srvSpent: asInt(s['coinsSpent']),
    );
    p.coins = merged.$1;
    p.coinsSpent = merged.$2;
    p.streak = mx(p.streak, s['streak']);
    for (final b in (s['badges'] as List?)?.cast<String>() ?? const []) {
      if (!p.badges.contains(b)) p.badges.add(b);
    }
    for (final a in (s['ownedAvatars'] as List?)?.cast<String>() ?? const []) {
      if (!p.ownedAvatars.contains(a)) p.ownedAvatars.add(a);
    }
    // Field harian/tanggal: adopsi server hanya bila lokal belum punya
    // (mencegah hadiah harian dobel setelah pasang ulang di hari yang sama).
    p.lastPlayedDate ??= s['lastPlayedDate'] as String?;
    p.lastRewardDate ??= s['lastRewardDate'] as String?;
    if (p.dailyDate == null && s['dailyDate'] != null) {
      p.dailyDate = s['dailyDate'] as String?;
      p.dailyCount = asInt(s['dailyCount']);
      p.dailyClaimed = s['dailyClaimed'] as bool? ?? false;
    }
  }

  /// Perbarui streak harian saat app dibuka. Beruntun bila main hari
  /// berturut-turut; reset bila terlewat satu hari atau lebih.
  Future<void> touchStreak(ChildProfile p) async {
    final now = DateTime.now();
    String key(DateTime d) => '${d.year}-${d.month}-${d.day}';
    final today = key(now);
    if (p.lastPlayedDate == today) return;
    final yesterday = key(DateTime(now.year, now.month, now.day)
        .subtract(const Duration(days: 1)));
    p.streak = (p.lastPlayedDate == yesterday) ? p.streak + 1 : 1;
    p.lastPlayedDate = today;
    await upsertProfile(p);
  }

  static String dayKey([DateTime? d]) {
    final x = d ?? DateTime.now();
    return '${x.year}-${x.month}-${x.day}';
  }

  /// Hadiah harian: sekali per hari saat buka app. Return koin yang diberikan
  /// (0 bila sudah klaim hari ini). Bonus naik sedikit mengikuti streak.
  Future<int> claimDailyReward(ChildProfile p) async {
    final today = dayKey();
    if (p.lastRewardDate == today) return 0;
    final bonus = 10 + (p.streak.clamp(0, 7) * 2); // 10..24 koin
    p.coins += bonus;
    p.lastRewardDate = today;
    await upsertProfile(p);
    return bonus;
  }

  /// Catat 1 level selesai untuk tantangan harian. Return status terkini:
  /// (count, target, baruSelesai) — baruSelesai true saat mencapai target.
  Future<({int count, int target, bool justCompleted})> recordDailyChallenge(
      ChildProfile p) async {
    const target = 3;
    final today = dayKey();
    if (p.dailyDate != today) {
      p.dailyDate = today;
      p.dailyCount = 0;
      p.dailyClaimed = false;
    }
    p.dailyCount++;
    bool justCompleted = false;
    if (p.dailyCount >= target && !p.dailyClaimed) {
      p.dailyClaimed = true;
      p.coins += 20; // hadiah tantangan harian
      justCompleted = true;
    }
    await upsertProfile(p);
    return (count: p.dailyCount, target: target, justCompleted: justCompleted);
  }

  Future<void> logout() async {
    final p = await _prefs;
    await p.remove(_kToken);
    await p.remove(_kCurrent);
    // Buang profil ter-cache milik akun ini agar tak bocor ke akun berikutnya
    // (mis. di perangkat berbagi). Sesi berikut menarik ulang dari server.
    await p.remove(_kProfiles);
    await p.remove(_kEmail);
    _pulledIds.clear();
  }
}
