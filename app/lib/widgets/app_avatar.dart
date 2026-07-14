import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../data/adinkra_symbols.dart';
import '../data/special_avatars.dart';
import '../theme.dart';

/// Renders a user's avatar from their Firebase profile:
///  - `adinkra://<glyphId>/<HEX>` token  → Adinkra glyph on an accent color
///  - an http(s) photoURL                → the uploaded photo
///  - otherwise                          → initials on slate
class AppAvatar extends StatelessWidget {
  final User? user;
  final double radius;
  const AppAvatar({super.key, required this.user, this.radius = 16});

  static const String adinkraScheme = 'adinkra://';

  @override
  Widget build(BuildContext context) {
    final photo = user?.photoURL;

    if (photo != null && photo.startsWith(adinkraScheme)) {
      final parts = photo.substring(adinkraScheme.length).split('/');
      final glyphId = parts.isNotEmpty ? parts[0] : 'gyenyame';
      final hex = parts.length > 1 ? parts[1] : '2B2B2D';
      final bg = _parseHex(hex);
      final svg = glyphId == kAnanseGlyphId
          ? kAnanseSvg
          : kAdinkraSymbols
              .firstWhere((s) => s.id == glyphId,
                  orElse: () => kAdinkraSymbols.first)
              .svg;
      return CircleAvatar(
        radius: radius,
        backgroundColor: bg,
        child: SizedBox(
          width: radius * 1.2,
          height: radius * 1.2,
          child: SvgPicture.string(
            svg,
            fit: BoxFit.contain,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
        ),
      );
    }

    if (photo != null && photo.startsWith('http')) {
      return CircleAvatar(radius: radius, backgroundImage: NetworkImage(photo));
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: slate,
      child: Text(
        _initial(user),
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: radius * 0.85,
        ),
      ),
    );
  }

  static Color _parseHex(String hex) {
    final clean = hex.replaceAll('#', '');
    final value = int.tryParse('FF$clean', radix: 16) ?? 0xFF5A5E63;
    return Color(value);
  }

  static String _initial(User? u) {
    final name = u?.displayName;
    if (name != null && name.trim().isNotEmpty) return name.trim()[0].toUpperCase();
    final email = u?.email;
    if (email != null && email.isNotEmpty) return email[0].toUpperCase();
    return 'S';
  }
}
