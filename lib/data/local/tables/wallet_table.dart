import 'package:drift/drift.dart';

class WalletTable extends Table {
  TextColumn get id => text()();

  /// Nama wallet dari user
  TextColumn get name => text()();

  /// Bank / Ewallet
  TextColumn get bank => text()();

  /// Saldo sekarang
  IntColumn get balance => integer().withDefault(const Constant(0))();

  /// Masih digunakan
  BoolColumn get active => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}
