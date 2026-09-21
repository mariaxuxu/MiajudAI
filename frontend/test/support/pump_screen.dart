import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miajudai/providers/account_provider.dart';
import 'package:miajudai/providers/auth_provider.dart';
import 'package:miajudai/providers/chat_provider.dart';
import 'package:miajudai/providers/expense_provider.dart';
import 'package:miajudai/providers/fixed_cost_provider.dart';
import 'package:miajudai/providers/income_provider.dart';
import 'package:miajudai/providers/installment_provider.dart';
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

/// Texto da tela de origem montada por [pumpScreen] quando `pushed` e true.
const String kOriginScreenText = 'ORIGEM';

/// Monta [screen] na viewport de referencia (390x844) com um
/// [FakeAuthProvider] e um [RouteLog].
///
/// Qualquer rota nomeada resolve para uma pagina "DESTINO /rota", entao as
/// telas podem navegar sem depender das telas reais.
///
/// [setup] configura o provider ANTES do primeiro frame (a home, por exemplo,
/// le o usuario no `build`).
///
/// [chat], quando informado, tambem e provido a arvore (telas de chat).
///
/// [accounts], [income], [expenses], [installments] e [fixedCosts], quando
/// informados, sao providos a arvore (telas de financas).
///
/// [pushed] monta a tela EMPILHADA sobre uma pagina "ORIGEM" em vez de como
/// raiz, para que "voltar" (`Navigator.pop`) tenha para onde voltar.
Future<({FakeAuthProvider auth, RouteLog log})> pumpScreen(
  WidgetTester tester,
  Widget screen, {
  void Function(FakeAuthProvider auth)? setup,
  ChatProvider? chat,
  AccountProvider? accounts,
  IncomeProvider? income,
  ExpenseProvider? expenses,
  InstallmentProvider? installments,
  FixedCostProvider? fixedCosts,
  bool pushed = false,
}) async {
  tester.view.physicalSize = const Size(390, 844) * 2;
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);

  final auth = FakeAuthProvider();
  setup?.call(auth);
  final log = RouteLog();
  final navigatorKey = GlobalKey<NavigatorState>();

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: auth),
        if (chat != null)
          ChangeNotifierProvider<ChatProvider>.value(value: chat),
        if (accounts != null)
          ChangeNotifierProvider<AccountProvider>.value(value: accounts),
        if (income != null)
          ChangeNotifierProvider<IncomeProvider>.value(value: income),
        if (expenses != null)
          ChangeNotifierProvider<ExpenseProvider>.value(value: expenses),
        if (installments != null)
          ChangeNotifierProvider<InstallmentProvider>.value(
            value: installments,
          ),
        if (fixedCosts != null)
          ChangeNotifierProvider<FixedCostProvider>.value(value: fixedCosts),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        home: pushed
            ? const Scaffold(body: Center(child: Text(kOriginScreenText)))
            : screen,
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

  if (pushed) {
    navigatorKey.currentState!.push(
      MaterialPageRoute<void>(builder: (_) => screen),
    );
    await tester.pumpAndSettle();
  }

  log.events.clear();
  return (auth: auth, log: log);
}
