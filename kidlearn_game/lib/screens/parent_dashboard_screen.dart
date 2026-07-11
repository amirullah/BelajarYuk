import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/subject.dart';
import '../models/level.dart';
import '../models/profile.dart';
import '../models/achievement.dart';
import '../services/storage_service.dart';
import '../utils/app_colors.dart';

/// Dashboard orang tua — ringkasan progres anak per mata pelajaran.
class ParentDashboardScreen extends StatefulWidget {
  const ParentDashboardScreen({super.key});

  @override
  State<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen> {
  final _storage = StorageService();
  List<ChildProfile> _all = [];
  ChildProfile? _profile;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await _storage.loadProfiles();
    final current = await _storage.currentProfile() ??
        await _storage.ensureLocalProfile();
    if (list.isEmpty) list.add(current);
    if (mounted) {
      setState(() {
        _all = list;
        _profile = list.firstWhere((p) => p.id == current.id,
            orElse: () => list.first);
      });
    }
  }

  /// (levelSelesai, bintang) untuk satu mapel di semua kelas yang terbuka.
  (int, int) _statFor(Subject s, ChildProfile p) {
    int done = 0, stars = 0;
    for (int g = 1; g <= p.unlockedGrade; g++) {
      for (final lvl in GameLevel.buildGrade(s, g)) {
        final st = p.starsFor(lvl.id);
        if (st > 0) done++;
        stars += st;
      }
    }
    return (done, stars);
  }

  Widget _miniStat(String emoji, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 2),
            Text(value,
                style: GoogleFonts.nunito(
                    fontSize: 18, fontWeight: FontWeight.w900, color: kDark)),
            Text(label,
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(fontSize: 10.5, color: kMuted)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = _profile;
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: kDark,
        title: Text('Progres Anak',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
      ),
      body: p == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // ── Pemilih anak (bila lebih dari satu) ──
                if (_all.length > 1) ...[
                  SizedBox(
                    height: 44,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: _all.map((c) {
                        final sel = c.id == p.id;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => setState(() => _profile = c),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: sel ? kPrimary : kSurface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: sel
                                        ? kPrimary
                                        : kMuted.withOpacity(0.3)),
                              ),
                              child: Row(
                                children: [
                                  Text(c.avatar,
                                      style: const TextStyle(fontSize: 18)),
                                  const SizedBox(width: 6),
                                  Text(c.name,
                                      style: GoogleFonts.nunito(
                                          fontWeight: FontWeight.w800,
                                          color:
                                              sel ? Colors.white : kDark)),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                // ── Kartu ringkasan ──
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [kPrimary, kPrimaryDark]),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Text(p.avatar, style: const TextStyle(fontSize: 48)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.name,
                                style: GoogleFonts.nunito(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white)),
                            Text(
                                'Kelas terbuka: ${p.unlockedGrade}  ·  ⭐ ${p.totalStars()}  ·  🪙 ${p.coins}',
                                style: GoogleFonts.nunito(
                                    fontSize: 13,
                                    color: Colors.white.withOpacity(0.9))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                // ── Ringkasan cepat ──
                Row(
                  children: [
                    _miniStat('🔥', '${p.streak}', 'hari beruntun'),
                    const SizedBox(width: 10),
                    _miniStat('🏅',
                        '${Achievement.all.where((a) => a.earned(p)).length}',
                        'lencana'),
                    const SizedBox(width: 10),
                    _miniStat('✅', '${p.levelsCompleted}', 'level selesai'),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: kStar.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Text('💡', style: TextStyle(fontSize: 22)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                            'Tips: Dampingi anak belajar 10–15 menit setiap hari. '
                            'Konsistensi lebih penting daripada durasi lama sekali-sekali.',
                            style: GoogleFonts.nunito(
                                fontSize: 12.5,
                                height: 1.35,
                                color: kDark,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text('Per Mata Pelajaran',
                    style: GoogleFonts.nunito(
                        fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                ...SubjectInfo.all.map((info) {
                  final (done, stars) = _statFor(info.subject, p);
                  final total = 12 * p.unlockedGrade;
                  final pct = total == 0 ? 0.0 : done / total;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: kSurface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('${info.emoji} ',
                                style: const TextStyle(fontSize: 20)),
                            Expanded(
                              child: Text(info.name,
                                  style: GoogleFonts.nunito(
                                      fontWeight: FontWeight.w800,
                                      color: kDark)),
                            ),
                            Text('$done/$total level · ⭐$stars',
                                style: GoogleFonts.nunito(
                                    fontSize: 12, color: kMuted)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: pct,
                            minHeight: 8,
                            backgroundColor: Colors.black12,
                            valueColor: AlwaysStoppedAnimation(info.color),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
    );
  }
}
