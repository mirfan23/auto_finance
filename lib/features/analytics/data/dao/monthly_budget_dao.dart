import 'package:auto_finance/data/local/database/app_database.dart';
import 'package:drift/drift.dart';

class MonthlyBudgetDao {
  MonthlyBudgetDao(this.db);

  final AppDatabase db;

  Stream<List<MonthlyBudgetsTableData>> watchAll() =>
      db.select(db.monthlyBudgetsTable).watch();

  Future<List<MonthlyBudgetsTableData>> getAll() =>
      db.select(db.monthlyBudgetsTable).get();

  Future<void> save({
    required String category,
    required int monthlyLimit,
    bool includeInWeeklyBudget = false,
  }) {
    return db
        .into(db.monthlyBudgetsTable)
        .insertOnConflictUpdate(
          MonthlyBudgetsTableCompanion.insert(
            category: category,
            monthlyLimit: monthlyLimit,
            includeInWeeklyBudget: Value(includeInWeeklyBudget),
            updatedAt: DateTime.now(),
          ),
        );
  }

  Future<void> delete(String category) {
    return (db.delete(
      db.monthlyBudgetsTable,
    )..where((budget) => budget.category.equals(category))).go();
  }
}
