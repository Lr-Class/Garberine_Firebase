import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRPopup extends StatelessWidget {
  final String userId;

  const QRPopup({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tu código QR'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          QrImageView(
            data: userId,
            version: QrVersions.auto,
            size: 200.0,
          ),
          const SizedBox(height: 16),
          const Text(
            'Este es tu QR. Muéstralo para que otros te escaneen.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
      actions: [
        TextButton(
          child: const Text('Cerrar'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
