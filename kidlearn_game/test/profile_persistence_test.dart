import 'package:flutter_test/flutter_test.dart';
import 'package:kidlearn_game/models/profile.dart';

/// Ketahanan penyimpanan profil: round-trip JSON tak boleh kehilangan data,
/// dan entri rusak tak boleh menggagalkan seluruh decode ("profil hilang").
void main() {
  test('toJson → fromJson mempertahankan semua data penting', () {
    final p = ChildProfile(
      id: '42',
      name: 'Adik',
      avatar: '🦊',
      stars: {'math_g1_l1': 3, 'math_g1_l2': 2},
      bestPct: {'math_g1_l1': 100, 'math_g1_l2': 80},
      unlockedGrade: 3,
      coins: 50,
      coinsSpent: 250,
      ownedAvatars: ['🦊', '🐼'],
      streak: 5,
      badges: ['first_win', 'streak3'],
    );
    final r = ChildProfile.fromJson(p.toJson());
    expect(r.id, '42');
    expect(r.name, 'Adik');
    expect(r.stars['math_g1_l1'], 3);
    expect(r.bestPct['math_g1_l2'], 80);
    expect(r.unlockedGrade, 3);
    expect(r.coins, 50);
    expect(r.coinsSpent, 250);
    expect(r.ownedAvatars.contains('🐼'), isTrue);
    expect(r.streak, 5);
    expect(r.badges.contains('first_win'), isTrue);
  });

  test('Entri rusak (tanpa id/name) tetap bisa di-decode dgn nilai aman', () {
    // Tidak boleh melempar → mencegah SATU entri rusak menghapus semua profil.
    final r = ChildProfile.fromJson({'coins': 10});
    expect(r.id, isNotEmpty);
    expect(r.name, isNotEmpty);
    expect(r.coins, 10);
  });
}
