import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:miajudai/models/event_model.dart';
import 'package:miajudai/providers/event_provider.dart';

/// `EventProvider` de teste.
///
/// O real instancia `EventService` (HTTP). Este fake serve os compromissos que
/// o teste define e REGISTRA cada chamada com os argumentos recebidos.
///
/// `eventsForDay` espelha a regra do provider real (mesmo ano, mes e dia) e
/// `addEvent`/`removeEvent` alteram a lista como o real, para a tela reagir.
class FakeEventProvider extends ChangeNotifier implements EventProvider {
  List<EventModel> items = [];

  final List<String> loadCalls = [];
  final List<({String token, String title, DateTime date})> addCalls = [];
  final List<({String token, int id})> removeCalls = [];

  /// Quando definido, `addEvent` so termina quando ele completar: a tela nao
  /// pode esperar por ele para fechar a sheet nem para avisar o usuario.
  Completer<void>? addGate;

  int _nextId = 100;

  /// Notifica os ouvintes sem alterar dados (reconstroi o `Consumer` da tela).
  void refresh() => notifyListeners();

  @override
  List<EventModel> get events => items;

  @override
  bool get isLoading => false;

  @override
  String? get error => null;

  @override
  List<EventModel> eventsForDay(DateTime day) {
    return items
        .where((e) =>
            e.eventDate.year == day.year &&
            e.eventDate.month == day.month &&
            e.eventDate.day == day.day)
        .toList();
  }

  @override
  Future<void> loadEvents(String token) async {
    loadCalls.add(token);
  }

  @override
  Future<void> addEvent(String token, String title, DateTime eventDate) async {
    addCalls.add((token: token, title: title, date: eventDate));
    await addGate?.future;
    items.add(fakeEvent(id: _nextId++, title: title, date: eventDate));
    items.sort((a, b) => a.eventDate.compareTo(b.eventDate));
    notifyListeners();
  }

  @override
  Future<void> removeEvent(String token, int eventId) async {
    removeCalls.add((token: token, id: eventId));
    items.removeWhere((e) => e.id == eventId);
    notifyListeners();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

EventModel fakeEvent({
  required int id,
  required String title,
  required DateTime date,
}) =>
    EventModel(
      id: id,
      userId: 1,
      title: title,
      eventDate: date,
      createdAt: DateTime(2026),
    );
