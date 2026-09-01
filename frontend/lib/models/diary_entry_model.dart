class DiaryEntry {
  final int id;
  final int userId;
  final String text;
  final String mood; // 'happy', 'sad', 'neutral'
  final List<String> tags; // ['finance', 'food', 'domestic', 'calendar']
  final int emotionScore; // 80, 20, 50
  final DateTime createdAt;
  final DateTime updatedAt;

  DiaryEntry({
    required this.id,
    required this.userId,
    required this.text,
    required this.mood,
    required this.tags,
    required this.emotionScore,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Parse from JSON (backend response)
  factory DiaryEntry.fromJson(Map<String, dynamic> json) {
    return DiaryEntry(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      text: json['text'] as String,
      mood: json['mood'] as String,
      tags: List<String>.from(json['tags'] as List? ?? []),
      emotionScore: json['emotion_score'] as int? ?? 50,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Serialize to JSON (for API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'text': text,
      'mood': mood,
      'tags': tags,
      'emotion_score': emotionScore,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Immutable copy with modifications
  DiaryEntry copyWith({
    int? id,
    int? userId,
    String? text,
    String? mood,
    List<String>? tags,
    int? emotionScore,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DiaryEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      text: text ?? this.text,
      mood: mood ?? this.mood,
      tags: tags ?? this.tags,
      emotionScore: emotionScore ?? this.emotionScore,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => 'DiaryEntry(id=$id, mood=$mood, createdAt=$createdAt)';
}
