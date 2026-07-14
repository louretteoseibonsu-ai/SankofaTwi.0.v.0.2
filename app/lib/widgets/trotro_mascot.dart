import 'package:flutter/material.dart';

/// The three journey states of the Sankofa tro tro mascot.
enum TroTroState { idle, drive, arrive }

extension _Asset on TroTroState {
  String get asset {
    switch (this) {
      case TroTroState.idle:
        return 'assets/mascot/trotro_idle.png';
      case TroTroState.drive:
        return 'assets/mascot/trotro_drive.png';
      case TroTroState.arrive:
        return 'assets/mascot/trotro_arrive.png';
    }
  }
}

/// The tro tro that carries the learner along the journey path.
///
/// Pass a [state] and it cross-fades to the matching frame. When idle it does a
/// gentle idle-bob so a parked bus still feels alive; the bob stops while
/// driving (motion comes from movement on the path instead).
///
/// Frames are 380:250 (w:h). Give it a [width]; height follows automatically.
class TroTroMascot extends StatefulWidget {
  final TroTroState state;
  final double width;

  /// Set false to disable the idle bob (e.g. for a static preview).
  final bool animate;

  const TroTroMascot({
    super.key,
    this.state = TroTroState.idle,
    this.width = 120,
    this.animate = true,
  });

  @override
  State<TroTroMascot> createState() => _TroTroMascotState();
}

class _TroTroMascotState extends State<TroTroMascot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bob = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _bob.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final img = AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      child: Image.asset(
        widget.state.asset,
        key: ValueKey(widget.state),
        width: widget.width,
        height: widget.width * 250 / 380,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
        // Visible fallback if the asset isn't bundled yet (needs a full
        // rebuild after adding assets/mascot/ — hot reload won't pick it up).
        errorBuilder: (context, error, stack) => Container(
          width: widget.width,
          height: widget.width * 250 / 380,
          decoration: BoxDecoration(
            color: const Color(0xFFBE5235),
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.directions_bus_rounded,
              color: Colors.white, size: 34),
        ),
      ),
    );

    // No bob while driving — the road movement carries the energy.
    if (!widget.animate || widget.state == TroTroState.drive) return img;

    return AnimatedBuilder(
      animation: _bob,
      builder: (_, child) => Transform.translate(
        offset: Offset(0, -2.5 * _bob.value),
        child: child,
      ),
      child: img,
    );
  }
}
