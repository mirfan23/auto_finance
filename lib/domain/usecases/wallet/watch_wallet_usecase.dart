import 'package:auto_finance/data/dao/wallet_dao.dart';
import 'package:auto_finance/data/local/database/app_database.dart';

class WatchWalletUseCase {
  final WalletDao dao;

  WatchWalletUseCase(this.dao);

  Stream<List<WalletTableData>> call() {
    return dao.watchAll();
  }
}
