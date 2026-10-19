// Preservacao de comportamento da tela de Despesas (ExpensesScreen).
//
// Cada caso prova que a UI redesenhada continua acionando o ExpenseProvider com
// os MESMOS argumentos, navegando para os MESMOS destinos do MESMO jeito (push
// vs replace vs pop), recarregando o MESMO mes, filtrando e somando por aba do
// MESMO jeito (com TabBarView/deslize) e mantendo as MESMAS validacoes.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:miajudai/models/account_model.dart';
import 'package:miajudai/models/expense_model.dart';
import 'package:miajudai/screens/expenses_screen.dart';
import 'package:miajudai/widgets/common/app_date_field.dart';
import 'package:miajudai/widgets/common/app_form_field.dart';
import 'package:miajudai/widgets/common/app_segmented_tabs.dart';
import 'package:miajudai/widgets/common/section_header.dart';
import 'package:miajudai/widgets/finance/month_selector.dart';

import 'support/fake_account_provider.dart';
import 'support/fake_expense_provider.dart';
import 'support/pump_screen.dart';
import 'support/test_fonts.dart';

typedef _Env = ({
  FakeExpenseProvider expenses,
  FakeAccountProvider accounts,
  RouteLog log,
});

Future<_Env> _pump(
  WidgetTester tester, {
  List<ExpenseModel> Function()? seed,
  List<AccountModel> Function()? accountSeed,
  String? token = 'test-token',
  bool pushed = false,
}) async {
  final expenses = FakeExpenseProvider();
  if (seed != null) expenses.items = seed();
  final accounts = FakeAccountProvider();
  if (accountSeed != null) accounts.items = accountSeed();

  final env = await pumpScreen(
    tester,
    const ExpensesScreen(),
    expenses: expenses,
    accounts: accounts,
    pushed: pushed,
    setup: (a) => a.token = token,
  );
  return (expenses: expenses, accounts: accounts, log: env.log);
}

/// 8 despesas que exercitam cada filtro:
///  - Contas Fixas: categorias 1..4  -> ids 1, 2
///  - Variaveis: fora de {1,2,3,4,12} e NAO cartao de credito -> ids 3, 4, 8
///  - Cartao: paymentMethod == credit_card (mesmo com categoria variavel)
///    -> ids 5, 6
///  - id 7 (categoria 12) so aparece em "Tudo".
List<ExpenseModel> _mixed() => [
      fakeExpense(
          id: 1, description: 'Conta de água', amount: 89.9, categoryId: 1),
      fakeExpense(
        id: 2,
        description: 'Aluguel',
        amount: 1500,
        categoryId: 4,
        paymentMethod: 'transfer',
      ),
      fakeExpense(
        id: 3,
        description: 'Mercado',
        amount: 320.45,
        categoryId: 5,
        paymentMethod: 'debit_card',
        status: 'pending',
      ),
      fakeExpense(id: 4, description: 'Cinema', amount: 60, categoryId: 9),
      fakeExpense(
        id: 5,
        description: 'Notebook',
        amount: 2500,
        categoryId: 5,
        paymentMethod: 'credit_card',
      ),
      fakeExpense(
        id: 6,
        description: 'Uber',
        amount: 40,
        categoryId: 6,
        paymentMethod: 'credit_card',
      ),
      fakeExpense(id: 7, description: 'Assinatura', amount: 30, categoryId: 12),
      fakeExpense(id: 8, description: 'Outros', amount: 15, categoryId: 10),
    ];

List<AccountModel> _accounts() => [
      fakeAccount(id: 7, name: 'Nubank', balance: 1320),
      fakeAccount(id: 9, name: 'Reserva', type: 'savings', balance: 3500.5),
    ];

Finder _pill(String label) => find.descendant(
      of: find.byType(AppSegmentedTabs),
      matching: find.text(label),
    );

Finder _sectionTitle(String title) => find.descendant(
      of: find.byType(SectionHeader),
      matching: find.text(title),
    );

Future<void> _openTab(WidgetTester tester, String label) async {
  await tester.tap(_pill(label));
  await tester.pumpAndSettle();
}

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

