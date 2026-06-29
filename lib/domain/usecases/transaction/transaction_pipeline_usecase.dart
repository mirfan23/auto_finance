// import 'package:auto_finance/domain/entities/pending_transaction.dart';
// import 'package:auto_finance/domain/usecases/parser/parser_dispatcher.dart';

// class TransactionPipelineUseCase {
//   final ParserDispatcher _dispatcher = ParserDispatcher();

//   PendingTransaction? call(Map data) {
//     final trx = _dispatcher.parse(data);
//     if (trx == null) return null;

//     return PendingTransaction(
//       id: DateTime.now().microsecondsSinceEpoch.toString(),
//       bank: trx.bank,
//       amount: trx.amount,
//       category: trx.category.name,
//       type: trx.type,
//       time: trx.time,
//       rawText: trx.rawText,
//     );
//   }
// }

import 'package:auto_finance/core/helpers/transaction_fingerprint_helper.dart';
import 'package:auto_finance/domain/entities/transaction.dart';
import 'package:auto_finance/domain/usecases/parser/parser_dispatcher.dart';

class TransactionPipelineUseCase {
  final ParserDispatcher _dispatcher = ParserDispatcher();

  Transaction? call(Map data) {
    final result = _dispatcher.parse(data);

    if (result == null) {
      return null;
    }

    final fingerprint = TransactionFingerprint.generate(
      bank: result.bank,
      amount: result.amount,
      type: result.type.name,
      rawText: result.rawText,
    );

    return Transaction(
      id: fingerprint,
      bank: result.bank,
      fromWallet: null,
      toWallet: null,
      amount: result.amount,
      type: result.type,
      category: result.category,
      rawText: result.rawText,
      time: result.time,
    );
  }
}
