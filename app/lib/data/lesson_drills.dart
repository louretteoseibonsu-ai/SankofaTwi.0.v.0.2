import 'dart:math';
import 'lesson_content.dart';
import 'picword_icons.dart';

/// The kinds of practice drill a lesson can serve. MCQ is the classic
/// multiple-choice; the rest are generated from the unit's own glossary and
/// example sentences so no extra authoring is needed.
enum DrillKind { mcq, match, listen, build, picture }

/// One picture tile in a [PictureDrill].
class PictureOption {
  final String iconStem; // filename stem in assets/images/picwords/
  final String en; // English label (shown only when the drill shows labels)
  const PictureOption(this.iconStem, this.en);
}

/// Hear the Twi word, tap the matching picture. The gentle first rung of the
/// difficulty staircase. [showLabels] carries the English under each tile on
/// the very first rung, then turns off so the learner graduates to sound-only.
class PictureDrill {
  final GlossEntry answer; // the prompt word (Twi + audio + gloss)
  final List<PictureOption> options;
  final int correctIndex;
  final bool showLabels;
  const PictureDrill(
      this.answer, this.options, this.correctIndex, this.showLabels);
}

/// Match English ↔ Twi pairs (up to four at a time).
class MatchDrill {
  final List<GlossEntry> pairs;
  const MatchDrill(this.pairs);
}

/// Hear the Twi, pick its English meaning.
class ListenDrill {
  final GlossEntry answer;
  final List<String> options; // english meanings incl. the correct one
  const ListenDrill(this.answer, this.options);
}

/// Arrange the scrambled word tiles to match the spoken Twi sentence.
class BuildDrill {
  final List<String> tokens; // the sentence, in order
  final String audio; // the full sentence, for TTS
  const BuildDrill(this.tokens, this.audio);
}

/// One item in a lesson's interleaved practice sequence.
class LessonDrill {
  final DrillKind kind;
  final Challenge? mcq;
  final MatchDrill? match;
  final ListenDrill? listen;
  final BuildDrill? build;
  final PictureDrill? picture;
  const LessonDrill._(this.kind,
      {this.mcq, this.match, this.listen, this.build, this.picture});

  factory LessonDrill.mcq(Challenge c) =>
      LessonDrill._(DrillKind.mcq, mcq: c);
  factory LessonDrill.match(MatchDrill m) =>
      LessonDrill._(DrillKind.match, match: m);
  factory LessonDrill.listen(ListenDrill l) =>
      LessonDrill._(DrillKind.listen, listen: l);
  factory LessonDrill.build(BuildDrill b) =>
      LessonDrill._(DrillKind.build, build: b);
  factory LessonDrill.picture(PictureDrill p) =>
      LessonDrill._(DrillKind.picture, picture: p);
}

/// Builds the word→picture drills that open a concrete-noun lesson: the easy
/// first rung(s) of the staircase. Only glossary words that have artwork (see
/// [picwordIcon]) can be a prompt or a distractor, so abstract units (greetings
/// etc.) simply get none. The first drill carries English labels; the second
/// drops them so the learner graduates to sound → picture.
List<LessonDrill> _pictureDrills(UnitContent u, Random r, {int max = 2}) {
  // The prompt must be a unit-glossary word that has artwork.
  final answers = [
    for (final g in u.glossary)
      if (picwordIcon(g.twi) != null) g
  ]..shuffle(r);
  if (answers.isEmpty) return const [];

  final out = <LessonDrill>[];
  for (var n = 0; n < answers.length && out.length < max; n++) {
    final ans = answers[n];
    final ansStem = picwordIcon(ans.twi)!;

    // Distractors: prefer other illustrated words from THIS unit (topical),
    // then top up from the shared pool so every unit with one illustrated word
    // still gets a full 4-tile choice.
    final opts = <PictureOption>[PictureOption(ansStem, ans.en)];
    final usedStems = <String>{ansStem};

    final local = [
      for (final g in u.glossary)
        if (g.twi != ans.twi && picwordIcon(g.twi) != null) g
    ]..shuffle(r);
    for (final g in local) {
      if (opts.length >= 4) break;
      final s = picwordIcon(g.twi)!;
      if (usedStems.add(s)) opts.add(PictureOption(s, g.en));
    }
    final global = [...kPicwordEntries]..shuffle(r);
    for (final e in global) {
      if (opts.length >= 4) break;
      if (usedStems.add(e.stem)) opts.add(PictureOption(e.stem, e.en));
    }

    opts.shuffle(r);
    final correct = opts.indexWhere((o) => o.iconStem == ansStem);
    out.add(LessonDrill.picture(
        PictureDrill(ans, opts, correct, out.isEmpty))); // labels on rung 1 only
  }
  return out;
}

/// Builds an interleaved, varied practice sequence for [u]: the classic MCQs
/// mixed with word-match, listen-and-choose and build-the-sentence drills
/// generated from the unit's glossary + example sentences. Falls back to
/// MCQ-only when a unit lacks the data. Capped so lessons stay a sensible length.
List<LessonDrill> buildLessonDrills(UnitContent u, Random r, {int cap = 12}) {
  final mcqs = [for (final c in u.challenges) LessonDrill.mcq(c.shuffledOptions(r))];

  // ── Word match: chunk the glossary into groups of up to four pairs ──
  final gloss = [...u.glossary]..shuffle(r);
  final matches = <LessonDrill>[];
  for (var i = 0; i + 3 <= gloss.length; i += 4) {
    final chunk = gloss.skip(i).take(4).toList();
    if (chunk.length >= 3) matches.add(LessonDrill.match(MatchDrill(chunk)));
  }

  // ── Listen & choose: single-word audio → pick the meaning ──
  final listens = <LessonDrill>[];
  if (u.glossary.length >= 3) {
    final picks = ([...u.glossary]..shuffle(r)).take(3).toList();
    for (final ans in picks) {
      final distract = ([
        ...u.glossary.where((g) => g.en != ans.en)
      ]..shuffle(r))
          .take(2)
          .map((g) => g.en)
          .toList();
      if (distract.length < 2) continue;
      final opts = [ans.en, ...distract]..shuffle(r);
      listens.add(LessonDrill.listen(ListenDrill(ans, opts)));
    }
  }

  // ── Build the sentence: scramble an example (3–6 words) ──
  final builds = <LessonDrill>[];
  for (final s in u.examples) {
    final toks =
        s.split(RegExp(r'\s+')).where((t) => t.trim().isNotEmpty).toList();
    if (toks.length >= 3 && toks.length <= 6) {
      builds.add(LessonDrill.build(BuildDrill(toks, s)));
    }
  }

  // ── Round-robin interleave so the practice never blocks on one type ──
  final pools = [mcqs, matches, listens, builds];
  final idx = [0, 0, 0, 0];
  final out = <LessonDrill>[];
  var guard = 0;
  while (out.length < cap && guard < 400) {
    guard++;
    final p = guard % 4;
    if (idx[p] < pools[p].length) {
      out.add(pools[p][idx[p]]);
      idx[p]++;
    }
    if (idx[0] >= mcqs.length &&
        idx[1] >= matches.length &&
        idx[2] >= listens.length &&
        idx[3] >= builds.length) {
      break;
    }
  }
  final body = out.isEmpty ? mcqs : out;
  // Open with the easy word→picture rung(s), then the harder drills. This is
  // the difficulty staircase: the advanced word→sentence match is now gated
  // behind a gentle picture match instead of being the very first thing.
  final pictures = _pictureDrills(u, r);
  if (pictures.isEmpty) return body;
  return [...pictures, ...body].take(cap).toList();
}
