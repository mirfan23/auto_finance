import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:auto_finance/features/transaction/domain/entities/transaction.dart';
import 'package:auto_finance/features/transaction/domain/usecases/parser/parser_dispatcher.dart';
import 'package:auto_finance/features/local_ai/data/services/local_ai_transaction_parser.dart';

class TransactionPipelineUseCase {
  final ParserDispatcher _dispatcher = ParserDispatcher();
  final LocalAiTransactionParser _localAiParser = LocalAiTransactionParser();

  Future<Transaction?> call(Map data) async {
    print("🔵 PIPELINE START");
    print("🔵 DATA => $data");

    var result = _dispatcher.parse(data);
    final packageName = (data['packageName'] ?? '').toString();
    if (result == null &&
        !_dispatcher.recognizesPackage(packageName) &&
        (data['walletBank'] ?? '').toString().isNotEmpty) {
      result = await _localAiParser.parse(data);
    }

    if (result == null) {
      print("❌ PIPELINE RESULT NULL");
      return null;
    }

    print(
      "✅ PARSER SUCCESS => "
      "${result.bank} | "
      "${result.amount} | "
      "${result.type} | "
      "${result.category}",
    );

    final rawNotificationId = data['id'];
    final notificationIdentity = rawNotificationId == null
        ? sha256
              .convert(
                utf8.encode(
                  '${data['packageName']}|${data['timestamp']}|${data['title']}|${data['text']}',
                ),
              )
              .toString()
        : rawNotificationId.toString();
    final transaction = Transaction(
      id: 'notification_$notificationIdentity',
      bank: result.bank,
      fromWallet: null,
      toWallet: null,
      amount: result.amount,
      type: result.type,
      category: result.category,
      rawText: result.rawText,
      time: result.time,
    );

    print(
      "✅ TRANSACTION CREATED => "
      "${transaction.id} | "
      "${transaction.amount}",
    );

    return transaction;
  }
}
