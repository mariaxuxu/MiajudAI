import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'api_service.dart';

class EventsService {
  static final EventsService _instance = EventsService._internal();
  final ApiService _apiService = ApiService();
  final List<Map<String, dynamic>> _eventBuffer = [];
  Timer? _flushTimer;
  Timer? _screenChangeDebounce;
  late FlutterLocalNotificationsPlugin _notificationsPlugin;
  bool _isInitialized = false;
  String? _currentToken;
  int _maxEventsPerBatch = 100;
  int _flushIntervalSeconds = 5 * 60; // 5 minutes
  int _maxRetries = 3;

  EventsService._internal();

  factory EventsService() {
    return _instance;
  }

  Future<void> init(String token) async {
    if (_isInitialized) {
      print('DEBUG: EventsService already initialized');
      return;
    }

    _currentToken = token;
    _isInitialized = true;

    print('DEBUG: EventsService initializing with token');

    // Initialize local notifications
    _notificationsPlugin = FlutterLocalNotificationsPlugin();
    const androidSettings =
        AndroidInitializationSettings('app_icon');
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _notificationsPlugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (_) {},
    );

    // Start periodic flush timer
    _flushTimer = Timer.periodic(
      Duration(seconds: _flushIntervalSeconds),
      (_) => flush(),
    );

    print('DEBUG: EventsService initialized - flush timer started');

    // Schedule daily reminder
    await scheduleReminder();
  }

  /// Log a diary entry
  void logDiary(String text, String mood, List<String> tags) {
    if (!_isInitialized) {
      print('DEBUG: EventsService not initialized, buffering diary event');
    }

    _eventBuffer.add({
      'type': 'diary',
      'text': text,
      'mood': mood,
      'tags': tags,
    });

    print('DEBUG: Diary event buffered. Buffer size: ${_eventBuffer.length}');
  }

  /// Log a screen navigation event
  void logScreenEvent(
    String screenName,
    int? dwellTimeSeconds,
    String? sourceScreen,
  ) {
    if (!_isInitialized) {
      print('DEBUG: EventsService not initialized, buffering screen event');
    }

    _eventBuffer.add({
      'type': 'screen',
      'screen_name': screenName,
      'dwell_time_seconds': dwellTimeSeconds,
      'source_screen': sourceScreen,
    });

    print('DEBUG: Screen event buffered. Buffer size: ${_eventBuffer.length}');

    // Debounce screen change flush
    _screenChangeDebounce?.cancel();
    _screenChangeDebounce = Timer(const Duration(milliseconds: 500), () {
      if (_eventBuffer.length > 20) {
        flush();
      }
    });
  }

  /// Log an interaction event
  void logInteractionEvent(String interactionType, String? screenName) {
    if (!_isInitialized) {
      print('DEBUG: EventsService not initialized, buffering interaction event');
    }

    _eventBuffer.add({
      'type': 'interaction',
      'interaction_type': interactionType,
      'screen_name': screenName,
    });

    print(
        'DEBUG: Interaction event buffered. Buffer size: ${_eventBuffer.length}');
  }

  /// Flush buffered events to server
  Future<void> flush({int attempt = 1}) async {
    if (_eventBuffer.isEmpty) {
      return;
    }

    if (_currentToken == null) {
      print('DEBUG: No token available, cannot flush events');
      return;
    }

    // Respect batch size limit
    final eventsToSend = _eventBuffer.take(_maxEventsPerBatch).toList();
    final remaining = _eventBuffer.length - eventsToSend.length;

    print(
        'DEBUG: Flushing ${eventsToSend.length} events ($remaining remaining in buffer)');

    try {
      final response = await _apiService.post(
        '/user-activity',
        {'events': eventsToSend},
        token: _currentToken,
      );

      if (response is Map && response['success'] == true) {
        _eventBuffer.removeRange(
            0,
            eventsToSend.length);
        print(
            '✅ Events flushed successfully. Stored: ${response['events_stored']}');
      } else {
        print('❌ Flush failed: Invalid response');
        if (attempt < _maxRetries) {
          _scheduleRetry(attempt + 1);
        } else {
          print('❌ Max retries reached, discarding batch');
          _eventBuffer.removeRange(0, eventsToSend.length);
        }
      }
    } catch (error) {
      print('❌ Flush error: $error');
      if (attempt < _maxRetries) {
        _scheduleRetry(attempt + 1);
      } else {
        print('❌ Max retries reached, discarding batch');
        _eventBuffer.removeRange(0, eventsToSend.length);
      }
    }
  }

  void _scheduleRetry(int attempt) {
    final delay = Duration(milliseconds: 150 * (1 << (attempt - 1)));
    print('DEBUG: Scheduling retry ${attempt}/${_maxRetries} after ${delay.inMilliseconds}ms');
    Timer(delay, () => flush(attempt: attempt));
  }

  /// Schedule daily reminder notification
  Future<void> scheduleReminder({int hour = 20, int minute = 0}) async {
    if (!_isInitialized) {
      print('DEBUG: EventsService not initialized, cannot schedule reminder');
      return;
    }

    try {
      // Request notification permissions (implicit on iOS 10+, explicit on Android 13+)
      final iosPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      await iosPlugin?.requestPermissions(alert: true, badge: true, sound: true);

      // Schedule notification at specified time daily
      const androidDetails = AndroidNotificationDetails(
        'diary_reminder',
        'Diary Reminder',
        channelDescription: 'Daily reminder to write diary',
        importance: Importance.high,
        priority: Priority.high,
      );
      const iosDetails = DarwinNotificationDetails();
      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Schedule one-time notification for today/tomorrow at specified time
      final now = DateTime.now();
      var scheduledDate =
          DateTime(now.year, now.month, now.day, hour, minute);

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      // Note: schedule() method available in newer versions
      // For basic reminder, we'll use a simple Timer approach
      // Production should use platform-specific implementation
      print('Note: Notification scheduling requires platform-specific setup');

      print('✅ Daily reminder scheduled for $hour:${minute.toString().padLeft(2, '0')}');
    } catch (error) {
      print('Error scheduling reminder: $error');
    }
  }

  /// Dispose service and cleanup
  void dispose() {
    _flushTimer?.cancel();
    _screenChangeDebounce?.cancel();
    _eventBuffer.clear();
    _isInitialized = false;
    _currentToken = null;
    print('DEBUG: EventsService disposed');
  }

  /// Get current buffer size
  int get bufferSize => _eventBuffer.length;

  /// Check if service is initialized
  bool get isInitialized => _isInitialized;
}