Future<void> _chooseFrom<T>(WidgetTester tester, String option) async {
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

      expect(r.expenses.loadCalls, [
        (token: 'test-token', month: now.month, year: now.year),
      ]);
      expect(find.text(MonthSelector.labelFor(now)), findsOneWidget);
    });

    testWidgets('does not load without a token', (tester) async {
      final r = await _pump(tester, token: null);
      expect(r.expenses.loadCalls, isEmpty);
    });

    testWidgets('previous / next reload the neighbouring month', (
      tester,
    ) async {
      final now = DateTime.now();
      final r = await _pump(tester);
      r.expenses.loadCalls.clear();

      await tester.tap(find.byTooltip('Próximo mês'));
      await tester.pumpAndSettle();
      final next = DateTime(now.year, now.month + 1);
      expect(r.expenses.loadCalls.last,
          (token: 'test-token', month: next.month, year: next.year));
      expect(find.text(MonthSelector.labelFor(next)), findsOneWidget);

      await tester.tap(find.byTooltip('Mês anterior'));
      await tester.tap(find.byTooltip('Mês anterior'));
      await tester.pumpAndSettle();
      final prev = DateTime(now.year, now.month - 1);
      expect(r.expenses.loadCalls.last,
          (token: 'test-token', month: prev.month, year: prev.year));
      expect(find.text(MonthSelector.labelFor(prev)), findsOneWidget);

      expect(r.expenses.loadCalls, hasLength(3));
    });

    testWidgets('changing month without a token reloads nothing', (
      tester,
    ) async {
      final r = await _pump(tester, token: null);

      await tester.tap(find.byTooltip('Próximo mês'));
      await tester.pumpAndSettle();

      expect(r.expenses.loadCalls, isEmpty);
    });

    testWidgets('changing month keeps the selected tab', (tester) async {
      await _pump(tester, seed: _mixed);
      await _openTab(tester, 'Cartão');

      await tester.tap(find.byTooltip('Próximo mês'));
      await tester.pumpAndSettle();

      expect(_sectionTitle('Cartão'), findsOneWidget);
      expect(find.text('Notebook'), findsOneWidget);
    });
  });

  group('tabs filter and sum exactly as before', () {
    testWidgets('the four tabs are there, "Tudo" first', (tester) async {
      await _pump(tester);
      for (final t in ['Tudo', 'Contas Fixas', 'Variáveis', 'Cartão']) {
        expect(_pill(t), findsOneWidget, reason: t);
      }
      final xs = [
        for (final t in ['Tudo', 'Contas Fixas', 'Variáveis', 'Cartão'])
          tester.getTopLeft(_pill(t)).dx
      ];
      expect(xs, [...xs]..sort());
      expect(_sectionTitle('Todas as despesas'), findsOneWidget);
    });

    testWidgets('Tudo lists everything and sums the whole list', (
      tester,
    ) async {
      await _pump(tester, seed: _mixed);

      expect(find.text('Total de despesas no mês'), findsOneWidget);
      // 89.9 + 1500 + 320.45 + 60 + 2500 + 40 + 30 + 15
      expect(find.text('R\$ 4555,35'), findsOneWidget);
      expect(find.text('8 despesas registradas'), findsOneWidget);
      for (final d in [
        'Conta de água',
        'Aluguel',
        'Mercado',
        'Cinema',
        'Notebook',
        'Uber',
        'Assinatura',
        'Outros',
      ]) {
        await tester.ensureVisible(find.text(d));
        expect(find.text(d), findsOneWidget, reason: d);
      }
    });

    testWidgets('Contas Fixas = categories 1..4', (tester) async {
      await _pump(tester, seed: _mixed);
      await _openTab(tester, 'Contas Fixas');

      expect(_sectionTitle('Contas Fixas'), findsOneWidget);
      expect(find.text('Total de Contas Fixas no mês'), findsOneWidget);
      expect(find.text('R\$ 1589,90'), findsOneWidget); // 89.9 + 1500
      expect(find.text('2 despesas registradas'), findsOneWidget);
      expect(find.text('Conta de água'), findsOneWidget);
      expect(find.text('Aluguel'), findsOneWidget);
      for (final d in ['Mercado', 'Cinema', 'Notebook', 'Uber', 'Assinatura']) {
        expect(find.text(d), findsNothing, reason: d);
      }
    });

    testWidgets(
      'Variáveis = not 1..4 / 12 and not credit card',
      (tester) async {
        await _pump(tester, seed: _mixed);
        await _openTab(tester, 'Variáveis');

        expect(_sectionTitle('Variáveis'), findsOneWidget);
        expect(find.text('R\$ 395,45'), findsOneWidget); // 320.45 + 60 + 15
        expect(find.text('3 despesas registradas'), findsOneWidget);
        for (final d in ['Mercado', 'Cinema', 'Outros']) {
          expect(find.text(d), findsOneWidget, reason: d);
        }
        // categoria 12, cartao de credito (mesmo com categoria 5/6) e fixas
        for (final d in ['Assinatura', 'Notebook', 'Uber', 'Aluguel']) {
          expect(find.text(d), findsNothing, reason: d);
        }
      },
    );

    testWidgets('Cartão = credit_card, whatever the category', (tester) async {
      await _pump(tester, seed: _mixed);
      await _openTab(tester, 'Cartão');

      expect(_sectionTitle('Cartão'), findsOneWidget);
      expect(find.text('Total de Cartão no mês'), findsOneWidget);
      expect(find.text('R\$ 2540,00'), findsOneWidget);
      expect(find.text('2 despesas registradas'), findsOneWidget);
      expect(find.text('Notebook'), findsOneWidget);
      expect(find.text('Uber'), findsOneWidget);
      expect(find.text('Mercado'), findsNothing);
    });

    testWidgets('the totals never read provider.monthlyTotal', (tester) async {
      // O fake nao implementa `monthlyTotal`: se a tela o lesse, o teste
      // quebraria. Os totais vem da soma da lista filtrada da aba.
      await _pump(tester, seed: _mixed);
      await _openTab(tester, 'Cartão');
      expect(tester.takeException(), isNull);
    });

    testWidgets('an empty tab shows the empty state and the tips', (
      tester,
    ) async {
      await _pump(
        tester,
        seed: () => [fakeExpense(id: 1, description: 'So variavel')],
      );
      await _openTab(tester, 'Cartão');

      expect(find.text('Nenhuma despesa neste mês'), findsOneWidget);
      expect(find.text('Nenhuma despesa registrada'), findsOneWidget);
      expect(find.text('R\$ 0,00'), findsOneWidget);
      expect(find.text('Dicas para começar'), findsOneWidget);
      expect(find.text('Categorize seus gastos'), findsOneWidget);
    });

    testWidgets('swiping moves between tabs (TabBarView is intact)', (
      tester,
    ) async {
      await _pump(tester, seed: _mixed);
      expect(_sectionTitle('Todas as despesas'), findsOneWidget);

      await tester.fling(find.byType(TabBarView), const Offset(-400, 0), 2000);
      await tester.pumpAndSettle();
      expect(_sectionTitle('Contas Fixas'), findsOneWidget);
      expect(find.text('Aluguel'), findsOneWidget);

      await tester.fling(find.byType(TabBarView), const Offset(400, 0), 2000);
      await tester.pumpAndSettle();
      expect(_sectionTitle('Todas as despesas'), findsOneWidget);
    });

    testWidgets('the selected pill follows the tab, by swipe or by tap', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await _pump(tester);

      Finder pill(String l, int n) => find.bySemanticsLabel('$l, aba $n de 4');
      expect(
          tester.getSemantics(pill('Tudo', 1)), isSemantics(isSelected: true));
      expect(tester.getSemantics(pill('Cartão', 4)),
          isSemantics(isSelected: false));

      await tester.tap(pill('Cartão', 4));
      await tester.pumpAndSettle();
      expect(tester.getSemantics(pill('Cartão', 4)),
          isSemantics(isSelected: true));
      expect(
          tester.getSemantics(pill('Tudo', 1)), isSemantics(isSelected: false));

      await tester.fling(find.byType(TabBarView), const Offset(400, 0), 2000);
      await tester.pumpAndSettle();
      expect(tester.getSemantics(pill('Variáveis', 3)),
          isSemantics(isSelected: true));
      handle.dispose();
    });

    testWidgets('lists records with the legacy money and date format', (
      tester,
    ) async {
      await _pump(
        tester,
        seed: () => [
          fakeExpense(
            id: 1,
            description: 'Mercado',
            amount: 1234.5,
            date: DateTime(2026, 9, 5),
          ),
        ],
      );
      // toStringAsFixed(2) + troca de "." por "," (sem separador de milhar).
      expect(find.text('R\$ 1234,50'), findsNWidgets(2)); // total + item
      expect(find.text('05/09/2026'), findsOneWidget);
      expect(find.text('1 despesa registrada'), findsOneWidget);
    });

    testWidgets('one icon per category', (tester) async {
      await _pump(
        tester,
        seed: () => [
          for (var c = 1; c <= 9; c++)
            fakeExpense(id: c, description: 'D$c', categoryId: c),
          fakeExpense(id: 10, description: 'D10', categoryId: 42),
        ],
      );
      for (final icon in [
        Icons.water_drop_outlined,
        Icons.bolt_outlined,
        Icons.wifi_outlined,
        Icons.home_outlined,
        Icons.restaurant_outlined,
        Icons.directions_car_outlined,
        Icons.favorite_border_rounded,
        Icons.school_outlined,
        Icons.sports_esports_outlined,
      ]) {
        await tester.scrollUntilVisible(find.byIcon(icon), 200,
            scrollable: find.byType(Scrollable).last);
        expect(find.byIcon(icon), findsOneWidget, reason: '$icon');
      }
      await tester.scrollUntilVisible(find.byIcon(Icons.receipt_outlined), 200,
          scrollable: find.byType(Scrollable).last);
      expect(find.byIcon(Icons.receipt_outlined), findsOneWidget);
    });
  });

  group('navigation keeps its destinations', () {
    testWidgets('the header action pushes /income', (tester) async {
      final r = await _pump(tester);
      await tester.tap(find.byTooltip('Receitas'));
      await tester.pumpAndSettle();
      expect(r.log.events, ['push /income']);
    });

    testWidgets('back pops the route', (tester) async {
      final r = await _pump(tester, pushed: true);
      await tester.tap(find.byTooltip('Voltar'));
      await tester.pumpAndSettle();

      expect(r.log.events, ['pop null']);
      expect(find.text(kOriginScreenText), findsOneWidget);
    });
  });

  group('new expense sheet', () {
    testWidgets('opens from the FAB with the same fields, in order', (
      tester,
    ) async {
      await _pump(tester);
      await _openSheetWithFab(tester);

      expect(find.text('Nova Despesa'), findsOneWidget);
      final labels = [
        'Valor',
        'Descrição',
        'Categoria',
        'Forma de Pagamento',
        'Conta (opcional)',
        'Data',
      ];
      for (final label in labels) {
        expect(find.text(label), findsOneWidget, reason: label);
      }
      final tops = [for (final l in labels) tester.getTopLeft(find.text(l)).dy];
      expect(tops, [...tops]..sort());
      expect(find.text('R\$ '), findsOneWidget);
    });

    testWidgets('the empty-state CTA opens the very same sheet', (
      tester,
    ) async {
      await _pump(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'Adicionar despesa'));
      await tester.pumpAndSettle();

      expect(find.text('Nova Despesa'), findsOneWidget);
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
      await _submit(tester, 'Adicionar despesa');

      expect(
          r.expenses.addCalls.single.date, DateTime(now.year, now.month + 1));
    });

    group('validation', () {
      const missing = 'Preencha todos os campos';

      Future<_Env> open(WidgetTester tester) async {
        final r = await _pump(tester);
        await _openSheetWithFab(tester);
        return r;
      }

      testWidgets('nothing filled', (tester) async {
        final r = await open(tester);
        await _submit(tester, 'Adicionar despesa');

        expect(r.expenses.addCalls, isEmpty);
        expect(find.text(missing), findsOneWidget);
        expect(find.text('Nova Despesa'), findsOneWidget);
      });

      testWidgets('amount only', (tester) async {
        final r = await open(tester);
        await _enter(tester, 'Valor', '10');
        await _submit(tester, 'Adicionar despesa');

        expect(r.expenses.addCalls, isEmpty);
        expect(find.text(missing), findsOneWidget);
      });

      testWidgets('description only', (tester) async {
        final r = await open(tester);
        await _enter(tester, 'Descrição', 'Mercado');
        await _submit(tester, 'Adicionar despesa');

        expect(r.expenses.addCalls, isEmpty);
        expect(find.text(missing), findsOneWidget);
      });

      testWidgets('whitespace-only counts as empty', (tester) async {
        final r = await open(tester);
        await _enter(tester, 'Valor', '   ');
        await _enter(tester, 'Descrição', '   ');
        await _submit(tester, 'Adicionar despesa');

        expect(r.expenses.addCalls, isEmpty);
        expect(find.text(missing), findsOneWidget);
      });

      testWidgets('a non-numeric amount is "Valor inválido"', (tester) async {
        final r = await open(tester);
        await _enter(tester, 'Valor', 'abc');
        await _enter(tester, 'Descrição', 'Mercado');
        await _submit(tester, 'Adicionar despesa');

        expect(r.expenses.addCalls, isEmpty);
        expect(find.text('Valor inválido'), findsOneWidget);
        expect(find.text('Nova Despesa'), findsOneWidget);
      });
    });

    group('submit', () {
      testWidgets(
        'sends the exact payload, then snackbar -> pop -> replace /accounts',
        (tester) async {
          final r = await _pump(tester);
          await _openSheetWithFab(tester);
          r.log.events.clear();

          await _enter(tester, 'Valor', ' 89,90 ');
          await _enter(tester, 'Descrição', '  Conta de água  ');
          await _submit(tester, 'Adicionar despesa');

          expect(r.expenses.addCalls, hasLength(1));
          final c = r.expenses.addCalls.single;
          expect(c.token, 'test-token');
          expect(c.categoryId, 1); // Água, o primeiro da lista
          expect(c.amount, 89.9); // virgula vira ponto
          expect(c.description, 'Conta de água'); // aparado
          expect(c.accountId, isNull); // "Nenhuma conta"
          expect(c.paymentMethod, 'cash'); // padrao
          expect(c.status, 'paid'); // sem campo na tela
          expect(c.isRecurring, isFalse);
          expect(c.recurrenceType, isNull);
          expect(c.tags, isNull);

          expect(find.text('Despesa adicionada!'), findsOneWidget);
          // fecha a sheet e SUBSTITUI a tela por /accounts (nao empilha).
          expect(r.log.events, ['pop null', 'replace /accounts']);
          expect(find.text('DESTINO /accounts'), findsOneWidget);
        },
      );

      const categories = {
        'Água': 1,
        'Luz': 2,
        'Internet': 3,
        'Aluguel': 4,
        'Alimentação': 5,
        'Transporte': 6,
        'Saúde': 7,
        'Educação': 8,
        'Diversão': 9,
      };
      for (final entry in categories.entries) {
        testWidgets('category "${entry.key}" is sent as ${entry.value}', (
          tester,
        ) async {
          final r = await _pump(tester);
          await _openSheetWithFab(tester);

          await _enter(tester, 'Valor', '10');
          await _enter(tester, 'Descrição', 'x');
          await _chooseFrom<int>(tester, entry.key);
          await _submit(tester, 'Adicionar despesa');

          expect(r.expenses.addCalls.single.categoryId, entry.value);
        });
      }

      const methods = {
        'Dinheiro': 'cash',
        'Cartão Débito': 'debit_card',
        'Cartão Crédito': 'credit_card',
        'Transferência': 'transfer',
        'Outro': 'other',
      };
      for (final entry in methods.entries) {
        testWidgets('payment "${entry.key}" is sent as "${entry.value}"', (
          tester,
        ) async {
          final r = await _pump(tester);
          await _openSheetWithFab(tester);

          await _enter(tester, 'Valor', '10');
          await _enter(tester, 'Descrição', 'x');
          await _chooseFrom<String>(tester, entry.key);
          await _submit(tester, 'Adicionar despesa');

          expect(r.expenses.addCalls.single.paymentMethod, entry.value);
        });
      }

      testWidgets('lists the accounts and sends the chosen id', (
        tester,
      ) async {
        final r = await _pump(tester, accountSeed: _accounts);
        await _openSheetWithFab(tester);

        await tester.tap(find.byType(DropdownButtonFormField<int?>));
        await tester.pumpAndSettle();
        expect(find.text('Nenhuma conta'), findsWidgets);
        expect(find.text('Nubank (R\$ 1320.00)'), findsOneWidget);
        expect(find.text('Reserva (R\$ 3500.50)'), findsOneWidget);
        await tester.tap(find.text('Reserva (R\$ 3500.50)'));
        await tester.pumpAndSettle();

        await _enter(tester, 'Valor', '10');
        await _enter(tester, 'Descrição', 'x');
        await _submit(tester, 'Adicionar despesa');

        expect(r.expenses.addCalls.single.accountId, 9);
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

        await _enter(tester, 'Valor', '10');
        await _enter(tester, 'Descrição', 'x');
        await _submit(tester, 'Adicionar despesa');

        expect(
            r.expenses.addCalls.single.date, DateTime(now.year, now.month, 15));
      });

      testWidgets('without a token nothing is sent and the sheet stays', (
        tester,
      ) async {
        final r = await _pump(tester, token: null);
        await _openSheetWithFab(tester);

        await _enter(tester, 'Valor', '10');
        await _enter(tester, 'Descrição', 'x');
        await _submit(tester, 'Adicionar despesa');

        expect(r.expenses.addCalls, isEmpty);
        expect(find.text('Nova Despesa'), findsOneWidget);
        expect(find.text('Despesa adicionada!'), findsNothing);
      });
    });
  });

  group('edit expense sheet', () {
    Future<_Env> open(WidgetTester tester) async {
      final r = await _pump(tester, seed: _mixed);
      await tester.tap(find.byTooltip('Editar Mercado'));
      await tester.pumpAndSettle();
      return r;
    }

    testWidgets('is prefilled and has only the four legacy fields', (
      tester,
    ) async {
      await open(tester);

      expect(find.text('Editar Despesa'), findsOneWidget);
      expect(find.widgetWithText(TextField, '320.45'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Mercado'), findsOneWidget);
      expect(find.text('Categoria'), findsOneWidget);
      expect(find.text('Alimentação'), findsOneWidget); // categoria 5
      expect(find.text('Forma de Pagamento'), findsOneWidget);
      expect(find.text('Cartão Débito'), findsOneWidget);
      expect(find.text('Conta (opcional)'), findsNothing);
      expect(find.byType(AppDateField), findsNothing);
      expect(find.widgetWithText(FilledButton, 'Salvar alterações'),
          findsOneWidget);
    });

    testWidgets(
      'saving untouched sends the original values (status and date included)',
      (tester) async {
        final r = await open(tester);
        r.log.events.clear();

        await _submit(tester, 'Salvar alterações');

        expect(r.expenses.updateCalls, hasLength(1));
        final c = r.expenses.updateCalls.single;
        expect(c.token, 'test-token');
        expect(c.id, 3);
        expect(c.categoryId, 5);
        expect(c.amount, 320.45);
        expect(c.description, 'Mercado');
        expect(c.date, DateTime(2026, 9, 5)); // nao editavel
        expect(c.paymentMethod, 'debit_card');
        expect(c.status, 'pending'); // nao editavel, mas preservado
        expect(c.tags, isNull);

        expect(find.text('Editar Despesa'), findsNothing);
        expect(find.text('Despesa atualizada!'), findsOneWidget);
        expect(r.log.events, ['pop null']); // sem navegacao
        expect(r.expenses.addCalls, isEmpty);
      },
    );

    testWidgets('sends the edited values', (tester) async {
      final r = await open(tester);

      await _enter(tester, 'Valor', '410,10');
      await _enter(tester, 'Descrição', '  Feira ');
      await _chooseFrom<int>(tester, 'Saúde');
      await _chooseFrom<String>(tester, 'Transferência');
      await _submit(tester, 'Salvar alterações');

      final c = r.expenses.updateCalls.single;
      expect(c.id, 3);
      expect(c.categoryId, 7);
      expect(c.amount, 410.1);
      expect(c.description, 'Feira');
      expect(c.paymentMethod, 'transfer');
    });

    testWidgets('empty fields are rejected', (tester) async {
      final r = await open(tester);

      await _enter(tester, 'Descrição', '');
      await _submit(tester, 'Salvar alterações');

      expect(r.expenses.updateCalls, isEmpty);
      expect(find.text('Preencha todos os campos'), findsOneWidget);
      expect(find.text('Editar Despesa'), findsOneWidget);
    });

    testWidgets('a non-numeric amount is "Valor inválido"', (tester) async {
      final r = await open(tester);

      await _enter(tester, 'Valor', 'abc');
      await _submit(tester, 'Salvar alterações');

      expect(r.expenses.updateCalls, isEmpty);
      expect(find.text('Valor inválido'), findsOneWidget);
    });

    testWidgets('without a token nothing is sent and the sheet stays', (
      tester,
    ) async {
      final r = await _pump(tester, seed: _mixed, token: null);
      await tester.tap(find.byTooltip('Editar Mercado'));
      await tester.pumpAndSettle();

      await _submit(tester, 'Salvar alterações');

      expect(r.expenses.updateCalls, isEmpty);
      expect(find.text('Editar Despesa'), findsOneWidget);
    });

    testWidgets('editing from a filtered tab works and keeps the tab', (
      tester,
    ) async {
      final r = await _pump(tester, seed: _mixed);
      await _openTab(tester, 'Cartão');

      await tester.tap(find.byTooltip('Editar Uber'));
      await tester.pumpAndSettle();
      await _submit(tester, 'Salvar alterações');

      expect(r.expenses.updateCalls.single.id, 6);
      expect(r.expenses.updateCalls.single.paymentMethod, 'credit_card');
      expect(_sectionTitle('Cartão'), findsOneWidget);
    });
  });

  group('remove expense', () {
    Future<void> tapRemove(WidgetTester tester, String description) async {
      await tester.tap(find.byTooltip('Remover $description'));
      await tester.pumpAndSettle();
    }

    testWidgets('asks first, naming the record', (tester) async {
      final r = await _pump(tester, seed: _mixed);
      await tapRemove(tester, 'Mercado');

      expect(find.text('Deletar despesa?'), findsOneWidget);
      expect(
        find.text('Tem certeza que deseja deletar "Mercado"?'),
        findsOneWidget,
      );
      expect(r.expenses.removeCalls, isEmpty);
    });

    testWidgets('cancel does not call the provider', (tester) async {
      final r = await _pump(tester, seed: _mixed);
      await tapRemove(tester, 'Mercado');

      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(r.expenses.removeCalls, isEmpty);
      expect(find.text('Deletar despesa?'), findsNothing);
      expect(find.text('Despesa deletada'), findsNothing);
    });

    testWidgets('confirm removes exactly that record', (tester) async {
      final r = await _pump(tester, seed: _mixed);
      await tapRemove(tester, 'Aluguel');

      await tester.tap(find.widgetWithText(FilledButton, 'Deletar'));
      await tester.pumpAndSettle();

      expect(r.expenses.removeCalls, [(token: 'test-token', id: 2)]);
      expect(find.text('Deletar despesa?'), findsNothing);
      expect(find.text('Despesa deletada'), findsOneWidget);
    });

    testWidgets('removing from a filtered tab works', (tester) async {
      final r = await _pump(tester, seed: _mixed);
      await _openTab(tester, 'Cartão');
      await tapRemove(tester, 'Uber');

      await tester.tap(find.widgetWithText(FilledButton, 'Deletar'));
      await tester.pumpAndSettle();

      expect(r.expenses.removeCalls, [(token: 'test-token', id: 6)]);
    });

    testWidgets('without a token: no call, but the notice still shows', (
      tester,
    ) async {
      final r = await _pump(tester, seed: _mixed, token: null);
      await tapRemove(tester, 'Mercado');

      await tester.tap(find.widgetWithText(FilledButton, 'Deletar'));
      await tester.pumpAndSettle();

      expect(r.expenses.removeCalls, isEmpty);
      expect(find.text('Despesa deletada'), findsOneWidget);
    });
  });
}
