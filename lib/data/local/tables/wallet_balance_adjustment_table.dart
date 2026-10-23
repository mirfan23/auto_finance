import 'package:drift/drift.dart';

class WalletBalanceAdjustmentTable extends Table {
  TextColumn get id => text()();
  TextColumn get walletId => text()();
  TextColumn get walletName => text()();
  IntColumn get previousBalance => integer()();
  IntColumn get newBalance => integer()();
  TextColumn get note => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
