// models/memory_card_model.dart

class MemoryCard {
  final int id;
  final String content; // Puede ser un emoji, un asset, o un texto
  bool isFlipped;
  bool isMatched;

  MemoryCard({
    required this.id,
    required this.content,
    this.isFlipped = false,
    this.isMatched = false,
  });

  MemoryCard copyWith({
    bool? isFlipped,
    bool? isMatched,
  }) {
    return MemoryCard(
      id: id,
      content: content,
      isFlipped: isFlipped ?? this.isFlipped,
      isMatched: isMatched ?? this.isMatched,
    );
  }
}
