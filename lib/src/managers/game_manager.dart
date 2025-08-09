import 'package:flutter/material.dart';

enum GameState { playing, paused, gameOver }

class GameManager extends ChangeNotifier {
  GameState _state = GameState.paused;
  int _score = 0;
  int _level = 1;
  double _difficulty = 1.0;

  GameState get state => _state;
  int get score => _score;
  int get level => _level;
  double get difficulty => _difficulty;

  void startGame() {
    _score = 0;
    _level = 1;
    _difficulty = 1.0;
    _state = GameState.playing;
    notifyListeners();
  }

  void pauseGame() {
    _state = GameState.paused;
    notifyListeners();
  }

  void endGame() {
    _state = GameState.gameOver;
    notifyListeners();
  }

  void increaseScore(int amount) {
    _score += amount;
    notifyListeners();
  }

  void increaseLevel() {
    _level++;
    _difficulty += 0.2;
    notifyListeners();
  }
}
