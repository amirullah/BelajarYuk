import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/profile.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../utils/app_colors.dart';
import '../widgets/uku_mascot.dart';
import 'home_v2_screen.dart';

/// Pilih profil anak (maks 5 per akun). Semua mulai Kelas 1.
/// [mustCreate] = arahkan langsung membuat profil bila belum ada.
class ProfileSelectScreen extends StatefulWidget {
  final bool mustCreate;
  const ProfileSelectScreen({super.key, this.mustCreate = false});

  @override
  State<ProfileSelectScreen> createState() => _ProfileSelectScreenState();
}

class _ProfileSelectScreenState extends State<ProfileSelectScreen> {
  final _api = ApiService();
  final _storage = StorageService();
  List<ChildProfile> _profiles = [];
  bool _loading = true;

  static const _avatars = ['🦊', '🐼', '🦁', '🐰', '🐨', '🐯', '🦉', '🐧'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final token = await _storage.getToken();
      if (token != null) {
        final res = await _api.profiles(token);
        if (res['ok'] == true && res['profiles'] is List) {
          _profiles = (res['profiles'] as List).map((p) {
            return ChildProfile(
              id: '${p['id']}',
              name: p['name'] as String,
              avatar: (p['avatar'] as String?) ?? '🦊',
              unlockedGrade: (p['unlocked_grade'] as num?)?.toInt() ?? 1,
            );
          }).toList();
          await _storage.saveProfiles(_profiles);
        } else {
          // Respons tak sesuai → pakai cache lokal yang ada.
          _profiles = await _storage.loadProfiles();
        }
      } else {
        _profiles = await _storage.loadProfiles();
      }
    } catch (_) {
      // Offline / lambat / gagal → jangan menggantung, pakai cache lokal.
      _profiles = await _storage.loadProfiles();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
    // Arahkan langsung membuat profil pertama bila belum ada.
    if (widget.mustCreate && _profiles.isEmpty && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _addProfile();
      });
    }
  }

  Future<void> _pick(ChildProfile p) async {
    await _storage.setCurrentProfileId(p.id);
    if (mounted) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeV2Screen()));
    }
  }

  Future<void> _addProfile() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => const _AddProfileDialog(avatars: _avatars),
    );
    if (result == null) return;
    final name = result['name']!;
    final avatar = result['avatar']!;
    final token = await _storage.getToken();

    // Coba buat di server bila login; kalau gagal/offline → buat lokal.
    if (token != null) {
      try {
        final res = await _api.createProfile(token, name, avatar);
        if (res['ok'] == true) {
          final wasEmpty = _profiles.isEmpty;
          await _load();
          if (wasEmpty && _profiles.isNotEmpty) {
            await _pick(_profiles.last);
          }
          return;
        }
      } catch (_) {
        // jatuh ke pembuatan lokal di bawah
      }
    }

    // Fallback lokal — pengguna tetap bisa lanjut walau server tak terjangkau.
    final local = ChildProfile(
      id: 'local-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      avatar: avatar,
    );
    await _storage.upsertProfile(local);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Profil dibuat. (Tersimpan di HP; akan disinkronkan bila online)')));
    }
    await _pick(local);
  }

  void _snack(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(msg), behavior: SnackBarBehavior.floating));
    }
  }

  /// Menu tindakan profil (Edit / Hapus).
  Future<void> _profileMenu(ChildProfile p) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('${p.avatar}  ${p.name}',
                  style: GoogleFonts.nunito(
                      fontSize: 18, fontWeight: FontWeight.w800)),
            ),
            ListTile(
              leading: const Icon(Icons.edit_rounded, color: kPrimary),
              title: Text('Edit profil', style: GoogleFonts.nunito()),
              onTap: () => Navigator.pop(context, 'edit'),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded, color: kError),
              title: Text('Hapus profil',
                  style: GoogleFonts.nunito(color: kError)),
              onTap: () => Navigator.pop(context, 'delete'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (action == 'edit') await _editProfile(p);
    if (action == 'delete') await _deleteProfile(p);
  }

  Future<void> _editProfile(ChildProfile p) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => _AddProfileDialog(
        avatars: _avatars,
        title: 'Edit Profil',
        initialName: p.name,
        initialAvatar: p.avatar,
      ),
    );
    if (result == null) return;
    final name = result['name']!;
    final avatar = result['avatar']!;
    final token = await _storage.getToken();
    final serverId = int.tryParse(p.id);
    if (token != null && serverId != null) {
      final res = await _api.updateProfile(token, serverId, name, avatar);
      if (res['ok'] != true) {
        _snack('${res['error'] ?? "Gagal memperbarui profil"}');
      }
    }
    // Perbarui salinan lokal apa pun hasilnya.
    p.name = name;
    p.avatar = avatar;
    await _storage.upsertProfile(p);
    await _load();
  }

  Future<void> _deleteProfile(ChildProfile p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        content: Text('Hapus profil "${p.name}"? Semua progresnya akan hilang.',
            style: GoogleFonts.nunito(fontSize: 15)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: kError),
              child: const Text('Hapus')),
        ],
      ),
    );
    if (ok != true) return;
    final token = await _storage.getToken();
    final serverId = int.tryParse(p.id);
    if (token != null && serverId != null) {
      final res = await _api.deleteProfile(token, serverId);
      if (res['ok'] != true) {
        _snack('${res['error'] ?? "Gagal menghapus profil"}');
        return; // jangan hapus lokal bila server gagal (agar tetap konsisten)
      }
    }
    await _storage.removeProfile(p.id);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: kDark,
        title: Text('Siapa yang mau belajar?',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 4, bottom: 8),
                  child: UkuMascot(
                      size: 76, greeting: 'Pilih atau buat profilmu ya!'),
                ),
                Expanded(
                  child: GridView.count(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      ..._profiles.map((p) => _ProfileTile(
                          profile: p,
                          onTap: () => _pick(p),
                          onMenu: () => _profileMenu(p))),
                      if (_profiles.length < 5) _AddTile(onTap: _addProfile),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final ChildProfile profile;
  final VoidCallback onTap;
  final VoidCallback onMenu;
  const _ProfileTile(
      {required this.profile, required this.onTap, required this.onMenu});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onMenu,
      child: Container(
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(profile.avatar, style: const TextStyle(fontSize: 56)),
                  const SizedBox(height: 8),
                  Text(profile.name,
                      style: GoogleFonts.nunito(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: kDark)),
                  Text('⭐ ${profile.totalStars()}',
                      style: GoogleFonts.nunito(fontSize: 13, color: kAccent)),
                ],
              ),
            ),
            // Tombol menu (edit/hapus) di pojok.
            Positioned(
              top: 2,
              right: 2,
              child: IconButton(
                icon: const Icon(Icons.more_vert_rounded, color: kMuted),
                onPressed: onMenu,
                tooltip: 'Edit / Hapus',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddTile extends StatelessWidget {
  final VoidCallback onTap;
  const _AddTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: DottedBorderBox(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_circle_outline_rounded, size: 48, color: kMuted),
            const SizedBox(height: 8),
            Text('Tambah',
                style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w800, color: kMuted)),
          ],
        ),
      ),
    );
  }
}

