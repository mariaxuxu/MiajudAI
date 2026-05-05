import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../services/event_service.dart';

class EventProvider extends ChangeNotifier {
  final EventService _eventService = EventService();

  List<EventModel> _events = [];
  bool _isLoading = false;
  String? _error;

  List<EventModel> get events => _events;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadEvents(String token) async {
    _setLoading(true);
    _clearError();

    try {
      _events = await _eventService.getEvents(token);
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  Future<void> addEvent(
    String token,
    String title,
    DateTime eventDate,
  ) async {
    _setLoading(true);
    _clearError();

    try {
      final event = await _eventService.createEvent(token, title, eventDate);
      _events.add(event);
      _events.sort((a, b) => a.eventDate.compareTo(b.eventDate));
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  Future<void> removeEvent(String token, int eventId) async {
    _setLoading(true);
    _clearError();

    try {
      await _eventService.deleteEvent(token, eventId);
      _events.removeWhere((e) => e.id == eventId);
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  List<EventModel> eventsForDay(DateTime day) {
    return _events
        .where((event) =>
            event.eventDate.year == day.year &&
            event.eventDate.month == day.month &&
            event.eventDate.day == day.day)
        .toList();
  }

  void _setLoading(bool value) {
    _isLoading = value;
  }

  void _setError(String error) {
    _error = error;
  }

  void _clearError() {
    _error = null;
  }
}
