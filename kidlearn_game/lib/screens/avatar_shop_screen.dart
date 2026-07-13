import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/profile.dart';
import '../models/avatars.dart';
import '../widgets/avatar_view.dart';
import '../services/sfx_service.dart';
import '../services/storage_service.dart';
import '../utils/app_colors.dart';

/// Toko avatar — beli dengan koin, lalu pakai.
class AvatarShopScreen extends StatefulWidget {
  const AvatarShopScreen({super.key});

  @override
  State<AvatarShopScreen> createState() => _AvatarShopScreenState();
}

class _AvatarShopScreenState extends State<AvatarShopScreen> {
  final _storage = StorageService();
  ChildProfile? _profile;

  /// Katalog avatar berjenjang (lihat models/avatars.dart).
  static const Map<String, int> catalog = Avatars.catalog;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await _storage.currentProfile() ??
        await _storage.ensureLocalProfile();
    if (mounted) setState(() => _profile = p);
  }

  Future<void> _tap(String emoji, int price) async {
    final p = _profile;
    if (p == null) return;
    // Avatar gratis atau sudah dimiliki → langsung pakai.
    if (price == 0 || p.ownsAvatar(emoji)) {
      if (!p.ownsAvatar(emoji)) p.ownedAvatars.add(emoji);
      p.avatar = emoji;
      await _storage.upsertProfile(p);
      SfxService.instance.tap(); // umpan balik saat memakai (konsisten dgn beli)
      setState(() {});
      _storage.syncProfile(p);
      return;
    }
    // Beli.
    if (p.coins < price) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Koin belum cukup — butuh $price 🪙')));
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        content: Text('Beli $emoji seharga $price 🪙?',
            style: GoogleFonts.nunito(fontSize: 16)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Beli')),
        ],
      ),
    );
    if (ok == true && p.buyAvatar(emoji, price)) {
      p.avatar = emoji; // langsung pakai
      await _storage.upsertProfile(p);
      SfxService.instance.coin();
      setState(() {});
      _storage.syncProfile(p); // simpan koin/avatar ke server
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = _profile;
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: kDark,
        title: Text('Toko Avatar',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text('🪙 ${p?.coins ?? 0}',
                  style: GoogleFonts.nunito(
                      fontWeight: FontWeight.w800, color: kAccent, fontSize: 16)),
            ),
          ),
        ],
      ),
      body: p == null
          ? const Center(child: CircularProgressIndicator())
          : GridView.count(
              padding: const EdgeInsets.all(16),
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: catalog.entries.map((e) {
                final owned = p.ownsAvatar(e.key);
                final equipped = p.avatar == e.key;
                // Terkunci = berbayar, belum dimiliki, koin belum cukup.
                final locked = e.value > 0 && !owned && p.coins < e.value;
                return _AvatarTile(
                  emoji: e.key,
                  price: e.value,
                  owned: owned,
                  equipped: equipped,
                  locked: locked,
                  onTap: () => _tap(e.key, e.value),
                );
              }).toList(),
            ),
    );
  }
}

class _AvatarTile extends StatelessWidget {
  final String emoji;
  final int price;
  final bool owned;
  final bool equipped;
  final bool locked;
  final VoidCallback onTap;

  const _AvatarTile({
    required this.emoji,
    required this.price,
    required this.owned,
    required this.equipped,
    required this.locked,
    required this.onTap,
  });

  static const _goldColor   = Color(0xFFD4AF37);
  static const _dewaColor   = Color(0xFFFF8C00);

  @override
  Widget build(BuildContext context) {
    final tier = Avatars.tierLabel(emoji);
    final isDewa = Avatars.isDewa(emoji);
    final isLegenda = Avatars.isLegenda(emoji);

    Color borderColor = Colors.transparent;
    double borderWidth = 3;
    if (equipped) {
      borderColor = kPrimary;
    } else if (isDewa) {
      borderColor = _dewaColor;
      borderWidth = 2.5;
    } else if (isLegenda) {
      borderColor = _goldColor;
      borderWidth = 2.5;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor, width: borderWidth),
          boxShadow: [
            BoxShadow(
                color: (isDewa ? _dewaColor : isLegenda ? _goldColor : Colors.black)
                    .withOpacity(isDewa || isLegenda ? 0.18 : 0.05),
                blurRadius: 8,
                offset: const Offset(0, 3))
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Terkunci → redup + gembok kecil agar jelas belum bisa dipakai.
            Stack(
              alignment: Alignment.center,
              children: [
                Opacity(
                  opacity: locked ? 0.35 : 1,
                  child: AvatarView(emoji, size: 44),
                ),
                if (locked)
                  const Icon(Icons.lock_rounded, size: 20, color: kMuted),
              ],
            ),
            if (tier != null)
              Text(
                tier == 'Sultan' ? '👑 Sultan' : tier == 'Legenda' ? '⭐ Legenda' : '✨ Bergerak',
                style: GoogleFonts.nunito(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: isDewa ? _dewaColor : isLegenda ? _goldColor : kPrimary),
              ),
            const SizedBox(height: 6),
            if (equipped)
              Text('Dipakai',
                  style: GoogleFonts.nunito(
                      fontSize: 12, fontWeight: FontWeight.w800, color: kPrimary))
            else if (price == 0)
              Text('Gratis',
                  style: GoogleFonts.nunito(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: kAgama)) // hijau tua = kontras cukup
            else if (owned)
              Text('Pakai',
                  style: GoogleFonts.nunito(
                      fontSize: 12, fontWeight: FontWeight.w800, color: kPrimary))
            else
              Text('🪙 $price',
                  style: GoogleFonts.nunito(
                      fontSize: 12, fontWeight: FontWeight.w800, color: kDark)),
          ],
        ),
      ),
    );
  }
}
