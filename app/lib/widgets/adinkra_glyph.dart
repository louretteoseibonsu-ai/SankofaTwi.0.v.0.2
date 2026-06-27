import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Renders an Adinkra symbol from its raw SVG string (colors baked in).
class AdinkraGlyph extends StatelessWidget {
  final String svg;
  final double size;
  const AdinkraGlyph({super.key, required this.svg, this.size = 48});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: SvgPicture.string(svg, fit: BoxFit.contain),
    );
  }
}
