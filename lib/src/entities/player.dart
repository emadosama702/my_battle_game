import 'package:flame/components.dart';
import 'package:flame/input.dart';
import '../components/health_bar.dart';
import '../engine/collision_detection.dart';
import '../core/constants/game_config.dart';

class Player extends SpriteAnimationComponent
    with HasGameRef, KeyboardHandler, CollisionCallbacks {
  late final HealthBar healthBar;
  double speed = GameConfig.playerSpeed;
  double health = GameConfig.playerMaxHealth;

  Player({
    required Vector2 position,
    required Vector2 size,
    required SpriteAnimation animation,
  }) : super(position: position, size: size, animation: animation) {
    anchor = Anchor.center;
  }

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox());
    healthBar = HealthBar(
      position: Vector2(0, -size.y / 1.5),
      maxHealth: GameConfig.playerMaxHealth,
    );
    add(healthBar);

    add(
      CollisionDetection(
        onCollisionStartCallback: (other) {
          // هنا تقدر تحط منطق التصادم مع العدو أو الرصاص
        },
      ),
    );
  }

  void takeDamage(double amount) {
    health -= amount;
    if (health < 0) {
      health = 0;
      removeFromParent(); // اللاعب مات
    }
    healthBar.updateHealth(health);
  }

  void move(Vector2 delta) {
    position.add(delta * speed * gameRef.deltaTime);
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    Vector2 movement = Vector2.zero();

    if (keysPressed.contains(LogicalKeyboardKey.keyW)) {
      movement.y -= 1;
    }
    if (keysPressed.contains(LogicalKeyboardKey.keyS)) {
      movement.y += 1;
    }
    if (keysPressed.contains(LogicalKeyboardKey.keyA)) {
      movement.x -= 1;
    }
    if (keysPressed.contains(LogicalKeyboardKey.keyD)) {
      movement.x += 1;
    }

    if (movement.length > 0) {
      move(movement.normalized());
    }

    return true;
  }
}
