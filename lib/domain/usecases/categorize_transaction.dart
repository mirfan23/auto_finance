import 'package:auto_finance/domain/entities/transaction_categories.dart';

class CategorizeTransactionUseCase {
  TransactionCategory call(String text) {
    final lower = text.toLowerCase();

    // ================= FOOD =================
    if (lower.contains("gofood") || lower.contains("mcd") || lower.contains("kfc") || lower.contains("resto")) {
      return TransactionCategory.food;
    }

    // ================= SHOPPING =================
    if (lower.contains("shopee") || lower.contains("tokopedia") || lower.contains("lazada")) {
      return TransactionCategory.shopping;
    }

    // ================= TRANSPORT =================
    if (lower.contains("gocar") || lower.contains("grab") || lower.contains("transit")) {
      return TransactionCategory.transport;
    }

    // ================= BILLS =================
    if (lower.contains("pln") || lower.contains("telkom") || lower.contains("pdam")) {
      return TransactionCategory.bills;
    }

    // ================= TRANSFER =================
    if (lower.contains("transfer") || lower.contains("db") || lower.contains("cr")) {
      return TransactionCategory.transfer;
    }

    return TransactionCategory.unknown;
  }
}
