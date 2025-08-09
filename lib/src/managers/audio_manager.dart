import 'package:flame_audio/flame_audio.dart';

class AudioManager {
  static bool _isMuted = false;

  static Future<void> playSound(String fileName) async {
    if (_isMuted) return;
    await FlameAudio.play(fileName);
  }

  static void mute() {
    _isMuted = true;
  }

  static void unmute() {
    _isMuted = false;
  }

  static bool get isMuted => _isMuted;
}
