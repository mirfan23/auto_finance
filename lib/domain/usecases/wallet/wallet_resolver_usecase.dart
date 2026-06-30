import 'package:auto_finance/data/dao/wallet_dao.dart';
import 'package:auto_finance/data/local/database/app_database.dart';

class WalletResolverUseCase {
  final WalletDao dao;

  WalletResolverUseCase(this.dao);

  Future<WalletTableData?> resolve(String bank) async {
    return dao.findByBank(bank);
  }
}
