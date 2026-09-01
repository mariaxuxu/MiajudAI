import 'package:flutter/foundation.dart';
import '../models/diary_entry_model.dart';
import '../services/diary_service.dart';

class DiaryProvider extends ChangeNotifier {
  final DiaryService _diaryService = DiaryService();

  bool _isLoading = false;
  bool _isLoadingEntries = false;
  String? _error;
  Map<String, List<DiaryEntry>> _entriesByDay = {};
  String? _loadedMonth;

  bool get isLoading => _isLoading;
  bool get isLoadingEntries => _isLoadingEntries;
  String? get error => _error;

  List<DiaryEntry> entriesForDay(DateTime day) {
    return _entriesByDay[_dayKey(day)] ?? [];
  }

  bool hasEntriesForDay(DateTime day) => entriesForDay(day).isNotEmpty;

  Future<void> loadEntriesForMonth(DateTime month, String token) async {
    final monthStr = _monthKey(month);
    if (_loadedMonth == monthStr) return;

    _isLoadingEntries = true;
    notifyListeners();

    try {
      final entries = await _diaryService.getEntriesForMonth(monthStr, token);
      final byDay = <String, List<DiaryEntry>>{};
      for (final entry in entries) {
        final key = _dayKey(entry.createdAt);
        byDay.putIfAbsent(key, () => []).add(entry);
      }
      _entriesByDay = byDay;
      _loadedMonth = monthStr;
    } catch (e) {
      _setError('Erro ao carregar entradas: $e');
    } finally {
      _isLoadingEntries = false;
      notifyListeners();
    }
  }

  Future<void> saveDiary(
    String text,
    String mood,
    List<String> tags,
    String token, {
    DateTime? date,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      await _diaryService.saveDiaryEntry(text, mood, tags, token, date: date);

      final effectiveDate = date ?? DateTime.now();
      _loadedMonth = null;
      await loadEntriesForMonth(effectiveDate, token);

      notifyListeners();
    } catch (e) {
      _setError('Erro ao salvar: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  String _dayKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _monthKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}';

  void _setLoading(bool v) => _isLoading = v;
  void _setError(String? v) => _error = v;
  void _clearError() => _error = null;
}
