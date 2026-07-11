import '../models/question.dart';
import '../models/subject.dart';

/// Bank soal Kelas 5 — Stage 5 — past tense, tata surya/ekosistem, Asmaul Husna, geografi.
/// Dihasilkan & diverifikasi otomatis (generate + fact-check), aligned rencana.
/// Catatan: soal Agama Islam perlu review akhir oleh ahli.
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
    const Question(question: 'Yesterday, my family ___ to the beach for a picnic.', emoji: '🏖️', options: ['go', 'went', 'gone', 'going'], correctIndex: 1, objectiveCode: '5G.01'),
    const Question(question: 'Choose the correct past tense: "The children ___ football in the garden last Saturday."', emoji: '⚽', options: ['played', 'plaied', 'playd', 'play'], correctIndex: 0, objectiveCode: '5G.01'),
    const Question(question: 'While I ___ my homework, the lights suddenly went out.', emoji: '💡', options: ['do', 'did', 'was doing', 'am doing'], correctIndex: 2, objectiveCode: '5G.02'),
    const Question(question: 'What is the correct past tense of the verb "catch"?', emoji: '🥎', options: ['catched', 'caught', 'cought', 'catchted'], correctIndex: 1, objectiveCode: '5G.01'),
    const Question(question: 'I stayed inside all afternoon ___ it was raining heavily.', emoji: '🌧️', options: ['but', 'because', 'although', 'or'], correctIndex: 1, objectiveCode: '5G.03'),
    const Question(question: 'Which sentence correctly uses the past continuous tense?', emoji: '🍳', options: ['She were cooking dinner.', 'She was cook dinner.', 'She was cooking dinner.', 'She cooking dinner.'], correctIndex: 2, objectiveCode: '5G.02'),
    const Question(question: 'My grandfather ___ me a lovely present for my birthday last week.', emoji: '🎁', options: ['buy', 'buyed', 'bought', 'boughted'], correctIndex: 2, objectiveCode: '5G.01'),
    const Question(question: '___ the weather was cold, we still went for a long walk.', emoji: '🚶', options: ['Although', 'Because', 'So', 'And'], correctIndex: 0, objectiveCode: '5G.03'),
    const Question(question: 'What is the correct past tense of the verb "write"?', emoji: '✍️', options: ['writed', 'written', 'wrote', 'writ'], correctIndex: 2, objectiveCode: '5G.01'),
    const Question(question: 'It was very late, ___ we decided to go home.', emoji: '🌙', options: ['because', 'although', 'but', 'so'], correctIndex: 3, objectiveCode: '5G.03'),
    const Question(question: 'The boys ___ not sleeping when their mother called them for dinner.', emoji: '🛏️', options: ['was', 'were', 'are', 'is'], correctIndex: 1, objectiveCode: '5G.02'),
    const Question(question: 'We ___ a delicious cake while our friends played games in the garden.', emoji: '🍰', options: ['eat', 'ate', 'eaten', 'eated'], correctIndex: 1, objectiveCode: '5G.01'),
    const Question(question: 'Which word best joins these two ideas: "I was reading a book ___ my sister was drawing."', emoji: '📖', options: ['while', 'because', 'although', 'so'], correctIndex: 0, objectiveCode: '5G.03'),
    const Question(question: 'The sun ___ brightly when we arrived at the park in the morning.', emoji: '☀️', options: ['shine', 'shined', 'shone', 'shining'], correctIndex: 2, objectiveCode: '5G.01'),
    Question.trueFalse(statement: 'The past tense of the verb "run" is "runned".', isTrue: false, emoji: '🏃'),
    Question.trueFalse(statement: 'The past continuous tense is formed with "was" or "were" and a verb ending in -ing.', isTrue: true, emoji: '⏳'),
    Question.trueFalse(statement: 'The connector "because" is used to give a reason.', isTrue: true, emoji: '🔗'),
    Question.trueFalse(statement: 'The past tense of the verb "see" is "saw".', isTrue: true, emoji: '👀'),
    Question.trueFalse(statement: 'The sentence "Yesterday, I am playing in the park." is grammatically correct.', isTrue: false, emoji: '🎡'),
    Question.trueFalse(statement: 'The word "although" is used to connect two ideas that contrast with each other.', isTrue: true, emoji: '🤔'),
    const Question(question: 'Write the correct past tense of the verb "swim": "Last summer, we ___ in the lake every day."', emoji: '🏊', type: QuestionType.fillBlank, answer: 'swam'),
    const Question(question: 'Complete with the past continuous: "While she ___ (cook), the doorbell rang loudly."', emoji: '🔔', type: QuestionType.fillBlank, answer: 'was cooking'),
    const Question(question: 'Write the correct past tense of the verb "bring": "He ___ his umbrella because it looked cloudy."', emoji: '☂️', type: QuestionType.fillBlank, answer: 'brought'),
    const Question(question: 'Fill in the connector that shows a result: "I was very tired, ___ I went to bed early."', emoji: '😴', type: QuestionType.fillBlank, answer: 'so'),
  ];

  static final List<Question> _indonesian = [
    const Question(question: 'Tokoh, latar, alur, dan amanat merupakan bagian dari...', emoji: '📖', options: ['Unsur cerita', 'Jenis kalimat', 'Tanda baca', 'Ejaan'], correctIndex: 0),
    const Question(question: 'Orang atau pelaku yang mengalami peristiwa dalam sebuah cerita disebut...', emoji: '🧑', options: ['Latar', 'Tokoh', 'Amanat', 'Alur'], correctIndex: 1),
    const Question(question: 'Pesan atau nasihat yang ingin disampaikan penulis kepada pembaca melalui cerita disebut...', emoji: '💌', options: ['Tema', 'Latar', 'Amanat', 'Tokoh'], correctIndex: 2),
    const Question(question: 'Latar dalam sebuah cerita menjelaskan tentang...', emoji: '🏞️', options: ['Nama penulis cerita', 'Waktu, tempat, dan suasana', 'Jumlah halaman buku', 'Harga buku'], correctIndex: 1),
    const Question(question: 'Urutan atau jalannya peristiwa dari awal hingga akhir cerita disebut...', emoji: '🔄', options: ['Amanat', 'Latar', 'Alur', 'Judul'], correctIndex: 2),
    const Question(question: 'Teks yang berisi rangkaian peristiwa atau kisah yang disusun secara berurutan disebut teks...', emoji: '📚', options: ['Eksposisi', 'Narasi', 'Iklan', 'Laporan'], correctIndex: 1),
    const Question(question: 'Teks yang berisi penjelasan, informasi, atau pengetahuan tentang suatu hal disebut teks...', emoji: '📰', options: ['Narasi', 'Puisi', 'Eksposisi', 'Dongeng'], correctIndex: 2),
    const Question(question: 'Gagasan utama yang menjadi dasar pengembangan sebuah paragraf disebut...', emoji: '💡', options: ['Ide pokok', 'Kalimat tanya', 'Kata baku', 'Tanda seru'], correctIndex: 0),
    const Question(question: 'Kalimat yang mengandung ide pokok dalam sebuah paragraf disebut kalimat...', emoji: '✏️', options: ['Penjelas', 'Utama', 'Tanya', 'Perintah'], correctIndex: 1),
    const Question(question: 'Tokoh yang memiliki sifat baik dan biasanya menjadi pusat cerita disebut tokoh...', emoji: '😇', options: ['Antagonis', 'Protagonis', 'Figuran', 'Pembantu'], correctIndex: 1),
    const Question(question: 'Tokoh yang memiliki watak jahat atau menjadi penentang tokoh utama disebut tokoh...', emoji: '😈', options: ['Protagonis', 'Antagonis', 'Utama', 'Baik'], correctIndex: 1),
    const Question(question: 'Cerita rakyat \'Malin Kundang\' memberikan amanat agar kita...', emoji: '⛵', options: ['Rajin berpetualang', 'Berbakti kepada orang tua', 'Suka mengumpulkan harta', 'Sering merantau jauh'], correctIndex: 1),
    const Question(question: 'Ide pokok sebuah paragraf biasanya dapat ditemukan pada kalimat...', emoji: '🔍', options: ['Pertama atau terakhir', 'Kedua saja', 'Tengah saja', 'Tidak ada'], correctIndex: 0),
    const Question(question: '\'Pada suatu pagi yang cerah, Doni bermain di halaman rumah.\' Latar tempat pada kalimat tersebut adalah...', emoji: '🏠', options: ['Pagi hari', 'Halaman rumah', 'Cerah', 'Doni'], correctIndex: 1),
    Question.trueFalse(statement: 'Teks eksposisi bertujuan untuk menghibur pembaca dengan kisah lucu.', isTrue: false, emoji: '📄'),
    Question.trueFalse(statement: 'Setiap paragraf yang baik memiliki satu ide pokok.', isTrue: true, emoji: '✅'),
    Question.trueFalse(statement: 'Amanat adalah nama tempat terjadinya peristiwa dalam cerita.', isTrue: false, emoji: '❌'),
    Question.trueFalse(statement: 'Teks narasi menyajikan peristiwa secara berurutan sesuai waktu kejadian.', isTrue: true, emoji: '⏳'),
    Question.trueFalse(statement: 'Kalimat penjelas berfungsi untuk mendukung dan menjelaskan kalimat utama.', isTrue: true, emoji: '🔗'),
    Question.trueFalse(statement: 'Latar suasana dalam cerita dapat berupa gembira, sedih, atau menegangkan.', isTrue: true, emoji: '🎭'),
    const Question(question: 'Pesan atau nasihat yang terkandung dalam sebuah cerita disebut ....', emoji: '📜', type: QuestionType.fillBlank, answer: 'amanat'),
    const Question(question: 'Gagasan utama yang menjadi inti sebuah paragraf disebut ide ....', emoji: '💭', type: QuestionType.fillBlank, answer: 'pokok'),
    const Question(question: 'Waktu, tempat, dan suasana terjadinya peristiwa dalam cerita disebut ....', emoji: '🌄', type: QuestionType.fillBlank, answer: 'latar'),
    const Question(question: 'Teks yang berisi rangkaian kisah atau peristiwa yang disusun berurutan disebut teks ....', emoji: '📕', type: QuestionType.fillBlank, answer: 'narasi'),
  ];

  static final List<Question> _science = [
    const Question(question: 'Bintang yang berada di pusat tata surya kita adalah...', emoji: '☀️', options: ['Bulan', 'Matahari', 'Bumi', 'Mars'], correctIndex: 1),
    const Question(question: 'Planet yang kita tinggali bernama...', emoji: '🌍', options: ['Venus', 'Bumi', 'Jupiter', 'Saturnus'], correctIndex: 1),
    const Question(question: 'Planet terdekat dengan Matahari adalah...', emoji: '🪐', options: ['Merkurius', 'Mars', 'Neptunus', 'Bumi'], correctIndex: 0),
    const Question(question: 'Planet terbesar di tata surya kita adalah...', emoji: '🪐', options: ['Bumi', 'Saturnus', 'Jupiter', 'Uranus'], correctIndex: 2),
    const Question(question: 'Planet yang dikenal dengan cincin indahnya adalah...', emoji: '💫', options: ['Mars', 'Saturnus', 'Venus', 'Merkurius'], correctIndex: 1),
    const Question(question: 'Planet yang sering disebut \'planet merah\' adalah...', emoji: '🔴', options: ['Mars', 'Jupiter', 'Neptunus', 'Venus'], correctIndex: 0),
    const Question(question: 'Dalam rantai makanan, makhluk hidup yang membuat makanannya sendiri disebut...', emoji: '🌱', options: ['Konsumen', 'Pengurai', 'Produsen', 'Karnivora'], correctIndex: 2),
    const Question(question: 'Hewan yang hanya memakan tumbuhan disebut...', emoji: '🐄', options: ['Karnivora', 'Herbivora', 'Omnivora', 'Pengurai'], correctIndex: 1),
    const Question(question: 'Hewan yang memakan daging atau hewan lain disebut...', emoji: '🦁', options: ['Herbivora', 'Produsen', 'Karnivora', 'Pengurai'], correctIndex: 2),
    const Question(question: 'Makhluk hidup yang menguraikan sisa makhluk hidup yang sudah mati disebut...', emoji: '🍄', options: ['Pengurai', 'Produsen', 'Herbivora', 'Konsumen'], correctIndex: 0),
    const Question(question: 'Pada rantai makanan \'padi → tikus → ular\', yang berperan sebagai produsen adalah...', emoji: '🌾', options: ['Ular', 'Tikus', 'Padi', 'Matahari'], correctIndex: 2),
    const Question(question: 'Contoh hewan pemakan segala (omnivora) adalah...', emoji: '🐔', options: ['Sapi', 'Ayam', 'Singa', 'Kelinci'], correctIndex: 1),
    const Question(question: 'Sumber energi utama bagi semua makhluk hidup dalam ekosistem berasal dari...', emoji: '☀️', options: ['Bulan', 'Matahari', 'Air', 'Tanah'], correctIndex: 1),
    const Question(question: 'Contoh makhluk hidup yang termasuk pengurai adalah...', emoji: '🦠', options: ['Jamur dan bakteri', 'Rumput dan pohon', 'Kucing dan anjing', 'Elang dan ular'], correctIndex: 0),
    Question.trueFalse(statement: 'Matahari termasuk sebuah bintang karena dapat memancarkan cahayanya sendiri.', isTrue: true, emoji: '⭐'),
    Question.trueFalse(statement: 'Bumi adalah pusat dari tata surya kita.', isTrue: false, emoji: '🌍'),
    Question.trueFalse(statement: 'Tumbuhan hijau berperan sebagai produsen dalam rantai makanan.', isTrue: true, emoji: '🌿'),
    Question.trueFalse(statement: 'Semua planet mengelilingi Matahari.', isTrue: true, emoji: '🪐'),
    Question.trueFalse(statement: 'Kambing termasuk hewan karnivora karena memakan daging.', isTrue: false, emoji: '🐐'),
    Question.trueFalse(statement: 'Pengurai membantu mengembalikan zat hara ke dalam tanah.', isTrue: true, emoji: '🍂'),
    const Question(question: 'Planet tempat tinggal manusia bernama ...', emoji: '🌎', type: QuestionType.fillBlank, answer: 'bumi'),
    const Question(question: 'Hewan pemakan tumbuhan disebut ...', emoji: '🐰', type: QuestionType.fillBlank, answer: 'herbivora'),
    const Question(question: 'Benda langit di pusat tata surya yang memancarkan cahaya sendiri adalah ...', emoji: '☀️', type: QuestionType.fillBlank, answer: 'matahari'),
    const Question(question: 'Dalam rantai makanan, tumbuhan hijau berperan sebagai ...', emoji: '🌱', type: QuestionType.fillBlank, answer: 'produsen'),
  ];

  static final List<Question> _religion = [
    const Question(question: 'Apa arti dari Asmaul Husna Ar-Rahman?', emoji: '💗', options: ['Maha Pengasih', 'Maha Kuasa', 'Maha Adil', 'Maha Suci'], correctIndex: 0),
    const Question(question: 'Asmaul Husna Ar-Rahim mempunyai arti...', emoji: '🤲', options: ['Maha Mendengar', 'Maha Penyayang', 'Maha Melihat', 'Maha Pemberi'], correctIndex: 1),
    const Question(question: 'Al-Alim artinya Allah Maha...', emoji: '📖', options: ['Melihat', 'Mendengar', 'Mengetahui', 'Pengasih'], correctIndex: 2),
    const Question(question: 'Asmaul Husna As-Sami\' berarti Allah Maha...', emoji: '👂', options: ['Mengetahui', 'Melihat', 'Penyayang', 'Mendengar'], correctIndex: 3),
    const Question(question: 'Al-Bashir mempunyai arti Allah Maha...', emoji: '👁️', options: ['Melihat', 'Mendengar', 'Mengetahui', 'Pengasih'], correctIndex: 0),
    const Question(question: 'Berapakah jumlah Asmaul Husna (nama-nama baik bagi Allah)?', emoji: '🔢', options: ['25', '33', '99', '100'], correctIndex: 2),
    const Question(question: 'Berikut ini yang termasuk contoh akhlak terpuji adalah...', emoji: '😇', options: ['Sombong', 'Jujur', 'Iri hati', 'Kikir'], correctIndex: 1),
    const Question(question: 'Manakah yang termasuk akhlak tercela?', emoji: '😠', options: ['Sabar', 'Rendah hati', 'Sombong', 'Dermawan'], correctIndex: 2),
    const Question(question: 'Karena Allah bersifat Al-Alim (Maha Mengetahui), maka kita sebaiknya...', emoji: '✅', options: ['Berbohong saat sendirian', 'Tidak pernah berbuat curang', 'Malas belajar', 'Menyembunyikan kesalahan'], correctIndex: 1),
    const Question(question: 'Sifat rendah hati dan tidak sombong disebut...', emoji: '🙏', options: ['Tawadhu', 'Tabzir', 'Takabur', 'Tamak'], correctIndex: 0),
    const Question(question: 'Karena Allah Maha Mendengar (As-Sami\'), maka setiap doa yang kita panjatkan...', emoji: '🤍', options: ['Tidak terdengar', 'Selalu didengar Allah', 'Hanya didengar malaikat', 'Harus diucapkan keras'], correctIndex: 1),
    const Question(question: 'Lawan dari sifat sombong adalah...', emoji: '🌸', options: ['Kikir', 'Rendah hati', 'Pemarah', 'Malas'], correctIndex: 1),
    const Question(question: 'Meyakini Allah bersifat Al-Bashir (Maha Melihat) mendorong kita untuk...', emoji: '🌟', options: ['Berbuat baik walau tidak dilihat orang', 'Berbuat curang diam-diam', 'Membenci teman', 'Bersikap sombong'], correctIndex: 0),
    const Question(question: 'Perilaku suka berkata bohong termasuk akhlak...', emoji: '🚫', options: ['Terpuji', 'Tercela', 'Mulia', 'Baik'], correctIndex: 1),
    Question.trueFalse(statement: 'Asmaul Husna berjumlah 100 nama.', isTrue: false, emoji: '🔢'),
    Question.trueFalse(statement: 'Ar-Rahim artinya Allah Maha Penyayang.', isTrue: true, emoji: '💞'),
    Question.trueFalse(statement: 'Sombong termasuk contoh akhlak terpuji.', isTrue: false, emoji: '😤'),
    Question.trueFalse(statement: 'As-Sami\' artinya Allah Maha Melihat.', isTrue: false, emoji: '👂'),
    Question.trueFalse(statement: 'Jujur adalah salah satu contoh akhlak terpuji.', isTrue: true, emoji: '😊'),
    Question.trueFalse(statement: 'Al-Bashir artinya Allah Maha Melihat.', isTrue: true, emoji: '👁️'),
    const Question(question: 'Asmaul Husna artinya nama-nama Allah yang ...', emoji: '✨', type: QuestionType.fillBlank, answer: 'baik'),
    const Question(question: 'Lengkapi: Al-Alim artinya Allah Maha ...', emoji: '📚', type: QuestionType.fillBlank, answer: 'mengetahui'),
    const Question(question: 'Jumlah Asmaul Husna ada ... (tulis angkanya).', emoji: '🔢', type: QuestionType.fillBlank, answer: '99'),
    const Question(question: 'Lawan kata dari sifat jujur adalah ...', emoji: '🙊', type: QuestionType.fillBlank, answer: 'bohong'),
  ];

  static final List<Question> _ips = [
    const Question(question: 'Indonesia terletak di antara dua benua, yaitu benua Asia dan benua...', emoji: '🌏', options: ['Afrika', 'Australia', 'Amerika', 'Eropa'], correctIndex: 1),
    const Question(question: 'Dua samudra yang mengapit wilayah Indonesia adalah Samudra Hindia dan Samudra...', emoji: '🌊', options: ['Atlantik', 'Arktik', 'Pasifik', 'Antarktika'], correctIndex: 2),
    const Question(question: 'Garis khayal yang membagi bumi menjadi belahan utara dan selatan serta melewati Indonesia disebut garis...', emoji: '🗺️', options: ['Bujur', 'Khatulistiwa', 'Balik Utara', 'Tanggal'], correctIndex: 1),
    const Question(question: 'Karena dilewati garis khatulistiwa, Indonesia memiliki iklim...', emoji: '☀️', options: ['Dingin', 'Subtropis', 'Tropis', 'Kutub'], correctIndex: 2),
    const Question(question: 'Kerajaan Majapahit berpusat di wilayah...', emoji: '🏰', options: ['Sumatra', 'Jawa Timur', 'Kalimantan', 'Sulawesi'], correctIndex: 1),
    const Question(question: 'Patih terkenal dari Kerajaan Majapahit yang mengucapkan Sumpah Palapa adalah...', emoji: '⚔️', options: ['Gajah Mada', 'Hayam Wuruk', 'Ken Arok', 'Balaputradewa'], correctIndex: 0),
    const Question(question: 'Kerajaan Sriwijaya merupakan kerajaan yang bercorak...', emoji: '🛕', options: ['Hindu', 'Buddha', 'Islam', 'Kristen'], correctIndex: 1),
    const Question(question: 'Kerajaan Sriwijaya terkenal sebagai kerajaan maritim yang berpusat di pulau...', emoji: '⛵', options: ['Jawa', 'Bali', 'Sumatra', 'Papua'], correctIndex: 2),
    const Question(question: 'Indonesia disebut sebagai negara kepulauan karena...', emoji: '🏝️', options: ['Hanya memiliki satu pulau besar', 'Terdiri atas banyak pulau', 'Tidak memiliki laut', 'Terletak di dua benua'], correctIndex: 1),
    const Question(question: 'Raja terbesar Kerajaan Majapahit yang membawa kerajaan mencapai puncak kejayaan adalah...', emoji: '👑', options: ['Raden Wijaya', 'Hayam Wuruk', 'Kertanegara', 'Jayabaya'], correctIndex: 1),
    const Question(question: 'Letak Indonesia berdasarkan kenyataan di permukaan bumi (posisi terhadap benua dan samudra) disebut letak...', emoji: '🧭', options: ['Astronomis', 'Geografis', 'Geologis', 'Ekonomis'], correctIndex: 1),
    const Question(question: 'Sebutan lain untuk garis khatulistiwa adalah garis...', emoji: '➖', options: ['Ekuator', 'Meridian', 'Wallace', 'Weber'], correctIndex: 0),
    const Question(question: 'Salah satu peninggalan Kerajaan Sriwijaya yang menjadi bukti kejayaannya adalah prasasti...', emoji: '📜', options: ['Kedukan Bukit', 'Ciaruteun', 'Yupa', 'Tugu'], correctIndex: 0),
    const Question(question: 'Keuntungan letak geografis Indonesia yang berada di jalur perdagangan dunia adalah...', emoji: '🚢', options: ['Sering terjadi gempa', 'Menjadi jalur perdagangan yang ramai', 'Sulit dijangkau kapal', 'Tidak memiliki hasil laut'], correctIndex: 1),
    Question.trueFalse(statement: 'Indonesia terletak di antara Benua Asia dan Benua Australia.', isTrue: true, emoji: '🌏'),
    Question.trueFalse(statement: 'Kerajaan Sriwijaya berpusat di Pulau Jawa.', isTrue: false, emoji: '🗿'),
    Question.trueFalse(statement: 'Gajah Mada adalah raja Kerajaan Majapahit.', isTrue: false, emoji: '⚔️'),
    Question.trueFalse(statement: 'Indonesia adalah negara kepulauan yang memiliki ribuan pulau.', isTrue: true, emoji: '🏝️'),
    Question.trueFalse(statement: 'Samudra yang berada di sebelah barat dan selatan Indonesia adalah Samudra Pasifik.', isTrue: false, emoji: '🌊'),
    const Question(question: 'Dua samudra yang mengapit Indonesia adalah Samudra Hindia dan Samudra ...', emoji: '🌊', type: QuestionType.fillBlank, answer: 'pasifik'),
    const Question(question: 'Nama patih Majapahit yang terkenal dengan Sumpah Palapa adalah ...', emoji: '⚔️', type: QuestionType.fillBlank, answer: 'gajah mada'),
    const Question(question: 'Garis khayal yang membagi bumi menjadi belahan utara dan selatan disebut garis ...', emoji: '🗺️', type: QuestionType.fillBlank, answer: 'khatulistiwa'),
    const Question(question: 'Kerajaan maritim yang bercorak Buddha dan berpusat di Sumatra bernama Kerajaan ...', emoji: '⛵', type: QuestionType.fillBlank, answer: 'sriwijaya'),
  ];

}
