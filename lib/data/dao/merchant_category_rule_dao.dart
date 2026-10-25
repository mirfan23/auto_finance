import 'package:auto_finance/core/helpers/merchant_name_helper.dart';
import 'package:auto_finance/data/local/database/app_database.dart';
import 'package:auto_finance/domain/entities/transaction_categories.dart';
import 'package:drift/drift.dart';

class MerchantCategoryRuleDao {
  MerchantCategoryRuleDao(this.db);

  final AppDatabase db;

  Future<TransactionCategory?> categoryForText(String rawText) async {
    final normalizedText = MerchantNameHelper.normalize(rawText);
    final rules = await db.select(db.merchantCategoryRulesTable).get();
    rules.sort((a, b) => b.merchantKey.length.compareTo(a.merchantKey.length));
    final rule = rules.where((item) {
      return item.merchantKey.isNotEmpty &&
          normalizedText.contains(item.merchantKey);
    }).firstOrNull;
    if (rule == null) return null;

    return TransactionCategory.values
        .where((category) => category.name == rule.category)
        .firstOrNull;
  }

  Future<void> saveRule({
    required String merchantName,
    required TransactionCategory category,
  }) async {
    final key = MerchantNameHelper.normalize(merchantName);
    if (key.isEmpty || category == TransactionCategory.transfer) return;

    await db
        .into(db.merchantCategoryRulesTable)
        .insertOnConflictUpdate(
          MerchantCategoryRulesTableCompanion.insert(
            merchantKey: key,
            merchantName: merchantName.trim(),
            category: category.name,
            updatedAt: DateTime.now(),
          ),
        );
  }

  Future<int> recategorizeExisting({
    required String merchantName,
    required TransactionCategory category,
  }) async {
    final key = MerchantNameHelper.normalize(merchantName);
    if (key.isEmpty || category == TransactionCategory.transfer) return 0;

    return db.transaction(() async {
      final rows = await (db.select(
        db.transactionsTable,
      )..where((table) => table.type.equals('expense'))).get();
      var count = 0;
      for (final row in rows) {
        if (!MerchantNameHelper.normalize(row.rawText).contains(key)) continue;
        if (row.category == category.name) continue;
        await (db.update(db.transactionsTable)
              ..where((table) => table.id.equals(row.id)))
            .write(TransactionsTableCompanion(category: Value(category.name)));
        count++;
      }
      return count;
    });
  }

  Future<int> applyAllRulesToExistingTransactions() async {
    final rules = await db.select(db.merchantCategoryRulesTable).get();
    if (rules.isEmpty) return 0;

    final applicableRules =
        rules
            .where(
              (rule) =>
                  rule.merchantKey.isNotEmpty &&
                  rule.category != TransactionCategory.transfer.name,
            )
            .toList()
          ..sort(
            (a, b) => b.merchantKey.length.compareTo(a.merchantKey.length),
          );
    if (applicableRules.isEmpty) return 0;

    return db.transaction(() async {
      final rows = await (db.select(
        db.transactionsTable,
      )..where((table) => table.type.equals('expense'))).get();
      var updated = 0;

      for (final row in rows) {
        final normalizedText = MerchantNameHelper.normalize(row.rawText);
        final matchingRule = applicableRules
            .where((rule) => normalizedText.contains(rule.merchantKey))
            .firstOrNull;
        if (matchingRule == null || row.category == matchingRule.category) {
          continue;
        }

        await (db.update(
          db.transactionsTable,
        )..where((table) => table.id.equals(row.id))).write(
          TransactionsTableCompanion(category: Value(matchingRule.category)),
        );
        updated++;
      }

      return updated;
    });
  }
}
