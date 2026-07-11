import '../models/question.dart';
import '../models/subject.dart';

/// Bank soal Kelas 1 — Stage 1 — fonik/huruf, kata dasar, makhluk hidup, Rukun Islam, keluarga.
/// Dihasilkan & diverifikasi otomatis (generate + fact-check), aligned rencana.
/// Catatan: soal Agama Islam perlu review akhir oleh ahli.
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
        return const [];
    }
  }

  static final List<Question> _english = [
    const Question(question: 'Which word begins with the /s/ sound?', emoji: '☀️', options: ['cat', 'sun', 'dog', 'hat'], correctIndex: 1),
    const Question(question: 'What is the first letter of the word \'apple\'?', emoji: '🍎', options: ['a', 'p', 'l', 'e'], correctIndex: 0),
    const Question(question: 'Which letter makes the /m/ sound?', emoji: '🔤', options: ['n', 't', 'm', 'b'], correctIndex: 2),
    const Question(question: 'Which word ends with the /t/ sound?', emoji: '🐱', options: ['cat', 'dog', 'pen', 'bus'], correctIndex: 0),
    const Question(question: 'A sentence should begin with a...', emoji: '🔠', options: ['small letter', 'capital letter', 'number', 'space'], correctIndex: 1),
    const Question(question: 'Which letter comes after \'b\' in the alphabet?', emoji: '🔤', options: ['a', 'd', 'c', 'e'], correctIndex: 2),
    const Question(question: 'Which word begins with the /b/ sound?', emoji: '⚽', options: ['ball', 'cup', 'fish', 'milk'], correctIndex: 0),
    const Question(question: 'What sound does the letter \'c\' make in \'cat\'?', emoji: '🐈', options: ['/s/', '/k/', '/t/', '/p/'], correctIndex: 1),
    const Question(question: 'Which word rhymes with \'cat\'?', emoji: '🎩', options: ['dog', 'hat', 'sun', 'pen'], correctIndex: 1),
    const Question(question: 'How many letters are in the word \'dog\'?', emoji: '🐶', options: ['2', '3', '4', '5'], correctIndex: 1),
    const Question(question: 'Which is the capital letter?', emoji: '✏️', options: ['a', 'b', 'T', 'g'], correctIndex: 2),
    const Question(question: 'Which word begins with the /f/ sound?', emoji: '🐟', options: ['fish', 'sun', 'cat', 'dog'], correctIndex: 0),
    const Question(question: 'What is the last letter of the word \'pen\'?', emoji: '🖊️', options: ['p', 'e', 'n', 'a'], correctIndex: 2),
    const Question(question: 'Which word begins with the /p/ sound?', emoji: '🐷', options: ['dog', 'pig', 'cat', 'sun'], correctIndex: 1),
    Question.trueFalse(statement: 'The letter \'A\' is a capital letter.', isTrue: true, emoji: '🅰️'),
    Question.trueFalse(statement: 'The word \'sun\' begins with the /s/ sound.', isTrue: true, emoji: '☀️'),
    Question.trueFalse(statement: 'We start a sentence with a small letter.', isTrue: false, emoji: '🔡'),
    Question.trueFalse(statement: 'The word \'dog\' has three letters.', isTrue: true, emoji: '🐕'),
    Question.trueFalse(statement: 'The letter \'z\' comes before the letter \'a\' in the alphabet.', isTrue: false, emoji: '🔤'),
    Question.trueFalse(statement: 'The word \'ball\' begins with the /b/ sound.', isTrue: true, emoji: '⚽'),
    const Question(question: 'Write the first letter of the word \'mum\'.', emoji: '👩', type: QuestionType.fillBlank, answer: 'm'),
    const Question(question: 'Write the letter that comes after \'a\' in the alphabet.', emoji: '🔤', type: QuestionType.fillBlank, answer: 'b'),
    const Question(question: 'Write the last letter of the word \'cat\'.', emoji: '🐱', type: QuestionType.fillBlank, answer: 't'),
    const Question(question: 'Write the first letter of the word \'sun\'.', emoji: '☀️', type: QuestionType.fillBlank, answer: 's'),
  ];

  static final List<Question> _indonesian = [
    const Question(question: 'Huruf kapital yang benar untuk awal nama orang adalah...', emoji: '👦', options: ['budi', 'Budi', 'bUdi', 'budI'], correctIndex: 1),
    const Question(question: 'Nama kota harus diawali dengan huruf...', emoji: '🏙️', options: ['kecil', 'kapital', 'angka', 'tanda baca'], correctIndex: 1),
    const Question(question: 'Penulisan yang benar adalah...', emoji: '✍️', options: ['saya tinggal di jakarta', 'Saya tinggal di Jakarta', 'saya Tinggal di Jakarta', 'SAYA tinggal di jakarta'], correctIndex: 1),
    const Question(question: 'Lawan kata dari \'besar\' adalah...', emoji: '🔵', options: ['tinggi', 'kecil', 'panjang', 'berat'], correctIndex: 1),
    const Question(question: 'Lawan kata dari \'panas\' adalah...', emoji: '❄️', options: ['dingin', 'hangat', 'cair', 'kering'], correctIndex: 0),
    const Question(question: 'Lawan kata dari \'tinggi\' adalah...', emoji: '📏', options: ['besar', 'pendek', 'lebar', 'cepat'], correctIndex: 1),
    const Question(question: 'Kata \'buku\' terdiri dari suku kata...', emoji: '📚', options: ['bu-ku', 'b-uku', 'buk-u', 'bu-k-u'], correctIndex: 0),
    const Question(question: 'Kata \'mata\' bila dipisah menjadi suku kata...', emoji: '👁️', options: ['ma-ta', 'mat-a', 'm-ata', 'ma-t-a'], correctIndex: 0),
    const Question(question: 'Berapa suku kata pada kata \'sepeda\'?', emoji: '🚲', options: ['dua', 'tiga', 'empat', 'satu'], correctIndex: 1),
    const Question(question: 'Lawan kata dari \'siang\' adalah...', emoji: '🌙', options: ['pagi', 'sore', 'malam', 'subuh'], correctIndex: 2),
    const Question(question: 'Lawan kata dari \'buka\' adalah...', emoji: '🚪', options: ['tutup', 'dorong', 'tarik', 'angkat'], correctIndex: 0),
    const Question(question: 'Huruf pertama pada awal kalimat ditulis dengan huruf...', emoji: '🔤', options: ['kecil', 'kapital', 'miring', 'tebal'], correctIndex: 1),
    const Question(question: 'Kata dasar dari \'bermain\' adalah...', emoji: '⚽', options: ['main', 'ber', 'bermain', 'mainan'], correctIndex: 0),
    const Question(question: 'Kata dasar dari \'makanan\' adalah...', emoji: '🍚', options: ['makan', 'kan', 'an', 'makanan'], correctIndex: 0),
    Question.trueFalse(statement: 'Nama hari \'senin\' seharusnya ditulis \'Senin\'.', isTrue: true, emoji: '📅'),
    Question.trueFalse(statement: 'Kata \'ibu\' memiliki dua suku kata.', isTrue: true, emoji: '👩'),
    Question.trueFalse(statement: 'Lawan kata dari \'naik\' adalah \'turun\'.', isTrue: true, emoji: '⬇️'),
    Question.trueFalse(statement: 'Awal kalimat ditulis dengan huruf kecil.', isTrue: false, emoji: '✏️'),
    Question.trueFalse(statement: 'Lawan kata dari \'gelap\' adalah \'terang\'.', isTrue: true, emoji: '💡'),
    Question.trueFalse(statement: 'Kata \'rumah\' hanya memiliki satu suku kata.', isTrue: false, emoji: '🏠'),
    const Question(question: 'Lawan kata dari \'atas\' adalah ...', emoji: '⬆️', type: QuestionType.fillBlank, answer: 'bawah'),
    const Question(question: 'Lawan kata dari \'bersih\' adalah ...', emoji: '🧼', type: QuestionType.fillBlank, answer: 'kotor'),
    const Question(question: 'Kata dasar dari \'membaca\' adalah ...', emoji: '📖', type: QuestionType.fillBlank, answer: 'baca'),
  ];

  static final List<Question> _science = [
    const Question(question: 'Manakah yang termasuk makhluk hidup?', emoji: '🐱', options: ['Batu', 'Kucing', 'Meja', 'Sepatu'], correctIndex: 1),
    const Question(question: 'Manakah benda tak hidup di bawah ini?', emoji: '⚽', options: ['Ikan', 'Burung', 'Bola', 'Bunga'], correctIndex: 2),
    const Question(question: 'Makhluk hidup memerlukan ... untuk tumbuh.', emoji: '🍎', options: ['Makanan', 'Kertas', 'Batu', 'Plastik'], correctIndex: 0),
    const Question(question: 'Ikan hidup di ...', emoji: '🐟', options: ['Pohon', 'Air', 'Gua', 'Awan'], correctIndex: 1),
    const Question(question: 'Hewan yang tinggal di kandang dan berkokok adalah ...', emoji: '🐔', options: ['Ayam', 'Gajah', 'Hiu', 'Katak'], correctIndex: 0),
    const Question(question: 'Burung bergerak dengan cara ...', emoji: '🐦', options: ['Berenang', 'Merayap', 'Terbang', 'Melompat'], correctIndex: 2),
    const Question(question: 'Bagian tumbuhan yang menyerap air dari tanah adalah ...', emoji: '🌱', options: ['Daun', 'Bunga', 'Akar', 'Buah'], correctIndex: 2),
    const Question(question: 'Bagian tumbuhan yang berwarna-warni dan harum adalah ...', emoji: '🌸', options: ['Akar', 'Bunga', 'Batang', 'Daun'], correctIndex: 1),
    const Question(question: 'Daun biasanya berwarna ...', emoji: '🍃', options: ['Hijau', 'Hitam', 'Biru', 'Ungu'], correctIndex: 0),
    const Question(question: 'Saat cuaca hujan, kita sebaiknya membawa ...', emoji: '☔', options: ['Kipas', 'Payung', 'Topi', 'Bola'], correctIndex: 1),
    const Question(question: 'Saat cuaca cerah, langit terlihat ...', emoji: '☀️', options: ['Gelap', 'Terang', 'Hitam', 'Berkabut'], correctIndex: 1),
    const Question(question: 'Hewan yang hidup di air dan bisa melompat di darat adalah ...', emoji: '🐸', options: ['Katak', 'Sapi', 'Ayam', 'Kucing'], correctIndex: 0),
    const Question(question: 'Sapi memakan ...', emoji: '🐄', options: ['Rumput', 'Daging', 'Ikan', 'Batu'], correctIndex: 0),
    const Question(question: 'Matahari membuat cuaca menjadi ...', emoji: '🌞', options: ['Dingin', 'Panas', 'Basah', 'Gelap'], correctIndex: 1),
    Question.trueFalse(statement: 'Kucing termasuk makhluk hidup.', isTrue: true, emoji: '🐈'),
    Question.trueFalse(statement: 'Batu bisa bernapas dan tumbuh.', isTrue: false, emoji: '🪨'),
    Question.trueFalse(statement: 'Ikan bisa hidup di darat tanpa air.', isTrue: false, emoji: '🐠'),
    Question.trueFalse(statement: 'Akar tumbuh di dalam tanah.', isTrue: true, emoji: '🌿'),
    Question.trueFalse(statement: 'Saat hujan, kita memakai payung agar tidak basah.', isTrue: true, emoji: '🌧️'),
    Question.trueFalse(statement: 'Burung terbang menggunakan sirip.', isTrue: false, emoji: '🦅'),
    const Question(question: 'Ketika air turun dari langit, kita menyebutnya cuaca ...', emoji: '🌦️', type: QuestionType.fillBlank, answer: 'hujan'),
  ];

  static final List<Question> _religion = [
    const Question(question: 'Rukun Islam yang pertama adalah mengucapkan dua kalimat...', emoji: '☝️', options: ['Syahadat', 'Adzan', 'Iqamah', 'Takbir'], correctIndex: 0),
    const Question(question: 'Umat Islam wajib salat sehari semalam sebanyak...', emoji: '🕌', options: ['3 waktu', '4 waktu', '5 waktu', '6 waktu'], correctIndex: 2),
    const Question(question: 'Kitab suci umat Islam adalah...', emoji: '📖', options: ['Al-Quran', 'Taurat', 'Zabur', 'Injil'], correctIndex: 0),
    const Question(question: 'Sebelum makan kita membaca...', emoji: '🍽️', options: ['Basmalah (Bismillah)', 'Hamdalah', 'Takbir', 'Tahlil'], correctIndex: 0),
    const Question(question: 'Ketika bertemu teman sesama Muslim kita mengucapkan salam...', emoji: '🤝', options: ['Assalamu\'alaikum', 'Selamat pagi', 'Halo', 'Sampai jumpa'], correctIndex: 0),
    const Question(question: 'Jawaban dari salam "Assalamu\'alaikum" adalah...', emoji: '💬', options: ['Wa\'alaikumsalam', 'Alhamdulillah', 'Insya Allah', 'Astaghfirullah'], correctIndex: 0),
    const Question(question: 'Puasa di bulan Ramadan termasuk Rukun Islam yang ke...', emoji: '🌙', options: ['Kesatu', 'Kedua', 'Ketiga', 'Keempat'], correctIndex: 3),
    const Question(question: 'Surah yang pertama dalam Al-Quran adalah...', emoji: '📜', options: ['Al-Fatihah', 'Al-Ikhlas', 'An-Nas', 'Al-Falaq'], correctIndex: 0),
    const Question(question: 'Setelah selesai makan kita membaca...', emoji: '🙏', options: ['Alhamdulillah', 'Bismillah', 'Astaghfirullah', 'Subhanallah'], correctIndex: 0),
    const Question(question: 'Ibadah haji dilakukan di kota...', emoji: '🕋', options: ['Mekah', 'Jakarta', 'Madinah', 'Kairo'], correctIndex: 0),
    const Question(question: 'Tempat umat Islam melaksanakan salat berjamaah adalah...', emoji: '🕌', options: ['Masjid', 'Pasar', 'Sekolah', 'Rumah sakit'], correctIndex: 0),
    const Question(question: 'Ketika akan tidur kita berdoa agar dilindungi oleh...', emoji: '🛌', options: ['Allah', 'teman', 'guru', 'orang tua'], correctIndex: 0),
    const Question(question: 'Membayar zakat termasuk salah satu...', emoji: '💰', options: ['Rukun Islam', 'Rukun sekolah', 'Rukun rumah', 'Rukun bermain'], correctIndex: 0),
    const Question(question: 'Adab yang baik saat makan adalah makan dengan tangan...', emoji: '✋', options: ['Kanan', 'Kiri', 'Kedua kaki', 'Tidak pakai tangan'], correctIndex: 0),
    Question.trueFalse(statement: 'Al-Quran adalah kitab suci umat Islam.', isTrue: true, emoji: '📖'),
    Question.trueFalse(statement: 'Rukun Islam ada enam.', isTrue: false, emoji: '🔢'),
    Question.trueFalse(statement: 'Sebelum makan kita membaca Bismillah.', isTrue: true, emoji: '🍚'),
    Question.trueFalse(statement: 'Mengucapkan salam kepada teman adalah perbuatan yang baik.', isTrue: true, emoji: '😊'),
    Question.trueFalse(statement: 'Salat wajib dikerjakan tiga kali sehari.', isTrue: false, emoji: '🕌'),
    Question.trueFalse(statement: 'Kita berdoa sebelum tidur agar tidur menjadi berkah.', isTrue: true, emoji: '🌙'),
    const Question(question: 'Rukun Islam yang pertama adalah mengucap dua kalimat ...', emoji: '☝️', type: QuestionType.fillBlank, answer: 'syahadat'),
    const Question(question: 'Kitab suci umat Islam adalah Al-...', emoji: '📖', type: QuestionType.fillBlank, answer: 'quran'),
    const Question(question: 'Sebelum makan kita membaca ...', emoji: '🍽️', type: QuestionType.fillBlank, answer: 'bismillah'),
    const Question(question: 'Rukun Islam seluruhnya berjumlah ... (angka)', emoji: '🔢', type: QuestionType.fillBlank, answer: '5'),
  ];

  static final List<Question> _ips = [
    const Question(question: 'Siapa yang biasanya memimpin dan mencari nafkah dalam sebuah keluarga?', emoji: '👨', options: ['Ayah', 'Kakek', 'Paman', 'Tetangga'], correctIndex: 0),
    const Question(question: 'Siapa yang melahirkan dan merawat kita di rumah?', emoji: '👩', options: ['Guru', 'Ibu', 'Bibi', 'Teman'], correctIndex: 1),
    const Question(question: 'Anak laki-laki yang lebih tua dari kita di dalam keluarga disebut...', emoji: '👦', options: ['Adik', 'Paman', 'Kakak', 'Sepupu'], correctIndex: 2),
    const Question(question: 'Ayah dari ayah atau ibu kita disebut...', emoji: '👴', options: ['Om', 'Ayah', 'Sepupu', 'Kakek'], correctIndex: 3),
    const Question(question: 'Ruangan yang digunakan untuk tidur di rumah disebut...', emoji: '🛏️', options: ['Kamar tidur', 'Dapur', 'Kamar mandi', 'Ruang tamu'], correctIndex: 0),
    const Question(question: 'Tempat untuk memasak makanan di rumah adalah...', emoji: '🍳', options: ['Kamar', 'Dapur', 'Halaman', 'Garasi'], correctIndex: 1),
    const Question(question: 'Kita mandi dan mencuci tangan di...', emoji: '🚿', options: ['Ruang tamu', 'Kamar tidur', 'Kamar mandi', 'Dapur'], correctIndex: 2),
    const Question(question: 'Apa warna bendera negara Indonesia?', emoji: '🇮🇩', options: ['Biru dan putih', 'Hijau dan kuning', 'Hitam dan putih', 'Merah dan putih'], correctIndex: 3),
    const Question(question: 'Bagian atas bendera Indonesia berwarna...', emoji: '🚩', options: ['Merah', 'Putih', 'Kuning', 'Biru'], correctIndex: 0),
    const Question(question: 'Agar badan sehat dan bersih, kita harus rajin...', emoji: '🧼', options: ['Bermain saja', 'Mandi', 'Tidur seharian', 'Jajan'], correctIndex: 1),
    const Question(question: 'Sampah sebaiknya dibuang ke...', emoji: '🗑️', options: ['Sungai', 'Halaman rumah', 'Tempat sampah', 'Jalan raya'], correctIndex: 2),
    const Question(question: 'Sebelum makan, sebaiknya kita mencuci...', emoji: '🖐️', options: ['Sepatu', 'Baju', 'Rambut', 'Tangan'], correctIndex: 3),
    const Question(question: 'Orang yang tinggal di rumah dekat rumah kita disebut...', emoji: '🏘️', options: ['Tetangga', 'Guru', 'Dokter', 'Polisi'], correctIndex: 0),
    const Question(question: 'Membersihkan rumah bersama keluarga sebaiknya dilakukan dengan cara...', emoji: '🧹', options: ['Bertengkar', 'Bergotong royong', 'Sendiri saja', 'Malas-malasan'], correctIndex: 1),
    Question.trueFalse(statement: 'Ibu adalah anggota keluarga di rumah.', isTrue: true, emoji: '👩'),
    Question.trueFalse(statement: 'Bendera Indonesia berwarna hijau dan kuning.', isTrue: false, emoji: '🇮🇩'),
    Question.trueFalse(statement: 'Kita harus rajin menyapu agar rumah bersih.', isTrue: true, emoji: '🧹'),
    Question.trueFalse(statement: 'Membuang sampah di sungai adalah perbuatan yang baik.', isTrue: false, emoji: '🌊'),
    Question.trueFalse(statement: 'Adik adalah anggota keluarga yang lebih muda dari kita.', isTrue: true, emoji: '👶'),
    Question.trueFalse(statement: 'Kita sebaiknya mencuci tangan sebelum makan.', isTrue: true, emoji: '🍽️'),
    const Question(question: 'Bendera Indonesia disebut bendera Merah ....', emoji: '🇮🇩', type: QuestionType.fillBlank, answer: 'putih'),
    const Question(question: 'Orang tua perempuan kita di rumah dipanggil ....', emoji: '👩', type: QuestionType.fillBlank, answer: 'ibu'),
    const Question(question: 'Agar tidak bau dan tetap bersih, setiap hari kita harus ....', emoji: '🚿', type: QuestionType.fillBlank, answer: 'mandi'),
    const Question(question: 'Tempat kita berteduh dan tinggal bersama keluarga disebut ....', emoji: '🏠', type: QuestionType.fillBlank, answer: 'rumah'),
  ];

}
