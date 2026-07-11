import '../models/question.dart';
import '../models/subject.dart';

/// Bank soal Kelas 5 (usia 10-11 th) — aligned Stage 5 per rencana:
/// English (past tense, kalimat kompleks), BI (narasi & eksposisi),
/// Sains (tata surya, ekosistem), Agama (akhlak, Asmaul Husna), IPS.
class ContentKelas5 {
  static List<Question> forSubject(Subject s) {
    switch (s) {
      case Subject.english:
        return _english;
      case Subject.indonesian:
        return _indonesian;
      case Subject.science:
        return _science;
      case Subject.religion:
        return _religion;
      case Subject.socialStudies:
        return _ips;
      case Subject.math:
        return const [];
    }
  }

  static final List<Question> _english = [
    const Question(question: 'Past tense of "go"?', emoji: '🚶', options: ['went', 'goed', 'gone', 'going'], correctIndex: 0),
    const Question(question: 'Past tense of "eat"?', emoji: '🍽️', options: ['ate', 'eated', 'eaten', 'eating'], correctIndex: 0),
    const Question(question: 'Correct: "Yesterday I ___ football."', emoji: '⚽', options: ['played', 'play', 'plays', 'playing'], correctIndex: 0),
    const Question(question: 'Join: "It was raining ___ we stayed home."', emoji: '🌧️', options: ['so', 'but', 'or', 'nor'], correctIndex: 0),
    Question.trueFalse(statement: '"She was reading" is past continuous.', isTrue: true, emoji: '📖'),
    const Question(question: 'Past tense of "buy"?', emoji: '🛒', options: ['bought', 'buyed', 'buied', 'buying'], correctIndex: 0),
    const Question(question: 'Which connects two ideas?', emoji: '🔗', options: ['because', 'quickly', 'happy', 'table'], correctIndex: 0),
    const Question(question: 'Past tense of "see"?', emoji: '👀', options: ['saw', 'seed', 'seen', 'seeing'], correctIndex: 0),
  ];

  static final List<Question> _indonesian = [
    const Question(question: 'Teks yang menceritakan rangkaian peristiwa disebut teks ...', emoji: '📖', options: ['narasi', 'eksposisi', 'iklan', 'puisi'], correctIndex: 0),
    const Question(question: 'Teks yang berisi penjelasan/informasi disebut teks ...', emoji: '📊', options: ['eksposisi', 'narasi', 'puisi', 'dongeng'], correctIndex: 0),
    const Question(question: 'Tokoh, latar, dan alur terdapat dalam teks ...', emoji: '🎭', options: ['narasi', 'eksposisi', 'laporan', 'iklan'], correctIndex: 0),
    Question.trueFalse(statement: 'Ide pokok biasanya terdapat pada kalimat utama.', isTrue: true, emoji: '💡'),
    const Question(question: 'Urutan waktu dalam cerita disebut ...', emoji: '⏳', options: ['alur', 'tema', 'amanat', 'rima'], correctIndex: 0),
    const Question(question: 'Pesan/pelajaran dalam cerita disebut ...', emoji: '📚', options: ['amanat', 'alur', 'latar', 'tokoh'], correctIndex: 0),
    const Question(question: 'Tempat dan waktu terjadinya cerita disebut ...', emoji: '🗺️', options: ['latar', 'tema', 'rima', 'bait'], correctIndex: 0),
    Question.trueFalse(statement: 'Teks eksposisi bertujuan memberi informasi.', isTrue: true, emoji: 'ℹ️'),
  ];

