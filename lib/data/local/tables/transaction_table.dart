import 'package:drift/drift.dart';

class TransactionsTable extends Table {
  TextColumn get id => text()();
  TextColumn get bank => text()();
  TextColumn get fromWallet => text().nullable()();
  TextColumn get toWallet => text().nullable()();
  IntColumn get amount => integer()();
  TextColumn get type => text()();
  TextColumn get category => text()();
  TextColumn get rawText => text()();
  DateTimeColumn get time => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
