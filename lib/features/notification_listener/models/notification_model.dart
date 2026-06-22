class TransactionModel {
  final String bank;
  final String title;
  final String text;
  final int amount;
  final DateTime time;
  final String type; // debit / credit

  TransactionModel({
    required this.bank,
    required this.title,
    required this.text,
    required this.amount,
    required this.time,
    required this.type,
  });
}
