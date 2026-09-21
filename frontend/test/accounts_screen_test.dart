// Preservacao de comportamento da tela de Financas (AccountsScreen).
//
// Cada caso prova que a UI redesenhada continua acionando o AccountProvider
// com os MESMOS argumentos, navegando para os MESMOS destinos do MESMO jeito
// (push vs replace vs pop) e mantendo as MESMAS validacoes.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miajudai/models/account_model.dart';
import 'package:miajudai/screens/accounts_screen.dart';
import 'package:miajudai/widgets/common/app_form_field.dart';

import 'support/fake_account_provider.dart';
import 'support/pump_screen.dart';
import 'support/test_fonts.dart';

Future<({FakeAccountProvider accounts, RouteLog log})> _pump(
  WidgetTester tester, {
  List<AccountModel> Function()? seed,
  String? token = 'test-token',
  bool pushed = false,
}) async {
  final accounts = FakeAccountProvider();
  if (seed != null) {
    accounts.items = seed();
  }
  final env = await pumpScreen(
    tester,
    const AccountsScreen(),
    accounts: accounts,
    pushed: pushed,
    setup: (a) => a.token = token,
  );
  return (accounts: accounts, log: env.log);
}

List<AccountModel> _twoAccounts() => [
      fakeAccount(id: 7, name: 'Nubank', balance: 1320),
      fakeAccount(id: 9, name: 'Reserva', type: 'savings', balance: 3500.5),
    ];

Future<void> _openSheetWithFab(WidgetTester tester) async {
  await tester.tap(find.byType(FloatingActionButton));
  await tester.pumpAndSettle();
}

Future<void> _enter(WidgetTester tester, String label, String text) async {
  // Cada AppFormField tem o rotulo visivel em um Text acima do seu TextField.
  final field = find.descendant(
    of: find.ancestor(
      of: find.text(label),
      matching: find.byType(AppFormField),
    ),
    matching: find.byType(TextField),
  );
  await tester.enterText(field, text);
}