class DottedBorderBox extends StatelessWidget {
  final Widget child;
  const DottedBorderBox({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kSurface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: kMuted.withOpacity(0.4), width: 2),
      ),
      child: child,
    );
  }
}

class _AddProfileDialog extends StatefulWidget {
  final List<String> avatars;
  final String title;
  final String? initialName;
  final String? initialAvatar;
  const _AddProfileDialog({
    required this.avatars,
    this.title = 'Profil Anak Baru',
    this.initialName,
    this.initialAvatar,
  });

  @override
  State<_AddProfileDialog> createState() => _AddProfileDialogState();
}

class _AddProfileDialogState extends State<_AddProfileDialog> {
  late final _name = TextEditingController(text: widget.initialName ?? '');
  late String _avatar = widget.initialAvatar ?? widget.avatars.first;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title,
          style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _name,
            decoration: const InputDecoration(hintText: 'Nama anak'),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: widget.avatars.map((a) {
              final sel = a == _avatar;
              return GestureDetector(
                onTap: () => setState(() => _avatar = a),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: sel ? kPrimary.withOpacity(0.2) : null,
                    shape: BoxShape.circle,
                    border: sel ? Border.all(color: kPrimary, width: 2) : null,
                  ),
                  child: Text(a, style: const TextStyle(fontSize: 28)),
                ),
              );
            }).toList(),
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal')),
        ElevatedButton(
          onPressed: () {
            if (_name.text.trim().isEmpty) return;
            Navigator.pop(context,
                {'name': _name.text.trim(), 'avatar': _avatar});
          },
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}
