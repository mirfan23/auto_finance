import 'package:auto_finance/domain/entities/transaction_categories.dart';
import 'package:flutter/material.dart';

class CategoryHelper {
  static IconData icon(TransactionCategory category) {
    switch (category) {
      case TransactionCategory.food:
        return Icons.restaurant_rounded;

      case TransactionCategory.shopping:
        return Icons.shopping_bag_rounded;

      case TransactionCategory.transport:
        return Icons.directions_car_rounded;

      case TransactionCategory.bills:
        return Icons.receipt_long_rounded;

      case TransactionCategory.entertainment:
        return Icons.movie_rounded;

      case TransactionCategory.health:
        return Icons.local_hospital_rounded;

      case TransactionCategory.education:
        return Icons.school_rounded;

      case TransactionCategory.salary:
        return Icons.payments_rounded;

      case TransactionCategory.investment:
        return Icons.trending_up_rounded;

      case TransactionCategory.topup:
        return Icons.account_balance_wallet_rounded;

      case TransactionCategory.transfer:
        return Icons.swap_horiz_rounded;

      case TransactionCategory.cashback:
        return Icons.savings_rounded;

      case TransactionCategory.gift:
        return Icons.card_giftcard_rounded;

      case TransactionCategory.other:
        return Icons.category_rounded;
    }
  }

  static String title(TransactionCategory category) {
    switch (category) {
      case TransactionCategory.food:
        return "Makanan";

      case TransactionCategory.shopping:
        return "Belanja";

      case TransactionCategory.transport:
        return "Transportasi";

      case TransactionCategory.bills:
        return "Tagihan";

      case TransactionCategory.entertainment:
        return "Hiburan";

      case TransactionCategory.health:
        return "Kesehatan";

      case TransactionCategory.education:
        return "Pendidikan";

      case TransactionCategory.salary:
        return "Gaji";

      case TransactionCategory.investment:
        return "Investasi";

      case TransactionCategory.topup:
        return "Isi saldo";

      case TransactionCategory.transfer:
        return "Transfer";

      case TransactionCategory.cashback:
        return "Cashback";

      case TransactionCategory.gift:
        return "Hadiah";

      case TransactionCategory.other:
        return "Lainnya";
    }
  }

  static Color color(TransactionCategory category) {
    switch (category) {
      case TransactionCategory.food:
        return Colors.orange;

      case TransactionCategory.shopping:
        return Colors.purple;

      case TransactionCategory.transport:
        return Colors.blue;

      case TransactionCategory.bills:
        return Colors.red;

      case TransactionCategory.entertainment:
        return Colors.deepPurple;

      case TransactionCategory.health:
        return Colors.pink;

      case TransactionCategory.education:
        return Colors.indigo;

      case TransactionCategory.salary:
        return Colors.blue;

      case TransactionCategory.investment:
        return Colors.deepPurple;

      case TransactionCategory.topup:
        return Colors.cyan;

      case TransactionCategory.transfer:
        return Colors.blueGrey;

      case TransactionCategory.cashback:
        return Colors.amber;

      case TransactionCategory.gift:
        return Colors.amber;

      case TransactionCategory.other:
        return Colors.grey;
    }
  }
}
