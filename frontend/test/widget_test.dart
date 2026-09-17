import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:miajudai/services/events_service.dart';
import 'package:miajudai/services/navigation_observer.dart';

void main() {
  testWidgets('navigation emits screen_opened via the registered observer',
      (tester) async {
    final events = EventsService.forTest(
      client: MockClient((_) async => http.Response('{"success": true}', 200)),
    );
    events.setToken('jwt');

    try {
      await tester.pumpWidget(
        MaterialApp(
          navigatorObservers: [AppNavigatorObserver(events: events)],
          initialRoute: '/',
          routes: {
            '/': (_) => const Scaffold(body: Text('root')),
            '/accounts': (_) => const Scaffold(body: Text('accounts')),
          },
        ),
      );

      final navigator = tester.state<NavigatorState>(find.byType(Navigator));
      navigator.pushNamed('/accounts');
      await tester.pumpAndSettle();

      expect(
        events.bufferedEvents,
        contains(
          allOf(
            containsPair('action', 'screen_opened'),
            containsPair('screen_name', 'accounts'),
          ),
        ),
      );
    } finally {
      events.dispose();
    }
  });
}
