import 'dart:typed_data';

/// In-memory cache of TTS audio bytes keyed by text (+ language). Lets repeat
/// plays of the same word skip the Khaya call entirely — so replays don't cost
/// an AI credit and don't hit the backend. Bounded (LRU-ish) to cap memory.
class TtsCache {
  TtsCache._();
  static final TtsCache instance = TtsCache._();

  static const int _max = 80;
  final Map<String, Uint8List> _map = {};
  final List<String> _order = []; // oldest first

  String key(String text, {String lang = 'tw'}) => '$lang:${text.trim()}';

  Uint8List? get(String key) {
    final v = _map[key];
    if (v != null) {
      _order.remove(key);
      _order.add(key); // mark most-recently-used
    }
    return v;
  }

  void put(String key, Uint8List bytes) {
    if (!_map.containsKey(key)) _order.add(key);
    _map[key] = bytes;
    while (_order.length > _max) {
      final oldest = _order.removeAt(0);
      _map.remove(oldest);
    }
  }
}
