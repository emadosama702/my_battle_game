import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import '../components/health_bar.dart';
import '../core/constants/game_config.dart';
import 'player.dart';

class EnemyAI extends SpriteAnimationComponent with HasGameRef {
  late final HealthBar healthBar;
  double speed = GameConfig.enemySpeed;
  double health = GameConfig.enemyMaxHealth;
  Player? target;
  double attackCooldown = 1.0; // ثانية بين الضربات
  double attackTimer = 0;

  EnemyAI({
    required Vector2 position,
    required Vector2 size,
    required SpriteAnimation animation,
    this.target,
  }) : super(position: position, size: size, animation: animation) {
    anchor = Anchor.center;
  }

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox());
    healthBar = HealthBar(
      position: Vector2(0, -size.y / 1.5),
      maxHealth: GameConfig.enemyMaxHealth,
    );
    add(healthBar);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (target != null && health > 0) {
      _chaseTarget(dt);
      _tryAttack(dt);
    }
  }

  void _chaseTarget(double dt) {
    final direction = (target!.position - position).normalized();
    position.add(direction * speed * dt);
  }

  void _tryAttack(double dt) {
    attackTimer -= dt;
    if (attackTimer <= 0 && _isNearTarget()) {
      target!.takeDamage(GameConfig.enemyAttackDamage);
      attackTimer = attackCooldown;
    }
  }

  bool _isNearTarget() {
    return position.distanceTo(target!.position) <
        GameConfig.enemyAttackRange;
  }

  void takeDamage(double amount) {
    health -= amount;
    if (health < 0) {
      health = 0;
      removeFromParent(); // العدو مات
    }
    healthBar.updateHealth(health);
  }
}
