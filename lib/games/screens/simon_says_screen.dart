// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/simon_says_controller.dart';
import '../widgets/color_button.dart';

class SimonSaysScreen extends StatelessWidget {
  const SimonSaysScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SimonSaysController()..startGame(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Simon Says"),
        ),
        body: SafeArea(
          child: Consumer<SimonSaysController>(
            builder: (context, controller, _) {
              if (controller.gameOver) {
                Future.delayed(Duration.zero, () {
                  _showGameOverDialog(context, controller.sequence.length - 1);
                });
              }

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (controller.isDisplayingSequence)
                    const Text(
                      "Mira la secuencia...",
                      style: TextStyle(fontSize: 24),
                    )
                  else
                    const Text(
                      "¡Tu turno!",
                      style: TextStyle(fontSize: 24),
                    ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(20),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // Ahora 3 columnas
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                      ),
                      itemCount: 6, // 6 botones
                      itemBuilder: (context, index) {
                        return ColorButton(
                          colorIndex: index,
                          isHighlighted: controller.currentHighlight == index,
                          onTap: () {
                            controller.userTap(index);
                          },
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _showGameOverDialog(BuildContext context, int score) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("¡Juego Terminado!"),
        content: Text("Lograste una secuencia de $score colores."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Cierra el dialog
              Navigator.pop(context); // Vuelve al menú
            },
            child: const Text("Salir"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Cierra el dialog
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const SimonSaysScreen()),
              );
            },
            child: const Text("Reintentar"),
          ),
        ],
      ),
    );
  }
}
