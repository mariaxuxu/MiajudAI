import 'api_service.dart';

class DiaryService {
  final ApiService _apiService = ApiService();

  /// Save a diary entry directly to backend
  /// MVP: Direct POST on save (no batching)
  Future<void> saveDiaryEntry(
    String text,
    String mood,
    List<String> tags,
    String token,
  ) async {
    // Validate
    if (text.trim().isEmpty) {
      throw ArgumentError('Diary text cannot be empty');
    }

    if (!['happy', 'sad', 'neutral'].contains(mood)) {
      throw ArgumentError('Invalid mood: $mood');
    }

    final allowedTags = ['finance', 'food', 'domestic', 'calendar'];
    final invalidTags = tags.where((t) => !allowedTags.contains(t)).toList();
    if (invalidTags.isNotEmpty) {
      throw ArgumentError('Invalid tags: ${invalidTags.join(', ')}');
    }

    try {
      print('📝 Saving diary entry...');

      final response = await _apiService.post(
        '/user-activity',
        {
          'events': [
            {
              'type': 'diary',
              'text': text,
              'mood': mood,
              'tags': tags,
            }
          ]
        },
        token: token,
      );

      if (response is Map && response['success'] == true) {
        print('✅ Diary entry saved: ${response['events_stored']} event(s) stored');
      } else {
        throw Exception('Failed to save diary entry');
      }
    } catch (error) {
      print('❌ Error saving diary: $error');
      rethrow;
    }
  }

  /// TODO upgrade: Phase 2 — Read operations (fetch, list, delete)
  /// Not implemented in MVP - focus on write/persist first
}

