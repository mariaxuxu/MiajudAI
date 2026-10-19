import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:miajudai/models/diary_entry_model.dart';
import 'package:miajudai/providers/diary_provider.dart';

/// `DiaryProvider` de teste.
///
/// O real instancia `DiaryService` (HTTP). Este fake serve as entradas que o
/// teste define e REGISTRA cada chamada com os argumentos recebidos.
///
/// `saveDiary` espelha o padrao de notificacao do provider real, que importa
/// para a tela: `isLoading` liga SEM notificar, e so a recarga do mes (que
/// notifica com o flag ainda ligado) reconstroi a tela com o botao ocupado.
///  - [saveGate]: segura a chamada ao servico (antes de qualquer notificacao);
///  - [reloadGate]: segura a recarga do mes, ja com `isLoading` ligado e a tela
///    reconstruida;
///  - [saveError]: faz a chamada ao servico falhar.
class FakeDiaryProvider extends ChangeNotifier implements DiaryProvider {
  List<DiaryEntry> items = [];

  final List<({DateTime month, String token})> loadCalls = [];
  final List<
      ({
        String text,
        String mood,
        List<String> tags,
        String token,
        DateTime? date,
      })> saveCalls = [];

  Completer<void>? saveGate;
  Completer<void>? reloadGate;
  Object? saveError;

  bool _isLoading = false;
  int _nextId = 100;

  /// Notifica os ouvintes sem alterar dados (reconstroi o `Consumer` da tela).
  void refresh() => notifyListeners();

  @override
  bool get isLoading => _isLoading;

  @override
  bool get isLoadingEntries => false;

  @override
  String? get error => null;

  @override
  List<DiaryEntry> entriesForDay(DateTime day) {
    return items
        .where((e) =>
            e.createdAt.year == day.year &&
            e.createdAt.month == day.month &&
            e.createdAt.day == day.day)
        .toList();
  }

  @override
  bool hasEntriesForDay(DateTime day) => entriesForDay(day).isNotEmpty;

  @override
  Future<void> loadEntriesForMonth(DateTime month, String token) async {
    loadCalls.add((month: month, token: token));
  }

  @override
  Future<void> saveDiary(
    String text,
    String mood,
    List<String> tags,
    String token, {
    DateTime? date,
  }) async {
    saveCalls.add((
      text: text,
      mood: mood,
      tags: tags,
      token: token,
      date: date,
    ));
    _isLoading = true;
    try {
      await saveGate?.future;
      if (saveError != null) throw saveError!;
      items.add(fakeDiaryEntry(
        id: _nextId++,
        text: text,
        mood: mood,
        tags: tags,
        createdAt: date ?? DateTime.now(),
      ));
      notifyListeners(); // a recarga do mes notifica com isLoading ligado
      await reloadGate?.future;
      notifyListeners();
    } finally {
      _isLoading = false;
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

DiaryEntry fakeDiaryEntry({
  required int id,
  required String text,
  String mood = 'neutral',
  List<String> tags = const [],
  required DateTime createdAt,
}) =>
    DiaryEntry(
      id: id,
      userId: 1,
      text: text,
      mood: mood,
      tags: tags,
      emotionScore: 50,
      createdAt: createdAt,
      updatedAt: createdAt,
    );
