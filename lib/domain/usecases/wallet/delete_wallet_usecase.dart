import 'package:auto_finance/data/dao/wallet_dao.dart';

class DeleteWalletUseCase {
  final WalletDao dao;

  DeleteWalletUseCase(this.dao);

  Future<void> call(String id) async {
    await dao.delete(id);
  }
}
