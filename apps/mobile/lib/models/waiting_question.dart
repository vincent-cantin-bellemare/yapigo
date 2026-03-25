class WaitingQuestion {
  final String id;
  final String question;
  final List<String> options;
  final String? category;
  final int xpReward;

  const WaitingQuestion({
    required this.id,
    required this.question,
    required this.options,
    this.category,
    this.xpReward = 5,
  });
}
