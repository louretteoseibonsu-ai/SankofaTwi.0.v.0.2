import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import '../data/adinkra_symbols.dart';
import '../services/auth_service.dart';
import '../theme.dart';
import '../widgets/floating_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

enum _AvatarMode { adinkra, photo }

class _ProfileScreenState extends State<ProfileScreen> {
  final _auth = AuthService();
  late final TextEditingController _name;

  // accent colors offered for Adinkra avatars
  static const _colors = ['E2725B', '2B2B2D', '5A5E63', 'E3A92C', '9B2D2A', '2E6B3B'];

  _AvatarMode _mode = _AvatarMode.adinkra;
  String _glyph = 'gyenyame';
  String _hex = 'E2725B';
  String? _existingPhoto;
  File? _picked;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final u = FirebaseAuth.instance.currentUser;
    _name = TextEditingController(
        text: u?.displayName ?? (u?.email?.split('@').first ?? ''));
    final p = u?.photoURL;
    if (p != null && p.startsWith('adinkra://')) {
      final parts = p.substring('adinkra://'.length).split('/');
      _glyph = parts.isNotEmpty ? parts[0] : 'gyenyame';
      _hex = parts.length > 1 ? parts[1] : '2B2B2D';
      _mode = _AvatarMode.adinkra;
    } else if (p != null && p.startsWith('http')) {
      _existingPhoto = p;
      _mode = _AvatarMode.photo;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Color get _color {
    final v = int.tryParse('FF$_hex', radix: 16) ?? 0xFF5A5E63;
    return Color(v);
  }

  Future<void> _pick(ImageSource src) async {
    final x = await ImagePicker()
        .pickImage(source: src, maxWidth: 800, imageQuality: 85);
    if (x != null) {
      setState(() {
        _picked = File(x.path);
        _mode = _AvatarMode.photo;
      });
    }
  }

  Future<void> _save() async {
    setState(() => _loading = true);
    try {
      if (_name.text.trim().isNotEmpty) {
        await _auth.updateDisplayName(_name.text);
      }
      if (_mode == _AvatarMode.photo && _picked != null) {
        await _auth.uploadPhotoAvatar(_picked!);
      } else if (_mode == _AvatarMode.adinkra) {
        await _auth.setAdinkraAvatar(_glyph, _hex);
      }
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Profile saved')));
        Navigator.of(context).pop();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Could not save. Photo uploads need Firebase Storage enabled.'),
        ));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _preview() {
    if (_mode == _AvatarMode.photo && _picked != null) {
      return CircleAvatar(radius: 48, backgroundImage: FileImage(_picked!));
    }
    if (_mode == _AvatarMode.photo && _existingPhoto != null) {
      return CircleAvatar(radius: 48, backgroundImage: NetworkImage(_existingPhoto!));
    }
    final sym = kAdinkraSymbols.firstWhere((s) => s.id == _glyph,
        orElse: () => kAdinkraSymbols.first);
    return CircleAvatar(
      radius: 48,
      backgroundColor: _color,
      child: SizedBox(
        width: 60,
        height: 60,
        child: SvgPicture.string(sym.svg,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(child: _preview()),
          const SizedBox(height: 20),
          const Text('Display name',
              style: TextStyle(
                  color: slate, fontWeight: FontWeight.w700, fontSize: 12)),
          const SizedBox(height: 6),
          TextField(
            controller: _name,
            decoration: const InputDecoration(hintText: 'Your name'),
          ),
          const SizedBox(height: 22),
          const Text('Pick an Adinkra avatar',
              style: TextStyle(
                  color: slate, fontWeight: FontWeight.w700, fontSize: 12)),
          const SizedBox(height: 10),
          SizedBox(
            height: 60,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: kAdinkraSymbols.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) {
                final s = kAdinkraSymbols[i];
                final selected = _mode == _AvatarMode.adinkra && s.id == _glyph;
                return GestureDetector(
                  onTap: () => setState(() {
                    _glyph = s.id;
                    _mode = _AvatarMode.adinkra;
                  }),
                  child: Container(
                    width: 60,
                    height: 60,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: glyphTile,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: selected ? terracotta : Colors.transparent,
                        width: 2.5,
                      ),
                    ),
                    child: SvgPicture.string(s.svg, fit: BoxFit.contain),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 18),
          const Text('Accent color',
              style: TextStyle(
                  color: slate, fontWeight: FontWeight.w700, fontSize: 12)),
          const SizedBox(height: 10),
          Row(
            children: _colors.map((h) {
              final v = int.tryParse('FF$h', radix: 16) ?? 0xFF5A5E63;
              final selected = _mode == _AvatarMode.adinkra && h == _hex;
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () => setState(() {
                    _hex = h;
                    _mode = _AvatarMode.adinkra;
                  }),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Color(v),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected ? charcoal : Colors.transparent,
                        width: 2.5,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 22),
          const Text('…or use a photo',
              style: TextStyle(
                  color: slate, fontWeight: FontWeight.w700, fontSize: 12)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pick(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_outlined, size: 18),
                  label: const Text('Gallery'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pick(ImageSource.camera),
                  icon: const Icon(Icons.photo_camera_outlined, size: 18),
                  label: const Text('Camera'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          FilledButton(
            onPressed: _loading ? null : _save,
            child: _loading
                ? const SizedBox(
                    width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Save profile'),
          ),
          const SizedBox(height: 12),
          FloatingCard(
            onTap: () async {
              await _auth.signOut();
              if (mounted) Navigator.of(context).pop();
            },
            child: const Row(
              children: [
                Icon(Icons.logout, size: 18, color: charcoal),
                SizedBox(width: 10),
                Text('Sign out', style: TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
