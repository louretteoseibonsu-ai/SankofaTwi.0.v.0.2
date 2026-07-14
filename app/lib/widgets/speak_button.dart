import 'package:flutter/material.dart';
import '../services/twi_speech.dart';
import '../theme.dart';

/// Taps to speak Twi text aloud (bundled clip → cache → live TTS). Reusable
/// across lessons, reading passages, etc.
class SpeakButton extends StatefulWidget {
  final String text;
  final double size;
  const SpeakButton({super.key, required this.text, this.size = 20});

  @override
  State<SpeakButton> createState() => _SpeakButtonState();
}

class _SpeakButtonState extends State<SpeakButton> {
  bool _busy = false;

  Future<void> _go() async {
    setState(() => _busy = true);
    final ok = await TwiSpeech.instance.speak(widget.text);
    if (!mounted) return;
    setState(() => _busy = false);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Could not load Twi audio — the server may be waking up. Try again.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: InkResponse(
        onTap: _busy ? null : _go,
        radius: 26,
        child: Center(
          child: _busy
              ? SizedBox(
                  width: widget.size,
                  height: widget.size,
                  child: const CircularProgressIndicator(strokeWidth: 2))
              : Icon(Icons.volume_up_rounded,
                  size: widget.size, color: terracotta),
        ),
      ),
    );
  }
}
