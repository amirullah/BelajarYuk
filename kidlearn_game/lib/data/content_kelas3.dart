import '../models/question.dart';
import '../models/subject.dart';

/// Bank soal Kelas 3 (usia 8-9 th) — aligned Stage 3 per rencana:
/// English (paragraf, jenis kata), BI (paragraf, sinonim/antonim),
/// Sains (metamorfosis, pencernaan), Agama (surat pendek Juz 'Amma), IPS (budaya).
class ContentKelas3 {
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
    const Question(question: 'Which is a question word?', emoji: '❓', options: ['What', 'Table', 'Run', 'Blue'], correctIndex: 0),
    const Question(question: 'What day comes after Monday?', emoji: '📅', options: ['Tuesday', 'Sunday', 'Friday', 'March'], correctIndex: 0),
    const Question(question: 'Which word is a noun?', emoji: '🏠', options: ['house', 'jump', 'quickly', 'happy'], correctIndex: 0),
    const Question(question: 'Which month has "May" in it?', emoji: '🗓️', options: ['May', 'Monday', 'Maybe', 'Man'], correctIndex: 0),
    Question.trueFalse(statement: '"They are playing" uses a verb.', isTrue: true, emoji: '⚽'),
    const Question(question: 'Choose the adjective: "a ___ dog"', emoji: '🐕', options: ['big', 'run', 'slowly', 'jump'], correctIndex: 0),
    const Question(question: 'Past form of "play"?', emoji: '🎮', options: ['played', 'plaid', 'playing', 'plays'], correctIndex: 0),
    const Question(question: 'How many days in a week?', emoji: '📆', options: ['7', '5', '10', '12'], correctIndex: 0),
  ];

  static final List<Question> _indonesian = [
    const Question(question: 'Sinonim dari "gembira" adalah ...', emoji: '😊', options: ['senang', 'sedih', 'marah', 'takut'], correctIndex: 0),
    const Question(question: 'Antonim dari "tinggi" adalah ...', emoji: '📏', options: ['rendah', 'besar', 'panjang', 'lebar'], correctIndex: 0),
    const Question(question: 'Gabungan beberapa kalimat menjadi satu disebut ...', emoji: '📄', options: ['paragraf', 'huruf', 'kata', 'titik'], correctIndex: 0),
    const Question(question: 'Kata tanya untuk menanyakan tempat adalah ...', emoji: '📍', options: ['di mana', 'siapa', 'kapan', 'berapa'], correctIndex: 0),
    Question.trueFalse(statement: '"cepat" adalah lawan kata dari "lambat".', isTrue: true, emoji: '🏃'),
    const Question(question: 'Sinonim "pandai" adalah ...', emoji: '🧠', options: ['pintar', 'bodoh', 'malas', 'lelah'], correctIndex: 0),
    const Question(question: 'Kata tanya untuk menanyakan orang adalah ...', emoji: '🙋', options: ['siapa', 'di mana', 'mengapa', 'berapa'], correctIndex: 0),
    const Question(question: 'Antonim "buka" adalah ...', emoji: '🚪', options: ['tutup', 'dorong', 'tarik', 'geser'], correctIndex: 0),
  ];

  static final List<Question> _science = [
    const Question(question: 'Kupu-kupu berasal dari ...', emoji: '🦋', options: ['ulat', 'ikan', 'burung', 'semut'], correctIndex: 0),
    const Question(question: 'Urutan metamorfosis kupu-kupu: telur → ulat → ... → kupu-kupu', emoji: '🐛', options: ['kepompong', 'ikan', 'katak', 'lebah'], correctIndex: 0),
    const Question(question: 'Organ pencernaan tempat makanan dikunyah adalah ...', emoji: '👄', options: ['mulut', 'kaki', 'mata', 'telinga'], correctIndex: 0),
    Question.trueFalse(statement: 'Lambung membantu mencerna makanan.', isTrue: true, emoji: '🫃'),
    const Question(question: 'Katak muda disebut ...', emoji: '🐸', options: ['berudu', 'ulat', 'kepompong', 'anak ayam'], correctIndex: 0),
    const Question(question: 'Gigi berguna untuk ... makanan', emoji: '🦷', options: ['mengunyah', 'melihat', 'mendengar', 'mencium'], correctIndex: 0),
    Question.trueFalse(statement: 'Semua serangga mengalami metamorfosis sempurna.', isTrue: false, emoji: '🦗'),
    const Question(question: 'Makanan masuk ke perut melalui ...', emoji: '🍽️', options: ['kerongkongan', 'hidung', 'telinga', 'mata'], correctIndex: 0),
  ];

  static final List<Question> _religion = [
    const Question(question: 'Surat Al-Fatihah terdiri dari ... ayat', emoji: '📖', options: ['7', '5', '6', '10'], correctIndex: 0),
    const Question(question: 'Surat Al-Ikhlas berisi tentang ...', emoji: '🕌', options: ['ke-Esa-an Allah', 'puasa', 'zakat', 'haji'], correctIndex: 0),
    const Question(question: 'Al-Fatihah adalah surat ke- ... dalam Al-Quran', emoji: '📕', options: ['1', '2', '10', '114'], correctIndex: 0),
    Question.trueFalse(statement: 'Kita membaca Al-Fatihah dalam setiap sholat.', isTrue: true, emoji: '🤲'),
    const Question(question: 'Surat An-Nas mengajarkan kita berlindung kepada ...', emoji: '🛡️', options: ['Allah', 'teman', 'guru', 'hewan'], correctIndex: 0),
    const Question(question: 'Juz \'Amma adalah juz ke- ... dalam Al-Quran', emoji: '📖', options: ['30', '1', '15', '20'], correctIndex: 0),
    Question.trueFalse(statement: 'Membaca Al-Quran termasuk ibadah.', isTrue: true, emoji: '📖'),
    const Question(question: 'Surat Al-Ikhlas terdiri dari ... ayat', emoji: '📕', options: ['4', '7', '5', '10'], correctIndex: 0),
  ];

  static final List<Question> _ips = [
    const Question(question: 'Rumah adat dari Sumatera Barat adalah ...', emoji: '🏠', options: ['Rumah Gadang', 'Joglo', 'Honai', 'Tongkonan'], correctIndex: 0),
    const Question(question: 'Alat musik angklung berasal dari ...', emoji: '🎶', options: ['Jawa Barat', 'Papua', 'Bali', 'Aceh'], correctIndex: 0),
    const Question(question: 'Tarian daerah dari Aceh adalah ...', emoji: '💃', options: ['Saman', 'Kecak', 'Jaipong', 'Reog'], correctIndex: 0),
    Question.trueFalse(statement: 'Indonesia memiliki banyak suku dan budaya.', isTrue: true, emoji: '🇮🇩'),
    const Question(question: 'Pulau terbesar di Indonesia bagian tengah, tempat Komodo hidup ...', emoji: '🦎', options: ['Nusa Tenggara', 'Jawa', 'Sumatera', 'Kalimantan'], correctIndex: 0),
    const Question(question: 'Candi Borobudur terletak di ...', emoji: '🛕', options: ['Jawa Tengah', 'Bali', 'Papua', 'Aceh'], correctIndex: 0),
    const Question(question: 'Semboyan bangsa Indonesia adalah ...', emoji: '🇮🇩', options: ['Bhinneka Tunggal Ika', 'Merdeka', 'Pancasila', 'Sumpah Pemuda'], correctIndex: 0),
    Question.trueFalse(statement: 'Gotong royong adalah bekerja sama membantu sesama.', isTrue: true, emoji: '🤝'),
  ];
}
