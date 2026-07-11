import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/profile.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../utils/app_colors.dart';
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
          : GridView.count(
              padding: const EdgeInsets.all(20),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                ..._profiles.map((p) => _ProfileTile(profile: p, onTap: () => _pick(p))),
                if (_profiles.length < 5)
                  _AddTile(onTap: _addProfile),
              ],
            ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final ChildProfile profile;
  final VoidCallback onTap;
  const _ProfileTile({required this.profile, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(profile.avatar, style: const TextStyle(fontSize: 56)),
            const SizedBox(height: 8),
            Text(profile.name,
                style: GoogleFonts.nunito(
                    fontSize: 18, fontWeight: FontWeight.w800, color: kDark)),
            Text('⭐ ${profile.totalStars()}',
                style: GoogleFonts.nunito(fontSize: 13, color: kAccent)),
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
  const _AddProfileDialog({required this.avatars});

  @override
  State<_AddProfileDialog> createState() => _AddProfileDialogState();
}

class _AddProfileDialogState extends State<_AddProfileDialog> {
  final _name = TextEditingController();
  late String _avatar = widget.avatars.first;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Profil Anak Baru',
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
