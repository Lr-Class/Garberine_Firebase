import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../games/screens/reaction_time_screen.dart';
import '../games/screens/simon_says_screen.dart';
import '../games/screens/tapping_game_screen.dart';
import '../games/services/score_manager.dart';


class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minijuegos'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          childAspectRatio: 1,
          children: [
            _buildMenuButton(
              context,
              title: "Reaction Time",
              icon: Icons.timer,
              screen: const ReactionTimeScreen(),
            ),
            _buildMenuButton(
              context,
              title: "Simon Says",
              icon: Icons.memory,
              screen: const SimonSaysScreen(),
            ),
            _buildMenuButton(
              context,
              title: "Tapping Game",
              icon: Icons.touch_app,
              screen: const TappingGameScreen(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final scoreManager = Provider.of<ScoreManager>(context, listen: false);

          // Primero cargar los datos actualizados
          await scoreManager.loadScoresFromFirebase();

          // Luego mostrar el AlertDialog
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Puntajes de los Juegos'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Reaction Time: ${scoreManager.reactionTimeScore}'),
                    Text('Simon Says: ${scoreManager.simonSaysScore}'),
                    Text('Tapping Game: ${scoreManager.tappingGameScore}'),
                    const Divider(),
                    Text(
                      'Puntaje Total: ${scoreManager.totalScore}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cerrar'),
                  ),
                ],
              );
            },
          );
        },
        label: const Text('Ver Puntaje Total'),
        icon: const Icon(Icons.star),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context,
      {required String title,
      required IconData icon,
      required Widget screen}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => screen),
        );
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 50),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}