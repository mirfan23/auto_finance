import 'transaction.dart';

class TransactionPair {
  final Transaction? debit;
  final Transaction? credit;
  final bool isCompleted;

  TransactionPair({this.debit, this.credit, this.isCompleted = false});

  int? get amount => debit?.amount ?? credit?.amount;

  String? get fromBank => debit?.bank;
  String? get toBank => credit?.bank;
}
