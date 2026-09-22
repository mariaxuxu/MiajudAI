import 'dart:convert';

import 'package:fake_async/fake_async.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:miajudai/services/events_service.dart';

void main() {
  group('EventsService', () {
    test('discards events before a token is set', () {
      final service = EventsService.forTest(
        client: MockClient((_) async => http.Response('{}', 200)),
      );

      service.publishEvent('screen_opened', screenName: 'accounts');

      expect(service.bufferSize, 0);
      service.dispose();
    });

    test('buffers events once a token is set', () {
      final service = EventsService.forTest(
        client: MockClient((_) async => http.Response('{}', 200)),
      );
      service.setToken('jwt');

      service.publishEvent('screen_opened', screenName: 'accounts');

      expect(service.bufferSize, 1);
      final event = service.bufferedEvents.single;
      expect(event['action'], 'screen_opened');
      expect(event['screen_name'], 'accounts');
      expect(event['metadata'], <String, dynamic>{});
      expect(event['client_event_id'], isA<String>());
      expect(event['client_event_id'], isNotEmpty);
      service.dispose();
    });

    test('assigns a unique client_event_id to every event', () {
      final service = EventsService.forTest(
        client: MockClient((_) async => http.Response('{}', 200)),
      );
      service.setToken('jwt');

      service.publishEvent('screen_opened');
      service.publishEvent('screen_opened');

      final ids = service.bufferedEvents
          .map((e) => e['client_event_id'])
          .toSet();
      expect(ids, hasLength(2));
      service.dispose();
    });

    test('caps the buffer, dropping the oldest event on overflow', () {
      final service = EventsService.forTest(
        client: MockClient(
          (_) async => http.Response('{"success": true, "events_stored": 1}', 200),
        ),
        batchSize: 1000,
        bufferCap: 5,
      );
      service.setToken('jwt');

      for (var i = 0; i < 7; i++) {
        service.publishEvent('action_$i');
      }

      expect(service.bufferSize, 5);
      expect(service.bufferedEvents.first['action'], 'action_2');
      expect(service.bufferedEvents.last['action'], 'action_6');
      service.dispose();
    });

    test('flushes when the batch reaches the size limit', () async {
      final requests = <http.Request>[];
      final service = EventsService.forTest(
        client: MockClient((req) async {
          requests.add(req);
          return http.Response('{"success": true, "events_stored": 3}', 200);
        }),
        batchSize: 3,
      );
      service.setToken('jwt');

      service.publishEvent('a');
      service.publishEvent('b');
      service.publishEvent('c'); // triggers flush

      await pumpEventQueue();

      expect(requests, hasLength(1));
      expect(service.bufferSize, 0);

      final req = requests.single;
      expect(req.url.path, '/api/user-events');
      expect(req.headers['Authorization'], 'Bearer jwt');
      final body = jsonDecode(req.body) as Map<String, dynamic>;
      expect(body['events'], hasLength(3));
      service.dispose();
    });

    test('flushes on the 5-minute timer', () {
      fakeAsync((async) {
        final requests = <http.Request>[];
        final service = EventsService.forTest(
          client: MockClient((req) async {
            requests.add(req);
            return http.Response('{"success": true, "events_stored": 1}', 200);
          }),
          flushInterval: const Duration(minutes: 5),
        );
        service.setToken('jwt');
        service.publishEvent('screen_opened', screenName: 'accounts');

        expect(requests, isEmpty);

        async.elapse(const Duration(minutes: 5));
        async.flushMicrotasks();

        expect(requests, hasLength(1));
        expect(service.bufferSize, 0);
        service.dispose();
      });
    });

    test('flushes when the app is paused', () async {
      final requests = <http.Request>[];
      final service = EventsService.forTest(
        client: MockClient((req) async {
          requests.add(req);
          return http.Response('{"success": true, "events_stored": 1}', 200);
        }),
      );
      service.setToken('jwt');
      service.publishEvent('screen_opened', screenName: 'accounts');

      service.onLifecycleChanged(AppLifecycleState.paused);

      await pumpEventQueue();

      expect(requests, hasLength(1));
      expect(service.bufferSize, 0);
      service.dispose();
    });

    test('flushes and clears the token on logout', () async {
      final requests = <http.Request>[];
      final service = EventsService.forTest(
        client: MockClient((req) async {
          requests.add(req);
          return http.Response('{"success": true, "events_stored": 1}', 200);
        }),
      );
      service.setToken('jwt');
      service.publishEvent('screen_opened', screenName: 'accounts');

      await service.flushAndClearToken();

      expect(requests, hasLength(1));
      expect(service.token, isNull);
      expect(service.bufferSize, 0);
    });

    test('drops un-flushable events on logout (no cross-user leak)', () async {
      final service = EventsService.forTest(
        client: MockClient((_) async => http.Response('{"error": "boom"}', 500)),
        backoffBase: const Duration(milliseconds: 1),
      );
      service.setToken('jwt');
      service.publishEvent('screen_opened', screenName: 'accounts');

      await service.flushAndClearToken();

      expect(service.token, isNull);
      expect(service.bufferSize, 0);
    });

    test('retries with backoff and succeeds on a later attempt', () async {
      var attempts = 0;
      final service = EventsService.forTest(
        client: MockClient((_) async {
          attempts++;
          if (attempts < 3) {
            return http.Response('{"error": "boom"}', 500);
          }
          return http.Response('{"success": true, "events_stored": 1}', 200);
        }),
        backoffBase: const Duration(milliseconds: 1),
      );
      service.setToken('jwt');
      service.publishEvent('screen_opened', screenName: 'accounts');

      await service.flush();

      expect(attempts, 3);
      expect(service.bufferSize, 0);
      service.dispose();
    });

    test('returns events to the buffer after retries are exhausted', () async {
      var attempts = 0;
      final service = EventsService.forTest(
        client: MockClient((_) async {
          attempts++;
          return http.Response('{"error": "boom"}', 500);
        }),
        backoffBase: const Duration(milliseconds: 1),
      );
      service.setToken('jwt');
      service.publishEvent('screen_opened', screenName: 'accounts');

      await service.flush();

      expect(attempts, 3);
      expect(service.bufferSize, 1); // event stays in the buffer
      service.dispose();
    });

    test('treats a non-success 2xx response as a failure', () async {
      var attempts = 0;
      final service = EventsService.forTest(
        client: MockClient((_) async {
          attempts++;
          return http.Response('{"success": false}', 200);
        }),
        backoffBase: const Duration(milliseconds: 1),
      );
      service.setToken('jwt');
      service.publishEvent('screen_opened', screenName: 'accounts');

      await service.flush();

      expect(attempts, 3);
      expect(service.bufferSize, 1);
      service.dispose();
    });
  });
}
