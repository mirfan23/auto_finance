class ReceivedNotification {
  const ReceivedNotification({
    required this.id,
    required this.packageName,
    required this.title,
    required this.text,
    required this.timestamp,
    required this.processed,
  });

  final int id;
  final String packageName;
  final String title;
  final String text;
  final int timestamp;
  final bool processed;

  factory ReceivedNotification.fromMap(Map<String, dynamic> map) {
    return ReceivedNotification(
      id: (map['id'] as num).toInt(),
      packageName: map['packageName'] as String? ?? '',
      title: map['title'] as String? ?? '',
      text: map['text'] as String? ?? '',
      timestamp: (map['timestamp'] as num).toInt(),
      processed: map['processed'] as bool? ?? false,
    );
  }

  DateTime get time => DateTime.fromMillisecondsSinceEpoch(timestamp);
}
