import 'package:flutter/foundation.dart';
import '../models/diary_entry_model.dart';
import '../services/diary_service.dart';

class DiaryProvider extends ChangeNotifier {
  final DiaryService _diaryService = DiaryService();
  bool _isLoading = false;
  String? _error;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// MVP: Save a new diary entry (direct POST to backend)
  Future<void> saveDiary(
    String text,
    String mood,
    List<String> tags,
    String token,
  ) async {
    _setLoading(true);
    _clearError();

    try {
      await _diaryService.saveDiaryEntry(text, mood, tags, token);
      print('✅ Diary entry saved to database');
      notifyListeners();
    } catch (error) {
      _setError('Failed to save diary: $error');
      print('❌ Error saving diary: $error');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// TODO upgrade: Phase 2 — Read, delete, and load operations
  /// loadDiariesForMonth()
  /// selectDate()
  /// deleteDiary()
  /// entriesForDay()

  // Private helpers
  void _setLoading(bool value) {
    _isLoading = value;
  }

  void _setError(String? value) {
    _error = value;
  }

  void _clearError() {
    _error = null;
  }
}
