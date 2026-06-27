import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'app_shell.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';

/// Shows the login screen when signed out, the app when signed in.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().authState,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.data == null) return const LoginScreen();
        return const AppShell();
      },
    );
  }
}
