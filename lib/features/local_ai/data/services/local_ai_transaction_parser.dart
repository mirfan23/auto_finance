import 'dart:convert';

import 'package:auto_finance/features/transaction/domain/entities/parser_result.dart';
import 'package:auto_finance/features/transaction/domain/entities/transaction_categories.dart';
import 'package:auto_finance/features/transaction/domain/entities/transaction_type.dart';
import 'package:auto_finance/features/local_ai/data/services/local_ai_service.dart';

class LocalAiTransactionParser {
  static final _explicitRupiah = RegExp(
    r'(?:Rp\.?|IDR)\s*([0-9][0-9.,]*)',
    caseSensitive: false,
  );

  Future<ParserResult?> parse(Map data) async {
    final walletBank = (data['walletBank'] ?? '').toString().trim();
    if (walletBank.isEmpty) return null;

    final title = (data['title'] ?? '').toString().trim();
    final text = (data['text'] ?? '').toString().trim();
    final rawText = [title, text].where((part) => part.isNotEmpty).join('\n');
    if (rawText.isEmpty) return null;

    final explicitAmounts = _explicitRupiah
        .allMatches(rawText)
        .map(
          (match) =>
              int.tryParse(match.group(1)!.replaceAll(RegExp(r'[^0-9]'), '')),
        )
        .whereType<int>()
        .where((amount) => amount > 0)
        .toSet();
    if (explicitAmounts.isEmpty) return null;

    final response = await LocalAiService.parseNotification(
      sourceApp: (data['sourceAppLabel'] ?? data['packageName'] ?? '')
          .toString(),
      title: title,
      text: text,
    );
    final result = _decodeObject(response);
    if (result == null || result['is_transaction'] != true) return null;

    final amountValue = result['amount'];
    final amount = amountValue is num
        ? amountValue.toInt()
        : int.tryParse(amountValue?.toString() ?? '');
    // A model can choose which explicit amount is the transaction amount,
    // but cannot create a value that was absent from the notification.
    if (amount == null || amount <= 0 || !explicitAmounts.contains(amount)) {
      return null;
    }

    final typeName = result['type']?.toString();
    final type = switch (typeName) {
      'income' => TransactionType.income,
      'expense' => TransactionType.expense,
      'transfer' => TransactionType.transfer,
      _ => null,
    };
    if (type == null) return null;

    final categoryName = result['category']?.toString();
    final matchingCategories = TransactionCategory.values.where(
      (value) => value.name == categoryName,
    );
    final category = matchingCategories.isEmpty
        ? TransactionCategory.other
        : matchingCategories.first;
    final timestamp = data['timestamp'];
    if (timestamp is! num) return null;

    return ParserResult(
      bank: walletBank,
      amount: amount,
      type: type,
      category: category,
      rawText: rawText,
      time: DateTime.fromMillisecondsSinceEpoch(timestamp.toInt()),
    );
  }

  Map<String, dynamic>? _decodeObject(String output) {
    final start = output.indexOf('{');
    final end = output.lastIndexOf('}');
    if (start < 0 || end <= start) return null;
    try {
      return Map<String, dynamic>.from(
        jsonDecode(output.substring(start, end + 1)) as Map,
      );
    } on FormatException {
      return null;
    } on TypeError {
      return null;
    }
  }
}
