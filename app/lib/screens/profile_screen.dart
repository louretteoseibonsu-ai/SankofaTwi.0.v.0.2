import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import '../config.dart';
import '../data/adinkra_symbols.dart';
import '../data/special_avatars.dart';
import '../services/auth_service.dart';
import '../theme.dart';
import '../widgets/floating_card.dart';
import 'legal_screen.dart';
import 'upgrade_screen.dart';

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

  // Inclusive gender options.
  static const _genderOptions = [
    'Woman',
    'Man',
    'Non-binary',
    'Genderfluid',
    'Agender',
    'Prefer to self-describe',
    'Prefer not to say',
  ];
  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  _AvatarMode _mode = _AvatarMode.adinkra;
  String _glyph = 'gyenyame';
  String _hex = 'E2725B';
  String? _existingPhoto;
  File? _picked;
  bool _loading = false;

  DateTime? _dob;
  String _gender = '';
  bool _premium = false;
  late final TextEditingController _selfDescribe;

  @override
  void initState() {
    super.initState();
    final u = FirebaseAuth.instance.currentUser;
    _name = TextEditingController(
        text: u?.displayName ?? (u?.email?.split('@').first ?? ''));
    _selfDescribe = TextEditingController();
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
    _loadExtended();
  }

  Future<void> _loadExtended() async {
    final p = await _auth.loadProfile();
    if (!mounted) return;
    setState(() {
      _premium = (p['premium'] as bool?) ?? false;
      final dobStr = p['dob'] as String?;
      if (dobStr != null) _dob = DateTime.tryParse(dobStr);
      final g = p['gender'] as String?;
      if (g != null && g.isNotEmpty) {
        if (_genderOptions.contains(g)) {
          _gender = g;
        } else {
          _gender = 'Prefer to self-describe';
          _selfDescribe.text = g;
        }
      }
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _selfDescribe.dispose();
    super.dispose();
  }

  String _formatDob(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'Select your date of birth',
    );
    if (picked != null) setState(() => _dob = picked);
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
      String? genderToSave;
      if (_gender == 'Prefer to self-describe') {
        final t = _selfDescribe.text.trim();
        genderToSave = t.isEmpty ? 'Prefer to self-describe' : t;
      } else if (_gender.isNotEmpty) {
        genderToSave = _gender;
      }
      final dobToSave = _dob == null
          ? null
          : '${_dob!.year.toString().padLeft(4, '0')}-'
              '${_dob!.month.toString().padLeft(2, '0')}-'
              '${_dob!.day.toString().padLeft(2, '0')}';
      if (genderToSave != null || dobToSave != null) {
        await _auth.saveProfile(dob: dobToSave, gender: genderToSave);
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

  Future<void> _cancelSubscription() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cancel subscription?'),
        content: const Text(
            'Subscriptions are managed by your app store. To cancel, open '
            'Play Store → Subscriptions (Android), or App Store → your name → '
            'Subscriptions (iPhone). Your Premium access stays active until the '
            'end of the paid period.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Keep Premium')),
          FilledButton(
              style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF9B2D2A)),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Cancel now')),
        ],
      ),
    );
    if (confirm == true) {
      await _auth.setPremium(false); // placeholder until real billing
      if (!mounted) return;
      setState(() => _premium = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Premium cancelled. (Real cancellations process through your app store.)')));
    }
  }

  void _openUpgrade() => Navigator.of(context)
      .push(MaterialPageRoute(builder: (_) => const UpgradeScreen()))
      .then((_) => _loadExtended());

  Widget _preview() {
    if (_mode == _AvatarMode.photo && _picked != null) {
      return CircleAvatar(radius: 48, backgroundImage: FileImage(_picked!));
    }
    if (_mode == _AvatarMode.photo && _existingPhoto != null) {
      return CircleAvatar(radius: 48, backgroundImage: NetworkImage(_existingPhoto!));
    }
    final svg = _glyph == kAnanseGlyphId
        ? kAnanseSvg
        : kAdinkraSymbols
            .firstWhere((s) => s.id == _glyph,
                orElse: () => kAdinkraSymbols.first)
            .svg;
    return CircleAvatar(
      radius: 48,
      backgroundColor: _color,
      child: SizedBox(
        width: 60,
        height: 60,
        child: SvgPicture.string(svg,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
      ),
    );
  }

  /// Premium gate + Anansesɛm reveal. Tapping "Subscribe" is a placeholder
  /// for real billing (wire `in_app_purchase` here before shipping).
  Future<void> _openAnanse() async {
    if (_premium) {
      setState(() {
        _glyph = kAnanseGlyphId;
        _mode = _AvatarMode.adinkra;
        _picked = null;
        _existingPhoto = null;
      });
      return;
    }
    final unlocked = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => const _AnanseSheet(),
    );
    if (unlocked == true && kBillingEnabled) {
      await _auth.setPremium(true);
      if (!mounted) return;
      setState(() {
        _premium = true;
        _glyph = kAnanseGlyphId;
        _hex = 'E2725B';
        _mode = _AvatarMode.adinkra;
        _picked = null;
        _existingPhoto = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Ananse unlocked — tap Save to keep him. Ayɛkoo!')));
    }
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
          const Text('Date of birth',
              style: TextStyle(
                  color: slate, fontWeight: FontWeight.w700, fontSize: 12)),
          const SizedBox(height: 6),
          InkWell(
            onTap: _pickDob,
            borderRadius: BorderRadius.circular(12),
            child: InputDecorator(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.cake_outlined),
                suffixIcon: Icon(Icons.calendar_today_outlined, size: 18),
              ),
              child: Text(
                _dob == null ? 'Select your date of birth' : _formatDob(_dob!),
                style: TextStyle(
                  fontSize: 16,
                  color: _dob == null ? Colors.black45 : charcoal,
                ),
              ),
            ),
          ),
          const SizedBox(height: 22),
          const Text('Gender',
              style: TextStyle(
                  color: slate, fontWeight: FontWeight.w700, fontSize: 12)),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: _gender.isEmpty ? null : _gender,
            isExpanded: true,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.wc_outlined),
            ),
            hint: const Text('Select gender'),
            items: _genderOptions
                .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                .toList(),
            onChanged: (v) => setState(() => _gender = v ?? ''),
          ),
          if (_gender == 'Prefer to self-describe') ...[
            const SizedBox(height: 10),
            TextField(
              controller: _selfDescribe,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'Describe your gender (optional)',
              ),
            ),
          ],
          const SizedBox(height: 22),
          const Text('Pick an Adinkra avatar',
              style: TextStyle(
                  color: slate, fontWeight: FontWeight.w700, fontSize: 12)),
          const SizedBox(height: 10),
          SizedBox(
            height: 64,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: kAdinkraSymbols.length + 1, // +1 for premium Ananse
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) {
                if (i == 0) {
                  final selected =
                      _mode == _AvatarMode.adinkra && _glyph == kAnanseGlyphId;
                  return GestureDetector(
                    onTap: _openAnanse,
                    child: Container(
                      width: 60,
                      height: 60,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2B2B2D),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: selected
                              ? terracotta
                              : const Color(0xFFE3A92C),
                          width: 2.5,
                        ),
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          SvgPicture.string(kAnanseSvg,
                              fit: BoxFit.contain,
                              colorFilter: const ColorFilter.mode(
                                  Color(0xFFE3A92C), BlendMode.srcIn)),
                          Positioned(
                            right: -8,
                            top: -8,
                            child: Icon(
                                _premium
                                    ? Icons.workspace_premium
                                    : Icons.lock,
                                size: 15,
                                color: const Color(0xFFE3A92C)),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                final s = kAdinkraSymbols[i - 1];
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
          const SizedBox(height: 22),

          // ── Subscription ──
          const Text('Subscription',
              style: TextStyle(
                  color: slate, fontWeight: FontWeight.w700, fontSize: 12)),
          const SizedBox(height: 8),
          if (_premium)
            FloatingCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Text('✦',
                          style: TextStyle(color: Color(0xFFE3A92C), fontSize: 18)),
                      SizedBox(width: 10),
                      Text('Premium active',
                          style: TextStyle(
                              fontWeight: FontWeight.w800, color: ink)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                            onPressed: _openUpgrade,
                            child: const Text('Change plan')),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _cancelSubscription,
                          style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF9B2D2A)),
                          child: const Text('Cancel'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          else
            FloatingCard(
              onTap: _openUpgrade,
              child: const Row(
                children: [
                  Text('✦',
                      style: TextStyle(color: Color(0xFFE3A92C), fontSize: 18)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Upgrade to Premium',
                            style: TextStyle(
                                fontWeight: FontWeight.w800, color: ink)),
                        Text('7-day free trial · change plans anytime',
                            style: TextStyle(color: slate, fontSize: 12)),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: Colors.black26),
                ],
              ),
            ),
          const SizedBox(height: 18),

          // ── Help & support ──
          const Text('Help & support',
              style: TextStyle(
                  color: slate, fontWeight: FontWeight.w700, fontSize: 12)),
          const SizedBox(height: 8),
          const FloatingCard(
            child: Row(
              children: [
                Icon(Icons.mail_outline, size: 20, color: charcoal),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Email us',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, color: ink)),
                      Text('sankofa@aparato.ai',
                          style: TextStyle(color: slate, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // ── Legal ──
          const Text('Legal',
              style: TextStyle(
                  color: slate, fontWeight: FontWeight.w700, fontSize: 12)),
          const SizedBox(height: 8),
          FloatingCard(
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const LegalScreen(
                    title: 'Privacy Policy', body: kPrivacyPolicy))),
            child: const Row(
              children: [
                Icon(Icons.privacy_tip_outlined, size: 20, color: charcoal),
                SizedBox(width: 12),
                Expanded(
                    child: Text('Privacy Policy',
                        style: TextStyle(fontWeight: FontWeight.w600))),
                Icon(Icons.chevron_right, color: Colors.black26),
              ],
            ),
          ),
          const SizedBox(height: 8),
          FloatingCard(
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const LegalScreen(
                    title: 'Terms & Conditions', body: kTermsAndConditions))),
            child: const Row(
              children: [
                Icon(Icons.description_outlined, size: 20, color: charcoal),
                SizedBox(width: 12),
                Expanded(
                    child: Text('Terms & Conditions',
                        style: TextStyle(fontWeight: FontWeight.w600))),
                Icon(Icons.chevron_right, color: Colors.black26),
              ],
            ),
          ),
          const SizedBox(height: 16),
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

/// The Anansesɛm reveal + premium gate. Pops `true` if the user subscribes.
class _AnanseSheet extends StatelessWidget {
  const _AnanseSheet();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 110,
                height: 110,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: charcoal,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: const Color(0xFFE3A92C), width: 3),
                ),
                child: SvgPicture.string(kAnanseSvg,
                    colorFilter: const ColorFilter.mode(
                        Color(0xFFE3A92C), BlendMode.srcIn)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.workspace_premium,
                    color: Color(0xFFE3A92C), size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('Premium treasure',
                      style: TextStyle(
                          color: slate,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          letterSpacing: 0.5)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(kAnanseTitle,
                style: TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 20, color: ink)),
            const SizedBox(height: 12),
            const Text(kAnanseBackstory,
                style: TextStyle(height: 1.55, color: ink, fontSize: 14.5)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: kBillingEnabled
                    ? () => Navigator.of(context).pop(true)
                    : null,
                icon: Icon(
                    kBillingEnabled ? Icons.lock_open : Icons.schedule,
                    size: 18),
                label: Text(kBillingEnabled
                    ? 'Subscribe to unlock Ananse'
                    : 'Subscriptions coming soon'),
              ),
            ),
            if (!kBillingEnabled) ...[
              const SizedBox(height: 8),
              const Center(
                child: Text('Paid plans launch soon — check back shortly.',
                    style: TextStyle(color: slate, fontSize: 12)),
              ),
            ],
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
