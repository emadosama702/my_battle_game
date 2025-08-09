import 'package:flame/components.dart';
import 'package:flame/effects.dart';

class UltiEffect extends SpriteAnimationComponent with HasGameRef {
  final double duration;

  UltiEffect({
    required Vector2 position,
    required Vector2 size,
    required SpriteAnimation animation,
    this.duration = 1.0,
  }) : super(
          position: position,
          size: size,
          animation: animation,
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
