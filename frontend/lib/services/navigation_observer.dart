import 'package:flutter/widgets.dart';

import '../config/event_actions.dart';
import 'events_service.dart';

/// Global navigation observer that emits a `screen_opened` event on every
/// route push/replace, so screen transitions are tracked without per-screen
/// code. Pop and bottom-nav tab switches are intentionally not tracked.
class AppNavigatorObserver extends NavigatorObserver {
  AppNavigatorObserver({EventsService? events})
      : _events = events ?? EventsService();

  final EventsService _events;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _emit(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute != null) {
      _emit(newRoute);
    }
  }

  void _emit(Route<dynamic> route) {
    final name = route.settings.name;
    if (name == null) return;

    final screenName = name.startsWith('/') ? name.substring(1) : name;
    if (screenName.isEmpty) return;

    _events.publishEvent(EventActions.screenOpened, screenName: screenName);
  }
}
