import 'dart:convert';
import 'package:http/http.dart' as http;

/// Klien HTTP untuk backend BelajarYuk! (PHP + MySQL di Hostinger).
class ApiService {
  static const String base =
      'https://belajaryuk.mkz.my.id/backend/api.php';

  final http.Client _client;
  ApiService([http.Client? client]) : _client = client ?? http.Client();

  Uri _u(String action, [Map<String, String>? q]) =>
      Uri.parse(base).replace(queryParameters: {'action': action, ...?q});

  Future<Map<String, dynamic>> _post(
    String action,
    Map<String, dynamic> body, {
    String? token,
  }) async {
    final res = await _client
        .post(
          _u(action),
          headers: {
            'Content-Type': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 20));
    return _decode(res);
  }

  Future<Map<String, dynamic>> _get(String action,
      [Map<String, String>? q, String? token]) async {
    final res = await _client.get(
      _u(action, q),
      headers: {if (token != null) 'Authorization': 'Bearer $token'},
    ).timeout(const Duration(seconds: 20));
    return _decode(res);
  }

  Map<String, dynamic> _decode(http.Response res) {
    try {
      final j = jsonDecode(res.body);
      if (j is Map<String, dynamic>) return j;
      return {'ok': false, 'error': 'Respons tidak valid'};
    } catch (_) {
      return {'ok': false, 'error': 'Gagal membaca respons (${res.statusCode})'};
    }
  }

  // ── Auth ──
  Future<Map<String, dynamic>> ping() => _get('ping');

  Future<Map<String, dynamic>> register(
          String email, String password, String? name) =>
      _post('register', {'email': email, 'password': password, 'name': name});

  Future<Map<String, dynamic>> login(String email, String password) =>
      _post('login', {'email': email, 'password': password});

  Future<Map<String, dynamic>> googleLogin(String idToken) =>
      _post('google_login', {'id_token': idToken});

  // ── Profil ──
  Future<Map<String, dynamic>> profiles(String token) =>
      _get('profiles', null, token);

  Future<Map<String, dynamic>> createProfile(
          String token, String name, String avatar) =>
      _post('create_profile', {'name': name, 'avatar': avatar}, token: token);

  // ── Sinkronisasi progres ──
  Future<Map<String, dynamic>> sync(
    String token,
    int profileId, {
    required List<Map<String, dynamic>> progress,
    required int unlockedGrade,
  }) =>
      _post('sync', {
        'profile_id': profileId,
        'progress': progress,
        'unlocked_grade': unlockedGrade,
      }, token: token);

  // ── Leaderboard ──
  Future<Map<String, dynamic>> leaderboard(int grade, String week) =>
      _get('leaderboard', {'grade': '$grade', 'week': week});

  void dispose() => _client.close();
}
