import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final p = await _storage.currentProfile();
    _grade = p?.unlockedGrade ?? 1;
    _myName = p?.name;
    try {
      final res = await _api.leaderboard(_grade, _isoWeek());
      if (res['ok'] == true && res['top'] is List) {
        _top = (res['top'] as List).cast<Map<String, dynamic>>();
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  String _isoWeek() {
    final now = DateTime.now();
    final dayOfYear = int.parse(
        '${now.difference(DateTime(now.year, 1, 1)).inDays + 1}');
    final week = ((dayOfYear - now.weekday + 10) / 7).floor();
    return '${now.year}-${week.toString().padLeft(2, '0')}';
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
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh_rounded)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _top.isEmpty
              ? _emptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _top.length,
                  itemBuilder: (_, i) => _row(i, _top[i]),
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
    final isMe = name == _myName;
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
          Text('⭐ $score',
              style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w800, color: kAccent)),
        ],
      ),
    );
  }
}
