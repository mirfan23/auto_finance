import 'package:auto_finance/domain/entities/transaction.dart';
import 'package:auto_finance/domain/usecases/parser/parser_dispatcher.dart';

class TransactionPipelineUseCase {
  final ParserDispatcher _dispatcher = ParserDispatcher();

  Transaction? call(Map data) {
    final result = _dispatcher.parse(data);

    if (result == null) {
      return null;
    }

    return Transaction(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
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
