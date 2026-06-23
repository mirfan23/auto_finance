import 'package:auto_finance/domain/entities/pending_transaction.dart';
import 'package:auto_finance/domain/usecases/parser/parser_dispatcher.dart';
import 'package:auto_finance/domain/usecases/transfer_pairing_usecase.dart';

import '../entities/transaction.dart';

class TransactionPipelineUseCase {
  final ParserDispatcher _dispatcher = ParserDispatcher();

  Transaction? call(Map data) {
    return _dispatcher.parse(data);
  }
}

// class TransactionPipelineUseCase {
//   final ParserDispatcher _dispatcher = ParserDispatcher();

//   final TransferPairingUseCase _pairing = TransferPairingUseCase();

//   dynamic call(Map data) {
//     final trx = _dispatcher.parse(data);

//     if (trx == null) return null;

//     final pending = PendingTransaction(
//       id: DateTime.now().microsecondsSinceEpoch.toString(),
//       bank: trx.bank,
//       amount: trx.amount,
//       type: trx.type,
//       time: trx.time,
//       rawText: trx.rawText,
//     );

//     final paired = _pairing.process(pending);

//     if (paired.isNotEmpty) {
//       return paired.first; // sudah jadi 1 transfer utuh
//     }

//     return null; // masih pending
//   }
// }
