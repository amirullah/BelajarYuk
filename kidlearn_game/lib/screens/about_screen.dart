import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';

/// Layar "Tentang" — info aplikasi & pengembang.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const String version = '2.0.4';
  static const String developer = 'Amirullah';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: kDark,
        title: Text('Tentang',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 12),
              const Text('🎓', style: TextStyle(fontSize: 80))
                  .animate()
                  .scale(duration: 400.ms, curve: Curves.elasticOut),
              const SizedBox(height: 12),
              Text('BelajarYuk!',
                  style: GoogleFonts.nunito(
                      fontSize: 30, fontWeight: FontWeight.w900, color: kDark)),
              Text('Versi $version',
                  style: GoogleFonts.nunito(fontSize: 13, color: kMuted)),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: kSurface,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  'Game edukasi untuk anak SD Kelas 1–6. Belajar sambil bermain: '
                  'Matematika, Bahasa Inggris, Bahasa Indonesia, Sains, Agama Islam, dan IPS. '
                  'Selaras dengan kurikulum Cambridge Primary untuk mata pelajaran internasional.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                      fontSize: 14, color: kDark, height: 1.6),
                ),
              ),
              const SizedBox(height: 20),

              // ── Pengembang ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [kPrimary, kPrimaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: [
                    Text('Dikembangkan oleh',
                        style: GoogleFonts.nunito(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.85),
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1)),
                    const SizedBox(height: 4),
                    Text(developer,
                        style: GoogleFonts.nunito(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Colors.white)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text('© 2026 $developer · Gratis untuk semua',
                  style: GoogleFonts.nunito(fontSize: 12, color: kMuted)),
              const SizedBox(height: 4),
              Text('Tanpa iklan · Tanpa pembelian dalam aplikasi',
                  style: GoogleFonts.nunito(fontSize: 12, color: kMuted)),
            ],
          ),
        ),
      ),
    );
  }
}
