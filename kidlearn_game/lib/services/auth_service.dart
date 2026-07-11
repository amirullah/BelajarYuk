import 'package:google_sign_in/google_sign_in.dart';
import 'api_service.dart';
import 'storage_service.dart';

/// Menangani autentikasi: email/password & Google Sign-In.
/// Token sesi disimpan lokal via StorageService.
class AuthService {
  /// Web Client ID (Google Cloud) — audience token yang diverifikasi backend.
  static const String webClientId =
      '984650746738-8sls02btq02mcvh5l7nojuc3cooq0r70.apps.googleusercontent.com';

  final ApiService api;
  final StorageService storage;

  AuthService({ApiService? api, StorageService? storage})
      : api = api ?? ApiService(),
        storage = storage ?? StorageService();

  /// Hasil: null bila sukses, atau pesan error bila gagal.
  Future<String?> registerEmail(
      String email, String password, String name) async {
    final res = await api.register(email.trim(), password, name.trim());
    return _handleToken(res);
  }

  Future<String?> loginEmail(String email, String password) async {
    final res = await api.login(email.trim(), password);
    return _handleToken(res);
  }

  Future<String?> loginGoogle() async {
    try {
      final gsi = GoogleSignIn(serverClientId: webClientId, scopes: ['email']);
      final account = await gsi.signIn();
      if (account == null) return 'Login dibatalkan';
      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null) return 'Gagal mendapat token Google';
      final res = await api.googleLogin(idToken);
      return _handleToken(res);
    } catch (e) {
      return 'Gagal login Google';
    }
  }

  Future<String?> _handleToken(Map<String, dynamic> res) async {
    if (res['ok'] == true && res['token'] is String) {
      await storage.setToken(res['token'] as String);
      return null;
    }
    return (res['error'] as String?) ?? 'Terjadi kesalahan';
  }

  Future<void> logout() async {
    try {
      await GoogleSignIn().signOut();
    } catch (_) {}
    await storage.logout();
  }
}
