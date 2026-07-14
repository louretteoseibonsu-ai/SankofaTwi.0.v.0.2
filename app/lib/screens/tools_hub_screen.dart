import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/floating_card.dart';
import 'alphabet_screen.dart';
import 'courses_screen.dart';
import 'day_name_screen.dart';
import 'journey_screen.dart';
import 'reading_screen.dart';
import 'review_quiz_screen.dart';
import 'leaderboard_screen.dart';
import 'lens_screen.dart';
import 'translate_screen.dart';

/// "Tools" tab — a hub for the secondary destinations that don't belong in the
/// daily learn → practice loop. Each opens as its own page with a back button.
class ToolsHubScreen extends StatelessWidget {
  const ToolsHubScreen({super.key});

  /// Body-only screens (no Scaffold of their own) get wrapped so they have an
  /// app bar + back button when pushed.
  void _openWrapped(BuildContext c, String title, Widget body) {
    Navigator.of(c).push(MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: Text(title)),
        body: SafeArea(child: body),
      ),
    ));
  }

  void _openPage(BuildContext c, Widget page) {
    Navigator.of(c).push(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('Tools',
            style:
                TextStyle(fontWeight: FontWeight.w800, fontSize: 26, color: ink)),
        const SizedBox(height: 4),
        const Text('Translate, scan, and explore.',
            style: TextStyle(color: slate, fontSize: 13.5)),
        const SizedBox(height: 16),
        _ToolRow(
          icon: Icons.school_outlined,
          title: 'Courses',
          subtitle: 'Structured tracks from basics to conversation',
          onTap: () => _openWrapped(context, 'Courses', const CoursesScreen()),
        ),
        _ToolRow(
          icon: Icons.abc,
          title: 'Twi Alphabet',
          subtitle: 'Vowels, sounds & digraphs — tap to hear',
          onTap: () =>
              _openWrapped(context, 'Twi Alphabet', const AlphabetScreen()),
        ),
        _ToolRow(
          icon: Icons.menu_book_outlined,
          title: 'Reading & Comprehension',
          subtitle: 'Read a passage, then answer questions',
          onTap: () => _openWrapped(
              context, 'Reading', const ReadingListScreen()),
        ),
        _ToolRow(
          icon: Icons.quiz_outlined,
          title: 'Review Quizzes',
          subtitle: 'Mixed practice from a course',
          onTap: () => _openWrapped(
              context, 'Review', const ReviewPickerScreen()),
        ),
        _ToolRow(
          icon: Icons.translate,
          title: 'AI Translate',
          subtitle: 'English ⇆ Twi with native audio',
          onTap: () =>
              _openWrapped(context, 'AI Translate', const TranslateScreen()),
        ),
        _ToolRow(
          icon: Icons.center_focus_strong_outlined,
          title: 'Sankofa Lens',
          subtitle: 'Point, learn & speak it out loud',
          onTap: () => _openWrapped(context, 'Sankofa Lens', const LensScreen()),
        ),
        _ToolRow(
          icon: Icons.calendar_today_outlined,
          title: 'Day Name',
          subtitle: 'Your Akan soul name (kra din)',
          onTap: () => _openWrapped(context, 'Day Name', const DayNameScreen()),
        ),
        _ToolRow(
          icon: Icons.route_outlined,
          title: 'Journey',
          subtitle: 'Your learning path',
          onTap: () => _openWrapped(context, 'Journey', const JourneyScreen()),
        ),
        _ToolRow(
          icon: Icons.emoji_events_outlined,
          title: 'Leaderboard',
          subtitle: 'League rankings this week',
          onTap: () => _openPage(context, const LeaderboardScreen()),
        ),
      ],
    );
  }
}

class _ToolRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _ToolRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: FloatingCard(
        onTap: onTap,
        child: Row(
          children: [
            Icon(icon, color: charcoal, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: ink)),
                  Text(subtitle,
                      style: const TextStyle(color: slate, fontSize: 12.5)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.black26),
          ],
        ),
      ),
    );
  }
}
