import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clasificación'),
        backgroundColor: Colors.blueAccent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('leaderboard')
            .orderBy('score', descending: true) // Ordenar por puntaje descendente
            .limit(10) // Limitar a los 10 mejores
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar el ranking.'));
          }

          final leaderboardData = snapshot.data?.docs ?? [];

          return ListView.builder(
            itemCount: leaderboardData.length,
            itemBuilder: (ctx, index) {
              final leaderboardItem = leaderboardData[index];
              return ListTile(
                title: Text(leaderboardItem['username']),
                trailing: Text('${leaderboardItem['score']} puntos'),
              );
            },
          );
        },
      ),
    );
  }
}
