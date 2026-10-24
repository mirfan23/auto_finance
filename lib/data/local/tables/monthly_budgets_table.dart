import 'package:drift/drift.dart';

class MonthlyBudgetsTable extends Table {
  TextColumn get category => text()();
  IntColumn get monthlyLimit => integer()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {category};
}
