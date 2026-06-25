import 'package:auto_finance/domain/entities/pending_transaction.dart';

class TransferPair {
  final PendingTransaction? debit;
  final PendingTransaction? credit;

  TransferPair({this.debit, this.credit});

  bool get isComplete => debit != null && credit != null;
}
