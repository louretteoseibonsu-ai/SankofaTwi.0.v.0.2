import 'package:flutter/material.dart';

/// Forward CTA. The label is hard-coded to "Continue" and cannot be overridden.
class ContinueButton extends StatelessWidget {
  final VoidCallback onPressed;
  const ContinueButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: onPressed,
        child: const Text('Continue'),
      ),
    );
  }
}
