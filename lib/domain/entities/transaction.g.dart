// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Transaction _$TransactionFromJson(Map<String, dynamic> json) => _Transaction(
  bank: json['bank'] as String,
  amount: (json['amount'] as num).toInt(),
  type: json['type'] as String,
  category: $enumDecode(_$TransactionCategoryEnumMap, json['category']),
  rawText: json['rawText'] as String,
  time: DateTime.parse(json['time'] as String),
);

Map<String, dynamic> _$TransactionToJson(_Transaction instance) =>
    <String, dynamic>{
      'bank': instance.bank,
      'amount': instance.amount,
      'type': instance.type,
      'category': _$TransactionCategoryEnumMap[instance.category]!,
      'rawText': instance.rawText,
      'time': instance.time.toIso8601String(),
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
