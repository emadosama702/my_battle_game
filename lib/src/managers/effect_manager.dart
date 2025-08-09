import 'package:flame/components.dart';
import '../entities/effects/hit_effect.dart';
import '../entities/effects/ulti_effect.dart';

class EffectManager {
  final Component parent;

  EffectManager(this.parent);

  void showHitEffect(Vector2 position, Vector2 size) {
    final hitEffect = HitEffect(
      position: position,
      size: size,
      sprite: parent.gameRef!.spriteBatch, // استبدل بمصدر sprite الصحيح
    );
    parent.add(hitEffect);
  }

  void showUltiEffect(Vector2 position, Vector2 size, SpriteAnimation animation) {
    final ultiEffect = UltiEffect(
      position: position,
      size: size,
      animation: animation,
    );
    parent.add(ultiEffect);
  }
}
