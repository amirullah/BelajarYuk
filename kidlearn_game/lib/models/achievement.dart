import 'profile.dart';
import 'subject.dart';

/// Lencana pencapaian. `earned` menentukan apakah profil sudah memenuhinya.
class Achievement {
  final String id;
  final String title;
  final String emoji;
  final String desc;
  final bool Function(ChildProfile p) earned;

  const Achievement({
    required this.id,
    required this.title,
    required this.emoji,
    required this.desc,
    required this.earned,
  });

  static int _subjectStars(ChildProfile p, Subject s) {
    // id level berformat "<subject>-<grade>-<index>" (lihat GameLevel.id).
    return p.stars.entries
        .where((e) => e.key.startsWith('${s.name}-'))
        .fold(0, (a, e) => a + e.value);
  }

  /// Daftar semua lencana yang bisa diraih.
  static final List<Achievement> all = [
    Achievement(
      id: 'first_star',
      title: 'Bintang Pertama',
      emoji: '⭐',
      desc: 'Dapatkan bintang pertamamu',
      earned: (p) => p.totalStars() >= 1,
    ),
    Achievement(
      id: 'ten_levels',
      title: 'Rajin Belajar',
      emoji: '📚',
      desc: 'Selesaikan 10 level',
      earned: (p) => p.levelsCompleted >= 10,
    ),
    Achievement(
      id: 'fifty_levels',
      title: 'Sang Juara',
      emoji: '🏅',
      desc: 'Selesaikan 50 level',
      earned: (p) => p.levelsCompleted >= 50,
    ),
    Achievement(
      id: 'hundred_stars',
      title: 'Kolektor Bintang',
      emoji: '🌟',
      desc: 'Kumpulkan 100 bintang',
      earned: (p) => p.totalStars() >= 100,
    ),
    Achievement(
      id: 'streak3',
      title: 'Semangat 3 Hari',
      emoji: '🔥',
      desc: 'Main 3 hari beruntun',
      earned: (p) => p.streak >= 3,
    ),
    Achievement(
      id: 'streak7',
      title: 'Sepekan Rajin',
      emoji: '🔥',
      desc: 'Main 7 hari beruntun',
      earned: (p) => p.streak >= 7,
    ),
    Achievement(
      id: 'rich',
      title: 'Kaya Koin',
      emoji: '🪙',
      desc: 'Punya 200 koin',
      earned: (p) => p.coins >= 200,
    ),
    Achievement(
      id: 'math_master',
      title: 'Jago Matematika',
      emoji: '➗',
      desc: 'Kumpulkan 30 bintang Matematika',
      earned: (p) => _subjectStars(p, Subject.math) >= 30,
    ),
    Achievement(
      id: 'english_master',
      title: 'Jago Bahasa Inggris',
      emoji: '🔤',
      desc: 'Kumpulkan 30 bintang Bahasa Inggris',
      earned: (p) => _subjectStars(p, Subject.english) >= 30,
    ),
    Achievement(
      id: 'science_master',
      title: 'Ilmuwan Cilik',
      emoji: '🔬',
      desc: 'Kumpulkan 30 bintang Sains',
      earned: (p) => _subjectStars(p, Subject.science) >= 30,
    ),
    Achievement(
      id: 'indonesian_master',
      title: 'Jago Bahasa Indonesia',
      emoji: '📖',
      desc: 'Kumpulkan 30 bintang Bahasa Indonesia',
      earned: (p) => _subjectStars(p, Subject.indonesian) >= 30,
    ),
    Achievement(
      id: 'religion_master',
      title: 'Rajin Agama Islam',
      emoji: '🕌',
      desc: 'Kumpulkan 30 bintang Agama Islam',
      earned: (p) => _subjectStars(p, Subject.religion) >= 30,
    ),
    Achievement(
      id: 'social_master',
      title: 'Jago IPS',
      emoji: '🌏',
      desc: 'Kumpulkan 30 bintang IPS',
      earned: (p) => _subjectStars(p, Subject.socialStudies) >= 30,
    ),
    Achievement(
      id: 'grade2',
      title: 'Naik ke Kelas 2',
      emoji: '🎓',
      desc: 'Buka Kelas 2',
      earned: (p) => p.unlockedGrade >= 2,
    ),
    Achievement(
      id: 'grade6',
      title: 'Lulus Kelas 6',
      emoji: '👑',
      desc: 'Buka Kelas 6',
      earned: (p) => p.unlockedGrade >= 6,
    ),
  ];

  /// Lencana baru yang belum tercatat di profil (untuk dirayakan).
  static List<Achievement> newlyEarned(ChildProfile p) {
    return all
        .where((a) => a.earned(p) && !p.badges.contains(a.id))
        .toList();
  }
}
