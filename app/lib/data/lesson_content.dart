import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;

/// A single multiple-choice challenge.
class Challenge {
  final String prompt;
  final List<String> options;
  final int correctIndex;
  final String category;
  final String? slangHint;
  const Challenge(this.prompt, this.options, this.correctIndex,
      {this.category = '', this.slangHint});

  String get correctLabel => options[correctIndex];

  /// Returns a copy with options shuffled (correct index re-pointed).
  Challenge shuffledOptions(Random r) {
    final label = correctLabel;
    final opts = [...options]..shuffle(r);
    return Challenge(prompt, opts, opts.indexOf(label),
        category: category, slangHint: slangHint);
  }
}

class GlossEntry {
  final String twi;
  final String en;
  /// Optional text to speak instead of [twi] when TTS mispronounces the bare
  /// word (e.g. a short verb read better inside a tiny carrier phrase).
  final String? audio;
  const GlossEntry(this.twi, this.en, {this.audio});
}

class UnitContent {
  final String title;
  final String headword;
  final String pronunciation;
  final String gloss;
  final List<String> examples;
  final Map<String, dynamic>? grammar;
  final List<Challenge> challenges;
  final List<GlossEntry> glossary;
  final String? cultureNote; // "Chale tip" — modern slang / cultural context
  final bool reviewRequired;
  /// Optional text spoken when the headword's audio button is tapped, when the
  /// bare headword alone is mispronounced by TTS (e.g. a single short verb).
  /// Falls back to [headword].
  final String? headwordAudio;
  const UnitContent({
    required this.title,
    required this.headword,
    required this.pronunciation,
    required this.gloss,
    required this.examples,
    required this.grammar,
    required this.challenges,
    required this.glossary,
    required this.cultureNote,
    required this.reviewRequired,
    this.headwordAudio,
  });
}

Future<UnitContent> loadUnit(String asset, {required String category}) async {
  final raw = await rootBundle.loadString(asset);
  final u = json.decode(raw) as Map<String, dynamic>;
  final v = u['vocabulary_spotlight'] as Map<String, dynamic>;
  final bridge = v['phonetic_bridge'] as Map<String, dynamic>?;
  final challenges = (u['lineage_challenges'] as List)
      .cast<Map<String, dynamic>>()
      .map((c) => Challenge(
            c['prompt'] as String,
            (c['options'] as List).cast<String>(),
            c['correct_index'] as int,
            category: category,
            slangHint: c['slang_hint'] as String?,
          ))
      .toList();
  final glossary = (u['glossary'] as List?)
          ?.cast<Map<String, dynamic>>()
          .map((g) => GlossEntry(g['twi'] as String, g['en'] as String,
              audio: g['audio'] as String?))
          .toList() ??
      const <GlossEntry>[];
  return UnitContent(
    title: u['unit_title'] as String,
    headword: v['headword'] as String,
    pronunciation: (bridge?['pronunciation'] as String?) ?? '',
    gloss: v['gloss'] as String,
    examples: (v['example_sentences'] as List?)?.cast<String>() ?? const [],
    grammar: u['grammar_mechanics'] as Map<String, dynamic>?,
    challenges: challenges,
    glossary: glossary,
    cultureNote: v['culture_note'] as String?,
    reviewRequired: (u['review_required'] as bool?) ?? false,
    headwordAudio: v['audio_text'] as String?,
  );
}
