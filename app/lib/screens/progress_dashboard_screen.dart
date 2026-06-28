import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../data/adinkra_symbols.dart';
import '../data/lesson_catalog.dart';
import '../services/progress_service.dart';
import '../theme.dart';
import '../widgets/floating_card.dart';

const Color _gold = Color(0xFFE3A92C);
const Color _green = Color(0xFF2E6B3B);
const Color _red = Color(0xFF9B2D2A);

class ProgressDashboardScreen extends StatefulWidget {
  const ProgressDashboardScreen({super.key});

  @override
  State<ProgressDashboardScreen> createState() =>
      _ProgressDashboardScreenState();
}

class _ProgressDashboardScreenState extends State<ProgressDashboardScreen> {
  final _service = ProgressService();
  Stats _s = Stats.empty;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final s = await _service.loadStats();
    if (!mounted) return;
    setState(() {
      _s = s;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    final p = _s.progress;
    final totalLessons = kLessonsFlat.length;

    return RefreshIndicator(
      onRefresh: _reload,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Your Progress',
              style: TextStyle(
                  fontWeight: FontWeight.w800, fontSize: 26, color: ink)),
          const SizedBox(height: 2),
          const Text('How you’re doing, all in one place.',
              style: TextStyle(color: slate, fontSize: 13.5)),
          const SizedBox(height: 16),

          _LevelHero(p: p),
          const SizedBox(height: 14),

          _StreakCard(s: _s),
          const SizedBox(height: 14),

          _DailyQuests(s: _s),
          const SizedBox(height: 14),

          // ── Stats grid ──
          Row(children: [
            _Metric(label: 'Day streak', value: '${_s.streak}', icon: '🔥'),
            const SizedBox(width: 10),
            _Metric(label: 'Total XP', value: '${p.totalXp}', icon: '⭐'),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            _Metric(
                label: 'Lessons',
                value: '${_s.lessonsCompleted}/$totalLessons',
                icon: '📘'),
            const SizedBox(width: 10),
            _Metric(label: 'Words', value: '${_s.wordsLearned}', icon: '🗣'),
          ]),
          const SizedBox(height: 22),

          const _SectionTitle('Mastery by subject'),
          const SizedBox(height: 8),
          for (final c in kCategories) _MasteryRow(category: c, p: p),
          const SizedBox(height: 18),

          const _SectionTitle('Adinkra badges'),
          const SizedBox(height: 10),
          _BadgeGrid(s: _s),
          const SizedBox(height: 28),
        ],
      ),
    );
  }
}

// ── Level + league ─────────────────────────────────────────────────────────
class _LevelHero extends StatelessWidget {
  final Progress p;
  const _LevelHero({required this.p});

  ({String name, String meaning}) _league(int xp) {
    if (xp >= 800) return (name: 'Ahenfie', meaning: 'the royal court');
    if (xp >= 300) return (name: 'Nkɔsoɔ', meaning: 'progress');
    return (name: 'Asɛmpa', meaning: 'good news');
  }

  @override
  Widget build(BuildContext context) {
    final lg = _league(p.totalXp);
    final pct = p.xpIntoLevel / p.xpForNextLevel;
    return FloatingCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: terracotta,
                    borderRadius: BorderRadius.circular(15)),
                child: Text('${p.level}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 22)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Level ${p.level}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                            color: ink)),
                    Text('${p.totalXp} XP total',
                        style: const TextStyle(color: slate, fontSize: 13)),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                    color: const Color(0xFFFBF1D8),
                    borderRadius: BorderRadius.circular(10)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('🏆 ${lg.name}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            color: Color(0xFF8A6A12))),
                    Text(lg.meaning,
                        style: const TextStyle(
                            color: Color(0xFFA98A3A), fontSize: 10)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: pct.clamp(0.0, 1.0),
              minHeight: 9,
              backgroundColor: silverLight,
              valueColor: const AlwaysStoppedAnimation(terracotta),
            ),
          ),
          const SizedBox(height: 6),
          Text('${p.xpIntoLevel} / ${p.xpForNextLevel} XP to level ${p.level + 1}',
              style: const TextStyle(color: slate, fontSize: 12)),
        ],
      ),
    );
  }
}

// ── Streak + kente cloth ────────────────────────────────────────────────────
class _StreakCard extends StatelessWidget {
  final Stats s;
  const _StreakCard({required this.s});

  @override
  Widget build(BuildContext context) {
    return FloatingCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🔥', style: TextStyle(fontSize: 26)),
              const SizedBox(width: 10),
              Text('${s.streak}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 26, color: ink)),
              const SizedBox(width: 6),
              const Text('day streak',
                  style: TextStyle(color: slate, fontSize: 14)),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                    color: glyphTile,
                    borderRadius: BorderRadius.circular(10)),
                child: Text('❄ ${s.freezes} freeze${s.freezes == 1 ? '' : 's'}',
                    style: const TextStyle(
                        color: slate,
                        fontWeight: FontWeight.w700,
                        fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text('YOUR KENTE CLOTH',
              style: TextStyle(
                  color: slate,
                  fontWeight: FontWeight.w700,
                  fontSize: 10.5,
                  letterSpacing: 0.6)),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CustomPaint(
              size: Size(double.infinity, (s.streak.clamp(1, 21)) * 9.0 + 6),
              painter: _KenteClothPainter(s.streak),
            ),
          ),
          const SizedBox(height: 6),
          Text(
              s.streak == 0
                  ? 'Finish a lesson today to start weaving your cloth.'
                  : 'Each day you practise weaves another row. Keep it going!',
              style: const TextStyle(color: slate, fontSize: 12)),
        ],
      ),
    );
  }
}

