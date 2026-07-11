import '../models/question.dart';
import '../models/subject.dart';

/// Bank soal starter Kelas 1 (buatan tangan, sesuai usia 6-7 th).
/// Matematika tidak di sini — dihasilkan algoritmik oleh MathGenerator.
/// Nanti diperbanyak lewat generasi AI per objektif Cambridge.
class ContentKelas1 {
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
        return const []; // math via generator
    }
  }

  // ── Bahasa Inggris (Cambridge 0058, Stage 1: fonik, huruf) ──
  static final List<Question> _english = [
    const Question(
        question: 'Which letter makes the "mmm" sound?',
        emoji: '🔤',
        options: ['M', 'S', 'B', 'T'],
        correctIndex: 0,
        objectiveCode: '1Rw.01'),
    const Question(
        question: 'What is the first letter of "Apple"?',
        emoji: '🍎',
        options: ['A', 'E', 'P', 'L'],
        correctIndex: 0,
        objectiveCode: '1Rw.01'),
    const Question(
        question: 'Which word starts with "B"?',
        emoji: '🐝',
        options: ['Ball', 'Cat', 'Dog', 'Egg'],
        correctIndex: 0),
    const Question(
        question: 'A sentence must start with a ...',
        emoji: '✏️',
        options: ['Capital letter', 'Number', 'Space', 'Dot'],
        correctIndex: 0,
        objectiveCode: '1Wg.01'),
    const Question(
        question: 'What comes after the letter "C"?',
        emoji: '🔡',
        options: ['D', 'B', 'A', 'F'],
        correctIndex: 0),
    const Question(
        question: 'Which one is a color?',
        emoji: '🎨',
        options: ['Red', 'Run', 'Rat', 'Rug'],
        correctIndex: 0),
    Question.trueFalse(
        statement: '"cat" starts with the letter C.',
        isTrue: true,
        emoji: '🐱'),
    Question.trueFalse(
        statement: 'The letter "S" makes a "buzz" sound.',
        isTrue: false,
        emoji: '🐍'),
    const Question(
        question: 'How many letters are in the word "sun"?',
        emoji: '☀️',
        options: ['3', '2', '4', '5'],
        correctIndex: 0),
    const Question(
        question: 'Which word means the opposite of "big"?',
        emoji: '📏',
        options: ['Small', 'Tall', 'Fat', 'Long'],
        correctIndex: 0),
  ];

  // ── Bahasa Indonesia (huruf kapital, kata dasar) ──
  static final List<Question> _indonesian = [
    const Question(
        question: 'Huruf pertama pada nama orang ditulis dengan huruf ...',
        emoji: '✏️',
        options: ['Kapital', 'Kecil', 'Angka', 'Miring'],
        correctIndex: 0),
    const Question(
        question: 'Manakah penulisan yang benar?',
        emoji: '📝',
        options: ['Budi', 'budi', 'BUDI', 'bUdi'],
        correctIndex: 0),
    const Question(
        question: 'Kata "buku" diawali huruf ...',
        emoji: '📚',
        options: ['B', 'K', 'U', 'O'],
        correctIndex: 0),
    const Question(
        question: 'Berapa suku kata pada kata "ma-ma"?',
        emoji: '👩',
        options: ['2', '1', '3', '4'],
        correctIndex: 0),
    const Question(
        question: 'Manakah yang termasuk buah?',
        emoji: '🍌',
        options: ['Pisang', 'Meja', 'Sapu', 'Baju'],
        correctIndex: 0),
    Question.trueFalse(
        statement: 'Nama hari "senin" ditulis dengan huruf kapital di awal.',
        isTrue: true,
        emoji: '📅'),
    const Question(
        question: 'Lawan kata "besar" adalah ...',
        emoji: '📏',
        options: ['Kecil', 'Tinggi', 'Panjang', 'Berat'],
        correctIndex: 0),
    const Question(
        question: 'Kata "i-bu" terdiri dari ... suku kata',
        emoji: '👩',
        options: ['2', '1', '3', '4'],
        correctIndex: 0),
    const Question(
        question: 'Manakah kata yang benar untuk hewan ini? 🐈',
        emoji: '🐈',
        options: ['Kucing', 'Kucng', 'Kuncing', 'Kicung'],
        correctIndex: 0),
    const Question(
        question: 'Huruf vokal di bawah ini adalah ...',
        emoji: '🔤',
        options: ['A', 'B', 'C', 'D'],
        correctIndex: 0),
  ];

  // ── Sains (hewan, tumbuhan, cuaca; hidup/tak hidup) ──
  static final List<Question> _science = [
    const Question(
        question: 'Manakah yang termasuk makhluk hidup?',
        emoji: '🌱',
        options: ['Tumbuhan', 'Batu', 'Meja', 'Sepatu'],
        correctIndex: 0,
        objectiveCode: '1Bp.01'),
    Question.trueFalse(
        statement: 'Ikan bernapas dengan insang.',
        isTrue: true,
        emoji: '🐟'),
    Question.trueFalse(
        statement: 'Batu bisa tumbuh besar seperti tanaman.',
        isTrue: false,
        emoji: '🪨'),
    const Question(
        question: 'Hewan ini hidup di ... 🐟',
        emoji: '🐟',
        options: ['Air', 'Udara', 'Pohon', 'Pasir'],
        correctIndex: 0),
    const Question(
        question: 'Saat hujan, langit biasanya ...',
        emoji: '🌧️',
        options: ['Mendung', 'Cerah', 'Berbintang', 'Panas'],
        correctIndex: 0),
    const Question(
        question: 'Bagian tumbuhan yang menyerap air dari tanah adalah ...',
        emoji: '🌳',
        options: ['Akar', 'Daun', 'Bunga', 'Buah'],
        correctIndex: 0),
    const Question(
        question: 'Manakah hewan yang bisa terbang?',
        emoji: '🐦',
        options: ['Burung', 'Ikan', 'Kucing', 'Ular'],
        correctIndex: 0),
    const Question(
        question: 'Matahari muncul pada waktu ...',
        emoji: '☀️',
        options: ['Siang', 'Malam', 'Tengah malam', 'Dini hari'],
        correctIndex: 0),
    Question.trueFalse(
        statement: 'Tumbuhan membutuhkan air untuk hidup.',
        isTrue: true,
        emoji: '💧'),
    const Question(
        question: 'Manakah yang BUKAN makhluk hidup?',
        emoji: '🚗',
        options: ['Mobil', 'Kucing', 'Pohon', 'Burung'],
        correctIndex: 0,
        objectiveCode: '1Bp.01'),
  ];

  // ── Agama Islam (Rukun Islam, doa sehari-hari) ──
  static final List<Question> _religion = [
    const Question(
        question: 'Rukun Islam ada berapa?',
        emoji: '☪️',
        options: ['5', '4', '6', '3'],
        correctIndex: 0),
    const Question(
        question: 'Rukun Islam yang pertama adalah ...',
        emoji: '🕌',
        options: ['Syahadat', 'Puasa', 'Zakat', 'Haji'],
        correctIndex: 0),
    const Question(
        question: 'Kita membaca "Bismillah" sebelum ...',
        emoji: '🤲',
        options: ['Makan', 'Tidur siang saja', 'Bermain saja', 'Menangis'],
        correctIndex: 0),
    const Question(
        question: 'Umat Islam beribadah wajib sehari ... kali sholat',
        emoji: '🕌',
        options: ['5', '3', '4', '6'],
        correctIndex: 0),
    Question.trueFalse(
        statement: 'Kita mengucapkan "Alhamdulillah" saat bersyukur.',
        isTrue: true,
        emoji: '🤲'),
    const Question(
        question: 'Sebelum tidur kita membaca ...',
        emoji: '😴',
        options: ['Doa', 'Lagu', 'Cerita', 'Angka'],
        correctIndex: 0),
    const Question(
        question: 'Kitab suci umat Islam adalah ...',
        emoji: '📖',
        options: ['Al-Quran', 'Kamus', 'Komik', 'Majalah'],
        correctIndex: 0),
    Question.trueFalse(
        statement: 'Kita mengucap salam "Assalamualaikum" saat bertemu teman.',
        isTrue: true,
        emoji: '🤝'),
    const Question(
        question: 'Tempat ibadah umat Islam disebut ...',
        emoji: '🕌',
        options: ['Masjid', 'Pasar', 'Sekolah', 'Taman'],
        correctIndex: 0),
    const Question(
        question: 'Nabi terakhir umat Islam adalah Nabi ...',
        emoji: '🌙',
        options: ['Muhammad SAW', 'Adam AS', 'Nuh AS', 'Musa AS'],
        correctIndex: 0),
  ];

  // ── IPS (keluarga, rumah, lingkungan) ──
  static final List<Question> _ips = [
    const Question(
        question: 'Ayah dan ibu dari kita disebut ...',
        emoji: '👨‍👩‍👧',
        options: ['Orang tua', 'Tetangga', 'Guru', 'Teman'],
        correctIndex: 0),
    const Question(
        question: 'Kakak dari ibu kita adalah ...',
        emoji: '👩',
        options: ['Tante/Bude', 'Nenek', 'Adik', 'Paman'],
        correctIndex: 0),
    const Question(
        question: 'Tempat kita tinggal bersama keluarga disebut ...',
        emoji: '🏠',
        options: ['Rumah', 'Kantor', 'Pasar', 'Kebun'],
        correctIndex: 0),
    const Question(
        question: 'Orang yang tinggal di dekat rumah kita disebut ...',
        emoji: '🏘️',
        options: ['Tetangga', 'Guru', 'Dokter', 'Sopir'],
        correctIndex: 0),
    const Question(
        question: 'Kita membuang sampah di ...',
        emoji: '🗑️',
        options: ['Tempat sampah', 'Sungai', 'Jalan', 'Taman'],
        correctIndex: 0),
    Question.trueFalse(
        statement: 'Kita harus menyayangi anggota keluarga.',
        isTrue: true,
        emoji: '❤️'),
    const Question(
        question: 'Di sekolah kita belajar bersama ...',
        emoji: '🏫',
        options: ['Guru', 'Petani', 'Nelayan', 'Pilot'],
        correctIndex: 0),
    const Question(
        question: 'Orang yang mengajar di sekolah disebut ...',
        emoji: '👩‍🏫',
        options: ['Guru', 'Dokter', 'Polisi', 'Koki'],
        correctIndex: 0),
    Question.trueFalse(
        statement: 'Kita harus menjaga kebersihan lingkungan.',
        isTrue: true,
        emoji: '🧹'),
    const Question(
        question: 'Bendera negara Indonesia berwarna ...',
        emoji: '🇮🇩',
        options: ['Merah dan Putih', 'Biru dan Putih', 'Hijau', 'Kuning'],
        correctIndex: 0),
  ];
}
