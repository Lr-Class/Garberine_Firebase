import 'package:flutter/material.dart';
import '../controllers/tapping_game_controller.dart';
import 'package:provider/provider.dart';
import '../widgets/tap_target_widget.dart';

class TappingGameScreen extends StatelessWidget {
  const TappingGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TappingGameController()..startGame(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Tapping Game"),
        ),
        body: SafeArea(
          child: Consumer<TappingGameController>(
            builder: (context, controller, _) {
              if (controller.isGameOver) {
                Future.delayed(Duration.zero, () {
                  showDialog(
                    context: context,
                    useRootNavigator: false,
                    barrierDismissible: false,
                    builder: (_) => AlertDialog(
                      title: const Text('¡Juego Terminado!'),
                      content: Text('Puntaje: ${controller.score}'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            controller.startGame();
                          },
                          child: const Text('Volver a intentar'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                          },
                          child: const Text('Salir'),
                        ),
                      ],
                    ),
                  );
                });
              }

              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (!controller.isTargetVisible && !controller.isGameOver) {
                    controller.tapOutside();
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  color: controller.flashRed
                      ? Colors.red.withOpacity(0.3)
                      : controller.flashGreen
                          ? Colors.green.withOpacity(0.3)
                          : Colors.transparent,
                  child: Stack(
                    children: [
                      Positioned(
                        top: 20,
                        left: 20,
                        child: Text(
                          "Puntos: ${controller.score}   Vidas: ${controller.lives}",
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                      if (controller.isTargetVisible)
                        TapTargetWidget(
                          position: controller.targetPosition,
                          size: controller.targetSize,
                          onTap: controller.tapTarget,
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
