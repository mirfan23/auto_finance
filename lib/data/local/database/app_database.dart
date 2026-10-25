import 'package:auto_finance/data/local/tables/notification_log_table.dart';
import 'package:auto_finance/data/local/tables/pending_transaction_table.dart';
import 'package:auto_finance/data/local/tables/transaction_table.dart';
import 'package:auto_finance/data/local/tables/wallet_table.dart';
import 'package:auto_finance/data/local/tables/wallet_balance_adjustment_table.dart';
import 'package:auto_finance/data/local/tables/monthly_budgets_table.dart';
import 'package:auto_finance/data/local/tables/merchant_category_rules_table.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    TransactionsTable,
    NotificationLogsTable,
    PendingTransactionsTable,
    WalletTable,
    WalletBalanceAdjustmentTable,
    MonthlyBudgetsTable,
    MerchantCategoryRulesTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  @override
  int get schemaVersion => 23;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      if (from < 19) {
        await m.createAll();
      } else if (from < 20) {
        await m.createTable(monthlyBudgetsTable);
      }
      if (from < 21) {
        await customStatement('''
          UPDATE transactions_table
          SET category = 'food'
          WHERE category = 'shopping'
            AND (
              LOWER(raw_text) LIKE '%groceries%'
              OR LOWER(raw_text) LIKE '%grocery%'
              OR LOWER(raw_text) LIKE '%sembako%'
              OR LOWER(raw_text) LIKE '%bahan makanan%'
              OR LOWER(raw_text) LIKE '%bahan pokok%'
            )
        ''');
      }
      if (from < 22) {
        await customStatement('''
          UPDATE transactions_table
          SET category = 'food'
          WHERE category = 'shopping'
            AND (
              LOWER(raw_text) LIKE '%nasi bebek songkam%'
              OR LOWER(raw_text) LIKE '%songkam-ho%'
            )
        ''');
      }
      if (from < 23) {
        await m.createTable(merchantCategoryRulesTable);
      }
    },
  );

  static AppDatabase? _instance;

  static AppDatabase get instance {
    _instance ??= AppDatabase();
    return _instance!;
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'auto_finance.db'));
    return NativeDatabase(file);
  });
}
