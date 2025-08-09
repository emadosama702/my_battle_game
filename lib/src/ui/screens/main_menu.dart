import 'package:flutter/material.dart';

class MainMenuScreen extends StatelessWidget {
  final VoidCallback onStartGame;

  const MainMenuScreen({Key? key, required this.onStartGame}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[900],
      body: Center(
        child: ElevatedButton(
          onPressed: onStartGame,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            backgroundColor: Colors.deepPurpleAccent,
          ),
          child: const Text(
            'Start Game',
            style: TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }
}
