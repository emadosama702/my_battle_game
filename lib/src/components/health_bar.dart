import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class HealthBar extends PositionComponent {
  final double maxHealth;
  double currentHealth;
  final double barWidth;
  final double barHeight;
  final Color backgroundColor;
  final Color healthColor;

  HealthBar({
    required this.maxHealth,
    required this.currentHealth,
    this.barWidth = 100,
    this.barHeight = 10,
    this.backgroundColor = Colors.redAccent,
    this.healthColor = Colors.greenAccent,
    Vector2? position,
  }) {
    this.position = position ?? Vector2.zero();
    size = Vector2(barWidth, barHeight);
  }

  void updateHealth(double newHealth) {
    currentHealth = newHealth.clamp(0, maxHealth);
  }

  @override
  void render(Canvas canvas) {
    // الخلفية
    final bgPaint = Paint()..color = backgroundColor;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, barWidth, barHeight),
      bgPaint,
    );

    // نسبة الصحة
    final healthRatio = currentHealth / maxHealth;
    final healthPaint = Paint()..color = healthColor;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, barWidth * healthRatio, barHeight),
      healthPaint,
    );

    // الإطار
    final borderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, barWidth, barHeight),
      borderPaint,
    );
  }
}
