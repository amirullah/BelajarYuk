import '../models/question.dart';
import '../models/subject.dart';

/// Bank soal starter Kelas 2 (usia 7-8 th) — aligned Stage 2 per rencana:
/// Math (s/d 100, via generator), English (ejaan/membaca), BI (kalimat/ejaan),
/// Sains (siklus air, bagian tumbuhan), Agama (Rukun Iman, sholat), IPS.
class ContentKelas2 {
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

  // ── English (Stage 2: ejaan, membaca kata, tanda baca) ──
  static final List<Question> _english = [
    const Question(
        question: 'Which is the correct spelling?',
        emoji: '📝',
        options: ['house', 'hause', 'hows', 'huse'],
        correctIndex: 0),
    const Question(
        question: 'What is the plural of "cat"?',
        emoji: '🐱',
        options: ['cats', 'cates', 'caties', 'cat'],
        correctIndex: 0),
    const Question(
        question: 'A question ends with a ...',
        emoji: '❓',
        options: ['?', '.', '!', ','],
        correctIndex: 0),
    const Question(
        question: 'Which word is a body part?',
        emoji: '✋',
        options: ['hand', 'chair', 'apple', 'blue'],
        correctIndex: 0),
    Question.trueFalse(
        statement: '"dog" and "log" rhyme.', isTrue: true, emoji: '🐶'),
    const Question(
        question: 'Choose the correct word: "I ___ a book."',
        emoji: '📖',
        options: ['read', 'reads', 'reading', 'reader'],
        correctIndex: 0),
    const Question(
        question: 'What comes after "twenty"?',
        emoji: '🔢',
        options: ['twenty-one', 'thirty', 'ten', 'eleven'],
        correctIndex: 0),
    const Question(
        question: 'Which is an action word (verb)?',
        emoji: '🏃',
        options: ['run', 'table', 'red', 'happy'],
        correctIndex: 0),
    Question.trueFalse(
        statement: 'A sentence ends with a full stop.',
        isTrue: true,
        emoji: '⏹️'),
    const Question(
        question: 'Opposite of "hot"?',
        emoji: '🔥',
        options: ['cold', 'warm', 'big', 'fast'],
        correctIndex: 0),
  ];

  // ── Bahasa Indonesia (Stage 2: kalimat sederhana, ejaan) ──
  static final List<Question> _indonesian = [
    const Question(
        question: 'Kalimat yang benar adalah ...',
        emoji: '📝',
        options: [
          'Saya makan nasi.',
          'saya makan nasi',
          'Saya Makan Nasi',
          'SAYA makan nasi'
        ],
        correctIndex: 0),
    const Question(
        question: 'Kalimat diakhiri dengan tanda ...',
        emoji: '⏹️',
        options: ['titik (.)', 'koma (,)', 'tanya (?)', 'seru (!)'],
        correctIndex: 0),
    const Question(
        question: 'Lawan kata "panjang" adalah ...',
        emoji: '📏',
        options: ['pendek', 'lebar', 'tinggi', 'besar'],
        correctIndex: 0),
    const Question(
        question: 'Kata "sekolah" memiliki ... suku kata',
        emoji: '🏫',
        options: ['3', '2', '4', '1'],
        correctIndex: 0),
    const Question(
        question: 'Manakah kata kerja?',
        emoji: '🏃',
        options: ['berlari', 'meja', 'merah', 'besar'],
        correctIndex: 0),
    Question.trueFalse(
        statement: 'Nama kota "Jakarta" diawali huruf kapital.',
        isTrue: true,
        emoji: '🏙️'),
    const Question(
        question: 'Ejaan yang benar untuk buah ini 🍓',
        emoji: '🍓',
        options: ['stroberi', 'stroberY', 'setroberi', 'strobery'],
        correctIndex: 0),
    const Question(
        question: 'Tanda untuk kalimat tanya adalah ...',
        emoji: '❓',
        options: ['?', '.', '!', ':'],
        correctIndex: 0),
    const Question(
        question: 'Sinonim (persamaan kata) dari "pintar" adalah ...',
        emoji: '🧠',
        options: ['cerdas', 'malas', 'lambat', 'kecil'],
        correctIndex: 0),
    Question.trueFalse(
        statement: '"Ibu pergi ke pasar" adalah kalimat lengkap.',
        isTrue: true,
        emoji: '🛒'),
  ];

