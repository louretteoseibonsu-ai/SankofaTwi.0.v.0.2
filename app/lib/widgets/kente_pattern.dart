import 'package:flutter/material.dart';

/// Original Kente header band — "warp stripes & hatch" (Version 2):
/// a gold field woven with fine horizontal black weave-lines and narrow
/// maroon/green warp bars. Used as the app-wide header strip.
class KenteStrip extends StatelessWidget {
  final double height;
  const KenteStrip({super.key, this.height = 16});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(painter: _KentePainter()),
    );
  }
}

/// Fills its parent with the Kente weave — used as an AppBar `flexibleSpace`
/// so the header band spans the full top area and the avatar rests in front.
class KenteHeaderBackground extends StatelessWidget {
  const KenteHeaderBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _KentePainter(), size: Size.infinite);
  }
}

class _KentePainter extends CustomPainter {
  static const _gold = Color(0xFFE3A92C);
  static const _red = Color(0xFF9B2D2A);
  static const _green = Color(0xFF2E6B3B);
  static const _black = Color(0xFF1A1A1A);

  @override
  void paint(Canvas canvas, Size size) {
    final h = size.height;
    const cell = 40.0;

    canvas.drawRect(Offset.zero & size, Paint()..color = _gold);

    final sep = Paint()
      ..color = _black
      ..strokeWidth = 1.5;
    for (double x = 0; x < size.width; x += cell) {
      canvas.drawRect(Rect.fromLTWH(x + 8, 0, 7, h), Paint()..color = _red);
      canvas.drawRect(Rect.fromLTWH(x + 25, 0, 7, h), Paint()..color = _green);
      canvas.drawLine(Offset(x, 0), Offset(x, h), sep);
      canvas.drawLine(Offset(x + cell / 2, 0), Offset(x + cell / 2, h), sep);
    }

    final hatch = Paint()
      ..color = _black
      ..strokeWidth = 1;
    for (final f in const [0.18, 0.40, 0.62, 0.84]) {
      final y = h * f;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), hatch);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
