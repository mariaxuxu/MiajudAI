// Preservacao de comportamento da home pos-login (WelcomeScreen).
//
// Cada caso prova que a UI redesenhada continua levando aos MESMOS destinos,
// do mesmo jeito (push vs replacement), e acionando o mesmo provider.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miajudai/models/user_model.dart';
import 'package:miajudai/screens/welcome_screen.dart';

import 'support/pump_screen.dart';
import 'support/test_fonts.dart';

UserModel _user(String? fullName) => UserModel(
      id: '1',
      email: 'pedro@mail.com',
      fullName: fullName,
      createdAt: DateTime(2024),
    );

Future<void> _tapText(WidgetTester tester, String text) async {
  await tester.ensureVisible(find.text(text));
  await tester.tap(find.text(text));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(loadRedesignFonts);

  group('greeting', () {
    testWidgets('uses the first name of the logged user', (tester) async {
      await pumpScreen(
        tester,
        const WelcomeScreen(),
        setup: (a) => a.currentUser = _user('  Pedro Kelvin da Silva '),
      );
      expect(find.text('Olá, Pedro!'), findsOneWidget);
    });

    testWidgets('falls back to a plain greeting without a name', (
      tester,
    ) async {
      await pumpScreen(tester, const WelcomeScreen());
      expect(find.text('Olá!'), findsOneWidget);
    });
  });

  group('quick access cards keep their destinations', () {
    const pushes = {
      'Calendário': 'push /calendar',
      'Meu Diário': 'push /diary',
      'Finanças': 'push /accounts',
      'Dashboard / Fatura': 'push /invoice-dashboard',
    };

    for (final entry in pushes.entries) {
      testWidgets('"${entry.key}" -> ${entry.value}', (tester) async {
        final env = await pumpScreen(tester, const WelcomeScreen());

        await _tapText(tester, entry.key);

        expect(env.log.events, [entry.value]);
      });
    }

    for (final title in ['Área Doméstica', 'Serviços Externos']) {
      testWidgets('"$title" stays a no-op', (tester) async {
        final env = await pumpScreen(tester, const WelcomeScreen());

        await _tapText(tester, title);

        expect(env.log.events, isEmpty);
      });
    }

    testWidgets('all six cards are still shown', (tester) async {
      await pumpScreen(tester, const WelcomeScreen());
      for (final t in [
        'Calendário',
        'Meu Diário',
        'Finanças',
        'Dashboard / Fatura',
        'Área Doméstica',
        'Serviços Externos',
      ]) {
        expect(find.text(t), findsOneWidget, reason: t);
      }
    });
  });

  group('logout', () {
    testWidgets('cancel closes the dialog and does not log out', (
      tester,
    ) async {
      final env = await pumpScreen(tester, const WelcomeScreen());

      await tester.tap(find.byTooltip('Sair'));
      await tester.pumpAndSettle();
      expect(find.text('Sair da conta?'), findsOneWidget);

      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(find.text('Sair da conta?'), findsNothing);
      expect(env.auth.logoutCalls, 0);
      expect(env.log.events.any((e) => e.startsWith('replace')), isFalse);
    });

    testWidgets('confirm logs out and REPLACES the route with /', (
      tester,
    ) async {
      final env = await pumpScreen(tester, const WelcomeScreen());

      await tester.tap(find.byTooltip('Sair'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Sair'));
      await tester.pumpAndSettle();

      expect(env.auth.logoutCalls, 1);
      expect(env.log.events.last, 'replace /');
    });
  });

  group('agent bottom navigation', () {
    testWidgets('Luna PUSHES /chat', (tester) async {
      final env = await pumpScreen(tester, const WelcomeScreen());

      await tester.tap(find.text('Luna'));
      await tester.pumpAndSettle();

      expect(env.log.events, ['push /chat']);
    });

    testWidgets('Otto shows the under-construction notice, no navigation', (
      tester,
    ) async {
      final env = await pumpScreen(tester, const WelcomeScreen());

      await tester.tap(find.text('Otto'));
      await tester.pumpAndSettle();

      expect(find.text('Em construção'), findsOneWidget);
      expect(find.text('Assistente de Cozinha'), findsOneWidget);
      expect(env.log.events.contains('push /chat'), isFalse);

      await tester.tap(find.text('Entendido'));
      await tester.pumpAndSettle();
      expect(find.text('Em construção'), findsNothing);
    });

    testWidgets('Tina shows the under-construction notice', (tester) async {
      await pumpScreen(tester, const WelcomeScreen());

      await tester.tap(find.text('Tina'));
      await tester.pumpAndSettle();

      expect(find.text('Em construção'), findsOneWidget);
      expect(find.text('Assistente Doméstica'), findsOneWidget);
    });

    testWidgets('Início does not navigate', (tester) async {
      final env = await pumpScreen(tester, const WelcomeScreen());

      await tester.tap(find.text('Início'));
      await tester.pumpAndSettle();

      expect(env.log.events, isEmpty);
    });

    testWidgets('agents without a screen are announced as "em breve"', (
      tester,
    ) async {
      await pumpScreen(tester, const WelcomeScreen());
      final handle = tester.ensureSemantics();

      expect(find.bySemanticsLabel('Otto, em breve'), findsOneWidget);
      expect(find.bySemanticsLabel('Tina, em breve'), findsOneWidget);
      expect(find.bySemanticsLabel('Luna'), findsOneWidget);

      handle.dispose();
    });
  });
}
