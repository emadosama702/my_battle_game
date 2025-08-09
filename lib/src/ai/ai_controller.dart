import 'package:flame/components.dart';
import '../entities/enemy_ai.dart';
import '../entities/player.dart';

class AIController {
  final EnemyAI enemy;
  final Player player;

  AIController({
    required this.enemy,
    required this.player,
  });

  void update(double dt) {
    if (enemy.health <= 0) return;

    final distance = enemy.position.distanceTo(player.position);

    if (distance > 100) {
      _chasePlayer(dt);
    } else {
      _attackPlayer(dt);
    }

    // تحديث مؤقت الهجوم (Cooldown)
    if (enemy.attackTimer > 0) {
      enemy.attackTimer -= dt;
    }
  }

  void _chasePlayer(double dt) {
    final direction = (player.position - enemy.position).normalized();
    enemy.position.add(direction * enemy.speed * dt);
  }

  void _attackPlayer(double dt) {
    if (enemy.attackTimer <= 0) {
      player.takeDamage(10); // قيمة الهجوم يمكن تعديلها حسب الحاجة
      enemy.attackTimer = enemy.attackCooldown;
    }
  }
}
