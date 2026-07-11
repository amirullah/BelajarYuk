import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/achievement.dart';
import '../models/profile.dart';
import '../services/storage_service.dart';
import '../utils/app_colors.dart';

/// Layar lencana pencapaian — yang sudah diraih berwarna, yang belum abu-abu.
class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  ChildProfile? _p;

  @override
  void initState() {
    super.initState();
    StorageService().currentProfile().then((p) {
      if (mounted) setState(() => _p = p);
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = _p;
    final earnedCount =
        p == null ? 0 : Achievement.all.where((a) => a.earned(p)).length;
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: kDark,
        title: Text('🏅 Lencana ${p == null ? '' : '($earnedCount/${Achievement.all.length})'}',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
      ),
      body: p == null
          ? const Center(child: CircularProgressIndicator())
          : GridView.count(
              padding: const EdgeInsets.all(16),
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.82,
              children: Achievement.all.map((a) {
                final got = a.earned(p);
                return Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: got ? kSurface : kSurface.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                        color: got ? kStar : kMuted.withOpacity(0.25),
                        width: got ? 2 : 1),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Opacity(
                        opacity: got ? 1 : 0.35,
                        child: Text(a.emoji,
                            style: const TextStyle(fontSize: 38)),
                      ),
                      const SizedBox(height: 6),
                      Text(a.title,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          style: GoogleFonts.nunito(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: got ? kDark : kMuted)),
                      const SizedBox(height: 2),
                      Text(a.desc,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          style: GoogleFonts.nunito(
                              fontSize: 9.5, color: kMuted)),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }
}
