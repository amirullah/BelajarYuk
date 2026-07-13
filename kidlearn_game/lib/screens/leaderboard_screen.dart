import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/achievement.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../utils/app_colors.dart';

/// Papan peringkat per kelas (skor = total bintang minggu ini).
/// Nama yang tampil adalah nama profil (sesuai rencana).
class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final _api = ApiService();
  final _storage = StorageService();
  List<Map<String, dynamic>> _top = [];
  bool _loading = true;
  int _grade = 1;
  String? _myName;
  String? _myId;

  @override
  void initState() {
    super.initState();
    _init();
  }

  /// Sekali: tentukan profil & kelas aktif, dorong state terbaru (termasuk
  /// lencana), lalu muat peringkat agar tampil lencana terbaru.
  Future<void> _init() async {
    final p = await _storage.currentProfile();
    _grade = (p?.unlockedGrade ?? 1).clamp(1, 6);
    _myName = p?.name;
    _myId = p?.id;
    if (p != null) await _storage.syncProfile(p); // pastikan lencana ter-upload
    await _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    List<Map<String, dynamic>> top = [];
    try {
      final res = await _api.leaderboard(_grade); // server pakai minggu berjalan
      if (res['ok'] == true && res['top'] is List) {
        top = (res['top'] as List).cast<Map<String, dynamic>>();
      }
    } catch (_) {}
    if (mounted) {
      setState(() {
        _top = top;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: kDark,
        title: Text('🏆 Peringkat Kelas $_grade',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(onPressed: _fetch, icon: const Icon(Icons.refresh_rounded)),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _top.isEmpty
                    ? _emptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _top.length,
                        itemBuilder: (_, i) => _row(i, _top[i]),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🏅', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 12),
            Text('Belum ada peringkat minggu ini',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                    fontSize: 18, fontWeight: FontWeight.w800, color: kDark)),
            const SizedBox(height: 6),
            Text('Main level & kumpulkan bintang untuk masuk papan peringkat! (perlu login)',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(fontSize: 13, color: kMuted)),
          ],
        ),
      ),
    );
  }

  Widget _row(int i, Map<String, dynamic> e) {
    final rank = i + 1;
    final name = '${e['name'] ?? '-'}';
    final avatar = '${e['avatar'] ?? '🦊'}';
    final score = e['score'] ?? 0;
    // Cocokkan berdasarkan id profil (bukan nama) agar tak salah sorot bila
    // dua anak bernama sama; fallback ke nama bila id tak tersedia.
    final rowId = e['profile_id'] == null ? null : '${e['profile_id']}';
    final isMe = (_myId != null && rowId != null)
        ? rowId == _myId
        : name == _myName;
    final medal = rank == 1 ? '🥇' : rank == 2 ? '🥈' : rank == 3 ? '🥉' : '$rank';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isMe ? kPrimary.withOpacity(0.12) : kSurface,
        borderRadius: BorderRadius.circular(14),
        border: isMe ? Border.all(color: kPrimary, width: 2) : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(medal,
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                    fontSize: 18, fontWeight: FontWeight.w900, color: kDark)),
          ),
          const SizedBox(width: 8),
          Text(avatar, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(name + (isMe ? ' (kamu)' : ''),
                style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: isMe ? kPrimary : kDark)),
          ),
          if ((e['badges'] as List?)?.isNotEmpty == true)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Text(
                (e['badges'] as List)
                    .take(3)
                    .map((id) => Achievement.emojiFor('$id') ?? '')
                    .where((s) => s.isNotEmpty)
                    .join(''),
                style: const TextStyle(fontSize: 14),
              ),
            ),
          Text('⭐ $score',
              style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w800, color: kAccent)),
        ],
      ),
    );
  }
}
