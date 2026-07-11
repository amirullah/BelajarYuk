import 'package:flutter_test/flutter_test.dart';
import 'package:kidlearn_game/services/storage_service.dart';

/// Koin harus konvergen dengan benar: pulih saat pasang ulang, tapi belanja
/// (termasuk saat offline) TIDAK boleh ter-refund oleh sinkronisasi.
void main() {
  test('Pasang ulang: koin server dipulihkan ke perangkat baru', () {
    // Perangkat baru kosong; server punya 300 koin (belum pernah belanja).
    final r = StorageService.mergeCoins(
        localCoins: 0, localSpent: 0, srvCoins: 300, srvSpent: 0);
    expect(r.$1, 300); // coins
    expect(r.$2, 0); // spent
  });

  test('Beli offline lalu buka online: koin TIDAK di-refund', () {
    // Lokal: dari 300 beli 250 → coins 50, spent 250. Server masih 300/0.
    final r = StorageService.mergeCoins(
        localCoins: 50, localSpent: 250, srvCoins: 300, srvSpent: 0);
    expect(r.$1, 50); // saldo tetap 50, bukan naik lagi ke 300
    expect(r.$2, 250);
  });

  test('Dapat koin offline lalu sinkron: koin bertambah', () {
    // Lokal dapat 50 lagi (350), server 300. Belum ada belanja.
    final r = StorageService.mergeCoins(
        localCoins: 350, localSpent: 0, srvCoins: 300, srvSpent: 0);
    expect(r.$1, 350);
    expect(r.$2, 0);
  });

  test('Belanja tercatat di server: kedua sisi konsisten', () {
    // Keduanya tahu belanja 250 dari total earned 300.
    final r = StorageService.mergeCoins(
        localCoins: 50, localSpent: 250, srvCoins: 50, srvSpent: 250);
    expect(r.$1, 50);
    expect(r.$2, 250);
  });
}
