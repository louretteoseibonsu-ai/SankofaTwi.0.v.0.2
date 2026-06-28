import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme.dart';
import 'widgets/app_avatar.dart';
import 'widgets/kente_pattern.dart';
import 'screens/profile_screen.dart';
import 'screens/journey_screen.dart';
import 'screens/progress_dashboard_screen.dart';
import 'screens/symbols_screen.dart';
import 'screens/lessons_screen.dart';
import 'screens/translate_screen.dart';
import 'screens/day_name_screen.dart';
import 'screens/quiz_screen.dart';
import 'screens/leaderboard_screen.dart';

class _Dest {
  final String label;
  final IconData icon;
  const _Dest(this.label, this.icon);
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 2; // land on Symbols (home); Progress/Journey are in the menu

  static const _dest = [
    _Dest('Progress', Icons.insights_outlined),
    _Dest('Journey', Icons.route_outlined),
    _Dest('Symbols', Icons.auto_awesome_outlined),
    _Dest('Lessons', Icons.menu_book_outlined),
    _Dest('Translate', Icons.translate_outlined),
    _Dest('Day Name', Icons.calendar_today_outlined),
    _Dest('Quiz', Icons.quiz_outlined),
    _Dest('Leaderboard', Icons.emoji_events_outlined),
  ];

  static const _screens = [
    ProgressDashboardScreen(),
    JourneyScreen(),
    SymbolsScreen(),
    LessonsScreen(),
    TranslateScreen(),
    DayNameScreen(),
    QuizScreen(),
    LeaderboardView(),
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
        title: _NavDropdown(
          current: _index,
          destinations: _dest,
          onSelected: _select,
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
    );
  }
}

class _NavDropdown extends StatelessWidget {
  final int current;
  final List<_Dest> destinations;
  final ValueChanged<int> onSelected;
  const _NavDropdown({
    required this.current,
    required this.destinations,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: PopupMenuButton<int>(
        initialValue: current,
        onSelected: onSelected,
        offset: const Offset(0, 52),
        color: Colors.white,
        elevation: 6,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        itemBuilder: (_) => [
          for (int i = 0; i < destinations.length; i++)
            PopupMenuItem<int>(
              value: i,
              child: Row(
                children: [
                  Icon(destinations[i].icon,
                      size: 20, color: i == current ? terracotta : charcoal),
                  const SizedBox(width: 12),
                  Text(destinations[i].label,
                      style: TextStyle(
                          fontWeight: i == current
                              ? FontWeight.w800
                              : FontWeight.w600,
                          color: i == current ? terracotta : charcoal)),
                  if (i == current) ...[
                    const Spacer(),
                    const Icon(Icons.check, size: 18, color: terracotta),
                  ],
                ],
              ),
            ),
        ],
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 8,
                  offset: Offset(0, 2)),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.menu, size: 20, color: charcoal),
              SizedBox(width: 8),
              Text('Menu',
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: charcoal)),
              SizedBox(width: 4),
              Icon(Icons.keyboard_arrow_down, size: 20, color: slate),
            ],
          ),
        ),
      ),
    );
  }
}
