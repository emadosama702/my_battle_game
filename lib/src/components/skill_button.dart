import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class SkillButton extends PositionComponent with Tappable {
  final VoidCallback onPressed;
  final double cooldown;
  double _cooldownRemaining = 0;
  bool _isCoolingDown = false;

  SkillButton({
    required this.onPressed,
    this.cooldown = 3.0,
    Vector2? position,
    Vector2? size,
  }) {
    this.position = position ?? Vector2.zero();
    this.size = size ?? Vector2.all(64);
  }

  @override
  bool onTapDown(TapDownInfo event) {
    if (!_isCoolingDown) {
      onPressed();
      _startCooldown();
    }
    return true;
  }

  void _startCooldown() {
    _isCoolingDown = true;
    _cooldownRemaining = cooldown;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_isCoolingDown) {
      _cooldownRemaining -= dt;
      if (_cooldownRemaining <= 0) {
        _isCoolingDown = false;
        _cooldownRemaining = 0;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = _isCoolingDown ? Colors.grey : Colors.blueAccent;
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.x / 2, paint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: _isCoolingDown ? _cooldownRemaining.toStringAsFixed(1) : 'GO',
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset((size.x - textPainter.width) / 2, (size.y - textPainter.height) / 2),
    );
  }
}
