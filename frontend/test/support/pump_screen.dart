import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miajudai/providers/auth_provider.dart';
import 'package:provider/provider.dart';

import 'fake_auth_provider.dart';

/// Registra como cada navegacao aconteceu (push, replace ou pop).
class RouteLog extends NavigatorObserver {
  final List<String> events = [];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      events.add('push ${route.settings.name}');

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) =>
      events.add('replace ${newRoute?.settings.name}');

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      events.add('pop ${route.settings.name}');
}

/// Monta [screen] na viewport de referencia (390x844) com um
/// [FakeAuthProvider] e um [RouteLog].
///
/// Qualquer rota nomeada resolve para uma pagina "DESTINO /rota", entao as
/// telas podem navegar sem depender das telas reais.
///
/// [setup] configura o provider ANTES do primeiro frame (a home, por exemplo,
/// le o usuario no `build`).
Future<({FakeAuthProvider auth, RouteLog log})> pumpScreen(
  WidgetTester tester,
  Widget screen, {
  void Function(FakeAuthProvider auth)? setup,
}) async {
  tester.view.physicalSize = const Size(390, 844) * 2;
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);

  final auth = FakeAuthProvider();
  setup?.call(auth);
  final log = RouteLog();

  await tester.pumpWidget(
    ChangeNotifierProvider<AuthProvider>.value(
      value: auth,
      child: MaterialApp(
        home: screen,
        navigatorObservers: [log],
        onGenerateRoute: (settings) => MaterialPageRoute<void>(
          settings: settings,
          builder: (_) =>
              Scaffold(body: Center(child: Text('DESTINO ${settings.name}'))),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  log.events.clear();
  return (auth: auth, log: log);
}
