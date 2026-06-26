// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'raw_notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RawNotification _$RawNotificationFromJson(Map<String, dynamic> json) =>
    _RawNotification(
      packageName: json['packageName'] as String,
      title: json['title'] as String,
      text: json['text'] as String,
      timestamp: (json['timestamp'] as num).toInt(),
    );

Map<String, dynamic> _$RawNotificationToJson(_RawNotification instance) =>
    <String, dynamic>{
      'packageName': instance.packageName,
      'title': instance.title,
      'text': instance.text,
      'timestamp': instance.timestamp,
    };
