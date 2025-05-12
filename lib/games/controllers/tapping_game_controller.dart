import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../services/score_manager.dart';

class TappingGameController extends ChangeNotifier {
  final Random _random = Random();
  Offset _targetPosition = Offset.zero;
  bool _isTargetVisible = false;
  late Timer _timer;
  int _score = 0;
  int _lives = 3;
  bool _isGameOver = false;
  double _targetSize = 60; // Tamaño inicial
  bool _flashRed = false;
  bool _flashGreen = false;

  Offset get targetPosition => _targetPosition;
  bool get isTargetVisible => _isTargetVisible;
  int get score => _score;
  int get lives => _lives;
  bool get isGameOver => _isGameOver;
  double get targetSize => _targetSize;
  bool get flashRed => _flashRed;
  bool get flashGreen => _flashGreen;

  void startGame() {
    _score = 0;
    _lives = 3;
    _isGameOver = false;
    _targetSize = 60;
    _flashRed = false;
    _flashGreen = false;
    _spawnTarget();
    _startDifficultyTimer();
  }

  void _spawnTarget() {
    if (_isGameOver) return;

    _targetPosition = Offset(
      _random.nextDouble() * 0.8 + 0.1,
      _random.nextDouble() * 0.8 + 0.1,
    );
    _isTargetVisible = true;
    notifyListeners();

    _timer = Timer(const Duration(milliseconds: 2000), () {
      if (!_isGameOver) {
        _missedTarget();
      }
    });
  }

  void tapTarget() {
    if (_isTargetVisible && !_isGameOver) {
      _score++;
      _isTargetVisible = false;
      _timer.cancel();
      notifyListeners();
      Future.delayed(const Duration(milliseconds: 500), _spawnTarget);
    }
  }

  void tapOutside() {
    if (!_isGameOver) {
      _loseLife();
    }
  }

  void _missedTarget() {
    if (!_isGameOver) {
      _isTargetVisible = false;
      _loseLife();
    }
  }

  void _loseLife() {
    _lives--;
    _flashRed = true;
    notifyListeners();
    Future.delayed(const Duration(milliseconds: 300), () {
      _flashRed = false;
      notifyListeners();
    });

    if (_lives <= 0) {
      _endGame();
    } else {
      Future.delayed(const Duration(milliseconds: 500), _spawnTarget);
    }
  }

  void _startDifficultyTimer() {
    Timer.periodic(const Duration(seconds: 20), (timer) {
      if (_isGameOver) {
        timer.cancel();
      } else {
        if (_targetSize > 30) {
          _targetSize -= 5;
          _flashGreen = true;
          notifyListeners();
          Future.delayed(const Duration(milliseconds: 300), () {
            _flashGreen = false;
            notifyListeners();
          });
        }
      }
    });
  }

  void _endGame() {
    _isGameOver = true;
    _isTargetVisible = false;
    _timer.cancel();
    notifyListeners();

    // Guardar el puntaje cuando termina el juego
    ScoreManager().updateTappingGameScore(_score);
  }

  void disposeController() {
    if (_timer.isActive) {
      _timer.cancel();
    }
  }
}
