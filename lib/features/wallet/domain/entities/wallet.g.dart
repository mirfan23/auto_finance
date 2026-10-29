// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Wallet _$WalletFromJson(Map<String, dynamic> json) => _Wallet(
  id: json['id'] as String,
  name: json['name'] as String,
  bank: json['bank'] as String,
  balance: (json['balance'] as num?)?.toInt() ?? 0,
  active: json['active'] as bool? ?? true,
);

Map<String, dynamic> _$WalletToJson(_Wallet instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'bank': instance.bank,
  'balance': instance.balance,
  'active': instance.active,
};
