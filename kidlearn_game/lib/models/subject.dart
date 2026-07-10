import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

/// Enam mata pelajaran inti BelajarYuk! 2.0 — semua mulai Kelas 1.
enum Subject {
  math,
  english,
  indonesian,
  science,
  religion,
  socialStudies,
}

/// Metadata tampilan & kurikulum untuk tiap mata pelajaran.
class SubjectInfo {
  final Subject subject;
  final String name; // Nama tampil (Indonesia)
  final String emoji;
  final Color color;
  final String tagline;
  final bool cambridge; // true = mengikuti Cambridge Primary
  final String curriculumCode; // mis. "0096" untuk Math

  const SubjectInfo({
    required this.subject,
    required this.name,
    required this.emoji,
    required this.color,
    required this.tagline,
    required this.cambridge,
    required this.curriculumCode,
  });

  static const List<SubjectInfo> all = [
    SubjectInfo(
      subject: Subject.math,
      name: 'Matematika',
      emoji: '🔢',
      color: kMath,
      tagline: 'Berhitung & logika',
      cambridge: true,
      curriculumCode: '0096',
    ),
    SubjectInfo(
      subject: Subject.english,
      name: 'Bahasa Inggris',
      emoji: '🌍',
      color: kEnglish,
      tagline: 'Reading, writing, listening',
      cambridge: true,
      curriculumCode: '0058',
    ),
    SubjectInfo(
      subject: Subject.indonesian,
      name: 'Bahasa Indonesia',
      emoji: '📚',
      color: kIndo,
      tagline: 'Kata & kalimat',
      cambridge: false,
      curriculumCode: '-',
    ),
    SubjectInfo(
      subject: Subject.science,
      name: 'Sains',
      emoji: '🔬',
      color: kScience,
      tagline: 'IPA & percobaan',
      cambridge: true,
      curriculumCode: '0097',
    ),
    SubjectInfo(
      subject: Subject.religion,
      name: 'Agama Islam',
      emoji: '☪️',
      color: kAgama,
      tagline: 'Iman & akhlak',
      cambridge: false,
      curriculumCode: '-',
    ),
    SubjectInfo(
      subject: Subject.socialStudies,
      name: 'IPS',
      emoji: '🗺️',
      color: kIps,
      tagline: 'Sosial & budaya',
      cambridge: false,
      curriculumCode: '-',
    ),
  ];

  static SubjectInfo of(Subject s) =>
      all.firstWhere((info) => info.subject == s);
}
