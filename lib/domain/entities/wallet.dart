import 'package:freezed_annotation/freezed_annotation.dart';

part 'wallet.freezed.dart';
part 'wallet.g.dart';

@freezed
abstract class Wallet with _$Wallet {
  const factory Wallet({
    required String id,

    /// Nama yang diberikan user
    required String name,

    /// Nama bank / e-wallet
    required String bank,

    /// Current balance
    @Default(0) int balance,

    /// Wallet masih aktif
    @Default(true) bool active,
  }) = _Wallet;

  factory Wallet.fromJson(Map<String, dynamic> json) => _$WalletFromJson(json);
}
