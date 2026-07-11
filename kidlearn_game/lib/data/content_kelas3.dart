import '../models/question.dart';
import '../models/subject.dart';

/// Bank soal Kelas 3 — Stage 3 — jenis kata, metamorfosis, surat pendek, budaya daerah.
/// Dihasilkan & diverifikasi otomatis (generate + fact-check), aligned rencana.
/// Catatan: soal Agama Islam perlu review akhir oleh ahli.
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
    const Question(question: 'Which word is a noun?', emoji: '🐶', options: ['run', 'happy', 'dog', 'quickly'], correctIndex: 2),
    const Question(question: 'Which word is a verb?', emoji: '🏃', options: ['table', 'jump', 'blue', 'under'], correctIndex: 1),
    const Question(question: 'Which word is an adjective?', emoji: '📏', options: ['swim', 'chair', 'tall', 'she'], correctIndex: 2),
    const Question(question: 'Choose the correct question word: \'_____ is your name?\'', emoji: '❓', options: ['What', 'When', 'Where', 'Why'], correctIndex: 0),
    const Question(question: 'Choose the correct question word: \'_____ do you live?\'', emoji: '🏠', options: ['Who', 'Where', 'What', 'When'], correctIndex: 1),
    const Question(question: 'Which question word do we use to ask about a time?', emoji: '⏰', options: ['Where', 'Who', 'When', 'Which'], correctIndex: 2),
    const Question(question: 'Which day comes after Monday?', emoji: '📅', options: ['Sunday', 'Tuesday', 'Friday', 'Wednesday'], correctIndex: 1),
    const Question(question: 'Which day comes before Saturday?', emoji: '🗓️', options: ['Sunday', 'Thursday', 'Friday', 'Monday'], correctIndex: 2),
    const Question(question: 'Which is the first month of the year?', emoji: '❄️', options: ['March', 'January', 'December', 'June'], correctIndex: 1),
    const Question(question: 'Which month comes after April?', emoji: '🌸', options: ['May', 'June', 'March', 'July'], correctIndex: 0),
    const Question(question: 'What is the past tense of \'play\'?', emoji: '⚽', options: ['plays', 'playing', 'played', 'play'], correctIndex: 2),
    const Question(question: 'What is the past tense of \'go\'?', emoji: '🚶', options: ['goed', 'went', 'gone', 'going'], correctIndex: 1),
    const Question(question: 'Choose the correct sentence about yesterday.', emoji: '🍎', options: ['I eat an apple yesterday.', 'I eats an apple yesterday.', 'I ate an apple yesterday.', 'I eating an apple yesterday.'], correctIndex: 2),
    const Question(question: 'Which sentence uses an adjective correctly?', emoji: '🐱', options: ['The cat is soft.', 'The cat is run.', 'The cat is quickly.', 'The cat is jump.'], correctIndex: 0),
    Question.trueFalse(statement: 'There are seven days in a week.', isTrue: true, emoji: '7️⃣'),
    Question.trueFalse(statement: 'December is the last month of the year.', isTrue: true, emoji: '🎄'),
    Question.trueFalse(statement: 'The past tense of \'run\' is \'runned\'.', isTrue: false, emoji: '🏃'),
    Question.trueFalse(statement: 'We use \'Who\' to ask about a person.', isTrue: true, emoji: '🧑'),
    Question.trueFalse(statement: '\'Beautiful\' is an adjective.', isTrue: true, emoji: '🌺'),
    const Question(question: 'Write the past tense of the verb \'walk\'.', emoji: '👣', type: QuestionType.fillBlank, answer: 'walked'),
    const Question(question: 'Fill in the question word: \'_____ are you? I am fine.\' (Hint: asking about feeling)', emoji: '🙂', type: QuestionType.fillBlank, answer: 'how'),
    const Question(question: 'Write the day that comes after Wednesday.', emoji: '📆', type: QuestionType.fillBlank, answer: 'thursday'),
    const Question(question: 'Write the past tense of \'see\'.', emoji: '👀', type: QuestionType.fillBlank, answer: 'saw'),
  ];

  static final List<Question> _indonesian = [
    const Question(question: 'Bagian tulisan yang terdiri atas beberapa kalimat yang saling berhubungan dan membahas satu ide pokok disebut ...', emoji: '📄', options: ['Paragraf', 'Huruf', 'Angka', 'Gambar'], correctIndex: 0),
    const Question(question: 'Kalimat pertama pada sebuah paragraf biasanya ditulis dengan cara ...', emoji: '✏️', options: ['Ditulis paling akhir', 'Menjorok ke dalam (masuk ke dalam)', 'Ditulis dengan huruf besar semua', 'Diberi garis bawah'], correctIndex: 1),
    const Question(question: 'Sinonim dari kata \'pintar\' adalah ...', emoji: '🧠', options: ['Bodoh', 'Malas', 'Cerdas', 'Lambat'], correctIndex: 2),
    const Question(question: 'Antonim (lawan kata) dari kata \'besar\' adalah ...', emoji: '🔍', options: ['Luas', 'Kecil', 'Tinggi', 'Lebar'], correctIndex: 1),
    const Question(question: 'Kata tanya yang tepat untuk menanyakan nama orang adalah ...', emoji: '🙋', options: ['Di mana', 'Kapan', 'Siapa', 'Berapa'], correctIndex: 2),
    const Question(question: 'Kata tanya yang digunakan untuk menanyakan tempat adalah ...', emoji: '📍', options: ['Di mana', 'Siapa', 'Kapan', 'Mengapa'], correctIndex: 0),
    const Question(question: 'Kata tanya yang digunakan untuk menanyakan waktu adalah ...', emoji: '⏰', options: ['Siapa', 'Di mana', 'Kapan', 'Apa'], correctIndex: 2),
    const Question(question: '\'... yang menyapu halaman sekolah pagi ini?\' Kata tanya yang tepat untuk melengkapi kalimat tersebut adalah ...', emoji: '🧹', options: ['Kapan', 'Siapa', 'Di mana', 'Berapa'], correctIndex: 1),
    const Question(question: 'Sinonim dari kata \'gembira\' adalah ...', emoji: '😄', options: ['Sedih', 'Senang', 'Marah', 'Takut'], correctIndex: 1),
    const Question(question: 'Antonim dari kata \'panjang\' adalah ...', emoji: '📏', options: ['Tinggi', 'Lebar', 'Pendek', 'Jauh'], correctIndex: 2),
    const Question(question: 'Antonim dari kata \'siang\' adalah ...', emoji: '🌙', options: ['Pagi', 'Malam', 'Sore', 'Petang'], correctIndex: 1),
    const Question(question: 'Kalimat \'Ibu memasak nasi goreng di dapur.\' Kata tanya yang tepat untuk menanyakan tempat ibu memasak adalah ...', emoji: '🍳', options: ['Siapa', 'Kapan', 'Di mana', 'Apa'], correctIndex: 2),
    const Question(question: 'Ide atau hal utama yang dibahas dalam sebuah paragraf disebut ...', emoji: '💡', options: ['Ide pokok', 'Judul buku', 'Nama tokoh', 'Tanda baca'], correctIndex: 0),
    const Question(question: 'Sinonim dari kata \'rajin\' adalah ...', emoji: '📚', options: ['Malas', 'Tekun', 'Lelah', 'Lambat'], correctIndex: 1),
    Question.trueFalse(statement: 'Satu paragraf yang baik hanya membahas satu ide pokok.', isTrue: true, emoji: '✅'),
    Question.trueFalse(statement: 'Sinonim adalah kata-kata yang memiliki arti berlawanan.', isTrue: false, emoji: '🔄'),
    Question.trueFalse(statement: 'Kata tanya \'kapan\' digunakan untuk menanyakan waktu.', isTrue: true, emoji: '⏳'),
    Question.trueFalse(statement: 'Antonim dari kata \'tinggi\' adalah \'rendah\'.', isTrue: true, emoji: '⬇️'),
    Question.trueFalse(statement: 'Kata tanya \'siapa\' digunakan untuk menanyakan tempat.', isTrue: false, emoji: '❓'),
    Question.trueFalse(statement: 'Kata \'cepat\' dan \'lambat\' merupakan pasangan antonim.', isTrue: true, emoji: '🏃'),
    const Question(question: 'Lawan kata (antonim) dari kata \'gelap\' adalah ...', emoji: '💡', type: QuestionType.fillBlank, answer: 'terang'),
    const Question(question: 'Sinonim dari kata \'cantik\' adalah ...', emoji: '🌸', type: QuestionType.fillBlank, answer: 'indah'),
    const Question(question: 'Kata tanya untuk menanyakan tempat kita bersekolah adalah ...', emoji: '🏫', type: QuestionType.fillBlank, answer: 'di mana'),
    const Question(question: 'Lawan kata dari \'naik\' adalah ...', emoji: '⬇️', type: QuestionType.fillBlank, answer: 'turun'),
  ];

  static final List<Question> _science = [
    const Question(question: 'Urutan daur hidup kupu-kupu yang benar adalah...', emoji: '🦋', options: ['Telur - ulat - kepompong - kupu-kupu', 'Telur - kepompong - ulat - kupu-kupu', 'Ulat - telur - kupu-kupu - kepompong', 'Kupu-kupu - telur - kepompong - ulat'], correctIndex: 0),
    const Question(question: 'Perubahan bentuk tubuh hewan dari lahir sampai dewasa disebut...', emoji: '🐛', options: ['Fotosintesis', 'Metamorfosis', 'Reproduksi', 'Adaptasi'], correctIndex: 1),
    const Question(question: 'Pada daur hidup katak, telur akan menetas menjadi...', emoji: '🐸', options: ['Katak dewasa', 'Kepompong', 'Berudu (kecebong)', 'Ulat'], correctIndex: 2),
    const Question(question: 'Berudu (kecebong) bernapas menggunakan...', emoji: '🐟', options: ['Paru-paru', 'Insang', 'Kulit', 'Hidung'], correctIndex: 1),
    const Question(question: 'Tahap kepompong pada daur hidup kupu-kupu disebut juga...', emoji: '🦋', options: ['Larva', 'Nimfa', 'Pupa', 'Imago'], correctIndex: 2),
    const Question(question: 'Ulat adalah tahap yang paling banyak makan karena...', emoji: '🍃', options: ['Sedang tumbuh dan mengumpulkan tenaga', 'Ingin bermain', 'Sedang tidur', 'Akan bertelur'], correctIndex: 0),
    const Question(question: 'Katak dewasa bernapas menggunakan paru-paru dan...', emoji: '🐸', options: ['Insang', 'Sisik', 'Kulit', 'Ekor'], correctIndex: 2),
    const Question(question: 'Proses pencernaan makanan pertama kali terjadi di...', emoji: '👄', options: ['Lambung', 'Mulut', 'Usus', 'Kerongkongan'], correctIndex: 1),
    const Question(question: 'Gigi berfungsi untuk... makanan.', emoji: '🦷', options: ['Menelan', 'Mengunyah', 'Menghirup', 'Mencium'], correctIndex: 1),
    const Question(question: 'Cairan di dalam mulut yang membantu melumatkan makanan disebut...', emoji: '💧', options: ['Air liur', 'Keringat', 'Air mata', 'Darah'], correctIndex: 0),
    const Question(question: 'Setelah dikunyah di mulut, makanan turun ke lambung melalui...', emoji: '⬇️', options: ['Usus halus', 'Kerongkongan', 'Hidung', 'Tenggorokan'], correctIndex: 1),
    const Question(question: 'Di dalam lambung, makanan dihaluskan dengan bantuan...', emoji: '🫃', options: ['Getah lambung', 'Air liur', 'Udara', 'Darah'], correctIndex: 0),
    const Question(question: 'Hewan berikut yang mengalami metamorfosis adalah...', emoji: '🦋', options: ['Ayam', 'Kucing', 'Kupu-kupu', 'Sapi'], correctIndex: 2),
    const Question(question: 'Kupu-kupu dewasa menghisap makanan berupa... dari bunga.', emoji: '🌸', options: ['Madu buatan', 'Nektar (sari bunga)', 'Air biasa', 'Daun'], correctIndex: 1),
    Question.trueFalse(statement: 'Kupu-kupu mengalami metamorfosis sempurna karena melewati tahap kepompong.', isTrue: true, emoji: '🦋'),
    Question.trueFalse(statement: 'Berudu (kecebong) hidup di darat.', isTrue: false, emoji: '🐸'),
    Question.trueFalse(statement: 'Ulat akan berubah menjadi kepompong sebelum menjadi kupu-kupu.', isTrue: true, emoji: '🐛'),
    Question.trueFalse(statement: 'Lambung terletak di dalam kepala manusia.', isTrue: false, emoji: '🫃'),
    Question.trueFalse(statement: 'Lidah membantu kita merasakan makanan dan membalik makanan saat dikunyah.', isTrue: true, emoji: '👅'),
    Question.trueFalse(statement: 'Katak dewasa masih bernapas menggunakan insang seperti berudu.', isTrue: false, emoji: '🐸'),
    const Question(question: 'Tahap pertama dalam daur hidup kupu-kupu adalah ____.', emoji: '🥚', type: QuestionType.fillBlank, answer: 'telur'),
    const Question(question: 'Hewan yang berubah menjadi kupu-kupu setelah keluar dari kepompong tadinya berbentuk ____.', emoji: '🐛', type: QuestionType.fillBlank, answer: 'ulat'),
    const Question(question: 'Organ tempat makanan dihaluskan setelah dari kerongkongan disebut ____.', emoji: '🫃', type: QuestionType.fillBlank, answer: 'lambung'),
    const Question(question: 'Katak muda yang baru menetas dari telur disebut berudu atau ____.', emoji: '🐸', type: QuestionType.fillBlank, answer: 'kecebong'),
  ];

  static final List<Question> _religion = [
    const Question(question: 'Berapa jumlah ayat surah Al-Fatihah?', emoji: '🕌', options: ['5 ayat', '6 ayat', '7 ayat', '8 ayat'], correctIndex: 2),
    const Question(question: 'Berapa jumlah ayat surah Al-Ikhlas?', emoji: '📖', options: ['3 ayat', '4 ayat', '5 ayat', '6 ayat'], correctIndex: 1),
    const Question(question: 'Berapa jumlah ayat surah An-Nas?', emoji: '👥', options: ['4 ayat', '5 ayat', '6 ayat', '7 ayat'], correctIndex: 2),
    const Question(question: 'Berapa jumlah ayat surah Al-Falaq?', emoji: '🌅', options: ['4 ayat', '5 ayat', '6 ayat', '7 ayat'], correctIndex: 1),
    const Question(question: 'Surah yang menjadi pembuka Al-Qur\'an adalah?', emoji: '📕', options: ['An-Nas', 'Al-Fatihah', 'Al-Ikhlas', 'Al-Falaq'], correctIndex: 1),
    const Question(question: 'Surah Al-Ikhlas menjelaskan tentang?', emoji: '☝️', options: ['Kisah para nabi', 'Keesaan Allah (Allah Maha Esa)', 'Hari kiamat', 'Nama-nama malaikat'], correctIndex: 1),
    const Question(question: 'Arti kata "An-Nas" adalah?', emoji: '🧑‍🤝‍🧑', options: ['Manusia', 'Waktu subuh', 'Keikhlasan', 'Pembukaan'], correctIndex: 0),
    const Question(question: 'Arti kata "Al-Fatihah" adalah?', emoji: '🔑', options: ['Penutup', 'Pembukaan', 'Manusia', 'Waktu subuh'], correctIndex: 1),
    const Question(question: 'Surah yang paling terakhir dalam Al-Qur\'an adalah?', emoji: '🏁', options: ['Al-Falaq', 'Al-Ikhlas', 'An-Nas', 'Al-Fatihah'], correctIndex: 2),
    const Question(question: 'Dalam surah An-Nas dan Al-Falaq, kita memohon ... kepada Allah.', emoji: '🤲', options: ['Rezeki', 'Perlindungan', 'Ilmu', 'Teman'], correctIndex: 1),
    const Question(question: 'Surah Al-Ikhlas diawali dengan kalimat "Qul huwallahu ..."', emoji: '📜', options: ['Ahad', 'Falaq', 'Nas', 'Nur'], correctIndex: 0),
    const Question(question: 'Surah yang wajib kita baca pada setiap rakaat shalat adalah?', emoji: '🙏', options: ['Al-Ikhlas', 'Al-Fatihah', 'An-Nas', 'Al-Falaq'], correctIndex: 1),
    const Question(question: 'Di antara empat surah ini, manakah yang jumlah ayatnya paling sedikit?', emoji: '🔢', options: ['Al-Fatihah', 'Al-Ikhlas', 'An-Nas', 'Al-Falaq'], correctIndex: 1),
    Question.trueFalse(statement: 'Surah Al-Fatihah terdiri dari 7 ayat.', isTrue: true, emoji: '✅'),
    Question.trueFalse(statement: 'Surah Al-Ikhlas terdiri dari 6 ayat.', isTrue: false, emoji: '❌'),
    Question.trueFalse(statement: 'Surah An-Nas mengajarkan kita memohon perlindungan kepada Allah dari kejahatan bisikan.', isTrue: true, emoji: '🛡️'),
    Question.trueFalse(statement: 'Surah Al-Falaq terdiri dari 5 ayat.', isTrue: true, emoji: '🌄'),
    Question.trueFalse(statement: 'Al-Fatihah adalah surah penutup Al-Qur\'an.', isTrue: false, emoji: '📗'),
    Question.trueFalse(statement: 'Surah An-Nas terdiri dari 6 ayat.', isTrue: true, emoji: '🧮'),
    const Question(question: 'Jumlah ayat surah Al-Fatihah adalah ___ ayat.', emoji: '7️⃣', type: QuestionType.fillBlank, answer: '7'),
    const Question(question: 'Surah yang artinya "manusia" adalah surah ___.', emoji: '👤', type: QuestionType.fillBlank, answer: 'an-nas'),
    const Question(question: 'Jumlah ayat surah Al-Ikhlas adalah ___ ayat.', emoji: '4️⃣', type: QuestionType.fillBlank, answer: '4'),
    const Question(question: 'Surah pembuka dalam Al-Qur\'an adalah surah ___.', emoji: '📖', type: QuestionType.fillBlank, answer: 'al-fatihah'),
  ];

  static final List<Question> _ips = [
    const Question(question: 'Rumah adat Gadang berasal dari daerah?', emoji: '🏠', options: ['Sumatera Barat', 'Jawa Tengah', 'Papua', 'Bali'], correctIndex: 0),
    const Question(question: 'Tari Kecak berasal dari pulau?', emoji: '💃', options: ['Sumatera', 'Kalimantan', 'Bali', 'Sulawesi'], correctIndex: 2),
    const Question(question: 'Alat musik angklung dimainkan dengan cara?', emoji: '🎵', options: ['Ditiup', 'Dipukul', 'Digesek', 'Digoyang'], correctIndex: 3),
    const Question(question: 'Semboyan Bhinneka Tunggal Ika berarti?', emoji: '🇮🇩', options: ['Berbeda-beda tetapi tetap satu', 'Bersatu kita teguh', 'Satu untuk semua', 'Rukun dan damai'], correctIndex: 0),
    const Question(question: 'Candi Borobudur terletak di provinsi?', emoji: '🛕', options: ['Jawa Timur', 'Jawa Tengah', 'Yogyakarta', 'Jawa Barat'], correctIndex: 1),
    const Question(question: 'Rumah adat Joglo berasal dari suku?', emoji: '🏡', options: ['Batak', 'Dayak', 'Jawa', 'Asmat'], correctIndex: 2),
    const Question(question: 'Tari Saman yang gerakannya cepat dan kompak berasal dari?', emoji: '🙌', options: ['Aceh', 'Maluku', 'Papua', 'Betawi'], correctIndex: 0),
    const Question(question: 'Alat musik gamelan banyak berasal dari daerah?', emoji: '🥁', options: ['Sumatera', 'Jawa dan Bali', 'Papua', 'Kalimantan'], correctIndex: 1),
    const Question(question: 'Alat musik tifa yang dipukul berasal dari daerah?', emoji: '🪘', options: ['Papua', 'Sunda', 'Minang', 'Bugis'], correctIndex: 0),
    const Question(question: 'Rumah adat Honai yang berbentuk bulat berasal dari?', emoji: '🛖', options: ['Bali', 'Papua', 'Aceh', 'Jawa'], correctIndex: 1),
    const Question(question: 'Kita harus bersikap seperti apa terhadap teman yang berbeda suku dan agama?', emoji: '🤝', options: ['Mengejek', 'Menjauhi', 'Saling menghormati', 'Bertengkar'], correctIndex: 2),
    const Question(question: 'Tari Piring yang penarinya membawa piring berasal dari?', emoji: '🍽️', options: ['Sumatera Barat', 'Bali', 'Papua', 'Kalimantan'], correctIndex: 0),
    const Question(question: 'Bangunan bersejarah berupa istana tempat tinggal raja disebut?', emoji: '👑', options: ['Museum', 'Keraton', 'Pasar', 'Terminal'], correctIndex: 1),
    const Question(question: 'Alat musik kolintang yang terbuat dari kayu berasal dari daerah?', emoji: '🎶', options: ['Sulawesi Utara', 'Bali', 'Aceh', 'Betawi'], correctIndex: 0),
    Question.trueFalse(statement: 'Indonesia memiliki banyak suku, budaya, dan bahasa yang berbeda-beda.', isTrue: true, emoji: '🌏'),
    Question.trueFalse(statement: 'Rumah adat Tongkonan berasal dari suku Toraja di Sulawesi.', isTrue: true, emoji: '🏠'),
    Question.trueFalse(statement: 'Angklung adalah alat musik yang berasal dari Papua.', isTrue: false, emoji: '🎼'),
    Question.trueFalse(statement: 'Kita boleh mengejek teman yang berbeda daerah asalnya.', isTrue: false, emoji: '🚫'),
    Question.trueFalse(statement: 'Candi Prambanan adalah tempat bersejarah peninggalan agama Hindu.', isTrue: true, emoji: '🛕'),
    Question.trueFalse(statement: 'Tari Reog berasal dari daerah Ponorogo di Jawa Timur.', isTrue: true, emoji: '🦁'),
    const Question(question: 'Alat musik yang dimainkan dengan cara digesek menggunakan busur adalah re...', emoji: '🎻', type: QuestionType.fillBlank, answer: 'rebab'),
    const Question(question: 'Rumah adat yang berasal dari daerah Sumatera Barat adalah rumah Ga...', emoji: '🏠', type: QuestionType.fillBlank, answer: 'gadang'),
    const Question(question: 'Semboyan bangsa Indonesia yang berarti berbeda-beda tetapi tetap satu adalah Bhinneka Tunggal ...', emoji: '🇮🇩', type: QuestionType.fillBlank, answer: 'ika'),
    const Question(question: 'Candi Buddha terbesar di Indonesia yang terletak di Magelang adalah candi Boro...', emoji: '🛕', type: QuestionType.fillBlank, answer: 'borobudur'),
  ];

}
