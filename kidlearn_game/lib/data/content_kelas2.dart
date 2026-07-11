import '../models/question.dart';
import '../models/subject.dart';

/// Bank soal Kelas 2 — Stage 2 — ejaan, siklus air, Rukun Iman/sholat, profesi.
/// Dihasilkan & diverifikasi otomatis (generate + fact-check), aligned rencana.
/// Catatan: soal Agama Islam perlu review akhir oleh ahli.
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

  static final List<Question> _english = [
    const Question(question: 'Which word rhymes with \'cat\'?', emoji: '🐱', options: ['dog', 'hat', 'sun', 'car'], correctIndex: 1),
    const Question(question: 'What is the plural of \'dog\'?', emoji: '🐶', options: ['dog', 'doges', 'dogs', 'doggs'], correctIndex: 2),
    const Question(question: 'Which word is spelled correctly?', emoji: '🏠', options: ['hows', 'howse', 'house', 'hause'], correctIndex: 2),
    const Question(question: 'What is the opposite of \'big\'?', emoji: '🐘', options: ['tall', 'small', 'fast', 'hot'], correctIndex: 1),
    const Question(question: 'Which mark ends this sentence? \'I like to play\'', emoji: '✏️', options: [',', '.', 'a', 'the'], correctIndex: 1),
    const Question(question: 'What is the plural of \'box\'?', emoji: '📦', options: ['boxs', 'boxes', 'boxen', 'box'], correctIndex: 1),
    const Question(question: 'Which word has the \'sh\' sound?', emoji: '🚢', options: ['ship', 'top', 'cat', 'pen'], correctIndex: 0),
    const Question(question: 'What is the opposite of \'hot\'?', emoji: '❄️', options: ['warm', 'cold', 'big', 'wet'], correctIndex: 1),
    const Question(question: 'Which word means more than one \'baby\'?', emoji: '👶', options: ['babys', 'babies', 'babyes', 'baby'], correctIndex: 1),
    const Question(question: 'Which letter is missing? \'ca_e\' (a sweet food)', emoji: '🍰', options: ['k', 't', 'g', 'p'], correctIndex: 0),
    const Question(question: 'What is the opposite of \'up\'?', emoji: '⬇️', options: ['down', 'fast', 'in', 'top'], correctIndex: 0),
    const Question(question: 'Which sentence begins correctly?', emoji: '☀️', options: ['the sun is hot.', 'The sun is hot.', 'the Sun is hot.', 'THE sun is hot.'], correctIndex: 1),
    const Question(question: 'Which word rhymes with \'tree\'?', emoji: '🌳', options: ['bee', 'car', 'dog', 'cup'], correctIndex: 0),
    const Question(question: 'What is the plural of \'foot\'?', emoji: '🦶', options: ['foots', 'feet', 'foots', 'feets'], correctIndex: 1),
    Question.trueFalse(statement: 'The word \'happy\' is the opposite of \'sad\'.', isTrue: true, emoji: '😊'),
    Question.trueFalse(statement: 'Every sentence should start with a capital letter.', isTrue: true, emoji: '🔠'),
    Question.trueFalse(statement: 'The plural of \'cat\' is \'cates\'.', isTrue: false, emoji: '🐈'),
    Question.trueFalse(statement: 'The word \'day\' is the opposite of \'night\'.', isTrue: true, emoji: '🌙'),
    Question.trueFalse(statement: 'A question sentence ends with a full stop (.).', isTrue: false, emoji: '❓'),
    Question.trueFalse(statement: 'The word \'fish\' sounds like it starts with \'f\'.', isTrue: true, emoji: '🐟'),
    const Question(question: 'Fill in the missing letter: \'s_n\' (it shines in the sky).', emoji: '☀️', type: QuestionType.fillBlank, answer: 'u'),
    const Question(question: 'Write the plural of \'apple\'.', emoji: '🍎', type: QuestionType.fillBlank, answer: 'apples'),
    const Question(question: 'Write the opposite of \'open\'.', emoji: '🚪', type: QuestionType.fillBlank, answer: 'closed'),
    const Question(question: 'Which mark do we put at the end of a question? Write it.', emoji: '❓', type: QuestionType.fillBlank, answer: '?'),
  ];

  static final List<Question> _indonesian = [
    const Question(question: 'Manakah penulisan huruf kapital yang benar untuk nama orang?', emoji: '✏️', options: ['budi', 'Budi', 'bUdi', 'budI'], correctIndex: 1),
    const Question(question: 'Tanda baca apa yang tepat diletakkan di akhir kalimat tanya?', emoji: '❓', options: ['Titik (.)', 'Koma (,)', 'Tanda tanya (?)', 'Tanda seru (!)'], correctIndex: 2),
    const Question(question: 'Lawan kata (antonim) dari kata \'besar\' adalah ...', emoji: '🔁', options: ['tinggi', 'kecil', 'panjang', 'lebar'], correctIndex: 1),
    const Question(question: 'Persamaan kata (sinonim) dari kata \'pintar\' adalah ...', emoji: '🧠', options: ['bodoh', 'malas', 'cerdas', 'nakal'], correctIndex: 2),
    const Question(question: 'Kalimat berikut yang ditulis dengan ejaan benar adalah ...', emoji: '🏫', options: ['Saya pergi ke sekolah.', 'saya Pergi ke sekolah', 'Saya pergi kesekolah', 'saya pergi ke sekolah'], correctIndex: 0),
    const Question(question: 'Kata \'meja\', \'kursi\', dan \'buku\' termasuk jenis kata ...', emoji: '📚', options: ['kata kerja', 'kata benda', 'kata sifat', 'kata bilangan'], correctIndex: 1),
    const Question(question: 'Kata \'makan\', \'lari\', dan \'tidur\' termasuk jenis kata ...', emoji: '🏃', options: ['kata benda', 'kata sifat', 'kata kerja', 'kata ganti'], correctIndex: 2),
    const Question(question: 'Lawan kata dari \'panas\' adalah ...', emoji: '❄️', options: ['dingin', 'hangat', 'kering', 'cerah'], correctIndex: 0),
    const Question(question: 'Tanda baca yang dipakai di akhir kalimat berita adalah ...', emoji: '📝', options: ['Tanda tanya (?)', 'Tanda seru (!)', 'Titik (.)', 'Tanda kutip'], correctIndex: 2),
    const Question(question: 'Nama hari \'senin\' seharusnya ditulis ...', emoji: '📅', options: ['senin', 'Senin', 'SENIN', 'sEnin'], correctIndex: 1),
    const Question(question: 'Sinonim dari kata \'gembira\' adalah ...', emoji: '😄', options: ['sedih', 'senang', 'marah', 'takut'], correctIndex: 1),
    const Question(question: 'Kata \'merah\', \'manis\', dan \'tinggi\' termasuk jenis kata ...', emoji: '🎨', options: ['kata benda', 'kata kerja', 'kata sifat', 'kata bilangan'], correctIndex: 2),
    const Question(question: 'Kalimat \'ibu memasak di dapur\' jika ditulis benar diawali dengan huruf ...', emoji: '👩‍🍳', options: ['kecil', 'kapital', 'miring', 'tebal'], correctIndex: 1),
    const Question(question: 'Lawan kata dari \'siang\' adalah ...', emoji: '🌙', options: ['pagi', 'sore', 'malam', 'subuh'], correctIndex: 2),
    Question.trueFalse(statement: 'Setiap awal kalimat harus ditulis dengan huruf kapital.', isTrue: true, emoji: '🔤'),
    Question.trueFalse(statement: 'Nama kota seperti \'Jakarta\' ditulis dengan huruf kecil semua.', isTrue: false, emoji: '🏙️'),
    Question.trueFalse(statement: 'Kalimat tanya diakhiri dengan tanda tanya (?).', isTrue: true, emoji: '❔'),
    Question.trueFalse(statement: 'Kata \'tinggi\' adalah lawan kata dari \'rendah\'.', isTrue: true, emoji: '📏'),
    Question.trueFalse(statement: 'Kata \'lompat\' termasuk kata benda.', isTrue: false, emoji: '🐸'),
    Question.trueFalse(statement: 'Sinonim dari \'cantik\' adalah \'jelek\'.', isTrue: false, emoji: '🌸'),
    const Question(question: 'Lawan kata dari \'tua\' adalah ...', emoji: '👶', type: QuestionType.fillBlank, answer: 'muda'),
    const Question(question: 'Tanda baca yang diletakkan di akhir kalimat perintah atau seruan adalah tanda ...', emoji: '❗', type: QuestionType.fillBlank, answer: 'seru'),
    const Question(question: 'Persamaan kata dari \'lezat\' adalah ...', emoji: '🍰', type: QuestionType.fillBlank, answer: 'enak'),
    const Question(question: 'Nama hari sesudah \'Rabu\' adalah ...', emoji: '📆', type: QuestionType.fillBlank, answer: 'kamis'),
  ];

  static final List<Question> _science = [
    const Question(question: 'Perubahan air menjadi uap air karena panas matahari disebut...', emoji: '☀️', options: ['Menguap', 'Mengembun', 'Membeku', 'Mencair'], correctIndex: 0),
    const Question(question: 'Uap air di langit yang mendingin akan berubah menjadi...', emoji: '☁️', options: ['Batu', 'Awan', 'Api', 'Pasir'], correctIndex: 1),
    const Question(question: 'Air yang jatuh dari awan ke bumi disebut...', emoji: '🌧️', options: ['Angin', 'Salju', 'Hujan', 'Petir'], correctIndex: 2),
    const Question(question: 'Panas yang membuat air di laut menguap berasal dari...', emoji: '🌞', options: ['Bulan', 'Bintang', 'Lampu', 'Matahari'], correctIndex: 3),
    const Question(question: 'Bagian tumbuhan yang menyerap air dari dalam tanah adalah...', emoji: '🌱', options: ['Akar', 'Bunga', 'Daun', 'Buah'], correctIndex: 0),
    const Question(question: 'Bagian tumbuhan tempat terjadinya proses membuat makanan adalah...', emoji: '🍃', options: ['Batang', 'Daun', 'Akar', 'Biji'], correctIndex: 1),
    const Question(question: 'Bagian tumbuhan yang berwarna indah dan sering menjadi tempat munculnya buah adalah...', emoji: '🌸', options: ['Akar', 'Batang', 'Bunga', 'Daun'], correctIndex: 2),
    const Question(question: 'Bagian tumbuhan yang berfungsi menopang atau menegakkan tumbuhan adalah...', emoji: '🌳', options: ['Bunga', 'Buah', 'Akar', 'Batang'], correctIndex: 3),
    const Question(question: 'Ikan bernapas menggunakan...', emoji: '🐟', options: ['Insang', 'Paru-paru', 'Kulit', 'Hidung'], correctIndex: 0),
    const Question(question: 'Hewan yang bernapas menggunakan paru-paru adalah...', emoji: '🐄', options: ['Ikan mas', 'Sapi', 'Cacing', 'Ikan lele'], correctIndex: 1),
    const Question(question: 'Cacing tanah bernapas melalui...', emoji: '🪱', options: ['Insang', 'Paru-paru', 'Kulit', 'Sayap'], correctIndex: 2),
    const Question(question: 'Serangga seperti belalang bernapas menggunakan...', emoji: '🦗', options: ['Insang', 'Paru-paru', 'Kulit', 'Trakea'], correctIndex: 3),
    const Question(question: 'Titik-titik air pada daun di pagi hari terjadi karena proses...', emoji: '💧', options: ['Mengembun', 'Menguap', 'Hujan', 'Membeku'], correctIndex: 0),
    const Question(question: 'Bagian tumbuhan yang biasa kita makan pada tanaman mangga adalah...', emoji: '🥭', options: ['Akar', 'Buah', 'Batang', 'Daun'], correctIndex: 1),
    Question.trueFalse(statement: 'Air laut dapat menguap karena terkena panas matahari.', isTrue: true, emoji: '🌊'),
    Question.trueFalse(statement: 'Hujan turun dari dalam tanah menuju ke langit.', isTrue: false, emoji: '🌧️'),
    Question.trueFalse(statement: 'Akar berfungsi untuk menyerap air dan zat makanan dari tanah.', isTrue: true, emoji: '🌱'),
    Question.trueFalse(statement: 'Semua hewan bernapas menggunakan paru-paru.', isTrue: false, emoji: '🐟'),
    Question.trueFalse(statement: 'Katak dewasa dapat bernapas menggunakan paru-paru dan kulitnya.', isTrue: true, emoji: '🐸'),
    Question.trueFalse(statement: 'Daun berfungsi untuk menyerap air dari dalam tanah.', isTrue: false, emoji: '🍃'),
    const Question(question: 'Perubahan air menjadi uap air disebut ...', emoji: '☀️', type: QuestionType.fillBlank, answer: 'menguap'),
    const Question(question: 'Alat pernapasan pada ikan disebut ...', emoji: '🐠', type: QuestionType.fillBlank, answer: 'insang'),
    const Question(question: 'Bagian tumbuhan yang menyerap air dari tanah adalah ...', emoji: '🌱', type: QuestionType.fillBlank, answer: 'akar'),
    const Question(question: 'Air yang turun dari awan ke bumi disebut ...', emoji: '🌧️', type: QuestionType.fillBlank, answer: 'hujan'),
  ];

  static final List<Question> _religion = [
    const Question(question: 'Berapa jumlah Rukun Iman?', emoji: '🕌', options: ['4', '5', '6', '7'], correctIndex: 2),
    const Question(question: 'Rukun Iman yang pertama adalah iman kepada ...', emoji: '🤲', options: ['Malaikat', 'Allah', 'Nabi', 'Kitab'], correctIndex: 1),
    const Question(question: 'Sebelum sholat kita harus berwudhu supaya ...', emoji: '💧', options: ['Suci dari hadas', 'Merasa lapar', 'Cepat tidur', 'Menjadi kuat'], correctIndex: 0),
    const Question(question: 'Saat wudhu, anggota tubuh yang pertama dibasuh setelah membaca niat adalah ...', emoji: '🖐️', options: ['Kaki', 'Kepala', 'Kedua telapak tangan', 'Telinga'], correctIndex: 2),
    const Question(question: 'Ketika berwudhu kita berkumur-kumur menggunakan ...', emoji: '💦', options: ['Air', 'Pasir', 'Minyak', 'Susu'], correctIndex: 0),
    const Question(question: 'Sholat Subuh dikerjakan sebanyak ... rakaat.', emoji: '🌅', options: ['2 rakaat', '3 rakaat', '4 rakaat', '5 rakaat'], correctIndex: 0),
    const Question(question: 'Sholat Magrib dikerjakan sebanyak ... rakaat.', emoji: '🌆', options: ['2 rakaat', '3 rakaat', '4 rakaat', '5 rakaat'], correctIndex: 1),
    const Question(question: 'Sholat Dzuhur dikerjakan sebanyak ... rakaat.', emoji: '☀️', options: ['2 rakaat', '3 rakaat', '4 rakaat', '5 rakaat'], correctIndex: 2),
    const Question(question: 'Gerakan membungkukkan badan dengan tangan memegang lutut dalam sholat disebut ...', emoji: '🙇', options: ['Sujud', 'Rukuk', 'Iktidal', 'Takbir'], correctIndex: 1),
    const Question(question: 'Gerakan meletakkan dahi ke tempat sujud disebut ...', emoji: '🧎', options: ['Rukuk', 'Sujud', 'Duduk', 'Salam'], correctIndex: 1),
    const Question(question: 'Umat Islam ketika sholat menghadap ke arah ...', emoji: '🧭', options: ['Kiblat', 'Matahari', 'Utara', 'Laut'], correctIndex: 0),
    const Question(question: 'Kiblat umat Islam adalah bangunan Kakbah yang berada di kota ...', emoji: '🕋', options: ['Madinah', 'Makkah', 'Jakarta', 'Kairo'], correctIndex: 1),
    const Question(question: 'Sholat dimulai dengan mengucap ... sambil mengangkat kedua tangan.', emoji: '🙌', options: ['Salam', 'Takbiratul ihram', 'Amin', 'Tasbih'], correctIndex: 1),
    const Question(question: 'Sholat diakhiri dengan mengucapkan ... sambil menoleh ke kanan dan ke kiri.', emoji: '👋', options: ['Takbir', 'Salam', 'Doa', 'Azan'], correctIndex: 1),
    Question.trueFalse(statement: 'Beriman kepada malaikat termasuk salah satu Rukun Iman.', isTrue: true, emoji: '👼'),
    Question.trueFalse(statement: 'Kita boleh melaksanakan sholat tanpa berwudhu terlebih dahulu.', isTrue: false, emoji: '🚫'),
    Question.trueFalse(statement: 'Sholat Isya dikerjakan sebanyak 4 rakaat.', isTrue: true, emoji: '🌙'),
    Question.trueFalse(statement: 'Ketika berwudhu, kita membasuh kedua kaki sampai mata kaki.', isTrue: true, emoji: '🦶'),
    Question.trueFalse(statement: 'Umat Islam sholat dengan menghadap ke arah matahari terbit.', isTrue: false, emoji: '🌄'),
    Question.trueFalse(statement: 'Sujud dilakukan sebanyak dua kali dalam setiap rakaat sholat.', isTrue: true, emoji: '🕌'),
    const Question(question: 'Iman kepada Allah adalah Rukun Iman yang pertama. Rukun Iman yang terakhir adalah iman kepada qada dan ...', emoji: '📿', type: QuestionType.fillBlank, answer: 'qadar'),
    const Question(question: 'Sholat yang dikerjakan pada pagi hari sebanyak dua rakaat bernama sholat ...', emoji: '🌅', type: QuestionType.fillBlank, answer: 'subuh'),
    const Question(question: 'Membersihkan diri dari hadas kecil dengan membasuh anggota tubuh menggunakan air sebelum sholat disebut ...', emoji: '💧', type: QuestionType.fillBlank, answer: 'wudhu'),
  ];

  static final List<Question> _ips = [
    const Question(question: 'Siapa yang bertugas mengajar murid di sekolah?', emoji: '👩‍🏫', options: ['Guru', 'Dokter', 'Petani', 'Nelayan'], correctIndex: 0),
    const Question(question: 'Orang yang bertugas menyembuhkan orang sakit adalah ...', emoji: '🩺', options: ['Polisi', 'Dokter', 'Tukang kayu', 'Sopir'], correctIndex: 1),
    const Question(question: 'Pekerjaan yang menangkap ikan di laut disebut ...', emoji: '🎣', options: ['Petani', 'Guru', 'Nelayan', 'Pilot'], correctIndex: 2),
    const Question(question: 'Orang yang menanam padi di sawah adalah ...', emoji: '🌾', options: ['Dokter', 'Polisi', 'Pedagang', 'Petani'], correctIndex: 3),
    const Question(question: 'Petugas yang memadamkan kebakaran adalah ...', emoji: '🚒', options: ['Pemadam kebakaran', 'Tukang pos', 'Guru', 'Nelayan'], correctIndex: 0),
    const Question(question: 'Tempat umum untuk meminjam dan membaca buku disebut ...', emoji: '📚', options: ['Pasar', 'Perpustakaan', 'Rumah sakit', 'Terminal'], correctIndex: 1),
    const Question(question: 'Tempat kita berobat ketika sakit adalah ...', emoji: '🏥', options: ['Sekolah', 'Pasar', 'Rumah sakit', 'Bank'], correctIndex: 2),
    const Question(question: 'Tempat untuk membeli sayur, buah, dan ikan adalah ...', emoji: '🛒', options: ['Perpustakaan', 'Museum', 'Kantor pos', 'Pasar'], correctIndex: 3),
    const Question(question: 'Ibu kota negara Indonesia adalah ...', emoji: '🏙️', options: ['Jakarta', 'Surabaya', 'Bandung', 'Medan'], correctIndex: 0),
    const Question(question: 'Salah satu aturan yang baik di sekolah adalah ...', emoji: '🏫', options: ['Datang terlambat', 'Datang tepat waktu', 'Membolos', 'Berkelahi'], correctIndex: 1),
    const Question(question: 'Sebelum masuk kelas, biasanya siswa berbaris lalu ...', emoji: '🙋', options: ['Berteriak', 'Berlari', 'Memberi salam kepada guru', 'Tidur'], correctIndex: 2),
    const Question(question: 'Petugas yang menjaga keamanan dan ketertiban masyarakat adalah ...', emoji: '👮', options: ['Petani', 'Nelayan', 'Pedagang', 'Polisi'], correctIndex: 3),
    const Question(question: 'Orang yang mengantarkan surat ke rumah-rumah adalah ...', emoji: '📮', options: ['Tukang pos', 'Dokter', 'Guru', 'Koki'], correctIndex: 0),
    const Question(question: 'Orang yang menerbangkan pesawat disebut ...', emoji: '✈️', options: ['Sopir', 'Pilot', 'Masinis', 'Nakhoda'], correctIndex: 1),
    Question.trueFalse(statement: 'Guru bertugas mengajar dan mendidik murid di sekolah.', isTrue: true, emoji: '📖'),
    Question.trueFalse(statement: 'Rumah sakit adalah tempat untuk membeli baju baru.', isTrue: false, emoji: '🏥'),
    Question.trueFalse(statement: 'Membuang sampah pada tempatnya adalah aturan yang baik di sekolah.', isTrue: true, emoji: '🗑️'),
    Question.trueFalse(statement: 'Jakarta adalah ibu kota negara Indonesia.', isTrue: true, emoji: '🇮🇩'),
    Question.trueFalse(statement: 'Kita boleh datang terlambat ke sekolah setiap hari.', isTrue: false, emoji: '⏰'),
    Question.trueFalse(statement: 'Nelayan bekerja menangkap ikan di sawah.', isTrue: false, emoji: '🐟'),
    const Question(question: 'Orang yang menjahit dan membuat pakaian disebut ...', emoji: '🧵', type: QuestionType.fillBlank, answer: 'penjahit'),
    const Question(question: 'Tempat anak-anak belajar bersama guru setiap hari disebut ...', emoji: '🏫', type: QuestionType.fillBlank, answer: 'sekolah'),
    const Question(question: 'Orang yang memasak makanan di restoran disebut ...', emoji: '👨‍🍳', type: QuestionType.fillBlank, answer: 'koki'),
  ];

}
