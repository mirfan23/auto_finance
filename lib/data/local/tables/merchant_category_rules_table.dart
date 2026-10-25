import 'package:drift/drift.dart';

class MerchantCategoryRulesTable extends Table {
  TextColumn get merchantKey => text()();
  TextColumn get merchantName => text()();
  TextColumn get category => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {merchantKey};
}
