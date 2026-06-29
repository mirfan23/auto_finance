import 'package:auto_finance/domain/entities/pending_transaction.dart';
import 'package:auto_finance/domain/usecases/parser/parser_dispatcher.dart';

class TransactionPipelineUseCase {
  final ParserDispatcher _dispatcher = ParserDispatcher();

  PendingTransaction? call(Map data) {
    final trx = _dispatcher.parse(data);
    if (trx == null) return null;

    return PendingTransaction(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      bank: trx.bank,
      amount: trx.amount,
      category: trx.category.name,
      type: trx.type,
      time: trx.time,
      rawText: trx.rawText,
    );
  }
}
