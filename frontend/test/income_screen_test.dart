// Preservacao de comportamento da tela de Receitas (IncomeScreen).
//
// Cada caso prova que a UI redesenhada continua acionando o IncomeProvider com
// os MESMOS argumentos, navegando para os MESMOS destinos do MESMO jeito (push
// vs replace vs pop), recarregando o MESMO mes e mantendo as MESMAS validacoes.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:miajudai/models/account_model.dart';
import 'package:miajudai/models/income_model.dart';
import 'package:miajudai/screens/income_screen.dart';
import 'package:miajudai/widgets/common/app_date_field.dart';
import 'package:miajudai/widgets/common/app_form_field.dart';
import 'package:miajudai/widgets/finance/month_selector.dart';

import 'support/fake_account_provider.dart';
import 'support/fake_income_provider.dart';
import 'support/pump_screen.dart';
import 'support/test_fonts.dart';

typedef _Env = ({
  FakeIncomeProvider income,
  FakeAccountProvider accounts,
  RouteLog log,
});

Future<_Env> _pump(
  WidgetTester tester, {
  List<IncomeModel> Function()? seed,
  double total = 0,
  List<AccountModel> Function()? accountSeed,
  String? token = 'test-token',
  bool pushed = false,
}) async {
  final income = FakeIncomeProvider()..total = total;
  if (seed != null) income.items = seed();
  final accounts = FakeAccountProvider();
  if (accountSeed != null) accounts.items = accountSeed();

  final env = await pumpScreen(
    tester,
    const IncomeScreen(),
    income: income,
    accounts: accounts,
    pushed: pushed,
    setup: (a) => a.token = token,
  );
  return (income: income, accounts: accounts, log: env.log);
}

List<IncomeModel> _twoIncomes() => [
      fakeIncome(
        id: 3,
        description: 'Salário mensal',
        amount: 1320,
        date: DateTime(2026, 9, 5),
      ),
      fakeIncome(
        id: 8,
        description: 'Freelance site',
        amount: 3500.5,
        type: 'freelance',
        date: DateTime(2026, 8, 12),
      ),
    ];

