import 'package:flutter/material.dart';

class RankProgressCircle extends StatelessWidget {
  final int qrScans;
  final int maxScansForNextRank;
  final String currentRank;

  const RankProgressCircle({
    Key? key,
    required this.qrScans,
    required this.maxScansForNextRank,
    required this.currentRank,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double progress = (qrScans / maxScansForNextRank).clamp(0.0, 1.0);

    return Column(
      children: [
        Text(
          currentRank,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 120,
              height: 120,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 10,
                backgroundColor: Colors.grey[300],
                color: Colors.blueAccent,
              ),
            ),
            Text(
              "$qrScans / $maxScansForNextRank",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }
}
