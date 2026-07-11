import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';

/// Gerbang orang tua: soal perkalian sederhana yang sulit bagi anak kecil,
/// dipakai untuk melindungi aksi berisiko (hapus profil, buka dashboard).
/// Return true bila dijawab benar.
class ParentGate {
  static Future<bool> show(BuildContext context, {String? reason}) async {
    final rng = Random();
    final a = 6 + rng.nextInt(7); // 6..12
    final b = 6 + rng.nextInt(7); // 6..12
    final answer = a * b;
    final controller = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        String? error;
        return StatefulBuilder(
          builder: (ctx, setLocal) {
            void submit() {
              if (int.tryParse(controller.text.trim()) == answer) {
                Navigator.pop(ctx, true);
              } else {
                setLocal(() => error = 'Jawaban belum benar. Coba lagi.');
              }
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  const Text('🔒 ', style: TextStyle(fontSize: 22)),
                  Expanded(
                    child: Text('Khusus Orang Tua',
                        style:
                            GoogleFonts.nunito(fontWeight: FontWeight.w900)),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      reason ??
                          'Untuk melanjutkan, jawab soal ini (memastikan '
                              'orang tua yang menekan).',
                      style: GoogleFonts.nunito(fontSize: 13, color: kMuted)),
                  const SizedBox(height: 14),
                  Text('$a × $b = ?',
                      style: GoogleFonts.nunito(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: kDark)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: controller,
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onSubmitted: (_) => submit(),
                    decoration: InputDecoration(
                      hintText: 'Jawaban',
                      filled: true,
                      fillColor: kSurface,
                      errorText: error,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: Text('Batal',
                        style: GoogleFonts.nunito(color: kMuted))),
                ElevatedButton(
                  onPressed: submit,
                  style: ElevatedButton.styleFrom(backgroundColor: kPrimary),
                  child: Text('Lanjut',
                      style: GoogleFonts.nunito(
                          fontWeight: FontWeight.w800, color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
    return ok == true;
  }
}
