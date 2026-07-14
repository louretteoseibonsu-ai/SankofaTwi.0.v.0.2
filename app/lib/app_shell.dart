import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme.dart';
import 'widgets/app_avatar.dart';
import 'widgets/kente_pattern.dart';
import 'screens/profile_screen.dart';
import 'screens/progress_dashboard_screen.dart';
import 'screens/symbols_screen.dart';
import 'screens/lessons_screen.dart';
import 'screens/quiz_screen.dart';
import 'screens/tools_hub_screen.dart';

class _Dest {
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  const _Dest(this.label, this.icon, this.selectedIcon);
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0; // land on Learn — the core daily loop

  static const _dest = [
    _Dest('Learn', Icons.menu_book_outlined, Icons.menu_book),
    _Dest('Practice', Icons.quiz_outlined, Icons.quiz),
    _Dest('Symbols', Icons.auto_awesome_outlined, Icons.auto_awesome),
    _Dest('Tools', Icons.apps_outlined, Icons.apps),
    _Dest('Progress', Icons.insights_outlined, Icons.insights),
  ];

  static const _screens = [
    LessonsScreen(),
    QuizScreen(),
    SymbolsScreen(),
    ToolsHubScreen(),
    ProgressDashboardScreen(),
  ];

  void _select(int i) {
    HapticFeedback.selectionClick();
    setState(() => _index = i);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 16,
        flexibleSpace: const KenteHeaderBackground(),
        title: Text(
          _dest[_index].label,
          style: const TextStyle(
              fontWeight: FontWeight.w800, fontSize: 20, color: charcoal),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: StreamBuilder<User?>(
              stream: FirebaseAuth.instance.userChanges(),
              builder: (context, snapshot) {
                return GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                        builder: (_) => const ProfileScreen()),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(2.5),
                    decoration: const BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle),
                    child: AppAvatar(
                        user: FirebaseAuth.instance.currentUser, radius: 16),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: IndexedStack(index: _index, children: _screens),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _select,
        destinations: [
          for (final d in _dest)
            NavigationDestination(
              icon: Icon(d.icon),
              selectedIcon: Icon(d.selectedIcon),
              label: d.label,
            ),
        ],
      ),
    );
  }
}
