import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'auth_gate.dart';
import 'services/currency_service.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // On Android, Firebase reads android/app/google-services.json via the
  // google-services Gradle plugin — no generated firebase_options.dart needed.
  await Firebase.initializeApp();
  // Localise displayed prices from the user's region (non-blocking).
  CurrencyService.instance.ensureLoaded();
  runApp(const SankofaTwiApp());
}

class SankofaTwiApp extends StatelessWidget {
  const SankofaTwiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sankofa Twi',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: const AuthGate(),
    );
  }
}