  static final List<Question> _science = [
    const Question(question: 'Planet terdekat dengan Matahari adalah ...', emoji: '☀️', options: ['Merkurius', 'Bumi', 'Mars', 'Jupiter'], correctIndex: 0),
    const Question(question: 'Planet tempat kita tinggal adalah ...', emoji: '🌍', options: ['Bumi', 'Mars', 'Venus', 'Saturnus'], correctIndex: 0),
    const Question(question: 'Planet terbesar di tata surya adalah ...', emoji: '🪐', options: ['Jupiter', 'Bumi', 'Mars', 'Merkurius'], correctIndex: 0),
    const Question(question: 'Dalam rantai makanan, tumbuhan berperan sebagai ...', emoji: '🌱', options: ['produsen', 'konsumen', 'pengurai', 'predator'], correctIndex: 0),
    Question.trueFalse(statement: 'Matahari adalah bintang.', isTrue: true, emoji: '⭐'),
    const Question(question: 'Hewan yang memakan tumbuhan disebut ...', emoji: '🐄', options: ['herbivora', 'karnivora', 'omnivora', 'predator'], correctIndex: 0),
    const Question(question: 'Jamur dan bakteri dalam ekosistem berperan sebagai ...', emoji: '🍄', options: ['pengurai', 'produsen', 'konsumen', 'matahari'], correctIndex: 0),
    const Question(question: 'Planet berwarna merah dijuluki Planet Merah adalah ...', emoji: '🔴', options: ['Mars', 'Venus', 'Bumi', 'Neptunus'], correctIndex: 0),
  ];

  static final List<Question> _religion = [
    const Question(question: 'Ar-Rahman dalam Asmaul Husna artinya ...', emoji: '💚', options: ['Maha Pengasih', 'Maha Kuat', 'Maha Melihat', 'Maha Esa'], correctIndex: 0),
    const Question(question: 'Al-\'Alim artinya Allah Maha ...', emoji: '🧠', options: ['Mengetahui', 'Mendengar', 'Melihat', 'Pengasih'], correctIndex: 0),
    const Question(question: 'Berkata jujur termasuk akhlak ...', emoji: '😇', options: ['terpuji', 'tercela', 'buruk', 'kasar'], correctIndex: 0),
    Question.trueFalse(statement: 'Asmaul Husna berjumlah 99 nama.', isTrue: true, emoji: '📿'),
    const Question(question: 'Menghormati orang tua adalah perbuatan ...', emoji: '👪', options: ['terpuji', 'tercela', 'sia-sia', 'dilarang'], correctIndex: 0),
    const Question(question: 'As-Sami\' artinya Allah Maha ...', emoji: '👂', options: ['Mendengar', 'Melihat', 'Kuasa', 'Kasih'], correctIndex: 0),
    Question.trueFalse(statement: 'Berbohong termasuk akhlak tercela.', isTrue: true, emoji: '🚫'),
    const Question(question: 'Al-Bashir artinya Allah Maha ...', emoji: '👁️', options: ['Melihat', 'Mendengar', 'Mengetahui', 'Pengasih'], correctIndex: 0),
  ];

  static final List<Question> _ips = [
    const Question(question: 'Kegiatan jual beli terjadi di ...', emoji: '🏪', options: ['pasar', 'sungai', 'gunung', 'hutan'], correctIndex: 0),
    const Question(question: 'Indonesia terletak di antara dua benua, yaitu Asia dan ...', emoji: '🌏', options: ['Australia', 'Afrika', 'Eropa', 'Amerika'], correctIndex: 0),
    const Question(question: 'Kerajaan Majapahit berpusat di ...', emoji: '👑', options: ['Jawa Timur', 'Sumatera', 'Bali', 'Papua'], correctIndex: 0),
    Question.trueFalse(statement: 'Indonesia adalah negara kepulauan.', isTrue: true, emoji: '🏝️'),
    const Question(question: 'Garis khayal yang membagi Bumi menjadi utara-selatan adalah ...', emoji: '🌐', options: ['khatulistiwa', 'meridian', 'kutub', 'lintang'], correctIndex: 0),
    const Question(question: 'Hasil utama dari kegiatan bertani adalah ...', emoji: '🌾', options: ['padi/sayur', 'ikan', 'kayu', 'emas'], correctIndex: 0),
    const Question(question: 'Kerajaan Sriwijaya terkenal sebagai kerajaan ...', emoji: '⛵', options: ['maritim', 'agraris', 'industri', 'dagang darat'], correctIndex: 0),
    Question.trueFalse(statement: 'Indonesia dilalui garis khatulistiwa.', isTrue: true, emoji: '🗺️'),
  ];
}
