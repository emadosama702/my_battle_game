import 'package:flame/components.dart';
import 'package:flame/effects.dart';

class HitEffect extends SpriteComponent with HasGameRef {
  final double duration;

  HitEffect({
    required Vector2 position,
    required Vector2 size,
    required Sprite sprite,
    this.duration = 0.2,
  }) : super(
          position: position,
          size: size,
          sprite: sprite,
        ) {
    anchor = Anchor.center;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(
      OpacityEffect.to(
        0,
        EffectController(duration: duration),
        onComplete: () => removeFromParent(),
      ),
    );
  }
}
