import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/sound_service.dart';

/// Forward CTA. Label is hard-coded to "Continue"; fires a soft tactile pulse
/// plus a subtle tap sound.
class ContinueButton extends StatelessWidget {
  final VoidCallback onPressed;
  const ContinueButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: () {
          HapticFeedback.lightImpact(); // premium, tactile (not a "toy" beep)
          SoundService.instance.tap();
          onPressed();
        },
        child: const Text('Continue'),
      ),
    );
  }
}
