import '../entities/transaction.dart';
import '../entities/transaction_pair.dart';

class TransferPairingUseCase {
  final List<Transaction> _buffer = [];

  List<TransactionPair> _pairs = [];

  List<TransactionPair> get pairs => _pairs;

  void add(Transaction trx) {
    _buffer.add(trx);
    _tryPair();
  }

  void _tryPair() {
    if (_buffer.length < 2) return;

    for (int i = 0; i < _buffer.length; i++) {
      for (int j = i + 1; j < _buffer.length; j++) {
        final a = _buffer[i];
        final b = _buffer[j];

        if (_match(a, b)) {
          _pairs.insert(0, TransactionPair(debit: a, credit: b, isCompleted: true));

          _buffer.removeAt(j);
          _buffer.removeAt(i);
          return;
        }
      }
    }
  }

  bool _match(Transaction a, Transaction b) {
    final diff = a.time.difference(b.time).abs().inSeconds;

    return a.amount == b.amount && a.type != b.type && diff <= 60;
  }
}
