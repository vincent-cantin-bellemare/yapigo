class CancellationPolicy {
  CancellationPolicy._();

  static const int fullRefundHours = 48;
  static const int partialRefundHours = 24;
  static const int partialRefundPercent = 50;

  static double refundAmount(double price, DateTime eventDate) {
    final hoursLeft = eventDate.difference(DateTime.now()).inHours;
    if (hoursLeft >= fullRefundHours) return price;
    if (hoursLeft >= partialRefundHours) return price * partialRefundPercent / 100;
    return 0;
  }

  static String currentTierLabel(DateTime eventDate) {
    final hoursLeft = eventDate.difference(DateTime.now()).inHours;
    if (hoursLeft >= fullRefundHours) return 'Remboursement 100 %';
    if (hoursLeft >= partialRefundHours) return 'Remboursement 50 %';
    return 'Non remboursable';
  }

  static const List<({String title, String description, String emoji})> tiers = [
    (
      title: 'Plus de 48 h avant l\'activité',
      description: 'Remboursement intégral (100 %)',
      emoji: '✅',
    ),
    (
      title: 'Entre 24 h et 48 h avant',
      description: 'Remboursement partiel (50 %)',
      emoji: '⚠️',
    ),
    (
      title: 'Moins de 24 h avant',
      description: 'Aucun remboursement',
      emoji: '❌',
    ),
  ];

  static String get policyText =>
      'Remboursement intégral si annulé plus de ${fullRefundHours}h avant '
      'l\'activité, $partialRefundPercent% entre ${partialRefundHours}h et '
      '${fullRefundHours}h, aucun remboursement après.';
}
