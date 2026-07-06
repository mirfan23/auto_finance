import 'package:auto_finance/data/dao/wallet_dao.dart';

class UpdateWalletBalanceUseCase {
  final WalletDao dao;

  UpdateWalletBalanceUseCase(this.dao);

  Future<void> call(String id, int balance, String name) async {
    await dao.update(id: id, balance: balance, name: name);
  }
}
