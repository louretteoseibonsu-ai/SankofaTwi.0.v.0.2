import 'package:audioplayers/audioplayers.dart';

/// Soft, low-volume UI sounds. Sampled (not synth beeps) and played at low
/// latency. Pairs with HapticFeedback for a premium, tactile feel.
class SoundService {
  SoundService._();
  static final SoundService instance = SoundService._();

  /// Toggle to mute all UI sounds app-wide (e.g. from a settings switch later).
  bool enabled = true;

  final AudioPlayer _player = AudioPlayer(playerId: 'sankofa_sfx')
    ..setReleaseMode(ReleaseMode.stop);

  Future<void> _play(String file, double volume) async {
    if (!enabled) return;
    try {
      await _player.stop();
      await _player.play(
        AssetSource('sfx/$file'),
        volume: volume,
        mode: PlayerMode.lowLatency,
      );
    } catch (_) {
      // never let a missing sound break the UI
    }
  }

  Future<void> correct() => _play('correct.wav', 0.55);
  Future<void> complete() => _play('complete.wav', 0.6);
  Future<void> tap() => _play('tap.wav', 0.35);
}
