// models/difficulty_config.dart

class DifficultyConfig {
  final int rows;
  final int columns;
  final int maxTurns;
  final int maxTimeInSeconds;

  const DifficultyConfig({
    required this.rows,
    required this.columns,
    required this.maxTurns,
    required this.maxTimeInSeconds,
  });
}

// Puedes definir dificultades predefinidas así:

enum DifficultyLevel { easy, medium, hard }

const Map<DifficultyLevel, DifficultyConfig> difficultySettings = {
  DifficultyLevel.easy: DifficultyConfig(rows: 3, columns: 4, maxTurns: 18, maxTimeInSeconds: 90),
  DifficultyLevel.medium: DifficultyConfig(rows: 4, columns: 5, maxTurns: 24, maxTimeInSeconds: 75),
  DifficultyLevel.hard: DifficultyConfig(rows: 5, columns: 6, maxTurns: 30, maxTimeInSeconds: 60),
};