  // ── Sains (Stage 2: siklus air, bagian tumbuhan) ──
  static final List<Question> _science = [
    const Question(
        question: 'Air hujan berasal dari ... yang menguap',
        emoji: '🌊',
        options: ['air laut', 'batu', 'pasir', 'kayu'],
        correctIndex: 0),
    const Question(
        question: 'Bagian tumbuhan yang membuat makanan adalah ...',
        emoji: '🍃',
        options: ['daun', 'akar', 'batang', 'bunga'],
        correctIndex: 0),
    Question.trueFalse(
        statement: 'Uap air naik ke langit membentuk awan.',
        isTrue: true,
        emoji: '☁️'),
    const Question(
        question: 'Bagian bunga yang berwarna cerah untuk menarik lebah ...',
        emoji: '🌸',
        options: ['kelopak', 'akar', 'batang', 'biji'],
        correctIndex: 0),
    const Question(
        question: 'Urutan siklus air: menguap → ... → hujan',
        emoji: '🌧️',
        options: ['mengembun', 'membeku', 'mencair', 'terbakar'],
        correctIndex: 0),
    const Question(
        question: 'Tumbuhan bernapas melalui ...',
        emoji: '🌿',
        options: ['daun', 'akar saja', 'bunga saja', 'buah'],
        correctIndex: 0),
    Question.trueFalse(
        statement: 'Akar menyerap air dan zat hara dari tanah.',
        isTrue: true,
        emoji: '🌱'),
    const Question(
        question: 'Awan yang penuh air akan turun menjadi ...',
        emoji: '🌧️',
        options: ['hujan', 'salju panas', 'api', 'angin'],
        correctIndex: 0),
    const Question(
        question: 'Bagian tumbuhan yang menopang berdiri tegak ...',
        emoji: '🌳',
        options: ['batang', 'daun', 'bunga', 'buah'],
        correctIndex: 0),
    Question.trueFalse(
        statement: 'Matahari membantu air menguap.',
        isTrue: true,
        emoji: '☀️'),
  ];

  // ── Agama Islam (Stage 2: Rukun Iman, tata cara sholat) ──
  static final List<Question> _religion = [
    const Question(
        question: 'Rukun Iman ada berapa?',
        emoji: '☪️',
        options: ['6', '5', '4', '7'],
        correctIndex: 0),
    const Question(
        question: 'Sebelum sholat kita harus ...',
        emoji: '💧',
        options: ['wudhu', 'makan', 'tidur', 'bermain'],
        correctIndex: 0),
    const Question(
        question: 'Iman kepada Allah adalah Rukun Iman yang ke- ...',
        emoji: '🕌',
        options: ['1', '2', '3', '6'],
        correctIndex: 0),
    const Question(
        question: 'Sholat Subuh berjumlah ... rakaat',
        emoji: '🌅',
        options: ['2', '3', '4', '1'],
        correctIndex: 0),
    Question.trueFalse(
        statement: 'Kita menghadap kiblat saat sholat.',
        isTrue: true,
        emoji: '🕋'),
    const Question(
        question: 'Gerakan sholat setelah berdiri adalah ...',
        emoji: '🤲',
        options: ['rukuk', 'sujud', 'salam', 'duduk'],
        correctIndex: 0),
    const Question(
        question: 'Kita beriman kepada ... Allah (kitab suci)',
        emoji: '📖',
        options: ['kitab', 'rumah', 'pohon', 'gunung'],
        correctIndex: 0),
    Question.trueFalse(
        statement: 'Wudhu membersihkan diri sebelum beribadah.',
        isTrue: true,
        emoji: '💧'),
    const Question(
        question: 'Sholat sehari semalam ada ... waktu',
        emoji: '🕌',
        options: ['5', '3', '6', '4'],
        correctIndex: 0),
    const Question(
        question: 'Setelah rukuk, gerakan berikutnya adalah ...',
        emoji: '🧎',
        options: ["i'tidal (berdiri)", 'makan', 'tidur', 'lari'],
        correctIndex: 0),
  ];

  // ── IPS (lingkungan, sekolah, pekerjaan) ──
  static final List<Question> _ips = [
    const Question(
        question: 'Orang yang menjaga keamanan lingkungan adalah ...',
        emoji: '👮',
        options: ['polisi', 'petani', 'nelayan', 'guru'],
        correctIndex: 0),
    const Question(
        question: 'Tempat membeli kebutuhan sehari-hari adalah ...',
        emoji: '🏪',
        options: ['pasar/toko', 'masjid', 'sekolah', 'sungai'],
        correctIndex: 0),
    const Question(
        question: 'Petani bekerja di ...',
        emoji: '🌾',
        options: ['sawah', 'laut', 'kantor', 'langit'],
        correctIndex: 0),
    const Question(
        question: 'Kita menyeberang jalan di ...',
        emoji: '🚸',
        options: ['zebra cross', 'tengah jalan', 'lampu merah', 'atap'],
        correctIndex: 0),
    Question.trueFalse(
        statement: 'Kita harus menaati aturan di sekolah.',
        isTrue: true,
        emoji: '🏫'),
    const Question(
        question: 'Orang yang mengobati orang sakit adalah ...',
        emoji: '👨‍⚕️',
        options: ['dokter', 'sopir', 'petani', 'nelayan'],
        correctIndex: 0),
    const Question(
        question: 'Nelayan menangkap ikan di ...',
        emoji: '🎣',
        options: ['laut', 'sawah', 'gunung', 'kota'],
        correctIndex: 0),
    Question.trueFalse(
        statement: 'Membuang sampah pada tempatnya menjaga lingkungan.',
        isTrue: true,
        emoji: '🗑️'),
    const Question(
        question: 'Ibu kota negara Indonesia adalah ...',
        emoji: '🏙️',
        options: ['Jakarta', 'Bandung', 'Medan', 'Surabaya'],
        correctIndex: 0),
    const Question(
        question: 'Kita menghormati orang yang lebih ...',
        emoji: '🙇',
        options: ['tua', 'kaya', 'tinggi', 'cepat'],
        correctIndex: 0),
  ];
}
