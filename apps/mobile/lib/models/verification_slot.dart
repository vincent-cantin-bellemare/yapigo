class VerificationSlot {
  final String id;
  final DateTime date;
  final String timeSlot;
  final bool isAvailable;

  const VerificationSlot({
    required this.id,
    required this.date,
    required this.timeSlot,
    this.isAvailable = true,
  });
}

enum VerificationStatus {
  notStarted,
  scheduled,
  verified,
  missed,
}
