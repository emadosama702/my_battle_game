import 'package:flame/components.dart';
import 'package:flame/game.dart';

class GameCamera {
  final CameraComponent camera;

  GameCamera({required this.camera});

  /// تتبع لاعب أو أي كائن في اللعبة
  void follow(Component target, {double lerp = 0.1}) {
    camera.follow(target, horizontalOnly: false, verticalOnly: false);
    camera.viewfinder.anchor = Anchor.center;
    camera.viewfinder.lerpSpeed = lerp;
  }

  /// اهتزاز الشاشة عند الضربات أو الانفجارات
  void shake({double intensity = 5.0, double duration = 0.2}) {
    camera.viewfinder.shake(intensity: intensity, duration: duration);
  }

  /// تكبير وتصغير الكاميرا
  void zoom(double scale) {
    camera.viewfinder.zoom = scale;
  }
}
