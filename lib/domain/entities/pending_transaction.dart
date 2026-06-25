class PendingTransaction {
  final String id;
  final String bank;
  final int amount;
  final String type;
  final DateTime time;
  final String rawText;

  bool pending;

  PendingTransaction({
    required this.id,
    required this.bank,
    required this.amount,
    required this.type,
    required this.time,
    required this.rawText,
    this.pending = true,
  });
}
