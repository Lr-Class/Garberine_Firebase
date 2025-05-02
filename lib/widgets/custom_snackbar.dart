import 'package:flutter/material.dart';

class CustomSnackbar {
  static void show({
    required BuildContext context,
    required String title,
    required String message,
    required Color backgroundColor, // Color de fondo
    required Color textColor, // Color del texto
    SnackBarBehavior behavior = SnackBarBehavior.floating, // El comportamiento del Snackbar (puede ser floating o fixed)
  }) {
    final snackBar = SnackBar(
      elevation: 6.0,
      behavior: behavior,
      backgroundColor: backgroundColor,
      content: Row(
        children: [
          Icon(
            Icons.info_outline, // Puedes personalizar el ícono si quieres
            color: textColor,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$title: $message',
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w600, // Texto en negrita para más profesionalismo
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

