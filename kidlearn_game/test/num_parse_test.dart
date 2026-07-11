import 'package:flutter_test/flutter_test.dart';
import 'package:kidlearn_game/utils/num_parse.dart';

/// Regresi bug: backend PDO/MySQL mengembalikan angka sebagai String dalam JSON
/// (mis. {"id":"1","unlocked_grade":"1"}). Sebelumnya `value as num` melempar
/// TypeError → di dalam try/catch, profil server GAGAL dimuat (tak muncul).
void main() {
  test('asInt menerima int, double, num, dan String', () {
    expect(asInt(3), 3);
    expect(asInt(3.9), 3);
    expect(asInt('1'), 1); // <- kasus yang dulu bikin crash
    expect(asInt('42'), 42);
    expect(asInt('3.0'), 3);
  });

  test('asInt aman untuk null/kosong/sampah → fallback', () {
    expect(asInt(null), 0);
    expect(asInt(null, 1), 1);
    expect(asInt(''), 0);
    expect(asInt('abc'), 0);
    expect(asInt('abc', 5), 5);
    expect(asInt({'x': 1}), 0);
  });

  test('meniru baris profil server (semua String) tak melempar', () {
    final raw = {'id': '1', 'unlocked_grade': '2', 'total_stars': '5'};
    // Pola yang dipakai profile_select saat menggabung profil server.
    expect(() {
      final id = '${raw['id']}';
      final ug = asInt(raw['unlocked_grade'], 1);
      final ts = asInt(raw['total_stars']);
      expect(id, '1');
      expect(ug, 2);
      expect(ts, 5);
    }, returnsNormally);
  });
}
