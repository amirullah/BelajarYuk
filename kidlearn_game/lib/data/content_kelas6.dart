import '../models/question.dart';
import '../models/subject.dart';

/// Bank soal Kelas 6 — Stage 6 — comprehension, listrik/Bumi, hari akhir/muamalah, ASEAN.
/// Dihasilkan & diverifikasi otomatis (generate + fact-check), aligned rencana.
/// Catatan: soal Agama Islam perlu review akhir oleh ahli.
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
    const Question(question: 'Read the passage: \'The old lighthouse had stood on the rocky cliff for over a hundred years. Its beam still swept across the dark sea every night, warning ships of the jagged rocks below.\' What is the main purpose of the lighthouse?', emoji: '🗼', options: ['To decorate the cliff', 'To warn ships of danger', 'To store fishing boats', 'To attract tourists at night'], correctIndex: 1, objectiveCode: '6Rw.01'),
    const Question(question: 'Read: \'Maya trembled as she stepped onto the stage. Her hands were cold and her heart pounded, but she took a deep breath and began to speak.\' How does Maya most likely feel?', emoji: '🎤', options: ['Bored', 'Angry', 'Nervous', 'Sleepy'], correctIndex: 2, objectiveCode: '6Rw.02'),
    const Question(question: 'Which sentence is written in the passive voice?', emoji: '🌹', options: ['The gardener plants the roses.', 'The roses are planted by the gardener.', 'The gardener is planting roses.', 'The gardener will plant roses.'], correctIndex: 1, objectiveCode: '6Ug.01'),
    const Question(question: 'Change to passive voice: \'The teacher marks the tests.\' Which is correct?', emoji: '📝', options: ['The tests are marked by the teacher.', 'The tests marked the teacher.', 'The teacher is marked by the tests.', 'The tests were marking the teacher.'], correctIndex: 0, objectiveCode: '6Ug.01'),
    const Question(question: 'In a formal letter, which greeting is most appropriate when you do not know the reader\'s name?', emoji: '✉️', options: ['Hey there,', 'Dear Sir or Madam,', 'Hi friend,', 'What\'s up,'], correctIndex: 1, objectiveCode: '6Wc.01'),
    const Question(question: 'Which word is the most formal synonym for \'buy\'?', emoji: '🛒', options: ['Grab', 'Purchase', 'Get', 'Pick up'], correctIndex: 1, objectiveCode: '6Rv.01'),
    const Question(question: 'Choose the most formal synonym for \'help\' suitable for a speech.', emoji: '🤝', options: ['Assist', 'Lend a hand', 'Back up', 'Give a hand'], correctIndex: 0, objectiveCode: '6Rv.01'),
    const Question(question: 'Read: \'Ladies and gentlemen, thank you for being here today. It is a great honour to address such a distinguished audience.\' This language is used in a —', emoji: '🎙️', options: ['Text message', 'Formal speech', 'Shopping list', 'Personal diary'], correctIndex: 1, objectiveCode: '6Wc.02'),
    const Question(question: 'Which sentence uses correct passive voice in the past tense?', emoji: '🪟', options: ['The window was broken by the storm.', 'The window breaks by the storm.', 'The storm broken the window.', 'The window is break by the storm.'], correctIndex: 0, objectiveCode: '6Ug.01'),
    const Question(question: 'Read: \'Although it was raining heavily, the children continued their football match without complaint.\' What can we infer about the children?', emoji: '⚽', options: ['They hated football', 'They were determined', 'They went home early', 'They were afraid of rain'], correctIndex: 1, objectiveCode: '6Rw.02'),
    const Question(question: 'Which is the most suitable closing for a formal letter?', emoji: '📮', options: ['See ya,', 'Yours faithfully,', 'Love,', 'Cheers mate,'], correctIndex: 1, objectiveCode: '6Wc.01'),
    const Question(question: 'Choose the formal synonym for \'ask for\' in a request letter.', emoji: '📩', options: ['Request', 'Beg', 'Wonder', 'Poke'], correctIndex: 0, objectiveCode: '6Rv.01'),
    const Question(question: 'Read: \'The ancient bridge, which had been built by Roman engineers, was still used by travellers today.\' Who built the bridge?', emoji: '🌉', options: ['Modern travellers', 'Roman engineers', 'Local farmers', 'The king\'s soldiers'], correctIndex: 1, objectiveCode: '6Rw.01'),
    const Question(question: 'Which sentence is the most formal way to begin a complaint letter?', emoji: '📄', options: ['I\'m writing \'cause I\'m angry.', 'I am writing to express my concern regarding your service.', 'Your service is rubbish and I hate it.', 'Just wanted to moan about stuff.'], correctIndex: 1, objectiveCode: '6Wc.02'),
    Question.trueFalse(statement: 'True or False: In the passive voice, the focus is on the action or the receiver of the action rather than who performs it.', isTrue: true, emoji: '🔄'),
    Question.trueFalse(statement: 'True or False: \'Yours sincerely\' is used when you begin a letter with the person\'s name, such as \'Dear Mrs Lee\'.', isTrue: true, emoji: '✍️'),
    Question.trueFalse(statement: 'True or False: The word \'kid\' is more formal than the word \'child\'.', isTrue: false, emoji: '🧒'),
    Question.trueFalse(statement: 'True or False: The sentence \'The letter was written yesterday\' is in the passive voice.', isTrue: true, emoji: '📜'),
    Question.trueFalse(statement: 'True or False: A formal speech should use plenty of slang to sound friendly to the audience.', isTrue: false, emoji: '🚫'),
    Question.trueFalse(statement: 'True or False: In reading comprehension, an inference is an idea the reader works out that is not stated directly in the text.', isTrue: true, emoji: '🧠'),
    const Question(question: 'Fill in the blank with the passive form: \'The cake ______ eaten by the guests.\' (use one word)', emoji: '🍰', type: QuestionType.fillBlank, answer: 'was'),
    const Question(question: 'Complete the formal letter opening: \'Dear Sir or ______,\' (one word)', emoji: '✉️', type: QuestionType.fillBlank, answer: 'madam'),
    const Question(question: 'Give a more formal synonym for the word \'big\' often used in formal writing (one word starting with \'l\').', emoji: '📏', type: QuestionType.fillBlank, answer: 'large'),
    const Question(question: 'Change to passive: \'Someone cleans the office every day.\' → \'The office ______ cleaned every day.\' (one word)', emoji: '🧹', type: QuestionType.fillBlank, answer: 'is'),
  ];

  static final List<Question> _indonesian = [
    const Question(question: 'Bagian surat resmi yang berisi tempat dan tanggal pembuatan surat biasanya diletakkan di bagian...', emoji: '📅', options: ['Kanan atas surat', 'Tengah surat', 'Bawah tanda tangan', 'Di dalam isi surat'], correctIndex: 0),
    const Question(question: 'Kalimat berikut yang menggunakan kata baku adalah...', emoji: '✍️', options: ['Saya sudah kasih tau dia kemarin.', 'Ibu membeli obat di apotek dekat rumah.', 'Adik lagi maen di halaman.', 'Kita nggak jadi pergi ke sekolah.'], correctIndex: 1),
    const Question(question: 'Bagian pidato yang berisi salam pembuka dan ucapan syukur disebut bagian...', emoji: '🎤', options: ['Isi', 'Penutup', 'Pembukaan', 'Kesimpulan'], correctIndex: 2),
    const Question(question: 'Kata baku yang benar dari kata \'apotik\' adalah...', emoji: '💊', options: ['Apotek', 'Apotix', 'Apoteker', 'Apotic'], correctIndex: 0),
    const Question(question: 'Salah satu ciri bahasa yang digunakan dalam surat resmi adalah...', emoji: '📄', options: ['Menggunakan bahasa gaul', 'Menggunakan bahasa baku dan sopan', 'Menggunakan singkatan bebas', 'Menggunakan bahasa daerah'], correctIndex: 1),
    const Question(question: 'Bagian akhir sebuah pidato yang berisi kesimpulan dan permohonan maaf disebut...', emoji: '🙏', options: ['Pembukaan', 'Isi', 'Judul', 'Penutup'], correctIndex: 3),
    const Question(question: 'Contoh kata tidak baku dalam kalimat \'Dia bilang akan datang besok\' adalah kata...', emoji: '🗣️', options: ['Dia', 'Bilang', 'Datang', 'Besok'], correctIndex: 1),
    const Question(question: 'Bagian surat resmi yang mencantumkan nama lembaga, alamat, dan nomor telepon disebut...', emoji: '🏢', options: ['Kepala surat (kop surat)', 'Salam pembuka', 'Isi surat', 'Tembusan'], correctIndex: 0),
    const Question(question: 'Kata baku yang tepat dari \'nasehat\' adalah...', emoji: '📚', options: ['Nasihat', 'Nasehat', 'Nasyat', 'Naseat'], correctIndex: 0),
    const Question(question: 'Kalimat pembuka pidato yang tepat adalah...', emoji: '👋', options: ['Sekian pidato dari saya.', 'Assalamualaikum dan selamat pagi, Bapak Ibu yang saya hormati.', 'Terima kasih atas perhatiannya.', 'Demikian yang dapat saya sampaikan.'], correctIndex: 1),
    const Question(question: 'Bagian isi pidato berfungsi untuk...', emoji: '💬', options: ['Mengucapkan salam', 'Menyampaikan pokok atau inti pembicaraan', 'Menutup pidato', 'Memperkenalkan diri saja'], correctIndex: 1),
    const Question(question: 'Kata baku yang benar adalah...', emoji: '🗓️', options: ['Jadwal', 'Jadual', 'Jadwaal', 'Jatwal'], correctIndex: 0),
    const Question(question: 'Surat undangan rapat dari sekolah kepada orang tua siswa termasuk jenis surat...', emoji: '✉️', options: ['Surat pribadi', 'Surat resmi', 'Surat cinta', 'Surat kaleng'], correctIndex: 1),
    const Question(question: 'Kata baku dari \'praktek\' menurut ejaan yang benar adalah...', emoji: '🔬', options: ['Praktik', 'Praktek', 'Prakktek', 'Pratik'], correctIndex: 0),
    Question.trueFalse(statement: 'Surat resmi selalu ditulis menggunakan bahasa baku.', isTrue: true, emoji: '📝'),
    Question.trueFalse(statement: 'Pidato hanya terdiri dari dua bagian, yaitu pembukaan dan isi saja.', isTrue: false, emoji: '🎙️'),
    Question.trueFalse(statement: 'Kata \'ijin\' adalah bentuk baku dari kata \'izin\'.', isTrue: false, emoji: '🚫'),
    Question.trueFalse(statement: 'Nomor surat merupakan salah satu bagian dari surat resmi.', isTrue: true, emoji: '🔢'),
    Question.trueFalse(statement: 'Dalam surat resmi kita boleh menggunakan bahasa gaul agar lebih akrab.', isTrue: false, emoji: '❌'),
    Question.trueFalse(statement: 'Salam penutup seperti \'Wassalamualaikum\' termasuk bagian penutup pidato.', isTrue: true, emoji: '🤝'),
    const Question(question: 'Bentuk baku dari kata \'aktifitas\' adalah ...', emoji: '🏃', type: QuestionType.fillBlank, answer: 'aktivitas'),
    const Question(question: 'Bagian pidato yang berisi inti atau pokok pembicaraan disebut bagian ...', emoji: '📖', type: QuestionType.fillBlank, answer: 'isi'),
    const Question(question: 'Bentuk baku dari kata \'sistim\' adalah ...', emoji: '⚙️', type: QuestionType.fillBlank, answer: 'sistem'),
    const Question(question: 'Bagian surat resmi yang berisi tujuan dan pokok surat disebut ... surat.', emoji: '📬', type: QuestionType.fillBlank, answer: 'isi'),
  ];

  static final List<Question> _science = [
    const Question(question: 'Pada rangkaian listrik seri, jika salah satu lampu putus atau dilepas, apa yang terjadi pada lampu lainnya?', emoji: '💡', options: ['Semua lampu lain ikut padam', 'Lampu lain menyala lebih terang', 'Lampu lain tetap menyala seperti biasa', 'Lampu lain menyala berkedip'], correctIndex: 0),
    const Question(question: 'Benda yang dapat menghantarkan arus listrik dengan baik disebut...', emoji: '🔌', options: ['Isolator', 'Konduktor', 'Resistor', 'Generator'], correctIndex: 1),
    const Question(question: 'Berikut ini yang merupakan contoh benda isolator listrik adalah...', emoji: '🧽', options: ['Paku besi', 'Kawat tembaga', 'Karet penghapus', 'Sendok aluminium'], correctIndex: 2),
    const Question(question: 'Alat yang berfungsi untuk memutus dan menyambung arus listrik pada rangkaian disebut...', emoji: '🔘', options: ['Baterai', 'Sakelar', 'Lampu', 'Kabel'], correctIndex: 1),
    const Question(question: 'Salah satu keuntungan rangkaian paralel dibanding rangkaian seri adalah...', emoji: '💡', options: ['Menggunakan lebih sedikit kabel', 'Jika satu lampu padam, lampu lain tetap menyala', 'Nyala lampu menjadi lebih redup', 'Baterai lebih cepat habis'], correctIndex: 1),
    const Question(question: 'Contoh sumber energi listrik yang biasa digunakan pada senter adalah...', emoji: '🔦', options: ['Baterai', 'Kincir angin', 'Panel surya besar', 'Bendungan air'], correctIndex: 0),
    const Question(question: 'Peristiwa perputaran Bumi pada porosnya disebut...', emoji: '🌍', options: ['Revolusi Bumi', 'Rotasi Bumi', 'Gravitasi Bumi', 'Orbit Bumi'], correctIndex: 1),
    const Question(question: 'Pergantian siang dan malam di Bumi disebabkan oleh...', emoji: '🌗', options: ['Revolusi Bumi mengelilingi Matahari', 'Rotasi Bumi pada porosnya', 'Perputaran Bulan mengelilingi Bumi', 'Gerhana Matahari'], correctIndex: 1),
    const Question(question: 'Waktu yang diperlukan Bumi untuk satu kali rotasi adalah sekitar...', emoji: '⏰', options: ['24 jam', '365 hari', '30 hari', '12 jam'], correctIndex: 0),
    const Question(question: 'Gerakan Bumi mengelilingi Matahari disebut...', emoji: '☀️', options: ['Rotasi', 'Revolusi', 'Gravitasi', 'Refleksi'], correctIndex: 1),
    const Question(question: 'Terjadinya pergantian musim di Bumi disebabkan oleh...', emoji: '🍂', options: ['Rotasi Bumi', 'Revolusi Bumi dan kemiringan sumbu Bumi', 'Perputaran Bulan', 'Gerakan awan'], correctIndex: 1),
    const Question(question: 'Kutub baterai yang menandakan arus keluar biasanya diberi tanda...', emoji: '🔋', options: ['Positif (+)', 'Netral (0)', 'Ganda (±)', 'Tidak ada tanda'], correctIndex: 0),
    const Question(question: 'Lampu di rumah biasanya dipasang secara paralel agar...', emoji: '🏠', options: ['Menghemat jumlah lampu', 'Setiap lampu bisa dinyalakan atau dimatikan sendiri-sendiri', 'Semua lampu selalu menyala bersamaan', 'Lampu menjadi lebih redup'], correctIndex: 1),
    const Question(question: 'Waktu yang diperlukan Bumi untuk satu kali revolusi mengelilingi Matahari adalah sekitar...', emoji: '📅', options: ['24 jam', '7 hari', '365 hari (1 tahun)', '30 hari'], correctIndex: 2),
    Question.trueFalse(statement: 'Pada rangkaian paralel, jika satu lampu dilepas maka lampu yang lain akan tetap menyala.', isTrue: true, emoji: '💡'),
    Question.trueFalse(statement: 'Kayu kering termasuk bahan konduktor yang menghantarkan listrik dengan baik.', isTrue: false, emoji: '🪵'),
    Question.trueFalse(statement: 'Rotasi Bumi menyebabkan terjadinya siang dan malam.', isTrue: true, emoji: '🌓'),
    Question.trueFalse(statement: 'Bumi berputar mengelilingi Bulan sehingga terjadi pergantian musim.', isTrue: false, emoji: '🌙'),
    Question.trueFalse(statement: 'Sakelar dalam keadaan terbuka (off) akan memutus aliran arus listrik sehingga lampu padam.', isTrue: true, emoji: '🔘'),
    Question.trueFalse(statement: 'Bagian Bumi yang menghadap Matahari akan mengalami waktu malam hari.', isTrue: false, emoji: '🌞'),
    const Question(question: 'Bahan yang tidak dapat menghantarkan arus listrik disebut ...', emoji: '🧤', type: QuestionType.fillBlank, answer: 'isolator'),
    const Question(question: 'Rangkaian listrik yang disusun secara berurutan atau satu jalur disebut rangkaian ...', emoji: '🔗', type: QuestionType.fillBlank, answer: 'seri'),
    const Question(question: 'Perputaran Bumi mengelilingi Matahari disebut ...', emoji: '🌍', type: QuestionType.fillBlank, answer: 'revolusi'),
    const Question(question: 'Sumber energi listrik yang berasal dari cahaya Matahari dan diubah oleh panel surya disebut energi ...', emoji: '☀️', type: QuestionType.fillBlank, answer: 'surya'),
  ];

  static final List<Question> _religion = [
    const Question(question: 'Iman kepada Hari Akhir termasuk Rukun Iman yang ke-...', emoji: '🕌', options: ['Ketiga', 'Keempat', 'Kelima', 'Keenam'], correctIndex: 2),
    const Question(question: 'Hari ketika semua manusia dibangkitkan kembali dari kubur disebut...', emoji: '⏳', options: ['Yaumul Ba\'ats', 'Yaumul Hisab', 'Yaumul Mizan', 'Yaumul Jaza'], correctIndex: 0),
    const Question(question: 'Hari perhitungan seluruh amal perbuatan manusia disebut...', emoji: '📖', options: ['Yaumul Ba\'ats', 'Yaumul Hisab', 'Yaumul Mahsyar', 'Yaumul Barzah'], correctIndex: 1),
    const Question(question: 'Timbangan yang digunakan untuk menimbang amal baik dan buruk manusia di akhirat disebut...', emoji: '⚖️', options: ['Sirat', 'Mizan', 'Hisab', 'Mahsyar'], correctIndex: 1),
    const Question(question: 'Malaikat yang bertugas meniup sangkakala sebagai tanda datangnya Hari Kiamat adalah...', emoji: '📯', options: ['Jibril', 'Mikail', 'Israfil', 'Izrail'], correctIndex: 2),
    const Question(question: 'Tambahan pembayaran yang dilarang dalam Islam ketika berutang atau meminjam disebut...', emoji: '💰', options: ['Zakat', 'Infak', 'Riba', 'Sedekah'], correctIndex: 2),
    const Question(question: 'Sikap yang benar bagi seorang pedagang Muslim ketika menjual barang adalah...', emoji: '🤝', options: ['Menyembunyikan cacat barang', 'Jujur menyebutkan keadaan barang', 'Mengurangi timbangan', 'Menaikkan harga dengan menipu'], correctIndex: 1),
    const Question(question: 'Bekal terbaik yang dapat menyelamatkan manusia di Hari Akhir adalah...', emoji: '🌟', options: ['Harta yang banyak', 'Jabatan tinggi', 'Amal saleh dan takwa', 'Rumah yang megah'], correctIndex: 2),
    const Question(question: 'Buku atau catatan yang berisi seluruh amal perbuatan manusia selama hidup disebut...', emoji: '📚', options: ['Kitab amal', 'Kitab suci', 'Mushaf', 'Sahifah wahyu'], correctIndex: 0),
    const Question(question: 'Kiamat yang berupa kematian seseorang atau bencana kecil disebut kiamat...', emoji: '🌪️', options: ['Kubra', 'Sugra', 'Akbar', 'Wusta'], correctIndex: 1),
    const Question(question: 'Berikut yang termasuk perbuatan curang dalam jual beli adalah...', emoji: '⚠️', options: ['Menimbang dengan adil', 'Mengurangi takaran atau timbangan', 'Menjelaskan harga dengan benar', 'Memberi barang sesuai pesanan'], correctIndex: 1),
    const Question(question: 'Padang luas tempat berkumpulnya seluruh manusia setelah dibangkitkan disebut padang...', emoji: '🏜️', options: ['Arafah', 'Mahsyar', 'Barzah', 'Firdaus'], correctIndex: 1),
    const Question(question: 'Hukum melakukan riba dalam agama Islam adalah...', emoji: '🚫', options: ['Wajib', 'Sunnah', 'Mubah', 'Haram'], correctIndex: 3),
    const Question(question: 'Amal yang pahalanya terus mengalir walaupun seseorang telah meninggal, misalnya sedekah jariyah, adalah bekal untuk...', emoji: '💧', options: ['Kehidupan dunia saja', 'Kehidupan akhirat', 'Menambah harta', 'Mendapat pujian'], correctIndex: 1),
    Question.trueFalse(statement: 'Iman kepada Hari Akhir merupakan Rukun Iman yang kelima.', isTrue: true, emoji: '✅'),
    Question.trueFalse(statement: 'Melakukan riba diperbolehkan dalam Islam asalkan jumlahnya sedikit.', isTrue: false, emoji: '❌'),
    Question.trueFalse(statement: 'Penjual boleh menyembunyikan cacat barang agar barangnya cepat laku.', isTrue: false, emoji: '🙅'),
    Question.trueFalse(statement: 'Setelah Hari Kiamat, semua manusia akan dibangkitkan untuk mempertanggungjawabkan amalnya.', isTrue: true, emoji: '🔔'),
    Question.trueFalse(statement: 'Amal baik yang kita lakukan di dunia menjadi bekal kita di akhirat.', isTrue: true, emoji: '🌱'),
    Question.trueFalse(statement: 'Hari Kiamat pasti akan terjadi, tetapi waktunya hanya diketahui oleh Allah Swt.', isTrue: true, emoji: '🌙'),
    const Question(question: 'Rukun Iman yang kelima adalah iman kepada ... (isi dua kata).', emoji: '🕋', type: QuestionType.fillBlank, answer: 'hari akhir'),
    const Question(question: 'Malaikat yang bertugas meniup sangkakala pada Hari Kiamat bernama ...', emoji: '📯', type: QuestionType.fillBlank, answer: 'israfil'),
    const Question(question: 'Tambahan pembayaran yang dilarang dalam pinjam-meminjam menurut Islam disebut ...', emoji: '💸', type: QuestionType.fillBlank, answer: 'riba'),
    const Question(question: 'Alat penimbang amal manusia baik dan buruk di akhirat disebut ...', emoji: '⚖️', type: QuestionType.fillBlank, answer: 'mizan'),
  ];

  static final List<Question> _ips = [
    const Question(question: 'Indonesia menjadi salah satu negara pendiri organisasi ASEAN. Apa kepanjangan dari ASEAN?', emoji: '🌏', options: ['Association of Southeast Asian Nations', 'Asian South East Alliance Nations', 'Association of South American Nations', 'Asia Europe Association Nations'], correctIndex: 0),
    const Question(question: 'ASEAN didirikan di kota mana pada tahun 1967?', emoji: '🏙️', options: ['Jakarta', 'Bangkok', 'Kuala Lumpur', 'Manila'], correctIndex: 1),
    const Question(question: 'Tokoh yang mewakili Indonesia dalam pendirian ASEAN adalah...', emoji: '🤝', options: ['Mohammad Hatta', 'Adam Malik', 'Ir. Soekarno', 'Sutan Sjahrir'], correctIndex: 1),
    const Question(question: 'Berapa jumlah negara yang menandatangani Deklarasi Bangkok sebagai pendiri ASEAN?', emoji: '🔢', options: ['3 negara', '4 negara', '5 negara', '6 negara'], correctIndex: 2),
    const Question(question: 'Naskah Proklamasi Kemerdekaan Indonesia dibacakan pada tanggal...', emoji: '📜', options: ['17 Agustus 1945', '1 Juni 1945', '28 Oktober 1928', '10 November 1945'], correctIndex: 0),
    const Question(question: 'Teks Proklamasi Kemerdekaan Indonesia dibacakan oleh...', emoji: '🎤', options: ['Mohammad Hatta', 'Ir. Soekarno', 'Ahmad Soebardjo', 'Sayuti Melik'], correctIndex: 1),
    const Question(question: 'Tokoh yang mendampingi Soekarno dan disebut sebagai Wakil Presiden pertama Indonesia adalah...', emoji: '👥', options: ['Mohammad Hatta', 'Sutan Sjahrir', 'Ahmad Soebardjo', 'Ki Hajar Dewantara'], correctIndex: 0),
    const Question(question: 'Karena kegiatan menjual barang ke luar negeri disebut ekspor, maka kegiatan membeli barang dari luar negeri disebut...', emoji: '🚢', options: ['Ekspor', 'Impor', 'Distribusi', 'Produksi'], correctIndex: 1),
    const Question(question: 'Berikut ini yang merupakan contoh barang ekspor unggulan Indonesia adalah...', emoji: '🌴', options: ['Kelapa sawit dan karet', 'Gandum dan terigu', 'Mobil mewah dari Eropa', 'Kurma dari Timur Tengah'], correctIndex: 0),
    const Question(question: 'Mata uang resmi negara Indonesia adalah...', emoji: '💵', options: ['Ringgit', 'Rupiah', 'Peso', 'Baht'], correctIndex: 1),
    const Question(question: 'Lembaga yang berwenang mengeluarkan dan mengedarkan uang Rupiah di Indonesia adalah...', emoji: '🏦', options: ['Bank Indonesia', 'Bank Dunia', 'Kementerian Perdagangan', 'PT Pos Indonesia'], correctIndex: 0),
    const Question(question: 'Orang atau negara yang melakukan kegiatan ekspor disebut...', emoji: '📦', options: ['Importir', 'Eksportir', 'Distributor', 'Konsumen'], correctIndex: 1),
    const Question(question: 'Peristiwa Rengasdengklok terjadi menjelang Proklamasi. Apa tujuan para pemuda membawa Soekarno-Hatta ke Rengasdengklok?', emoji: '🚗', options: ['Mendesak agar segera memproklamasikan kemerdekaan', 'Menyembunyikan mereka dari rakyat', 'Mengungsi karena bencana alam', 'Menghadiri sidang ASEAN'], correctIndex: 0),
    const Question(question: 'Salah satu tujuan dibentuknya ASEAN adalah...', emoji: '🕊️', options: ['Menjajah negara tetangga', 'Meningkatkan kerja sama di bidang ekonomi dan sosial', 'Menciptakan mata uang tunggal dunia', 'Membentuk pasukan perang bersama melawan Asia'], correctIndex: 1),
    Question.trueFalse(statement: 'Indonesia adalah salah satu negara pendiri ASEAN.', isTrue: true, emoji: '🇮🇩'),
    Question.trueFalse(statement: 'Proklamasi Kemerdekaan Indonesia dibacakan di Kota Surabaya.', isTrue: false, emoji: '📍'),
    Question.trueFalse(statement: 'Kegiatan menjual barang ke luar negeri disebut impor.', isTrue: false, emoji: '🔄'),
    Question.trueFalse(statement: 'Mata uang Rupiah menggunakan lambang atau simbol "Rp".', isTrue: true, emoji: '💴'),
    Question.trueFalse(statement: 'Semua negara di ASEAN menggunakan mata uang Rupiah.', isTrue: false, emoji: '🌐'),
    Question.trueFalse(statement: 'Ir. Soekarno adalah Presiden pertama Republik Indonesia.', isTrue: true, emoji: '⭐'),
    const Question(question: 'Naskah Proklamasi diketik oleh Sayuti Melik. Proklamasi dibacakan pada tahun ...', emoji: '🗓️', type: QuestionType.fillBlank, answer: '1945'),
  ];

}
