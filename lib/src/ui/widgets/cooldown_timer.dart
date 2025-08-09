import 'package:flutter/material.dart';

class CooldownTimer extends StatelessWidget {
  final double cooldown;
  final double remaining;

  const CooldownTimer({Key? key, required this.cooldown, required this.remaining}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double progress = (cooldown - remaining) / cooldown;
    if (progress > 1) progress = 1;
    if (progress < 0) progress = 0;

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[700],
            color: Colors.blueAccent,
            strokeWidth: 4,
          ),
        ),
        Text(
          remaining > 0 ? remaining.toStringAsFixed(1) : 'Ready',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
