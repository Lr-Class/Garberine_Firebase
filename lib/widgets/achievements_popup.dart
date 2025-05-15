import 'package:flutter/material.dart';

class AchievementsPopup extends StatelessWidget {
  final Map<String, bool> achievements;

  const AchievementsPopup({Key? key, required this.achievements}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final achievementLabels = {
      'firstScan': 'Primer escaneo',
      'fiveScans': '5 escaneos',
      'tenScans': '10 escaneos',
      'twentyScans': '20 escaneos',
    };

    return AlertDialog(
      title: const Text('Logros'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: achievementLabels.entries.map((entry) {
          final isAchieved = achievements[entry.key] ?? false;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(entry.value),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: isAchieved ? 1 : 0,
                backgroundColor: Colors.grey[300],
                color: isAchieved ? Colors.green : Colors.grey,
              ),
              const SizedBox(height: 12),
            ],
          );
        }).toList(),
      ),
      actions: [
        TextButton(
          child: const Text('Cerrar'),
          onPressed: () => Navigator.of(context).pop(),
        )
      ],
    );
  }
}
