import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/level.dart';
import '../models/subject.dart';
import '../models/profile.dart';
import '../services/sfx_service.dart';
import '../services/storage_service.dart';
import '../utils/app_colors.dart';
import 'play_screen.dart';

/// Peta 12 level untuk satu mata pelajaran (Kelas tertentu).
/// Level terbuka bila level sebelumnya sudah lulus (≥1 bintang).
class LevelMapScreen extends StatefulWidget {
  final Subject subject;
  final int grade;
  const LevelMapScreen({super.key, required this.subject, this.grade = 1});

  @override
  State<LevelMapScreen> createState() => _LevelMapScreenState();
}

class _LevelMapScreenState extends State<LevelMapScreen> {
  final _storage = StorageService();
  ChildProfile? _profile;
  late List<GameLevel> _levels;

  SubjectInfo get _info => SubjectInfo.of(widget.subject);

  @override
  void initState() {
    super.initState();
    _levels = GameLevel.buildGrade(widget.subject, widget.grade);
    _load();
    // Musik khas mata pelajaran ini (agar tak bosan).
    SfxService.instance.playMusic(widget.subject.name);
  }

  @override
  void dispose() {
    // Kembali ke beranda → musik beranda.
    SfxService.instance.playMusic('home');
    super.dispose();
  }

  Future<void> _load() async {
    final p = await _storage.currentProfile();
    if (mounted) setState(() => _profile = p);
  }

  bool _isUnlocked(int i) {
    if (i == 0) return true;
    final prev = _levels[i - 1];
    return (_profile?.starsFor(prev.id) ?? 0) > 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: _info.color,
        foregroundColor: Colors.white,
        title: Text('${_info.emoji} ${_info.name}',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
      ),
      body: Column(
        children: [
          _header(),
          Expanded(
            child: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        children: List.generate(_levels.length, (i) {
          final level = _levels[i];
          final unlocked = _isUnlocked(i);
          final stars = _profile?.starsFor(level.id) ?? 0;
          final isNext = unlocked && stars == 0; // level berikutnya yg dimainkan
          final node = _LevelNode(
            level: level,
            color: _info.color,
            unlocked: unlocked,
            stars: stars,
            onTap: unlocked
                ? () async {
                    await Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => PlayScreen(level: level)));
                    _load(); // segarkan bintang setelah main
                  }
                : null,
          );
          // Level berikutnya "berdenyut" agar menarik perhatian anak.
          if (!isNext) return node;
          return node
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.08, 1.08),
                  duration: 700.ms,
                  curve: Curves.easeInOut);
        }),
            ),
          ),
        ],
      ),
    );
  }

  /// Header dengan ilustrasi khas mapel yang beranimasi (mengambang + berdenyut).
  Widget _header() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 18),
      decoration: BoxDecoration(
        color: _info.color,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 76,
            height: 76,
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
                color: Colors.white, shape: BoxShape.circle),
            child: Image.asset(
                'assets/img/subjects/subj_${widget.subject.name}.png'),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .moveY(begin: 0, end: -6, duration: 1500.ms, curve: Curves.easeInOut),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_info.name,
                    style: GoogleFonts.nunito(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.white)),
                const SizedBox(height: 2),
                Text(_info.tagline,
                    style: GoogleFonts.nunito(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.95),
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelNode extends StatelessWidget {
  final GameLevel level;
  final Color color;
  final bool unlocked;
  final int stars;
  final VoidCallback? onTap;

  const _LevelNode({
    required this.level,
    required this.color,
    required this.unlocked,
    required this.stars,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: unlocked ? color : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(18),
          boxShadow: unlocked
              ? [
                  BoxShadow(
                      color: color.withOpacity(0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 4))
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!unlocked)
              const Icon(Icons.lock_rounded, color: Colors.white, size: 28)
            else if (level.isBoss)
              const Text('👑', style: TextStyle(fontSize: 26))
            else
              Text('${level.index}',
                  style: GoogleFonts.nunito(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Colors.white)),
            const SizedBox(height: 4),
            Text(
              List.generate(3, (s) => s < stars ? '⭐' : '·').join(),
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
