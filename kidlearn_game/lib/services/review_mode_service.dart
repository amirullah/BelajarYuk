/// Mode Review: buka akses semua kelas untuk developer/admin.
/// HANYA flag in-memory — tidak menyentuh profil anak sama sekali.
/// Otomatis mereset saat app di-restart (tidak persist ke storage).
class ReviewModeService {
  ReviewModeService._();
  static final instance = ReviewModeService._();

  bool _active = false;
  bool get isActive => _active;

  void activate() => _active = true;
  void deactivate() => _active = false;
}
