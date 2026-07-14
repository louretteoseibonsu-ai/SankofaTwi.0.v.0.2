import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/sound_service.dart';
import '../theme.dart';
import 'animations.dart';
import 'app_avatar.dart';
import 'greeting.dart';

/// A personalised "Ayɛkoo, {name}!" celebration for a milestone (level-up,
/// boss defeat, 3-star mastery). Confetti + sound + haptic + the user's avatar.
/// Auto-dismisses after a few seconds.
Future<void> celebrateMilestone(
  BuildContext context, {
  required String headline,
  required String subline,
}) async {
  SoundService.instance.complete();
  HapticFeedback.heavyImpact();
  celebrateBurst(context);
  final name = firstNameOf(FirebaseAuth.instance.currentUser);

  await showDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black26,
    builder: (ctx) {
      // Auto-dismiss so it never blocks the flow.
      Future.delayed(const Duration(milliseconds: 2800), () {
        if (Navigator.of(ctx).canPop()) Navigator.of(ctx).pop();
      });
      return Dialog(
        backgroundColor: Colors.white,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Color(0x22000000), blurRadius: 12)
                  ],
                ),
                child: AppAvatar(
                    user: FirebaseAuth.instance.currentUser, radius: 34),
              ),
              const SizedBox(height: 16),
              Text(headline,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 22, color: ink)),
              const SizedBox(height: 4),
              Text('Ayɛkoo, $name!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: terracottaDeep)),
              const SizedBox(height: 6),
              Text(subline,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: slate, fontSize: 14)),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Medaase 🎉'),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
