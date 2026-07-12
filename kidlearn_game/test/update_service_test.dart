import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:kidlearn_game/app_version.dart';
import 'package:kidlearn_game/services/update_service.dart';

/// Deteksi update: hanya menyarankan bila build server > build terpasang.
void main() {
  http.Client jsonClient(String body, [int status = 200]) =>
      MockClient((_) async => http.Response(body, status));

  test('Build server LEBIH BARU → sarankan update', () async {
    final svc = UpdateService(jsonClient(
        '{"version":"9.9.9","build":${AppVersion.build + 1},'
        '"url":"https://x/BelajarYuk.apk","notes":"Uji"}'));
    final info = await svc.check();
    expect(info, isNotNull);
    expect(info!.build, AppVersion.build + 1);
    expect(info.version, '9.9.9');
    expect(info.url, 'https://x/BelajarYuk.apk');
  });

  test('Build server SAMA/lebih lama → TIDAK menyarankan', () async {
    final same = UpdateService(
        jsonClient('{"version":"1.0.0","build":${AppVersion.build}}'));
    expect(await same.check(), isNull);
    final older = UpdateService(
        jsonClient('{"version":"0.0.1","build":${AppVersion.build - 1}}'));
    expect(await older.check(), isNull);
  });

  test('Respons rusak / non-200 → aman (null, tak melempar)', () async {
    expect(await UpdateService(jsonClient('bukan json')).check(), isNull);
    expect(await UpdateService(jsonClient('{}', 500)).check(), isNull);
    // build hilang → dianggap 0 → tak menyarankan.
    expect(await UpdateService(jsonClient('{"version":"9.9"}')).check(), isNull);
  });

  test('URL kosong → pakai fallback APK', () async {
    final svc = UpdateService(jsonClient(
        '{"version":"9.9","build":${AppVersion.build + 5},"url":""}'));
    final info = await svc.check();
    expect(info!.url, UpdateService.fallbackApk);
  });
}
