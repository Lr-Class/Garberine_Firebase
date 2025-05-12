import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ScoreManager with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  int reactionTimeScore = 0;
  int simonSaysScore = 0;
  int tappingGameScore = 0;

  int get totalScore => reactionTimeScore + simonSaysScore + tappingGameScore;

  Future<void> updateReactionTimeScore(int score) async {
    final user = _auth.currentUser;
    if (user != null) {
      reactionTimeScore = score;
      await _firestore.collection('users').doc(user.uid).update({
        'reactionTimeScore': reactionTimeScore,
      });
      await _updateTotalScore();
      notifyListeners();
    }
  }

  Future<void> updateSimonSaysScore(int score) async {
    final user = _auth.currentUser;
    if (user != null) {
      simonSaysScore = score;
      await _firestore.collection('users').doc(user.uid).update({
        'simonSaysScore': simonSaysScore,
      });
      await _updateTotalScore();
      notifyListeners();
    }
  }

  Future<void> updateTappingGameScore(int score) async {
    final user = _auth.currentUser;
    if (user != null) {
      tappingGameScore = score;
      await _firestore.collection('users').doc(user.uid).update({
        'tappingGameScore': tappingGameScore,
      });
      await _updateTotalScore();
      notifyListeners();
    }
  }

  Future<void> _updateTotalScore() async {
    final user = _auth.currentUser;
    if (user != null) {
      final userDoc = _firestore.collection('users').doc(user.uid);
      final snapshot = await userDoc.get();

      // Asegúrate de cargar los valores actuales de la base de datos
      final data = snapshot.data();
      final reactionScore = data?['reactionTimeScore'] ?? 0;
      final simonScore = data?['simonSaysScore'] ?? 0;
      final tappingScore = data?['tappingGameScore'] ?? 0;

      final updatedTotal = reactionScore + simonScore + tappingScore;

      await userDoc.update({
        'totalScore': updatedTotal,
      });
    }
  }

  Future<void> loadScoresFromFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final snapshot = await userDoc.get();
      final data = snapshot.data();

      if (data != null) {
        reactionTimeScore = data['reactionTimeScore'] ?? 0;
        simonSaysScore = data['simonSaysScore'] ?? 0;
        tappingGameScore = data['tappingGameScore'] ?? 0;
        notifyListeners();
      }
    }
  }
}
