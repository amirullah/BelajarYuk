import '../models/question.dart';
import '../models/subject.dart';

/// Bank soal Kelas 6 (usia 11-12 th) — aligned Stage 6 per rencana:
/// English (comprehension, menulis formal), BI (surat resmi, pidato),
/// Sains (listrik, bumi & alam semesta), Agama (hari akhir, muamalah), IPS.
class ContentKelas6 {
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
    const Question(question: 'A formal letter usually begins with ...', emoji: '✉️', options: ['Dear Sir/Madam', 'Hi', 'Yo', 'Hey there'], correctIndex: 0),
    const Question(question: 'Which is a formal word for "kid"?', emoji: '🧒', options: ['child', 'buddy', 'pal', 'dude'], correctIndex: 0),
    const Question(question: 'Read: "The sun rises in the east." Where does the sun rise?', emoji: '🌅', options: ['east', 'west', 'north', 'south'], correctIndex: 0),
    const Question(question: 'Best closing for a formal letter?', emoji: '📝', options: ['Yours sincerely', 'Bye', 'See ya', 'Cheers mate'], correctIndex: 0),
    Question.trueFalse(statement: 'A comprehension question tests understanding of a text.', isTrue: true, emoji: '📖'),
    const Question(question: 'Correct passive: "The book ___ by Ani."', emoji: '📚', options: ['was read', 'read', 'reads', 'reading'], correctIndex: 0),
    const Question(question: 'Synonym of "important"?', emoji: '⭐', options: ['significant', 'silly', 'small', 'slow'], correctIndex: 0),
    const Question(question: 'A speech usually starts with a ...', emoji: '🎤', options: ['greeting', 'closing', 'signature', 'address'], correctIndex: 0),
  ];

  static final List<Question> _indonesian = [
    const Question(question: 'Surat resmi menggunakan bahasa ...', emoji: '✉️', options: ['baku/formal', 'gaul', 'santai', 'daerah'], correctIndex: 0),
    const Question(question: 'Bagian surat resmi yang berisi tujuan surat adalah ...', emoji: '📄', options: ['isi surat', 'salam penutup', 'tanda tangan', 'kop surat'], correctIndex: 0),
    const Question(question: 'Pidato biasanya diawali dengan ...', emoji: '🎤', options: ['salam pembuka', 'penutup', 'kesimpulan', 'tanda tangan'], correctIndex: 0),
    Question.trueFalse(statement: 'Surat resmi memakai kop surat dan nomor surat.', isTrue: true, emoji: '📋'),
    const Question(question: 'Kalimat "Mohon kehadiran Bapak/Ibu" termasuk bahasa ...', emoji: '🙏', options: ['formal', 'gaul', 'tidak baku', 'daerah'], correctIndex: 0),
    const Question(question: 'Orang yang menyampaikan pidato disebut ...', emoji: '🗣️', options: ['orator', 'penonton', 'penulis', 'pembaca'], correctIndex: 0),
    const Question(question: 'Ringkasan isi di akhir pidato disebut ...', emoji: '📝', options: ['kesimpulan', 'pembuka', 'salam', 'judul'], correctIndex: 0),
    Question.trueFalse(statement: 'Kata "gue" cocok dipakai dalam surat resmi.', isTrue: false, emoji: '🚫'),
  ];

  static final List<Question> _science = [
    const Question(question: 'Alat untuk memutus/menyambung arus listrik adalah ...', emoji: '🔌', options: ['sakelar', 'lampu', 'kabel', 'baterai'], correctIndex: 0),
    const Question(question: 'Sumber energi listrik pada senter adalah ...', emoji: '🔦', options: ['baterai', 'matahari', 'angin', 'air'], correctIndex: 0),
    const Question(question: 'Rangkaian listrik yang lampunya tetap menyala jika satu putus disebut ...', emoji: '💡', options: ['paralel', 'seri', 'terbuka', 'pendek'], correctIndex: 0),
    const Question(question: 'Bumi berputar pada porosnya disebut ...', emoji: '🌍', options: ['rotasi', 'revolusi', 'gravitasi', 'orbit'], correctIndex: 0),
    Question.trueFalse(statement: 'Rotasi Bumi menyebabkan siang dan malam.', isTrue: true, emoji: '🌗'),
    const Question(question: 'Bumi mengelilingi Matahari disebut ...', emoji: '🔄', options: ['revolusi', 'rotasi', 'gerhana', 'pasang'], correctIndex: 0),
    const Question(question: 'Benda yang menghantarkan listrik disebut ...', emoji: '⚡', options: ['konduktor', 'isolator', 'magnet', 'baterai'], correctIndex: 0),
    Question.trueFalse(statement: 'Karet dan plastik adalah isolator listrik.', isTrue: true, emoji: '🧤'),
  ];

  static final List<Question> _religion = [
    const Question(question: 'Beriman kepada Hari Akhir termasuk Rukun Iman yang ke- ...', emoji: '🌅', options: ['5', '1', '3', '6'], correctIndex: 0),
    const Question(question: 'Hari kiamat disebut juga hari ...', emoji: '⏳', options: ['akhir', 'raya', 'jumat', 'besar'], correctIndex: 0),
    const Question(question: 'Jual beli yang jujur dan halal termasuk ...', emoji: '🤝', options: ['muamalah yang baik', 'riba', 'penipuan', 'dilarang'], correctIndex: 0),
    Question.trueFalse(statement: 'Kita harus jujur dalam berdagang.', isTrue: true, emoji: '⚖️'),
    const Question(question: 'Meminjamkan uang dengan tambahan berlebih (bunga mencekik) disebut ...', emoji: '🚫', options: ['riba', 'zakat', 'infak', 'sedekah'], correctIndex: 0),
    const Question(question: 'Setelah hari akhir, manusia akan dibangkitkan di ...', emoji: '🌄', options: ['akhirat', 'dunia', 'laut', 'gunung'], correctIndex: 0),
    Question.trueFalse(statement: 'Beramal baik menjadi bekal di hari akhir.', isTrue: true, emoji: '🤲'),
    const Question(question: 'Kejujuran dalam muamalah membawa ...', emoji: '💚', options: ['keberkahan', 'kerugian', 'dosa', 'permusuhan'], correctIndex: 0),
  ];

  static final List<Question> _ips = [
    const Question(question: 'ASEAN adalah organisasi negara di kawasan ...', emoji: '🌏', options: ['Asia Tenggara', 'Eropa', 'Afrika', 'Amerika'], correctIndex: 0),
    const Question(question: 'Indonesia memproklamasikan kemerdekaan pada tahun ...', emoji: '🇮🇩', options: ['1945', '1928', '1908', '1965'], correctIndex: 0),
    const Question(question: 'Kegiatan ekspor berarti ... barang ke luar negeri', emoji: '🚢', options: ['menjual', 'membeli', 'menyimpan', 'membuang'], correctIndex: 0),
    Question.trueFalse(statement: 'Indonesia adalah salah satu pendiri ASEAN.', isTrue: true, emoji: '🤝'),
    const Question(question: 'Impor berarti ... barang dari luar negeri', emoji: '📦', options: ['membeli/mendatangkan', 'menjual', 'membuang', 'menanam'], correctIndex: 0),
    const Question(question: 'Proklamator kemerdekaan Indonesia adalah Soekarno dan ...', emoji: '🎙️', options: ['Hatta', 'Sudirman', 'Kartini', 'Diponegoro'], correctIndex: 0),
    const Question(question: 'Mata uang negara Indonesia adalah ...', emoji: '💵', options: ['Rupiah', 'Ringgit', 'Dolar', 'Peso'], correctIndex: 0),
    Question.trueFalse(statement: 'Perdagangan antarnegara disebut perdagangan internasional.', isTrue: true, emoji: '🌐'),
  ];
}