List<AccountModel> _accounts() => [
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

/// Toca o botao de envio da sheet (o de cima, quando ha outro atras dela).
Future<void> _submit(WidgetTester tester, String label) async {
  await tester.tap(find.widgetWithText(FilledButton, label).last);
  await tester.pumpAndSettle();
}

Future<void> _chooseFrom<T>(
  WidgetTester tester,
  String option,
) async {
  await tester.tap(find.byType(DropdownButtonFormField<T>));
  await tester.pumpAndSettle();
  await tester.tap(find.text(option).last);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() async {
    await loadRedesignFonts();
    await initializeDateFormatting('pt_BR');
  });

  group('loading and month navigation', () {
    testWidgets('loads the current month once, with the auth token', (
      tester,
    ) async {
      final now = DateTime.now();
      final r = await _pump(tester);

      expect(r.income.loadCalls, [
        (token: 'test-token', month: now.month, year: now.year),
      ]);
      expect(find.text(MonthSelector.labelFor(now)), findsOneWidget);
    });

    testWidgets('does not load without a token', (tester) async {
      final r = await _pump(tester, token: null);
      expect(r.income.loadCalls, isEmpty);
    });

    testWidgets('previous / next reload the neighbouring month', (
      tester,
    ) async {
      final now = DateTime.now();
      final r = await _pump(tester);
      r.income.loadCalls.clear();

      await tester.tap(find.byTooltip('Próximo mês'));
      await tester.pumpAndSettle();
      final next = DateTime(now.year, now.month + 1);
      expect(r.income.loadCalls.last,
          (token: 'test-token', month: next.month, year: next.year));
      expect(find.text(MonthSelector.labelFor(next)), findsOneWidget);

      await tester.tap(find.byTooltip('Mês anterior'));
      await tester.tap(find.byTooltip('Mês anterior'));
      await tester.pumpAndSettle();
      final prev = DateTime(now.year, now.month - 1);
      expect(r.income.loadCalls.last,
          (token: 'test-token', month: prev.month, year: prev.year));
      expect(find.text(MonthSelector.labelFor(prev)), findsOneWidget);

      expect(r.income.loadCalls, hasLength(3));
    });

    testWidgets('changing month without a token reloads nothing', (
      tester,
    ) async {
      final now = DateTime.now();
      final r = await _pump(tester, token: null);

      await tester.tap(find.byTooltip('Próximo mês'));
      await tester.pumpAndSettle();

      expect(r.income.loadCalls, isEmpty);
      expect(
        find.text(MonthSelector.labelFor(DateTime(now.year, now.month + 1))),
        findsOneWidget,
      );
    });

    testWidgets('month label is capitalised pt-BR', (tester) async {
      await _pump(tester);
      expect(MonthSelector.labelFor(DateTime(2026, 9)), 'Setembro de 2026');
      expect(MonthSelector.labelFor(DateTime(2027, 1)), 'Janeiro de 2027');
    });
  });

  group('content and calculations come from the provider', () {
    testWidgets('empty state', (tester) async {
      await _pump(tester);

      expect(find.text('Receitas'), findsOneWidget);
      expect(find.text('Acompanhe suas entradas de dinheiro'), findsOneWidget);
      expect(find.text('Total de receitas no mês'), findsOneWidget);
      expect(find.text('R\$ 0,00'), findsOneWidget);
      // legenda do card + titulo do estado vazio
      expect(find.text('Nenhuma receita registrada'), findsNWidgets(2));
      expect(find.text('Registros'), findsOneWidget);
      expect(find.text('Dicas para começar'), findsOneWidget);
      expect(find.text('Registre suas fontes de renda'), findsOneWidget);
    });

    testWidgets('lists records with the legacy money and date format', (
      tester,
    ) async {
      await _pump(tester, seed: _twoIncomes, total: 4820.5);

      // toStringAsFixed(2) + troca de "." por "," (sem separador de milhar).
      expect(find.text('R\$ 4820,50'), findsOneWidget); // monthlyTotal
      expect(find.text('2 receitas registradas'), findsOneWidget);
      expect(find.text('Salário mensal'), findsOneWidget);
      expect(find.text('05/09/2026'), findsOneWidget);
      expect(find.text('R\$ 1320,00'), findsOneWidget);
      expect(find.text('Freelance site'), findsOneWidget);
      expect(find.text('12/08/2026'), findsOneWidget);
      expect(find.text('R\$ 3500,50'), findsOneWidget);
      expect(find.text('Nenhuma receita registrada'), findsNothing);
      expect(find.text('Dicas para começar'), findsNothing);
    });

    testWidgets('the total is monthlyTotal, not the sum of the list', (
      tester,
    ) async {
      await _pump(tester, seed: _twoIncomes, total: 99);
      expect(find.text('R\$ 99,00'), findsOneWidget);
      expect(find.text('R\$ 4820,50'), findsNothing);
    });

    testWidgets('singular caption for exactly one record', (tester) async {
      await _pump(
        tester,
        seed: () => [fakeIncome(id: 1, description: 'Unica', amount: 10)],
      );
      expect(find.text('1 receita registrada'), findsOneWidget);
    });

    testWidgets('one icon per income type', (tester) async {
      await _pump(
        tester,
        seed: () => [
          fakeIncome(id: 1, description: 'A', type: 'salary'),
          fakeIncome(id: 2, description: 'B', type: 'freelance'),
          fakeIncome(id: 3, description: 'C', type: 'investment'),
          fakeIncome(id: 4, description: 'D', type: 'gift'),
          fakeIncome(id: 5, description: 'E', type: 'other'),
        ],
      );
      expect(find.byIcon(Icons.payments_outlined), findsOneWidget);
      expect(find.byIcon(Icons.work_outline_rounded), findsOneWidget);
      expect(find.byIcon(Icons.card_giftcard_outlined), findsOneWidget);
      expect(find.byIcon(Icons.monetization_on_outlined), findsOneWidget);
      // o de investimento + o do card de resumo
      expect(find.byIcon(Icons.trending_up_rounded), findsNWidgets(2));
    });
  });

  group('navigation keeps its destinations', () {
    testWidgets('the header action pushes /expenses', (tester) async {
      final r = await _pump(tester);
      await tester.tap(find.byTooltip('Despesas'));
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

  group('new income sheet', () {
    testWidgets('opens from the FAB with the same fields, in order', (
      tester,
    ) async {
      await _pump(tester);
      await _openSheetWithFab(tester);

      expect(find.text('Nova Receita'), findsOneWidget);
      final labels = [
        'Valor',
        'Descrição',
        'Tipo de receita',
        'Conta (opcional)',
        'Data',
      ];
      for (final label in labels) {
        expect(find.text(label), findsOneWidget, reason: label);
      }
      // ordem de cima para baixo
      final tops = [for (final l in labels) tester.getTopLeft(find.text(l)).dy];
      expect(tops, [...tops]..sort());
      expect(find.text('R\$ '), findsOneWidget); // prefixo do valor
    });

    testWidgets('the empty-state CTA opens the very same sheet', (
      tester,
    ) async {
      await _pump(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'Adicionar receita'));
      await tester.pumpAndSettle();

      expect(find.text('Nova Receita'), findsOneWidget);
    });

    testWidgets('the date defaults to the selected month', (tester) async {
      final now = DateTime.now();
      final r = await _pump(tester);
      await _openSheetWithFab(tester);
      await _enter(tester, 'Valor', '10');
      await _enter(tester, 'Descrição', 'x');
      await _submit(tester, 'Adicionar receita');

      final d = r.income.addCalls.single.date;
      expect(DateTime(d.year, d.month, d.day),
          DateTime(now.year, now.month, now.day));
    });

    testWidgets('after navigating, the default date is that month', (
      tester,
    ) async {
      final now = DateTime.now();
      final r = await _pump(tester);
      await tester.tap(find.byTooltip('Próximo mês'));
      await tester.pumpAndSettle();

      await _openSheetWithFab(tester);
      await _enter(tester, 'Valor', '10');
      await _enter(tester, 'Descrição', 'x');
      await _submit(tester, 'Adicionar receita');

      expect(r.income.addCalls.single.date, DateTime(now.year, now.month + 1));
    });

    group('validation', () {
      const missing = 'Preencha valor e descrição';

      Future<_Env> open(WidgetTester tester) async {
        final r = await _pump(tester);
        await _openSheetWithFab(tester);
        return r;
      }

      testWidgets('nothing filled', (tester) async {
        final r = await open(tester);
        await _submit(tester, 'Adicionar receita');

        expect(r.income.addCalls, isEmpty);
        expect(find.text(missing), findsOneWidget);
        expect(find.text('Nova Receita'), findsOneWidget);
      });

      testWidgets('amount only', (tester) async {
        final r = await open(tester);
        await _enter(tester, 'Valor', '10');
        await _submit(tester, 'Adicionar receita');

        expect(r.income.addCalls, isEmpty);
        expect(find.text(missing), findsOneWidget);
      });

      testWidgets('description only', (tester) async {
        final r = await open(tester);
        await _enter(tester, 'Descrição', 'Salário');
        await _submit(tester, 'Adicionar receita');

        expect(r.income.addCalls, isEmpty);
        expect(find.text(missing), findsOneWidget);
      });

      testWidgets('whitespace-only counts as empty', (tester) async {
        final r = await open(tester);
        await _enter(tester, 'Valor', '   ');
        await _enter(tester, 'Descrição', '   ');
        await _submit(tester, 'Adicionar receita');

        expect(r.income.addCalls, isEmpty);
        expect(find.text(missing), findsOneWidget);
      });

      testWidgets('a non-numeric amount is "Valor inválido"', (tester) async {
        final r = await open(tester);
        await _enter(tester, 'Valor', 'abc');
        await _enter(tester, 'Descrição', 'Salário');
        await _submit(tester, 'Adicionar receita');

        expect(r.income.addCalls, isEmpty);
        expect(find.text('Valor inválido'), findsOneWidget);
        expect(find.text('Nova Receita'), findsOneWidget);
      });

      testWidgets('a thousands separator is still rejected (legacy)', (
        tester,
      ) async {
        final r = await open(tester);
        await _enter(tester, 'Valor', '1.234,56');
        await _enter(tester, 'Descrição', 'Salário');
        await _submit(tester, 'Adicionar receita');

        expect(r.income.addCalls, isEmpty);
        expect(find.text('Valor inválido'), findsOneWidget);
      });
    });

    group('submit', () {
      testWidgets(
        'sends the exact payload, then snackbar -> pop -> replace /accounts',
        (tester) async {
          final r = await _pump(tester);
          await _openSheetWithFab(tester);
          r.log.events.clear();

          await _enter(tester, 'Valor', ' 1234,56 ');
          await _enter(tester, 'Descrição', '  Salário mensal  ');
          await _submit(tester, 'Adicionar receita');

          expect(r.income.addCalls, hasLength(1));
          final c = r.income.addCalls.single;
          expect(c.token, 'test-token');
          expect(c.amount, 1234.56); // virgula vira ponto
          expect(c.description, 'Salário mensal'); // aparado
          expect(c.type, 'salary'); // padrao
          expect(c.accountId, isNull); // "Nenhuma conta"
          expect(c.isRecurring, isFalse);
          expect(c.recurrenceType, isNull);

          expect(find.text('Receita adicionada!'), findsOneWidget);
          // fecha a sheet e SUBSTITUI a tela por /accounts (nao empilha).
          expect(r.log.events, ['pop null', 'replace /accounts']);
          expect(find.text('DESTINO /accounts'), findsOneWidget);
        },
      );

      const types = {
        'Salário': 'salary',
        'Freelance': 'freelance',
        'Investimento': 'investment',
        'Presente': 'gift',
        'Outro': 'other',
      };
      for (final entry in types.entries) {
        testWidgets('type "${entry.key}" is sent as "${entry.value}"', (
          tester,
        ) async {
          final r = await _pump(tester);
          await _openSheetWithFab(tester);

          await _enter(tester, 'Valor', '10');
          await _enter(tester, 'Descrição', 'x');
          await _chooseFrom<String>(tester, entry.key);
          await _submit(tester, 'Adicionar receita');

          expect(r.income.addCalls.single.type, entry.value);
        });
      }

      testWidgets('lists the accounts and sends the chosen id', (
        tester,
      ) async {
        final r = await _pump(tester, accountSeed: _accounts);
        await _openSheetWithFab(tester);

        await tester.tap(find.byType(DropdownButtonFormField<int?>));
        await tester.pumpAndSettle();
        // nome + saldo com duas casas, ponto decimal (formato do legado)
        expect(find.text('Nenhuma conta'), findsWidgets);
        expect(find.text('Nubank (R\$ 1320.00)'), findsOneWidget);
        expect(find.text('Reserva (R\$ 3500.50)'), findsOneWidget);
        await tester.tap(find.text('Reserva (R\$ 3500.50)'));
        await tester.pumpAndSettle();

        await _enter(tester, 'Valor', '10');
        await _enter(tester, 'Descrição', 'x');
        await _submit(tester, 'Adicionar receita');

        expect(r.income.addCalls.single.accountId, 9);
      });

      testWidgets('the picked date is what gets sent', (tester) async {
        final now = DateTime.now();
        final r = await _pump(tester);
        await _openSheetWithFab(tester);

        await tester.tap(find.byType(AppDateField));
        await tester.pumpAndSettle();
        await tester.tap(
          find.descendant(
            of: find.byType(CalendarDatePicker),
            matching: find.text('15'),
          ),
        );
        await tester.pump();
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();

        final shown = '15/${now.month.toString().padLeft(2, '0')}/${now.year}';
        expect(find.text(shown), findsOneWidget);

        await _enter(tester, 'Valor', '10');
        await _enter(tester, 'Descrição', 'x');
        await _submit(tester, 'Adicionar receita');

        expect(
            r.income.addCalls.single.date, DateTime(now.year, now.month, 15));
      });

      testWidgets('cancelling the date picker keeps the date', (
        tester,
      ) async {
        final now = DateTime.now();
        final r = await _pump(tester);
        await _openSheetWithFab(tester);

        await tester.tap(find.byType(AppDateField));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        await _enter(tester, 'Valor', '10');
        await _enter(tester, 'Descrição', 'x');
        await _submit(tester, 'Adicionar receita');

        final d = r.income.addCalls.single.date;
        expect(DateTime(d.year, d.month, d.day),
            DateTime(now.year, now.month, now.day));
      });

      testWidgets('without a token nothing is sent and the sheet stays', (
        tester,
      ) async {
        final r = await _pump(tester, token: null);
        await _openSheetWithFab(tester);

        await _enter(tester, 'Valor', '10');
        await _enter(tester, 'Descrição', 'x');
        await _submit(tester, 'Adicionar receita');

        expect(r.income.addCalls, isEmpty);
        expect(find.text('Nova Receita'), findsOneWidget);
        expect(find.text('Receita adicionada!'), findsNothing);
      });
    });
  });

  group('edit income sheet', () {
    Future<_Env> open(WidgetTester tester) async {
      final r = await _pump(tester, seed: _twoIncomes);
      await tester.tap(find.byTooltip('Editar Freelance site'));
      await tester.pumpAndSettle();
      return r;
    }

    testWidgets('is prefilled and has only amount, description and type', (
      tester,
    ) async {
      await open(tester);

      expect(find.text('Editar Receita'), findsOneWidget);
      expect(find.widgetWithText(TextField, '3500.5'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Freelance site'), findsOneWidget);
      expect(find.text('Tipo'), findsOneWidget);
      expect(find.text('Freelance'), findsOneWidget); // valor atual do tipo
      expect(find.text('Conta (opcional)'), findsNothing);
      expect(find.byType(AppDateField), findsNothing);
      expect(find.widgetWithText(FilledButton, 'Salvar alterações'),
          findsOneWidget);
    });

    testWidgets('saving untouched sends the original values and only pops', (
      tester,
    ) async {
      final r = await open(tester);
      r.log.events.clear();

      await _submit(tester, 'Salvar alterações');

      expect(r.income.updateCalls, hasLength(1));
      final c = r.income.updateCalls.single;
      expect(c.token, 'test-token');
      expect(c.id, 8);
      expect(c.amount, 3500.5);
      expect(c.description, 'Freelance site');
      expect(c.type, 'freelance');
      expect(c.date, DateTime(2026, 8, 12)); // a data nao e editavel

      expect(find.text('Editar Receita'), findsNothing);
      expect(find.text('Receita atualizada!'), findsOneWidget);
      expect(r.log.events, ['pop null']); // sem navegacao
      expect(r.income.addCalls, isEmpty);
    });

    testWidgets('sends the edited values', (tester) async {
      final r = await open(tester);

      await _enter(tester, 'Valor', '2000,75');
      await _enter(tester, 'Descrição', '  Novo nome ');
      await _chooseFrom<String>(tester, 'Presente');
      await _submit(tester, 'Salvar alterações');

      final c = r.income.updateCalls.single;
      expect(c.id, 8);
      expect(c.amount, 2000.75);
      expect(c.description, 'Novo nome');
      expect(c.type, 'gift');
    });

    testWidgets('empty fields are rejected', (tester) async {
      final r = await open(tester);

      await _enter(tester, 'Descrição', '');
      await _submit(tester, 'Salvar alterações');

      expect(r.income.updateCalls, isEmpty);
      expect(find.text('Preencha todos os campos'), findsOneWidget);
      expect(find.text('Editar Receita'), findsOneWidget);
    });

    testWidgets('a non-numeric amount is "Valor inválido"', (tester) async {
      final r = await open(tester);

      await _enter(tester, 'Valor', 'abc');
      await _submit(tester, 'Salvar alterações');

      expect(r.income.updateCalls, isEmpty);
      expect(find.text('Valor inválido'), findsOneWidget);
    });

    testWidgets('without a token nothing is sent and the sheet stays', (
      tester,
    ) async {
      final r = await _pump(tester, seed: _twoIncomes, token: null);
      await tester.tap(find.byTooltip('Editar Salário mensal'));
      await tester.pumpAndSettle();

      await _submit(tester, 'Salvar alterações');

      expect(r.income.updateCalls, isEmpty);
      expect(find.text('Editar Receita'), findsOneWidget);
    });
  });

  group('remove income', () {
    Future<void> tapRemove(WidgetTester tester, String description) async {
      await tester.tap(find.byTooltip('Remover $description'));
      await tester.pumpAndSettle();
    }

    testWidgets('asks first, naming the record', (tester) async {
      final r = await _pump(tester, seed: _twoIncomes);
      await tapRemove(tester, 'Salário mensal');

      expect(find.text('Deletar receita?'), findsOneWidget);
      expect(
        find.text('Tem certeza que deseja deletar "Salário mensal"?'),
        findsOneWidget,
      );
      expect(r.income.removeCalls, isEmpty);
    });

    testWidgets('cancel does not call the provider', (tester) async {
      final r = await _pump(tester, seed: _twoIncomes);
      await tapRemove(tester, 'Salário mensal');

      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(r.income.removeCalls, isEmpty);
      expect(find.text('Deletar receita?'), findsNothing);
      expect(find.text('Receita deletada'), findsNothing);
    });

    testWidgets('confirm removes exactly that record', (tester) async {
      final r = await _pump(tester, seed: _twoIncomes);
      await tapRemove(tester, 'Freelance site');

      await tester.tap(find.widgetWithText(FilledButton, 'Deletar'));
      await tester.pumpAndSettle();

      expect(r.income.removeCalls, [(token: 'test-token', id: 8)]);
      expect(find.text('Deletar receita?'), findsNothing);
      expect(find.text('Receita deletada'), findsOneWidget);
    });

    testWidgets('without a token: no call, but the notice still shows', (
      tester,
    ) async {
      final r = await _pump(tester, seed: _twoIncomes, token: null);
      await tapRemove(tester, 'Salário mensal');

      await tester.tap(find.widgetWithText(FilledButton, 'Deletar'));
      await tester.pumpAndSettle();

      expect(r.income.removeCalls, isEmpty);
      expect(find.text('Receita deletada'), findsOneWidget);
    });
  });
}
