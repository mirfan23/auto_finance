import 'package:drift/drift.dart';

class MonthlyBudgetsTable extends Table {
  TextColumn get category => text()();
  IntColumn get monthlyLimit => integer()();
  BoolColumn get includeInWeeklyBudget =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {category};
}
