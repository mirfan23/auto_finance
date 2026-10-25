import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:auto_finance/domain/entities/transaction.dart';
import 'package:auto_finance/domain/usecases/parser/parser_dispatcher.dart';

class TransactionPipelineUseCase {
  final ParserDispatcher _dispatcher = ParserDispatcher();

  Transaction? call(Map data) {
    print("🔵 PIPELINE START");
    print("🔵 DATA => $data");

    final result = _dispatcher.parse(data);

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
