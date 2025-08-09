import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import '../core/constants/game_config.dart';
import 'enemy_ai.dart';

class Projectile extends SpriteComponent with HasGameRef {
  final Vector2 direction;
  final double speed;
  final double damage;
  double lifetime = GameConfig.projectileLifetime;

  Projectile({
    required Vector2 position,
    required Vector2 size,
    required Sprite sprite,
    required this.direction,
    this.speed = GameConfig.projectileSpeed,
    this.damage = GameConfig.projectileDamage,
  }) : super(
          position: position,
          size: size,
          sprite: sprite,
        ) {
    anchor = Anchor.center;
  }

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);

    position.add(direction.normalized() * speed * dt);

    lifetime -= dt;
    if (lifetime <= 0) {
      removeFromParent();
    }
  }

  void onHitEnemy(EnemyAI enemy) {
    enemy.takeDamage(damage);
    removeFromParent();
  }
}
