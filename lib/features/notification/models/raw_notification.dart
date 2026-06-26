import 'package:freezed_annotation/freezed_annotation.dart';

part 'raw_notification.freezed.dart';
part 'raw_notification.g.dart';

@freezed
abstract class RawNotification with _$RawNotification {
  const factory RawNotification({
    required String packageName,
    required String title,
    required String text,
    required int timestamp,
  }) = _RawNotification;

  factory RawNotification.fromJson(Map<String, dynamic> json) => _$RawNotificationFromJson(json);
}
