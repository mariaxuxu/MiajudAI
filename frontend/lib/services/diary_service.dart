import '../models/diary_entry_model.dart';
import 'api_service.dart';

class DiaryService {
  final ApiService _apiService = ApiService();

  Future<void> saveDiaryEntry(
    String text,
    String mood,
    List<String> tags,
    String token, {
    DateTime? date,
  }) async {
    if (text.trim().isEmpty) throw ArgumentError('Diary text cannot be empty');
    if (!['happy', 'sad', 'neutral'].contains(mood)) throw ArgumentError('Invalid mood: $mood');

    final allowedTags = ['finance', 'food', 'domestic', 'calendar'];
    final invalidTags = tags.where((t) => !allowedTags.contains(t)).toList();
    if (invalidTags.isNotEmpty) throw ArgumentError('Invalid tags: ${invalidTags.join(', ')}');

    final event = <String, dynamic>{
      'type': 'diary',
      'text': text,
      'mood': mood,
      'tags': tags,
    };
    if (date != null) event['date'] = date.toIso8601String();

    final response = await _apiService.post('/user-activity', {'events': [event]}, token: token);

    if (response is! Map || response['success'] != true) {
      throw Exception('Failed to save diary entry');
    }
  }

  Future<List<DiaryEntry>> getEntriesForMonth(String month, String token) async {
    try {
      final response = await _apiService.get('/user-activity/diary?month=$month', token: token);
      if (response is Map && response['entries'] != null) {
        return (response['entries'] as List)
            .map((e) => DiaryEntry.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      print('❌ Error loading diary entries for month $month: $e');
      rethrow;
    }
  }
}
