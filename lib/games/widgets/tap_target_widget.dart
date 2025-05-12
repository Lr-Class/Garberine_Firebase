import 'package:flutter/material.dart';

class TapTargetWidget extends StatelessWidget {
  final Offset position;
  final VoidCallback onTap;
  final double size;

  const TapTargetWidget({
    super.key,
    required this.position,
    required this.onTap,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Positioned(
      left: position.dx * screenSize.width,
      top: position.dy * screenSize.height,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.purple,
            borderRadius: BorderRadius.circular(size / 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
