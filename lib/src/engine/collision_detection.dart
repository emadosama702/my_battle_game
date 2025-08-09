import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

/// كلاس مسؤول عن منطق التصادم بين الكائنات
class CollisionDetection extends CollisionCallbacks {
  final void Function(PositionComponent other)? onCollisionStartCallback;
  final void Function(PositionComponent other)? onCollisionEndCallback;

  CollisionDetection({
    this.onCollisionStartCallback,
    this.onCollisionEndCallback,
  });

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    onCollisionStartCallback?.call(other);
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);
    onCollisionEndCallback?.call(other);
  }
}
