// lib/src/ui/screens/game_screen.dart
import 'dart:math';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../engine/game.dart';
import 'package:vector_math/vector_math_64.dart' show Vector2;

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = MyBattleGame();

    // Prevent device rotation for a consistent gameplay area (اختياري)
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    return Scaffold(
      body: GameWidget(
        game: game,
        overlayBuilderMap: {
          'hud': (context, gameRef) => HudOverlay(game: gameRef as MyBattleGame),
        },
        initialActiveOverlays: const ['hud'],
      ),
    );
  }
}

/// HUD overlay: joystick (left) + skill buttons (right) + HP & Charge bars (top)
class HudOverlay extends StatefulWidget {
  final MyBattleGame game;
  const HudOverlay({required this.game, super.key});

  @override
  State<HudOverlay> createState() => _HudOverlayState();
}

class _HudOverlayState extends State<HudOverlay> {
  // Joystick state
  Offset joystickDrag = Offset.zero;
  bool joystickActive = false;
  final double joystickRadius = 50;

  // Cooldowns / state placeholders (the game should manage real values)
  Map<int, double> cooldowns = {1: 0, 2: 0, 3: 0, 0: 0}; // 0 = basic
  @override
  void initState() {
    super.initState();
    // Optionally tie into game's stream or periodic timer to update HP/charge/cooldowns
  }

  void onJoystickStart(DragStartDetails d) {
    setState(() {
      joystickActive = true;
      joystickDrag = d.localPosition;
    });
  }

  void onJoystickUpdate(DragUpdateDetails d) {
    // Compute direction vector in range [-1,1]
    final local = d.localPosition;
    final center = Offset(0, 0); // we will reinterpret relative coords
    // For simplicity, we use the drag delta from start position
    setState(() {
      joystickDrag = local;
    });

    // Map joystickDrag to a Vector2 movement direction for the game
    // Normalize by joystickRadius (clamp)
    final dx = joystickDrag.dx.clamp(-joystickRadius, joystickRadius) / joystickRadius;
    final dy = joystickDrag.dy.clamp(-joystickRadius, joystickRadius) / joystickRadius;
    final moveVec = Vector2(dx.toDouble(), dy.toDouble());

    // Notify game (implement movePlayer in your MyBattleGame)
    widget.game.movePlayer(moveVec);
  }

  void onJoystickEnd(DragEndDetails d) {
    setState(() {
      joystickActive = false;
      joystickDrag = Offset.zero;
    });
    widget.game.movePlayer(Vector2.zero()); // stop movement
  }

  // Buttons
  void onBasicPressed() {
    widget.game.basicAttack();
    // you can start a local cooldown UI while game enforces real cooldown
  }

  void onSkillPressed(int idx) {
    widget.game.useSkill(idx); // idx: 1,2,3 or 0 for basic
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // Retrieve some values from the game if implemented, otherwise show defaults
    final playerHp = widget.game.getPlayerHp?.call() ?? 1.0; // 0..1
    final enemyHp = widget.game.getEnemyHp?.call() ?? 1.0; // 0..1
    final charge = widget.game.getCharge?.call() ?? 0.0; // 0..1

    return SafeArea(
      child: Stack(
        children: [
          // Top bars: Enemy HP (left) and Player HP (right) + Charge bar center-bottom of top
          Positioned(
            top: 12,
            left: 16,
            right: 16,
            child: Column(
              children: [
                // Enemy HP
                _hpBar(label: 'ENEMY', value: enemyHp, color: Colors.red),
                const SizedBox(height: 6),
                // Charge bar (yellow)
                _chargeBar(value: charge),
                const SizedBox(height: 6),
                // Player HP
                _hpBar(label: 'YOU', value: playerHp, color: Colors.green),
              ],
            ),
          ),

          // Left: Joystick area
          Positioned(
            left: 12,
            bottom: 24,
            child: GestureDetector(
              onPanStart: onJoystickStart,
              onPanUpdate: onJoystickUpdate,
              onPanEnd: onJoystickEnd,
              child: SizedBox(
                width: joystickRadius * 2.5,
                height: joystickRadius * 2.5,
                child: CustomPaint(
                  painter: _JoystickPainter(
                    drag: joystickDrag,
                    active: joystickActive,
                    radius: joystickRadius,
                  ),
                ),
              ),
            ),
          ),

          // Right: Skill buttons + Basic
          Positioned(
            right: 12,
            bottom: 24,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _skillButton(icon: 'S1', onTap: () => onSkillPressed(1), cooldown: cooldowns[1]!),
                const SizedBox(height: 12),
                _skillButton(icon: 'S2', onTap: () => onSkillPressed(2), cooldown: cooldowns[2]!),
                const SizedBox(height: 12),
                _skillButton(icon: 'S3', onTap: () => onSkillPressed(3), cooldown: cooldowns[3]!),
                const SizedBox(height: 18),
                // Basic attack - bigger
                _basicButton(onTap: onBasicPressed),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _hpBar({required String label, required double value, required Color color}) {
    final clamped = value.clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 4),
        Container(
          height: 10,
          decoration: BoxDecoration(
            color: Colors.white12,
            borderRadius: BorderRadius.circular(6),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: clamped,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _chargeBar({required double value}) {
    final clamped = value.clamp(0.0, 1.0);
    return Column(
      children: [
        Text('CHARGE', style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 4),
        Container(
          height: 8,
          width: 240,
          decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(6)),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: clamped,
            child: Container(
              decoration: BoxDecoration(color: Colors.yellowAccent, borderRadius: BorderRadius.circular(6)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _skillButton({required String icon, required VoidCallback onTap, required double cooldown}) {
    final cd = cooldown.clamp(0.0, 1.0);
    return GestureDetector(
      onTap: cd == 0 ? onTap : null,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: cd == 0 ? Colors.blueGrey[800] : Colors.blueGrey[700],
              shape: BoxShape.circle,
              boxShadow: const [BoxShadow(blurRadius: 6, color: Colors.black45, offset: Offset(0, 2))],
            ),
            alignment: Alignment.center,
            child: Text(icon, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          if (cd > 0)
            SizedBox(
              width: 64,
              height: 64,
              child: CircularProgressIndicator(value: cd, color: Colors.black38, strokeWidth: 6),
            ),
        ],
      ),
    );
  }

  Widget _basicButton({required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.orange[700],
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(blurRadius: 8, color: Colors.black45, offset: Offset(0, 4))],
        ),
        alignment: Alignment.center,
        child: const Text('BASIC', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

/// Simple joystick painter: shows base circle and knob relative to center
class _JoystickPainter extends CustomPainter {
  final Offset drag;
  final bool active;
  final double radius;
  _JoystickPainter({required this.drag, required this.active, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(radius * 1.25, radius * 1.25);
    final basePaint = Paint()..color = Colors.white10;
    final knobPaint = Paint()..color = Colors.white24;

    // base
    canvas.drawCircle(center, radius, basePaint);

    // knob offset
    final knobOffset = center + drag;
    // limit knob distance to radius
    final dx = (knobOffset.dx - center.dx);
    final dy = (knobOffset.dy - center.dy);
    final dist = sqrt(dx * dx + dy * dy);
    final maxDist = radius - 8;
    final limited = dist > maxDist ? Offset(dx / dist * maxDist, dy / dist * maxDist) : Offset(dx, dy);
    final knobPos = center + limited;

    // knob
    canvas.drawCircle(knobPos, radius * 0.45, knobPaint);
  }

  @override
  bool shouldRepaint(covariant _JoystickPainter oldDelegate) {
    return oldDelegate.drag != drag || oldDelegate.active != active;
  }
}
