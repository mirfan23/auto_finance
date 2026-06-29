import 'package:auto_finance/domain/entities/transaction.dart';

// class TransferPair {
//   final PendingTransaction? debit;
//   final PendingTransaction? credit;

//   TransferPair({this.debit, this.credit});

//   bool get isComplete => debit != null && credit != null;
// }

class TransferPair {
  final Transaction? debit;
  final Transaction? credit;

  const TransferPair({this.debit, this.credit});

  bool get isComplete => debit != null && credit != null;
}
