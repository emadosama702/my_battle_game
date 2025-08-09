import 'package:flame/flame.dart';
import 'package:flame_audio/flame_audio.dart';

class AssetLoader {
  /// تحميل جميع الصور
  static Future<void> loadImages(List<String> imagePaths) async {
    try {
      await Future.wait(imagePaths.map((path) => Flame.images.load(path)));
    } catch (e) {
      print('خطأ أثناء تحميل الصور: $e');
    }
  }

  /// تحميل جميع الملفات الصوتية
  static Future<void> loadAudio(List<String> audioPaths) async {
    try {
      await FlameAudio.audioCache.loadAll(audioPaths);
    } catch (e) {
      print('خطأ أثناء تحميل الملفات الصوتية: $e');
    }
  }

  /// تحميل جميع الأصول (صور + أصوات)
  static Future<void> loadAllAssets({
    required List<String> imagePaths,
    required List<String> audioPaths,
  }) async {
    await loadImages(imagePaths);
    await loadAudio(audioPaths);
  }
}
