import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/profile.dart';
import 'api_service.dart';

/// Penyimpanan lokal offline-first. Progres selalu tersimpan di HP;
/// disinkronkan ke backend saat ada koneksi (pull-on-open).
class StorageService {
  static const _kToken = 'auth_token';
  static const _kProfiles = 'profiles';
  static const _kCurrent = 'current_profile';

  final ApiService api;
  StorageService({ApiService? api}) : api = api ?? ApiService();

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  // ── Token sesi ──
  Future<String?> getToken() async => (await _prefs).getString(_kToken);
  Future<void> setToken(String token) async =>
      (await _prefs).setString(_kToken, token);
  Future<void> clearToken() async => (await _prefs).remove(_kToken);
  Future<bool> get isLoggedIn async => (await getToken()) != null;

  // ── Profil (cache lokal) ──
  Future<List<ChildProfile>> loadProfiles() async {
    final raw = (await _prefs).getString(_kProfiles);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list
        .map((e) => ChildProfile.fromJson(e as Map<String, dynamic>))
        .toList();
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
    final existing = await currentProfile();
    if (existing != null) return existing;
    final list = await loadProfiles();
    if (list.isNotEmpty) {
      await setCurrentProfileId(list.first.id);
      return list.first;
    }
    final p = ChildProfile(id: 'local-1', name: 'Pemain', avatar: '🦊');
    await upsertProfile(p);
    await setCurrentProfileId(p.id);
    return p;
  }

  /// Catat hasil level pada profil lokal & simpan. Return true bila rekor baru.
  Future<bool> recordLevelResult(
      ChildProfile profile, String levelId, int stars, int pct) async {
    final isRecord = profile.recordStars(levelId, stars);
    await upsertProfile(profile);
    return isRecord;
  }

  // ── Sinkronisasi ke backend ──
  /// Kirim progres lokal ke server & tarik progres terbaru (merge ambil maksimum).
  Future<void> syncProfile(ChildProfile profile) async {
    final token = await getToken();
    if (token == null) return; // mode offline / belum login
    final int? serverId = int.tryParse(profile.id);
    if (serverId == null) return;

    final progressList = profile.stars.entries
        .map((e) => {'level_id': e.key, 'stars': e.value, 'best_pct': 0})
        .toList();

    try {
      final res = await api.sync(token, serverId,
          progress: progressList, unlockedGrade: profile.unlockedGrade);
      if (res['ok'] == true && res['progress'] is List) {
        for (final row in res['progress'] as List) {
          final lid = row['level_id'] as String;
          final s = (row['stars'] as num?)?.toInt() ?? 0;
          if (s > (profile.stars[lid] ?? 0)) profile.stars[lid] = s;
        }
        await upsertProfile(profile);
      }
    } catch (_) {
      // Diam saja bila offline — progres lokal tetap aman.
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
  }
}
