import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../services/score_manager.dart';

class SimonSaysController extends ChangeNotifier {
  final List<int> _sequence = [];
  final List<int> _userInput = [];
  final Random _random = Random();
  bool _isDisplayingSequence = false;
  int? _currentHighlight;
  bool _gameOver = false;

  bool get isDisplayingSequence => _isDisplayingSequence;
  List<int> get sequence => _sequence;
  List<int> get userInput => _userInput;
  int? get currentHighlight => _currentHighlight;
  bool get gameOver => _gameOver;

  void startGame() {
    _sequence.clear();
    _userInput.clear();
    _gameOver = false;
    addColorToSequence();
  }

  void addColorToSequence() {
    _sequence.add(_random.nextInt(6)); // colores del 0 al 5
    _userInput.clear();
    playSequence();
  }

  Future<void> playSequence() async {
    _isDisplayingSequence = true;
    notifyListeners();

    for (var colorIndex in _sequence) {
      await Future.delayed(const Duration(milliseconds: 500));
      _currentHighlight = colorIndex;
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 500));
      _currentHighlight = null;
      notifyListeners();
    }

    _isDisplayingSequence = false;
    notifyListeners();
  }

  void userTap(int colorIndex) async {
    if (_isDisplayingSequence || _gameOver) return;

    _currentHighlight = colorIndex;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 200));
    _currentHighlight = null;
    notifyListeners();

    _userInput.add(colorIndex);

    for (int i = 0; i < _userInput.length; i++) {
      if (_userInput[i] != _sequence[i]) {
        _gameOver = true;
        notifyListeners();

        // Guardar el puntaje al perder
        int finalScore = _sequence.length - 1;
        ScoreManager().updateSimonSaysScore(finalScore);
        return;
      }
    }

    if (_userInput.length == _sequence.length) {
      Future.delayed(const Duration(milliseconds: 500), () {
        addColorToSequence();
      });
    }
  }

  void disposeController() {
    // No hay timers que limpiar
  }
}
