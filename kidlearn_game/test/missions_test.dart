import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kidlearn_game/models/profile.dart';
import 'package:kidlearn_game/services/storage_service.dart';

/// Misi Harian & Target Mingguan: pelacakan bintang & klaim hadiah.
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  final storage = StorageService();

  test('Bintang baru menambah misi harian & target mingguan', () async {
    final p = ChildProfile(id: '1', name: 'A');
    await storage.upsertProfile(p);
    await storage.recordLevelResult(p, 'lvl1', 3, 100);
    expect(p.dailyStars, 3);
    expect(p.weekStars, 3);
    expect(p.dailyPerfect, isTrue); // 3⭐ = level sempurna
    // Ulang level yang sama tanpa bintang baru → tak menambah.
    await storage.recordLevelResult(p, 'lvl1', 3, 100);
    expect(p.dailyStars, 3);
    expect(p.weekStars, 3);
    // Level lain +2 bintang → bertambah.
    await storage.recordLevelResult(p, 'lvl2', 2, 90);
    expect(p.weekStars, 5);
  });

  test('Klaim Target Mingguan hanya saat cukup & sekali saja', () async {
    final p = ChildProfile(id: '2', name: 'B');
    p.weekKey = StorageService.weekKey();
    p.weekStars = StorageService.weeklyTarget - 1; // belum cukup
    expect(await storage.claimWeeklyTarget(p), 0);
    p.weekStars = StorageService.weeklyTarget; // cukup
    final koinAwal = p.coins;
    expect(await storage.claimWeeklyTarget(p), 50);
    expect(p.coins, koinAwal + 50);
    expect(p.weekClaimed, isTrue);
    // Klaim kedua → tak dapat lagi.
    expect(await storage.claimWeeklyTarget(p), 0);
  });
}
