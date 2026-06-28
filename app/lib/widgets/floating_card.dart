import 'package:flutter/material.dart';
import '../theme.dart';

/// Apple-style squircle card with a soft, neutral drop shadow and roomy padding.
class FloatingCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  const FloatingCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(18),
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const ShapeDecoration(
        color: surfaceCard,
        shape: kSquircleCard,
        shadows: kSoftShadow,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          customBorder: kSquircleCard,
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
