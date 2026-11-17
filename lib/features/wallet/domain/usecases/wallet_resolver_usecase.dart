import 'package:auto_finance/features/wallet/data/dao/wallet_dao.dart';
import 'package:auto_finance/data/local/database/app_database.dart';

class WalletResolverUseCase {
  final WalletDao dao;

  WalletResolverUseCase(this.dao);

  Future<WalletTableData?> resolve(String bank) async {
    return dao.findByBank(bank);
  }

  Future<WalletTableData?> resolveById(String id) async {
    final wallet = await dao.getById(id);
    return wallet?.active == true ? wallet : null;
  }
}
