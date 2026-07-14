import 'package:flutter/material.dart';
import '../data/reading_passages.dart';
import '../services/progress_service.dart';
import '../theme.dart';
import '../widgets/challenge_quiz.dart';
import '../widgets/floating_card.dart';
import '../widgets/speak_button.dart';

/// Progressive list of reading passages — pass one to unlock the next.
class ReadingListScreen extends StatefulWidget {
  const ReadingListScreen({super.key});

  @override
  State<ReadingListScreen> createState() => _ReadingListScreenState();
}

class _ReadingListScreenState extends State<ReadingListScreen> {
  final _service = ProgressService();
  Set<String> _passed = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final passed = await _service.loadReadingPassed();
    if (!mounted) return;
    setState(() {
      _passed = passed;
      _loading = false;
    });
  }

  bool _unlocked(int i) =>
      i == 0 || _passed.contains(kReadingPassages[i - 1].id);

  Future<void> _open(ReadingPassage p) async {
    final result = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => ReadingDetailScreen(passage: p)));
    if (result == true) _reload();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return RefreshIndicator(
      onRefresh: _reload,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Reading & Comprehension',
              style: TextStyle(
                  fontWeight: FontWeight.w800, fontSize: 26, color: ink)),
          const SizedBox(height: 4),
          Text('${_passed.length} / ${kReadingPassages.length} passages passed. '
              'Score 60% or more to pass and unlock the next.',
              style: const TextStyle(color: slate, fontSize: 13.5, height: 1.5)),
          const SizedBox(height: 16),
          for (int i = 0; i < kReadingPassages.length; i++)
            _PassageRow(
              passage: kReadingPassages[i],
              unlocked: _unlocked(i),
              passed: _passed.contains(kReadingPassages[i].id),
              onOpen: () => _open(kReadingPassages[i]),
            ),
        ],
      ),
    );
  }
}

class _PassageRow extends StatelessWidget {
  final ReadingPassage passage;
  final bool unlocked;
  final bool passed;
  final VoidCallback onOpen;
  const _PassageRow({
    required this.passage,
    required this.unlocked,
    required this.passed,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final IconData icon;
    final Color iconColor;
    if (passed) {
      icon = Icons.check_circle;
      iconColor = const Color(0xFF2E6B3B);
    } else if (unlocked) {
      icon = Icons.menu_book_outlined;
      iconColor = terracotta;
    } else {
      icon = Icons.lock_outline;
      iconColor = silver;
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: FloatingCard(
        onTap: unlocked ? onOpen : null,
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(passage.title,
                      style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: unlocked ? ink : slate)),
                  Text(
                      unlocked
                          ? '${passage.level}  ·  pass ${passage.passMark}/${passage.questions.length}'
                          : 'Locked — pass the previous passage',
                      style: const TextStyle(color: slate, fontSize: 12.5)),
                ],
              ),
            ),
            if (unlocked)
              const Icon(Icons.chevron_right, color: Colors.black26),
          ],
        ),
      ),
    );
  }
}

/// A single passage: read (with audio) → reveal translation → comprehension.
class ReadingDetailScreen extends StatefulWidget {
  final ReadingPassage passage;
  const ReadingDetailScreen({super.key, required this.passage});

  @override
  State<ReadingDetailScreen> createState() => _ReadingDetailScreenState();
}

class _ReadingDetailScreenState extends State<ReadingDetailScreen> {
  final _service = ProgressService();
  bool _showEnglish = false;
  bool _started = false;

  Future<void> _onPassed() async {
    await _service.markReadingPassed(widget.passage.id);
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.passage;
    return Scaffold(
      appBar: AppBar(title: Text(p.title)),
      body: SafeArea(
        child: _started ? _buildQuiz(p) : _buildReading(p),
      ),
    );
  }

  // ── Reading view ──
  Widget _buildReading(ReadingPassage p) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(p.level.toUpperCase(),
            style: const TextStyle(
                color: terracotta,
                fontWeight: FontWeight.w800,
                fontSize: 12,
                letterSpacing: 1.2)),
        const SizedBox(height: 10),
        FloatingCard(
          child: Column(
            children: [
              for (int i = 0; i < p.lines.length; i++) ...[
                if (i > 0)
                  const Divider(height: 1, color: silverLight),
                Row(
                  children: [
                    Expanded(
                      child: Text(p.lines[i],
                          style: const TextStyle(
                              fontSize: 18, height: 1.5, color: ink)),
                    ),
                    SpeakButton(text: p.lines[i], size: 22),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 4),
        const Text('Tap 🔊 to hear each line.',
            style: TextStyle(color: slate, fontSize: 12)),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => setState(() => _showEnglish = !_showEnglish),
            icon: Icon(
                _showEnglish ? Icons.visibility_off_outlined : Icons.translate,
                size: 18),
            label:
                Text(_showEnglish ? 'Hide translation' : 'Show translation'),
          ),
        ),
        if (_showEnglish) ...[
          const SizedBox(height: 4),
          FloatingCard(
            child: Text(p.english,
                style: const TextStyle(
                    fontSize: 15, height: 1.6, color: slate)),
          ),
        ],
        const SizedBox(height: 16),
        _PassLegend(passMark: p.passMark, total: p.questions.length),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: () => setState(() => _started = true),
          child: const Text('Start comprehension'),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // ── Quiz view (with listen-again strip + pass legend) ──
  Widget _buildQuiz(ReadingPassage p) {
    return Column(
      children: [
        _ListenStrip(lines: p.lines),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
          child: _PassLegend(passMark: p.passMark, total: p.questions.length),
        ),
        Expanded(
          child: ChallengeQuiz(
            challenges: p.questions,
            maxQuestions: p.questions.length,
            kicker: 'Comprehension · ${p.title}',
            passMode: true,
            passThreshold: 0.6,
            onPassed: _onPassed,
            passButtonLabel: 'Done',
          ),
        ),
      ],
    );
  }
}

/// "Pass mark: X of Y correct" — sets expectations before/while testing.
class _PassLegend extends StatelessWidget {
  final int passMark;
  final int total;
  const _PassLegend({required this.passMark, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: glyphTile,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.emoji_events_outlined, size: 18, color: slate),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Pass mark: $passMark of $total correct (60%). '
              'Below that, you can retry.',
              style: const TextStyle(
                  color: slate, fontSize: 12.5, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

/// Horizontal strip of numbered speaker buttons so learners can re-hear any
/// line while answering the comprehension questions.
class _ListenStrip extends StatelessWidget {
  final List<String> lines;
  const _ListenStrip({required this.lines});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 10, 8, 6),
      color: const Color(0xFFF7F5F0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Listen again',
              style: TextStyle(
                  color: slate, fontSize: 11.5, fontWeight: FontWeight.w800)),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (int i = 0; i < lines.length; i++)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${i + 1}',
                          style: const TextStyle(
                              color: slate,
                              fontSize: 12,
                              fontWeight: FontWeight.w700)),
                      SpeakButton(text: lines[i], size: 18),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
