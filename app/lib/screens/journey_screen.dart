import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/lesson_catalog.dart';
import '../services/progress_service.dart';
import '../services/sound_service.dart';
import '../theme.dart';
import '../widgets/trotro_mascot.dart';
import 'lesson_quiz_screen.dart';

const Color _roadGold = Color(0xFFE3A92C);
const Color _roadGoldDeep = Color(0xFFC68A1E);
const Color _doneGreen = Color(0xFF2E6B3B);

/// The learning path — "how it started → how it's going" — with the Sankofa
/// tro tro driving the learner down a winding road of lessons, stop by stop.
class JourneyScreen extends StatefulWidget {
  const JourneyScreen({super.key});

  @override
  State<JourneyScreen> createState() => _JourneyScreenState();
}

class _JourneyScreenState extends State<JourneyScreen> {
  final _service = ProgressService();
  Progress _p = Progress.empty;
  bool _loading = true;

  // Where the tro tro is drawn. Decoupled from the "true" current index so it
  // can animate (drive) from the old stop to the new one when a lesson unlocks
  // the next, rather than teleporting.
  int _displayIndex = 0;
  TroTroState _troState = TroTroState.idle;
  bool _firstLoad = true;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final p = await _service.load();
    if (!mounted) return;
    final newCurrent = _currentIndexFor(p);
    final prev = _displayIndex;
    setState(() {
      _p = p;
      _loading = false;
    });

    // First open: just park at the current stop, no drive animation.
    if (_firstLoad) {
      _firstLoad = false;
      setState(() => _displayIndex = newCurrent);
      return;
    }

    if (newCurrent > prev) {
      // Progressed: drive up the road to the newly unlocked stop.
      setState(() {
        _troState = TroTroState.drive;
        _displayIndex = newCurrent; // AnimatedPositioned slides it there
      });
      await Future.delayed(const Duration(milliseconds: 950));
      if (!mounted) return;
      setState(() => _troState = TroTroState.arrive);
      SoundService.instance.complete();
      HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      setState(() => _troState = TroTroState.idle);
    } else {
      setState(() => _displayIndex = newCurrent);
    }
  }

  Future<void> _open(Lesson l) async {
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => LessonQuizScreen(lesson: l)));
    _reload();
  }

  static int _currentIndexFor(Progress p) {
    final i =
        kLessonsFlat.indexWhere((l) => p.unlocked(l.id) && !p.passed(l.id));
    if (i != -1) return i;
    return kLessonsFlat.isEmpty ? 0 : kLessonsFlat.length - 1;
  }

  int get _currentIndex => _currentIndexFor(_p);

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    final lessons = kLessonsFlat;
    final n = lessons.length;
    final passedCount = lessons.where((l) => _p.passed(l.id)).length;
    final current = _currentIndex;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Your Journey',
                  style: TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 26, color: ink)),
              const SizedBox(height: 2),
              Text('How it started  →  how it\'s going    ·    '
                  '$passedCount of $n lessons    ·    Level ${_p.level}',
                  style: const TextStyle(color: slate, fontSize: 13)),
            ],
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, c) {
              final w = c.maxWidth;
              const topPad = 50.0, spacing = 118.0, bottomPad = 90.0;
              final height = topPad + spacing * (n - 1) + bottomPad;
              Offset posOf(int i) => Offset(
                    i.isEven ? w * 0.30 : w * 0.70,
                    topPad + spacing * i,
                  );
              final points = [for (int i = 0; i < n; i++) posOf(i)];

              return SingleChildScrollView(
                child: SizedBox(
                  width: w,
                  height: height,
                  child: Stack(
                    children: [
                      CustomPaint(
                          size: Size(w, height),
                          painter: _RoadPainter(points)),
                      // Start flag
                      Positioned(
                        left: points.first.dx - 70,
                        top: points.first.dy - 44,
                        child: const _Tag(text: 'How it started'),
                      ),
                      // Finish trophy
                      Positioned(
                        left: points.last.dx - 22,
                        top: points.last.dy + 34,
                        child: const Icon(Icons.emoji_events,
                            color: _roadGold, size: 36),
                      ),
                      // Nodes (the stop under the tro tro is hidden)
                      for (int i = 0; i < n; i++)
                        if (i != _displayIndex)
                          Positioned(
                            left: points[i].dx - 26,
                            top: points[i].dy - 26,
                            child: _Node(
                              lesson: lessons[i],
                              passed: _p.passed(lessons[i].id),
                              unlocked: _p.unlocked(lessons[i].id),
                              onTap: _p.unlocked(lessons[i].id)
                                  ? () => _open(lessons[i])
                                  : null,
                            ),
                          ),
                      // The tro tro on the current stop (drawn last = on top).
                      // AnimatedPositioned makes it drive between stops.
                      if (n > 0)
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 900),
                          curve: Curves.easeInOut,
                          left: points[_displayIndex].dx - 54,
                          top: points[_displayIndex].dy - 46,
                          width: 108,
                          height: 108 * 250 / 380,
                          child: GestureDetector(
                            onTap: () => _open(lessons[current]),
                            child: TroTroMascot(
                              state: _troState,
                              width: 108,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _Node extends StatelessWidget {
  final Lesson lesson;
  final bool passed;
  final bool unlocked;
  final VoidCallback? onTap;
  const _Node({
    required this.lesson,
    required this.passed,
    required this.unlocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color fill;
    final Color border;
    final Widget icon;
    if (passed) {
      fill = _doneGreen;
      border = _doneGreen;
      icon = const Icon(Icons.check, color: Colors.white, size: 24);
    } else if (unlocked) {
      fill = Colors.white;
      border = terracotta;
      icon = const Icon(Icons.play_arrow_rounded, color: terracotta, size: 26);
    } else {
      fill = const Color(0xFFEDEEF0);
      border = silver;
      icon = const Icon(Icons.lock, color: silver, size: 20);
    }
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: fill,
          shape: BoxShape.circle,
          border: Border.all(color: border, width: 3),
          boxShadow: const [
            BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 6,
                offset: Offset(0, 2)),
          ],
        ),
        child: Center(child: icon),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  const _Tag({required this.text});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
          color: glyphTile, borderRadius: BorderRadius.circular(10)),
      child: Text(text,
          style: const TextStyle(
              color: slate, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
}

class _RoadPainter extends CustomPainter {
  final List<Offset> pts;
  const _RoadPainter(this.pts);

  Path _buildPath() {
    final path = Path();
    if (pts.isEmpty) return path;
    path.moveTo(pts.first.dx, pts.first.dy);
    for (int i = 1; i < pts.length; i++) {
      final prev = pts[i - 1];
      final cur = pts[i];
      final midY = (prev.dy + cur.dy) / 2;
      path.cubicTo(prev.dx, midY, cur.dx, midY, cur.dx, cur.dy);
    }
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (pts.length < 2) return;
    final path = _buildPath();
    // Outer edge
    canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 22
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = _roadGoldDeep);
    // Inner road
    canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 15
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = _roadGold);
    // Dashed cream centre line
    final dash = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFFFBF1D8);
    final metrics = path.computeMetrics();
    for (final m in metrics) {
      double d = 0;
      while (d < m.length) {
        final seg = m.extractPath(d, d + 9);
        canvas.drawPath(seg, dash);
        d += 20;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _RoadPainter old) => old.pts != pts;
}
