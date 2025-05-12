import 'dart:async';
import 'package:flutter/material.dart';
import '../services/score_manager.dart';

enum ReactionGameState { waiting, ready, reacted, tooSoon }

class ReactionTimeController extends ChangeNotifier {
  ReactionGameState _state = ReactionGameState.waiting;
  ReactionGameState get state => _state;

  late DateTime _startTime;
  late Timer _timer;
  Duration? _reactionTime;

  Duration? get reactionTime => _reactionTime;

  void startWaiting() {
    _state = ReactionGameState.waiting;
    _reactionTime = null;
    notifyListeners();

    int waitTime = (2000 + (3000 * (DateTime.now().millisecondsSinceEpoch % 1000) / 1000)).toInt(); // entre 2 y 5 segundos
    _timer = Timer(Duration(milliseconds: waitTime), () {
      _state = ReactionGameState.ready;
      _startTime = DateTime.now();
      notifyListeners();
    });
  }

  void tap() {
    if (_state == ReactionGameState.waiting) {
      _timer.cancel();
      _state = ReactionGameState.tooSoon;
      notifyListeners();
    } else if (_state == ReactionGameState.ready) {
      _reactionTime = DateTime.now().difference(_startTime);
      _state = ReactionGameState.reacted;
      notifyListeners();

      if (_reactionTime != null) {
        int score = (1000 - _reactionTime!.inMilliseconds).clamp(0, 1000);
        ScoreManager().updateReactionTimeScore(score);
      }
    }
  }

  void reset() {
    _timer.cancel();
    startWaiting();
  }

  void disposeController() {
    _timer.cancel();
  }
}