Future<void> _tapCreate(WidgetTester tester) async {
  await tester.tap(find.widgetWithText(FilledButton, 'Criar conta'));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(loadRedesignFonts);

  group('loading', () {
    testWidgets('loads accounts once, with the auth token', (tester) async {
      final r = await _pump(tester);
      expect(r.accounts.loadCalls, ['test-token']);
    });

    testWidgets('does not load without a token', (tester) async {
      final r = await _pump(tester, token: null);
      expect(r.accounts.loadCalls, isEmpty);
    });
  });

  group('content and calculations come from the provider', () {
    testWidgets('empty state', (tester) async {
      await _pump(tester);

      expect(find.text('Finanças'), findsOneWidget);
      expect(find.text('Saldo total'), findsOneWidget);
      expect(find.text('R\$ 0,00'), findsOneWidget);
      expect(find.text('0 contas'), findsOneWidget);
      expect(find.text('Nenhuma conta cadastrada'), findsOneWidget);
    });

    testWidgets('lists accounts with the legacy money format', (tester) async {
      await _pump(tester, seed: _twoAccounts);

      // toStringAsFixed(2) + troca de "." por "," (sem separador de milhar).
      expect(find.text('R\$ 4820,50'), findsOneWidget); // total
      expect(find.text('2 contas'), findsOneWidget);
      expect(find.text('Nubank'), findsOneWidget);
      expect(find.text('Conta Corrente'), findsOneWidget);
      expect(find.text('R\$ 1320,00'), findsOneWidget);
      expect(find.text('Reserva'), findsOneWidget);
      expect(find.text('Poupança'), findsOneWidget);
      expect(find.text('R\$ 3500,50'), findsOneWidget);
      expect(find.text('Nenhuma conta cadastrada'), findsNothing);
    });

    testWidgets('singular caption for exactly one account', (tester) async {
      await _pump(
        tester,
        seed: () => [fakeAccount(id: 1, name: 'Unica', balance: 10)],
      );
      expect(find.text('1 conta'), findsOneWidget);
    });

    testWidgets('type labels for every account type', (tester) async {
      await _pump(
        tester,
        seed: () => [
          fakeAccount(id: 1, name: 'A', type: 'checking'),
          fakeAccount(id: 2, name: 'B', type: 'savings'),
          fakeAccount(id: 3, name: 'C', type: 'credit_card'),
          fakeAccount(id: 4, name: 'D', type: 'other'),
        ],
      );
      for (final label in [
        'Conta Corrente',
        'Poupança',
        'Cartão de Crédito',
        'Outra',
      ]) {
        expect(find.text(label), findsOneWidget, reason: label);
      }
    });
  });

  group('navigation keeps its destinations', () {
    testWidgets('"Receitas" pushes /income', (tester) async {
      final r = await _pump(tester);
      await tester.tap(find.text('Receitas'));
      await tester.pumpAndSettle();
      expect(r.log.events, ['push /income']);
    });

    testWidgets('"Despesas" pushes /expenses', (tester) async {
      final r = await _pump(tester);
      await tester.tap(find.text('Despesas'));
      await tester.pumpAndSettle();
      expect(r.log.events, ['push /expenses']);
    });

    testWidgets('back pops the route', (tester) async {
      final r = await _pump(tester, pushed: true);
      await tester.tap(find.byTooltip('Voltar'));
      await tester.pumpAndSettle();

      expect(r.log.events, ['pop null']);
      expect(find.text(kOriginScreenText), findsOneWidget);
    });
  });

  group('new account sheet', () {
    testWidgets('opens from the FAB with the same four fields', (tester) async {
      await _pump(tester);
      await _openSheetWithFab(tester);

      expect(find.text('Nova Conta'), findsOneWidget);
      for (final label in [
        'Nome da conta',
        'Tipo de conta',
        'Banco (opcional)',
        'Número da conta (opcional)',
      ]) {
        expect(find.text(label), findsOneWidget, reason: label);
      }
      expect(find.widgetWithText(FilledButton, 'Criar conta'), findsOneWidget);
    });

    testWidgets('the empty-state CTA opens the very same sheet', (
      tester,
    ) async {
      await _pump(tester);
      await tester.tap(find.widgetWithText(OutlinedButton, 'Adicionar conta'));
      await tester.pumpAndSettle();

      expect(find.text('Nova Conta'), findsOneWidget);
    });

    testWidgets('empty name is rejected: no provider call, sheet stays', (
      tester,
    ) async {
      final r = await _pump(tester);
      await _openSheetWithFab(tester);

      await _tapCreate(tester);

      expect(r.accounts.addCalls, isEmpty);
      expect(find.text('Digite o nome da conta'), findsOneWidget);
      expect(find.text('Nova Conta'), findsOneWidget);
    });

    testWidgets('whitespace-only name is rejected too', (tester) async {
      final r = await _pump(tester);
      await _openSheetWithFab(tester);

      await _enter(tester, 'Nome da conta', '    ');
      await _tapCreate(tester);

      expect(r.accounts.addCalls, isEmpty);
      expect(find.text('Digite o nome da conta'), findsOneWidget);
    });

    testWidgets(
      'minimal submit: trimmed name, default type, null optionals, sheet closes',
      (tester) async {
        final r = await _pump(tester);
        await _openSheetWithFab(tester);

        await _enter(tester, 'Nome da conta', '  Nubank  ');
        await _tapCreate(tester);

        expect(r.accounts.addCalls, hasLength(1));
        final call = r.accounts.addCalls.single;
        expect(call.token, 'test-token');
        expect(call.name, 'Nubank');
        expect(call.type, 'checking');
        expect(call.bankName, isNull);
        expect(call.accountNumber, isNull);

        expect(find.text('Nova Conta'), findsNothing);
        expect(find.text('Conta criada!'), findsOneWidget);
      },
    );

    testWidgets('optional fields are sent verbatim (not trimmed)', (
      tester,
    ) async {
      final r = await _pump(tester);
      await _openSheetWithFab(tester);

      await _enter(tester, 'Nome da conta', 'Reserva');
      await _enter(tester, 'Banco (opcional)', '  Itaú ');
      await _enter(tester, 'Número da conta (opcional)', '123456-7');
      await _tapCreate(tester);

      final call = r.accounts.addCalls.single;
      expect(call.bankName, '  Itaú ');
      expect(call.accountNumber, '123456-7');
    });

    const types = {
      'Conta Corrente': 'checking',
      'Poupança': 'savings',
      'Cartão de Crédito': 'credit_card',
      'Outra': 'other',
    };
    for (final entry in types.entries) {
      testWidgets('type "${entry.key}" is sent as "${entry.value}"', (
        tester,
      ) async {
        final r = await _pump(tester);
        await _openSheetWithFab(tester);

        await _enter(tester, 'Nome da conta', 'Conta X');
        await tester.tap(find.byType(DropdownButtonFormField<String>));
        await tester.pumpAndSettle();
        await tester.tap(find.text(entry.key).last);
        await tester.pumpAndSettle();
        await _tapCreate(tester);

        expect(r.accounts.addCalls.single.type, entry.value);
      });
    }

    testWidgets('without a token nothing is sent and the sheet stays open', (
      tester,
    ) async {
      final r = await _pump(tester, token: null);
      await _openSheetWithFab(tester);

      await _enter(tester, 'Nome da conta', 'Nubank');
      await _tapCreate(tester);

      expect(r.accounts.addCalls, isEmpty);
      expect(find.text('Nova Conta'), findsOneWidget);
      expect(find.text('Conta criada!'), findsNothing);
    });
  });

  group('remove account', () {
    Future<void> tapRemove(WidgetTester tester, String name) async {
      await tester.tap(find.byTooltip('Remover $name'));
      await tester.pumpAndSettle();
    }

    testWidgets('asks first, naming the account', (tester) async {
      final r = await _pump(tester, seed: _twoAccounts);
      await tapRemove(tester, 'Nubank');

      expect(find.text('Deletar conta?'), findsOneWidget);
      expect(
        find.text('Tem certeza que deseja deletar "Nubank"?'),
        findsOneWidget,
      );
      expect(r.accounts.removeCalls, isEmpty);
    });

    testWidgets('cancel does not call the provider', (tester) async {
      final r = await _pump(tester, seed: _twoAccounts);
      await tapRemove(tester, 'Nubank');

      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(r.accounts.removeCalls, isEmpty);
      expect(find.text('Deletar conta?'), findsNothing);
      expect(find.text('Conta deletada'), findsNothing);
    });

    testWidgets('confirm removes exactly that account', (tester) async {
      final r = await _pump(tester, seed: _twoAccounts);
      await tapRemove(tester, 'Reserva');

      await tester.tap(find.widgetWithText(FilledButton, 'Deletar'));
      await tester.pumpAndSettle();

      expect(r.accounts.removeCalls, hasLength(1));
      expect(r.accounts.removeCalls.single.token, 'test-token');
      expect(r.accounts.removeCalls.single.accountId, 9);
      expect(find.text('Deletar conta?'), findsNothing);
      expect(find.text('Conta deletada'), findsOneWidget);
    });

    testWidgets('without a token: no call, but the notice still shows', (
      tester,
    ) async {
      final r = await _pump(tester, seed: _twoAccounts, token: null);
      await tapRemove(tester, 'Nubank');

      await tester.tap(find.widgetWithText(FilledButton, 'Deletar'));
      await tester.pumpAndSettle();

      expect(r.accounts.removeCalls, isEmpty);
      expect(find.text('Conta deletada'), findsOneWidget);
    });
  });
}
