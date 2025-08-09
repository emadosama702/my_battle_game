import 'package:flame_audio/flame_audio.dart';

class AudioHelper {
  /// تشغيل مؤثر صوتي قصير
  static Future<void> playSfx(String fileName, {double volume = 1.0}) async {
    try {
      await FlameAudio.play(fileName, volume: volume);
    } catch (e) {
      print('خطأ أثناء تشغيل الصوت: $e');
    }
  }

  /// تشغيل موسيقى في الخلفية (loop)
  static Future<void> playBgm(String fileName, {double volume = 0.5}) async {
    try {
      await FlameAudio.bgm.play(fileName, volume: volume);
    } catch (e) {
      print('خطأ أثناء تشغيل موسيقى الخلفية: $e');
    }
  }

  /// إيقاف موسيقى الخلفية
  static void stopBgm() {
    try {
      FlameAudio.bgm.stop();
    } catch (e) {
      print('خطأ أثناء إيقاف الموسيقى: $e');
    }
  }

  /// تحميل كل الملفات الصوتية
  static Future<void> loadAll(List<String> files) async {
    try {
      await FlameAudio.audioCache.loadAll(files);
    } catch (e) {
      print('خطأ أثناء تحميل الملفات الصوتية: $e');
    }
  }
}
