// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Transaction _$TransactionFromJson(Map<String, dynamic> json) => _Transaction(
  id: json['id'] as String,
  bank: json['bank'] as String,
  fromWallet: json['fromWallet'] as String?,
  toWallet: json['toWallet'] as String?,
  amount: (json['amount'] as num).toInt(),
  type: $enumDecode(_$TransactionTypeEnumMap, json['type']),
  category: $enumDecode(_$TransactionCategoryEnumMap, json['category']),
  rawText: json['rawText'] as String,
  time: DateTime.parse(json['time'] as String),
);

Map<String, dynamic> _$TransactionToJson(_Transaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'bank': instance.bank,
      'fromWallet': instance.fromWallet,
      'toWallet': instance.toWallet,
      'amount': instance.amount,
      'type': _$TransactionTypeEnumMap[instance.type]!,
      'category': _$TransactionCategoryEnumMap[instance.category]!,
      'rawText': instance.rawText,
      'time': instance.time.toIso8601String(),
    };

const _$TransactionTypeEnumMap = {
  TransactionType.income: 'income',
  TransactionType.expense: 'expense',
  TransactionType.transfer: 'transfer',
};

const _$TransactionCategoryEnumMap = {
  TransactionCategory.food: 'food',
  TransactionCategory.shopping: 'shopping',
  TransactionCategory.transport: 'transport',
  TransactionCategory.bills: 'bills',
  TransactionCategory.transfer: 'transfer',
  TransactionCategory.entertainment: 'entertainment',
  TransactionCategory.unknown: 'unknown',
};
