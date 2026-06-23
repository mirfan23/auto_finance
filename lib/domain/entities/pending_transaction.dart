class PendingTransaction {
  final String id;
  final String bank;
  final int amount;
  final String type; // debit / credit
  final DateTime time;
  final String rawText;

  PendingTransaction({
    required this.id,
    required this.bank,
    required this.amount,
    required this.type,
    required this.time,
    required this.rawText,
  });
}
