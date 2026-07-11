import '../models/question.dart';
import '../models/subject.dart';

/// Bank soal Kelas 4 (usia 9-10 th) — aligned Stage 4 per rencana:
/// English (apostrof, strategi baca), BI (puisi, teks deskripsi),
/// Sains (energi, gaya & gerak), Agama (kisah Nabi, fiqh puasa), IPS.
class ContentKelas4 {
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
    const Question(question: 'Which shows possession?', emoji: '✏️', options: ["Ani's book", 'Anis book', 'Ani book', 'book Ani'], correctIndex: 0),
    const Question(question: 'Correct: "It ___ raining."', emoji: '🌧️', options: ['is', 'are', 'am', 'be'], correctIndex: 0),
    const Question(question: 'Simple present of "she (go)": She ___ to school.', emoji: '🏫', options: ['goes', 'go', 'going', 'gone'], correctIndex: 0),
    const Question(question: 'Plural of "child"?', emoji: '🧒', options: ['children', 'childs', 'childes', 'child'], correctIndex: 0),
    Question.trueFalse(statement: '"dogs\'" shows something belongs to many dogs.', isTrue: true, emoji: '🐕'),
    const Question(question: 'Which is correct?', emoji: '📖', options: ['I have read', 'I have readed', 'I has read', 'I reading'], correctIndex: 0),
    const Question(question: 'Synonym of "big"?', emoji: '🐘', options: ['large', 'small', 'tiny', 'thin'], correctIndex: 0),
    const Question(question: 'Opposite of "always"?', emoji: '🔁', options: ['never', 'often', 'sometimes', 'usually'], correctIndex: 0),
  ];

  static final List<Question> _indonesian = [
    const Question(question: 'Karya sastra yang terikat rima dan bait disebut ...', emoji: '📜', options: ['puisi', 'cerpen', 'berita', 'surat'], correctIndex: 0),
    const Question(question: 'Teks yang menggambarkan suatu benda secara rinci disebut teks ...', emoji: '🔍', options: ['deskripsi', 'narasi', 'prosedur', 'laporan'], correctIndex: 0),
    const Question(question: 'Bagian akhir baris puisi yang berbunyi mirip disebut ...', emoji: '🎵', options: ['rima', 'bait', 'judul', 'tema'], correctIndex: 0),
    Question.trueFalse(statement: 'Puisi biasanya menggunakan bahasa yang indah.', isTrue: true, emoji: '🌸'),
    const Question(question: 'Kumpulan beberapa baris dalam puisi disebut ...', emoji: '📝', options: ['bait', 'paragraf', 'kalimat', 'huruf'], correctIndex: 0),
    const Question(question: 'Teks deskripsi bertujuan untuk ...', emoji: '🖼️', options: ['menggambarkan', 'menyuruh', 'melarang', 'bertanya'], correctIndex: 0),
    const Question(question: 'Antonim "terang" adalah ...', emoji: '💡', options: ['gelap', 'jauh', 'cepat', 'ringan'], correctIndex: 0),
    Question.trueFalse(statement: 'Judul puisi ditulis di awal.', isTrue: true, emoji: '📖'),
  ];

  static final List<Question> _science = [
    const Question(question: 'Energi dari matahari disebut energi ...', emoji: '☀️', options: ['cahaya & panas', 'listrik', 'suara', 'gerak'], correctIndex: 0),
    const Question(question: 'Gaya yang membuat benda jatuh ke bawah adalah ...', emoji: '🍎', options: ['gravitasi', 'gesek', 'magnet', 'otot'], correctIndex: 0),
    const Question(question: 'Kipas angin mengubah energi listrik menjadi energi ...', emoji: '🌀', options: ['gerak', 'suara', 'cahaya', 'kimia'], correctIndex: 0),
    Question.trueFalse(statement: 'Gaya dapat mengubah bentuk benda.', isTrue: true, emoji: '🏀'),
    const Question(question: 'Magnet dapat menarik benda dari ...', emoji: '🧲', options: ['besi', 'kayu', 'plastik', 'kertas'], correctIndex: 0),
    const Question(question: 'Lampu mengubah energi listrik menjadi energi ...', emoji: '💡', options: ['cahaya', 'gerak', 'suara', 'gravitasi'], correctIndex: 0),
    Question.trueFalse(statement: 'Gaya gesek memperlambat gerak benda.', isTrue: true, emoji: '🛞'),
    const Question(question: 'Sumber energi utama di Bumi adalah ...', emoji: '🌍', options: ['matahari', 'bulan', 'bintang', 'angin'], correctIndex: 0),
  ];

  static final List<Question> _religion = [
    const Question(question: 'Nabi yang membangun kapal besar adalah Nabi ...', emoji: '🚢', options: ['Nuh AS', 'Musa AS', 'Isa AS', 'Yusuf AS'], correctIndex: 0),
    const Question(question: 'Puasa Ramadhan dilakukan selama ... hari (sebulan)', emoji: '🌙', options: ['29-30', '7', '10', '40'], correctIndex: 0),
    const Question(question: 'Saat puasa kita menahan diri dari ... dari subuh hingga maghrib', emoji: '🍽️', options: ['makan dan minum', 'berbicara', 'berjalan', 'belajar'], correctIndex: 0),
    Question.trueFalse(statement: 'Nabi Musa AS diberi mukjizat tongkat.', isTrue: true, emoji: '🪄'),
    const Question(question: 'Makan sebelum berpuasa (dini hari) disebut ...', emoji: '🌅', options: ['sahur', 'berbuka', 'sholat', 'zakat'], correctIndex: 0),
    const Question(question: 'Membatalkan puasa saat maghrib disebut ...', emoji: '🌆', options: ['berbuka', 'sahur', 'imsak', 'wudhu'], correctIndex: 0),
    Question.trueFalse(statement: 'Puasa mengajarkan kita menahan diri dan bersabar.', isTrue: true, emoji: '🤲'),
    const Question(question: 'Nabi Ibrahim AS adalah ayah dari Nabi ...', emoji: '🕋', options: ['Ismail AS', 'Nuh AS', 'Adam AS', 'Isa AS'], correctIndex: 0),
  ];

  static final List<Question> _ips = [
    const Question(question: 'Kegiatan menghasilkan barang disebut ...', emoji: '🏭', options: ['produksi', 'konsumsi', 'distribusi', 'donasi'], correctIndex: 0),
    const Question(question: 'Orang yang memakai/menggunakan barang disebut ...', emoji: '🛍️', options: ['konsumen', 'produsen', 'penjual', 'petani'], correctIndex: 0),
    const Question(question: 'Sumber daya alam yang dapat diperbarui contohnya ...', emoji: '🌳', options: ['air dan pohon', 'minyak bumi', 'batu bara', 'emas'], correctIndex: 0),
    Question.trueFalse(statement: 'Menanam kembali pohon disebut reboisasi.', isTrue: true, emoji: '🌲'),
    const Question(question: 'Pahlawan yang dijuluki "Ayam Jantan dari Timur" adalah ...', emoji: '⚔️', options: ['Sultan Hasanuddin', 'Diponegoro', 'Imam Bonjol', 'Kartini'], correctIndex: 0),
    const Question(question: 'Kegiatan menyalurkan barang ke konsumen disebut ...', emoji: '🚚', options: ['distribusi', 'produksi', 'konsumsi', 'promosi'], correctIndex: 0),
    const Question(question: 'R.A. Kartini memperjuangkan hak ...', emoji: '👩', options: ['perempuan', 'petani', 'nelayan', 'pedagang'], correctIndex: 0),
    Question.trueFalse(statement: 'Kita harus menghemat sumber daya alam.', isTrue: true, emoji: '💧'),
  ];
}
