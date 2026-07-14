import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

/// Looks up pre-generated, bundled Twi audio clips so common lesson words play
/// from the app package instead of calling the Khaya TTS API every time
/// (saves API quota; lesson vocabulary is a fixed, known set).
///
/// Populate the clips + manifest with `scripts/generate_lesson_audio.mjs`.
/// The manifest maps normalised Twi text -> asset filename in assets/audio/.
class AudioBundle {
  AudioBundle._();
  static final AudioBundle instance = AudioBundle._();

  Map<String, String>? _manifest; // normalisedText -> filename
  bool _loaded = false;

  String _norm(String text) => text.trim().toLowerCase();

  Future<void> _ensureLoaded() async {
    if (_loaded) return;
    _loaded = true;
    try {
      final raw = await rootBundle.loadString('assets/audio/manifest.json');
      final map = jsonDecode(raw) as Map<String, dynamic>;
      _manifest = map.map((k, v) => MapEntry(k, v.toString()));
    } catch (_) {
      _manifest = {}; // no bundle yet — callers fall back to live TTS
    }
  }

  /// Returns the asset path for [text] if a bundled clip exists, else null.
  /// AudioPlayer's AssetSource expects the path WITHOUT the leading "assets/".
  Future<String?> assetPathFor(String text) async {
    await _ensureLoaded();
    final file = _manifest?[_norm(text)];
    if (file == null || file.isEmpty) return null;
    return 'audio/$file';
  }
}
