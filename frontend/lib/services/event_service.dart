import 'api_service.dart';
import '../models/event_model.dart';

class EventService {
  final ApiService _apiService = ApiService();

  Future<List<EventModel>> getEvents(String token) async {
    final response = await _apiService.get('/events', token: token);
    final events = response['events'] as List<dynamic>? ?? [];
    return events.map((e) => EventModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<EventModel> createEvent(
    String token,
    String title,
    DateTime eventDate,
  ) async {
    final response = await _apiService.post(
      '/events',
      {
        'title': title,
        'event_date': eventDate.toIso8601String().split('T')[0],
      },
      token: token,
    );
    return EventModel.fromJson(response['event'] as Map<String, dynamic>);
  }

  Future<void> deleteEvent(String token, int eventId) async {
    await _apiService.delete('/events/$eventId', token: token);
  }
}
