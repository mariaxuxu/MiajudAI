import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

import '../config/constants.dart';

/// Bufferized publisher of user behavior events.
///
/// Events are accumulated in memory and flushed in batches to
/// `POST /api/user-events` (the `user_id` is derived from the JWT on the
/// backend, so only the token is needed here). Events published before a token
/// is set are discarded — they have no owner.
class EventsService {
  EventsService._({
    http.Client? client,
    String? baseUrl,
    Duration flushInterval = const Duration(minutes: 5),
    Duration backoffBase = const Duration(seconds: 1),
    Duration requestTimeout = const Duration(seconds: 30),
    int batchSize = 100,
    int bufferCap = 1000,
    int maxRetries = 3,
  })  : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? ApiConfig.baseUrl,
        _flushInterval = flushInterval,
        _backoffBase = backoffBase,
        _requestTimeout = requestTimeout,
        _batchSize = batchSize,
        _bufferCap = bufferCap,
        _maxRetries = maxRetries;

  static final EventsService _instance = EventsService._();

  factory EventsService() => _instance;

  /// Test-only constructor returning an isolated instance with injectable seams.
  @visibleForTesting
  factory EventsService.forTest({
    http.Client? client,
    String baseUrl = 'http://localhost/api',
    Duration flushInterval = const Duration(minutes: 5),
    Duration backoffBase = const Duration(seconds: 1),
    Duration requestTimeout = const Duration(seconds: 30),
    int batchSize = 100,
    int bufferCap = 1000,
    int maxRetries = 3,
  }) {
    return EventsService._(
      client: client,
      baseUrl: baseUrl,
      flushInterval: flushInterval,
      backoffBase: backoffBase,
      requestTimeout: requestTimeout,
      batchSize: batchSize,
      bufferCap: bufferCap,
      maxRetries: maxRetries,
    );
  }

  final http.Client _client;
  final String _baseUrl;
  final Duration _flushInterval;
  final Duration _backoffBase;
  final Duration _requestTimeout;
  final int _batchSize;
  final int _bufferCap;
  final int _maxRetries;

  final List<Map<String, dynamic>> _buffer = [];
  Timer? _flushTimer;
  String? _token;
  Future<void>? _inFlight;

  String? get token => _token;
  int get bufferSize => _buffer.length;

  @visibleForTesting
  List<Map<String, dynamic>> get bufferedEvents => List.unmodifiable(_buffer);

  /// Sets (or clears) the auth token. A non-null token starts the periodic
  /// flush timer; `null` cancels it.
  void setToken(String? token) {
    _token = token;
    if (token != null) {
      _flushTimer ??= Timer.periodic(_flushInterval, (_) => flush());
    } else {
      _flushTimer?.cancel();
      _flushTimer = null;
    }
  }

  /// Buffers a single event. Events published before a token is set are
  /// discarded (they have no `user_id`).
  void publishEvent(
    String action, {
    String? screenName,
    Map<String, dynamic>? metadata,
  }) {
    if (_token == null) return;

    final event = <String, dynamic>{
      'action': action,
      if (screenName != null && screenName.isNotEmpty)
        'screen_name': screenName,
      'metadata': metadata ?? <String, dynamic>{},
    };

    _buffer.add(event);
    if (_buffer.length > _bufferCap) {
      _buffer.removeAt(0);
    }

    if (_buffer.length >= _batchSize) {
      flush();
    }
  }

  /// Flushes buffered events to the backend (best-effort). Overlapping calls
  /// share the same in-flight drain, which picks up any newly buffered events.
  Future<void> flush() {
    return _inFlight ??= _drain().whenComplete(() {
      _inFlight = null;
    });
  }

  /// Flushes pending events, then clears the token and any events that could
  /// not be flushed (the logout trigger). Clearing prevents events from one
  /// session being attributed to the next user that logs in.
  Future<void> flushAndClearToken() async {
    await flush();
    setToken(null);
    _buffer.clear();
  }

  /// Notifies the publisher of an app lifecycle change; flushes on pause.
  void onLifecycleChanged(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      flush();
    }
  }

  Future<void> _drain() async {
    while (_buffer.isNotEmpty && _token != null) {
      final events = _buffer.take(_batchSize).toList();
      final sent = await _sendWithRetry(events);
      if (!sent) return; // retries exhausted; events stay in the buffer
      _buffer.removeRange(0, events.length);
    }
  }

  Future<bool> _sendWithRetry(List<Map<String, dynamic>> events) async {
    for (var attempt = 1; attempt <= _maxRetries; attempt++) {
      try {
        final body = await _post('/user-events', {'events': events});
        if (body['success'] == true) return true;
      } catch (_) {
        // fall through to retry
      }
      if (attempt < _maxRetries) {
        await Future<void>.delayed(_backoffDelay(attempt));
      }
    }
    return false;
  }

  Duration _backoffDelay(int attempt) =>
      _backoffBase * (1 << (attempt - 1));

  Future<Map<String, dynamic>> _post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final response = await _client
        .post(
          Uri.parse('$_baseUrl$endpoint'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            if (_token != null) 'Authorization': 'Bearer $_token',
          },
          body: jsonEncode(body),
        )
        .timeout(_requestTimeout);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw http.ClientException('HTTP ${response.statusCode}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// Cancels the flush timer and clears buffered state (test/teardown helper).
  @visibleForTesting
  void dispose() {
    _flushTimer?.cancel();
    _flushTimer = null;
    _buffer.clear();
    _token = null;
  }
}
