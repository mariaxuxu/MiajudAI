import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:miajudai/services/events_service.dart';
import 'package:miajudai/services/navigation_observer.dart';

Route<void> _route(String name) => MaterialPageRoute<void>(
      settings: RouteSettings(name: name),
      builder: (_) => const SizedBox.shrink(),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  EventsService makeService() => EventsService.forTest(
        client: MockClient((_) async => http.Response('{"success": true}', 200)),
      );

  test('emits screen_opened on didPush with the route name sans slash', () {
    final events = makeService();
    events.setToken('jwt');
    final observer = AppNavigatorObserver(events: events);

    observer.didPush(_route('/accounts'), null);

    final event = events.bufferedEvents.single;
    expect(event['action'], 'screen_opened');
    expect(event['screen_name'], 'accounts');
    expect(event['metadata'], <String, dynamic>{});
    expect(event['client_event_id'], isA<String>());
    expect(event['client_event_id'], isNotEmpty);
    events.dispose();
  });

  test('emits screen_opened on didReplace', () {
    final events = makeService();
    events.setToken('jwt');
    final observer = AppNavigatorObserver(events: events);

    observer.didReplace(
      newRoute: _route('/calendar'),
      oldRoute: _route('/accounts'),
    );

    expect(events.bufferedEvents.single['action'], 'screen_opened');
    expect(events.bufferedEvents.single['screen_name'], 'calendar');
    events.dispose();
  });

  test('skips routes with no name', () {
    final events = makeService();
    events.setToken('jwt');
    final observer = AppNavigatorObserver(events: events);

    observer.didPush(
      MaterialPageRoute<void>(builder: (_) => const SizedBox.shrink()),
      null,
    );

    expect(events.bufferSize, 0);
    events.dispose();
  });

  test('does not emit on didPop', () {
    final events = makeService();
    events.setToken('jwt');
    final observer = AppNavigatorObserver(events: events);

    observer.didPop(_route('/accounts'), null);

    expect(events.bufferSize, 0);
    events.dispose();
  });
}
