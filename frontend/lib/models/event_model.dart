class EventModel {
  final int id;
  final int userId;
  final String title;
  final DateTime eventDate;
  final DateTime createdAt;

  EventModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.eventDate,
    required this.createdAt,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      title: json['title'] as String? ?? '',
      eventDate: DateTime.parse(json['event_date'] as String? ?? '2000-01-01'),
      createdAt: DateTime.parse(json['created_at'] as String? ?? '2000-01-01'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'event_date': eventDate.toIso8601String().split('T')[0],
      'created_at': createdAt.toIso8601String(),
    };
  }

  EventModel copyWith({
    int? id,
    int? userId,
    String? title,
    DateTime? eventDate,
    DateTime? createdAt,
  }) {
    return EventModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      eventDate: eventDate ?? this.eventDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() => 'EventModel(id: $id, title: $title, eventDate: $eventDate)';
}
