import 'package:auto_finance/data/local/database/app_database.dart';
import 'package:drift/drift.dart';

class WalletDao {
  final AppDatabase db;

  WalletDao(this.db);

  Stream<List<WalletTableData>> watchAll() {
    return db.select(db.walletTable).watch();
  }

  Future<List<WalletTableData>> getAll() {
    return db.select(db.walletTable).get();
  }

  Future<void> insert({required String id, required String name, required String bank}) async {
    await db.into(db.walletTable).insert(WalletTableCompanion.insert(id: id, name: name, bank: bank));
  }

  Future<WalletTableData?> findByBank(String bank) async {
    final result = await (db.select(db.walletTable)..where((t) => t.bank.equals(bank))).getSingleOrNull();

    return result;
  }

  Future<void> updateBalance(String id, int balance) async {
    await (db.update(
      db.walletTable,
    )..where((t) => t.id.equals(id))).write(WalletTableCompanion(balance: Value(balance)));
  }

  Future<void> delete(String id) async {
    await (db.delete(db.walletTable)..where((t) => t.id.equals(id))).go();
  }

  Future<void> addBalance(String id, int amount) async {
    final wallet = await (db.select(db.walletTable)..where((t) => t.id.equals(id))).getSingle();

    await updateBalance(id, wallet.balance + amount);
  }

  Future<void> subtractBalance(String id, int amount) async {
    final wallet = await (db.select(db.walletTable)..where((t) => t.id.equals(id))).getSingle();

    await updateBalance(id, wallet.balance - amount);
  }
}
