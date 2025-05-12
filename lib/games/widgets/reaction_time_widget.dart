import 'package:flutter/material.dart';
import '../controllers/reaction_time_controller.dart';

class ReactionTimeWidget extends StatelessWidget {
  final ReactionTimeController controller;

  const ReactionTimeWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    String text;

    bool showBackButton = false;

    switch (controller.state) {
      case ReactionGameState.waiting:
        backgroundColor = Colors.red;
        text = "Espera que la pantalla cambie...";
        break;
      case ReactionGameState.ready:
        backgroundColor = Colors.green;
        text = "¡Toca ahora!";
        break;
      case ReactionGameState.reacted:
        backgroundColor = Colors.blue;
        text = "¡Tiempo: ${controller.reactionTime?.inMilliseconds} ms!\n\nToca para volver a empezar.";
        showBackButton = true;
        break;
      case ReactionGameState.tooSoon:
        backgroundColor = Colors.orange;
        text = "¡Muy pronto!\n\nToca para volver a intentar.";
        showBackButton = true;
        break;
    }

    return Stack(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          color: backgroundColor,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (controller.state == ReactionGameState.reacted || controller.state == ReactionGameState.tooSoon) {
                controller.reset();
              } else {
                controller.tap();
              }
            },
            child: Center(
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        if (showBackButton)
          Positioned(
            top: 40,
            left: 16,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context); // Regresa sin apilar pantallas
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('Volver'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black.withOpacity(0.5),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