class _KenteClothPainter extends CustomPainter {
  final int streak;
  const _KenteClothPainter(this.streak);
  static const _cols = [_gold, _red, _green, Color(0xFF2B2B2D)];

  @override
  void paint(Canvas canvas, Size size) {
    final rows = streak.clamp(1, 21);
    const rowH = 9.0;
    for (int r = 0; r < rows; r++) {
      final filled = r < streak;
      final y = r * rowH;
      const seg = 6;
      final w = size.width / seg;
      for (int c = 0; c < seg; c++) {
        final base = _cols[(r + c) % _cols.length];
        final paint = Paint()
          ..color = filled ? base : silverLight;
        canvas.drawRect(Rect.fromLTWH(c * w, y, w - 1, rowH - 1), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _KenteClothPainter old) =>
      old.streak != streak;
}

// ── Daily quests ────────────────────────────────────────────────────────────
class _DailyQuests extends StatelessWidget {
  final Stats s;
  const _DailyQuests({required this.s});

  @override
  Widget build(BuildContext context) {
    final quests = <({String label, double progress, bool done})>[
      (
        label: 'Finish a lesson',
        progress: s.dailyLessons >= 1 ? 1 : 0,
        done: s.dailyLessons >= 1
      ),
      (
        label: 'Earn 50 XP',
        progress: (s.dailyXp / 50).clamp(0.0, 1.0),
        done: s.dailyXp >= 50
      ),
      (
        label: 'Ace a quiz (10/10)',
        progress: s.dailyPerfect ? 1 : 0,
        done: s.dailyPerfect
      ),
    ];
    final doneCount = quests.where((q) => q.done).length;
    return FloatingCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Daily quests',
                  style: TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 16, color: ink)),
              const Spacer(),
              Text('$doneCount / 3',
                  style: const TextStyle(
                      color: slate, fontWeight: FontWeight.w700, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 10),
          for (final q in quests)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Icon(
                      q.done
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: q.done ? _green : silver,
                      size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(q.label,
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: q.done ? slate : ink)),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: q.progress,
                            minHeight: 5,
                            backgroundColor: silverLight,
                            valueColor: AlwaysStoppedAnimation(
                                q.done ? _green : terracotta),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          if (doneCount == 3)
            const Text('All done — Ayɛkoo! Come back tomorrow.',
                style: TextStyle(
                    color: _green, fontWeight: FontWeight.w700, fontSize: 12)),
        ],
      ),
    );
  }
}

// ── Small pieces ────────────────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style:
          const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: ink));
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;
  final String icon;
  const _Metric(
      {required this.label, required this.value, required this.icon});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
            color: glyphTile, borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(icon, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 6),
            Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 22, color: ink)),
            Text(label, style: const TextStyle(color: slate, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _MasteryRow extends StatelessWidget {
  final LessonCategory category;
  final Progress p;
  const _MasteryRow({required this.category, required this.p});
  @override
  Widget build(BuildContext context) {
    final m = p.categoryMastery(category);
    final full = m >= 1.0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
              width: 26,
              child: Text(category.emoji,
                  style: const TextStyle(fontSize: 18))),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(category.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13.5,
                        color: ink)),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: m.clamp(0.0, 1.0),
                    minHeight: 6,
                    backgroundColor: silverLight,
                    valueColor:
                        AlwaysStoppedAnimation(full ? _green : charcoal),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text('${(m * 100).round()}%',
              style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 12.5,
                  color: full ? _green : slate)),
        ],
      ),
    );
  }
}

// ── Adinkra badges ──────────────────────────────────────────────────────────
class _BadgeGrid extends StatelessWidget {
  final Stats s;
  const _BadgeGrid({required this.s});

  @override
  Widget build(BuildContext context) {
    final masteredAny =
        kCategories.any((c) => s.progress.categoryMastery(c) >= 1.0);
    final badges = <({String title, String glyph, bool earned})>[
      (title: 'First Steps', glyph: 'akoma', earned: s.lessonsCompleted >= 1),
      (title: 'Streak x3', glyph: 'sankofa', earned: s.streak >= 3),
      (title: 'On Fire', glyph: 'gyenyame', earned: s.streak >= 7),
      (
        title: 'Perfectionist',
        glyph: 'dwennimmen',
        earned: s.perfectLessons >= 1
      ),
      (title: 'Scholar', glyph: 'nyame_dua', earned: s.lessonsCompleted >= 5),
      (title: 'Polyglot', glyph: 'akoma', earned: s.lessonsCompleted >= 10),
      (
        title: 'Loremaster',
        glyph: 'sankofa',
        earned: masteredAny
      ),
      (
        title: 'Centurion',
        glyph: 'dwennimmen',
        earned: s.progress.totalXp >= 1000
      ),
    ];
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.78,
      children: [for (final b in badges) _BadgeTile(b: b)],
    );
  }
}

class _BadgeTile extends StatelessWidget {
  final ({String title, String glyph, bool earned}) b;
  const _BadgeTile({required this.b});

  @override
  Widget build(BuildContext context) {
    final svg = kAdinkraSymbols
        .firstWhere((s) => s.id == b.glyph, orElse: () => kAdinkraSymbols.first)
        .svg;
    final color = b.earned ? _gold : silver;
    return Column(
      children: [
        Container(
          width: 54,
          height: 54,
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            color: b.earned ? const Color(0xFF2B2B2D) : glyphTile,
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: SvgPicture.string(svg,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn)),
        ),
        const SizedBox(height: 5),
        Text(b.title,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: TextStyle(
                fontSize: 10.5,
                height: 1.1,
                fontWeight: FontWeight.w600,
                color: b.earned ? ink : slate)),
      ],
    );
  }
}
