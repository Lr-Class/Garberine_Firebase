import 'package:flutter/material.dart';

class ColorButton extends StatelessWidget {
  final int colorIndex;
  final bool isHighlighted;
  final VoidCallback onTap;

  const ColorButton({
    super.key,
    required this.colorIndex,
    required this.isHighlighted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = [
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
    ];

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isHighlighted ? colors[colorIndex].withOpacity(0.6) : colors[colorIndex],
          borderRadius: BorderRadius.circular(16),
          boxShadow: isHighlighted
              ? [
                  BoxShadow(
                    color: Colors.black38,
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ]
              : [],
        ),
      ),
    );
  }
}

