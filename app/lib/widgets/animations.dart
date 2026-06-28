import 'dart:math';
import 'package:flutter/material.dart';
import '../config.dart';

/// Animations run only when enabled AND the OS "reduce motion" setting is off.
bool animationsOn(BuildContext context) =>
    kAnimationsEnabled && !MediaQuery.of(context).disableAnimations;

// ── 1 + 4 (celebration / landing): kente confetti burst overlay ─────────────
const _kKente = [
  Color(0xFFE3A92C),
  Color(0xFF9B2D2A),
  Color(0xFF2E6B3B),
  Color(0xFF2B2B2D),
  Color(0xFFE2725B),
];

/// Fires a short, self-removing confetti burst from the screen centre.
void celebrateBurst(BuildContext context, {int particles = 26}) {
  if (!animationsOn(context)) return;
  final overlay = Overlay.maybeOf(context);
  if (overlay == null) return;
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _ConfettiOverlay(
      count: particles,
      onDone: () => entry.remove(),
    ),
  );
  overlay.insert(entry);
}

class _ConfettiOverlay extends StatefulWidget {
  final int count;
  final VoidCallback onDone;
  const _ConfettiOverlay({required this.count, required this.onDone});

  @override
  State<_ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<_ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final List<_Particle> _ps;

  @override
  void initState() {
    super.initState();
    final r = Random();
    _ps = List.generate(widget.count, (_) {
      final angle = -pi / 2 + (r.nextDouble() - 0.5) * pi; // mostly upward
      final speed = 140 + r.nextDouble() * 220;
      return _Particle(
        vx: cos(angle) * speed,
        vy: sin(angle) * speed,
        color: _kKente[r.nextInt(_kKente.length)],
        size: 5 + r.nextDouble() * 7,
        rot: r.nextDouble() * pi,
        spin: (r.nextDouble() - 0.5) * 8,
      );
    });
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1100))
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) widget.onDone();
      })
      ..forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _c,
          builder: (_, __) =>
              CustomPaint(painter: _ConfettiPainter(_ps, _c.value)),
        ),
      ),
    );
  }
}

class _Particle {
  final double vx, vy, size, rot, spin;
  final Color color;
  _Particle({
    required this.vx,
    required this.vy,
    required this.color,
    required this.size,
    required this.rot,
    required this.spin,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_Particle> ps;
  final double t; // 0..1
  _ConfettiPainter(this.ps, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final origin = Offset(size.width / 2, size.height * 0.42);
    const gravity = 520.0;
    final opacity = (1.0 - t).clamp(0.0, 1.0);
    for (final p in ps) {
      final dx = p.vx * t;
      final dy = p.vy * t + 0.5 * gravity * t * t;
      final pos = origin + Offset(dx, dy);
      final paint = Paint()..color = p.color.withValues(alpha: opacity);
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(p.rot + p.spin * t);
      canvas.drawRect(
          Rect.fromCenter(
              center: Offset.zero, width: p.size, height: p.size * 0.55),
          paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) => old.t != t;
}

// ── 2 (breathing streak flame): gentle repeating scale on an emoji ──────────
class PulseEmoji extends StatefulWidget {
  final String emoji;
  final double size;
  const PulseEmoji(this.emoji, {super.key, this.size = 26});

  @override
  State<PulseEmoji> createState() => _PulseEmojiState();
}

class _PulseEmojiState extends State<PulseEmoji>
    with SingleTickerProviderStateMixin {
  AnimationController? _c;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !animationsOn(context)) return;
      setState(() {
        _c = AnimationController(
            vsync: this, duration: const Duration(milliseconds: 1100))
          ..repeat(reverse: true);
      });
    });
  }

  @override
  void dispose() {
    _c?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = Text(widget.emoji, style: TextStyle(fontSize: widget.size));
    if (_c == null) return text;
    return ScaleTransition(
      scale: Tween(begin: 0.9, end: 1.12)
          .animate(CurvedAnimation(parent: _c!, curve: Curves.easeInOut)),
      child: text,
    );
  }
}

// ── 5 (word / glyph reveal): one-shot fade + slide-up entrance ──────────────
class Reveal extends StatefulWidget {
  final Widget child;
  final Duration delay;
  const Reveal({super.key, required this.child, this.delay = Duration.zero});

  @override
  State<Reveal> createState() => _RevealState();
}

class _RevealState extends State<Reveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 420));

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!animationsOn(context)) {
        _c.value = 1;
        return;
      }
      Future.delayed(widget.delay, () {
        if (mounted) _c.forward();
      });
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween(begin: const Offset(0, 0.12), end: Offset.zero)
            .animate(curved),
        child: widget.child,
      ),
    );
  }
}

// ── 3 + 4 (living / hopping avatar): scale-in landing + gentle idle bob ─────
class AvatarBob extends StatefulWidget {
  final Widget child;
  const AvatarBob({super.key, required this.child});

  @override
  State<AvatarBob> createState() => _AvatarBobState();
}

class _AvatarBobState extends State<AvatarBob>
    with TickerProviderStateMixin {
  late final AnimationController _in =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 480));
  AnimationController? _bob;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!animationsOn(context)) {
        _in.value = 1;
        return;
      }
      _in.forward();
      _bob = AnimationController(
          vsync: this, duration: const Duration(milliseconds: 1600))
        ..repeat(reverse: true);
      setState(() {});
    });
  }

  @override
  void dispose() {
    _in.dispose();
    _bob?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget c = ScaleTransition(
      scale: Tween(begin: 0.4, end: 1.0)
          .animate(CurvedAnimation(parent: _in, curve: Curves.elasticOut)),
      child: widget.child,
    );
    final bob = _bob;
    if (bob != null) {
      c = AnimatedBuilder(
        animation: bob,
        builder: (_, child) => Transform.translate(
          offset: Offset(0, -3 * sin(bob.value * pi)),
          child: child,
        ),
        child: c,
      );
    }
    return c;
  }
}
