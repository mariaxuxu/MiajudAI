// Preservacao de comportamento da tela Dashboard / Fatura
// (InvoiceDashboardScreen).
//
// Cada caso prova que a UI redesenhada continua acionando o InstallmentProvider
// e o FixedCostProvider com os MESMOS argumentos, calculando/filtrando o mesmo
// mes do MESMO jeito, mantendo as duas abas (Contas, Dashboard) com TabBarView e
// as MESMAS guardas de formulario (inclusive as que so falham em silencio) e o
// MESMO fluxo dos dialogos de remocao (esperam a remocao antes de fechar).

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:miajudai/models/fixed_cost_model.dart';
import 'package:miajudai/models/installment_model.dart';
import 'package:miajudai/screens/invoice_dashboard_screen.dart';
import 'package:miajudai/widgets/common/app_date_field.dart';
import 'package:miajudai/widgets/common/app_form_field.dart';
import 'package:miajudai/widgets/common/app_underline_tabs.dart';
import 'package:miajudai/widgets/common/section_header.dart';
import 'package:miajudai/widgets/finance/balance_hero_card.dart';
import 'package:miajudai/widgets/finance/finance_metric_card.dart';
import 'package:miajudai/widgets/finance/finance_record_tile.dart';
import 'package:miajudai/widgets/finance/tip_card.dart';
import 'package:miajudai/widgets/finance/tonal_summary_card.dart';

import 'support/fake_fixed_cost_provider.dart';
import 'support/fake_installment_provider.dart';
import 'support/pump_screen.dart';
import 'support/test_fonts.dart';

typedef _Env = ({
  FakeInstallmentProvider installments,
  FakeFixedCostProvider fixedCosts,
  RouteLog log,
});

final DateTime _now = DateTime.now();

/// Mes relativo a hoje (a tela abre no mes corrente).
DateTime _month(int offset, [int day = 12]) =>
    DateTime(_now.year, _now.month + offset, day);

String _monthLabel(DateTime month) {
  final name = DateFormat('MMMM', 'pt_BR').format(month);
  return '${name[0].toUpperCase()}${name.substring(1)} ${month.year}';
}

/// "12 jul": a data curta que o legado mostra em cada parcela.
String _short(DateTime date) {
  const months = [
    'jan', 'fev', 'mar', 'abr', 'mai', 'jun',
    'jul', 'ago', 'set', 'out', 'nov', 'dez', //
  ];
  return '${date.day} ${months[date.month - 1]}';
}

/// A legenda do hero usa espaco sem quebra depois de "R$" e dos rotulos.
String _nb(String text) =>
    text.replaceAll('R\$ ', 'R\$\u{A0}').replaceAll(': ', ':\u{A0}');

Future<_Env> _pump(
  WidgetTester tester, {
  List<InstallmentModel> Function()? installmentSeed,
  List<FixedCostModel> Function()? fixedCostSeed,
  String? token = 'test-token',
  bool pushed = false,
}) async {
  final installments = FakeInstallmentProvider();
  if (installmentSeed != null) installments.items = installmentSeed();
  final fixedCosts = FakeFixedCostProvider();
  if (fixedCostSeed != null) fixedCosts.items = fixedCostSeed();

  final env = await pumpScreen(
    tester,
    const InvoiceDashboardScreen(),
    installments: installments,
    fixedCosts: fixedCosts,
    pushed: pushed,
    setup: (a) => a.token = token,
  );
  return (installments: installments, fixedCosts: fixedCosts, log: env.log);
}

/// Parcelas que exercitam cada regra da janela de meses.
///
/// No mes corrente aparecem 1, 2 e 6 (100 + 200 + 100 = 400):
///  - 1: comecou ha 2 meses, 12 parcelas   -> "3 de 12"
///  - 2: comecou este mes, 3 parcelas, PIX -> "1 de 3"
///  - 6: comecou no mes passado, debito    -> "2 de 3"
/// Nao aparecem: 3 (ja terminou), 4 (comeca no mes que vem) e 5 (inativa).
List<InstallmentModel> _installments() => [
      fakeInstallment(
        id: 1,
        name: 'iPhone',
        merchantName: 'Apple Store',
        totalAmount: 1200,
        totalInstallments: 12,
        dueDayOfMonth: 10,
        startDate: _month(-2, 12),
      ),
      fakeInstallment(
        id: 2,
        name: 'Geladeira',
        totalAmount: 600,
        totalInstallments: 3,
        dueDayOfMonth: 5,
        startDate: _month(0, 3),
        paymentMethod: 'pix',
      ),
      fakeInstallment(
        id: 3,
        name: 'Curso',
        totalAmount: 900,
        totalInstallments: 3,
        startDate: _month(-5),
      ),
      fakeInstallment(
        id: 4,
        name: 'Notebook',
        totalAmount: 2400,
        totalInstallments: 6,
        startDate: _month(1, 1),
      ),
      fakeInstallment(
        id: 5,
        name: 'Inativa',
        totalAmount: 500,
        totalInstallments: 5,
        startDate: _month(-1),
        isActive: false,
      ),
      fakeInstallment(
        id: 6,
        name: 'Fone',
        totalAmount: 300,
        totalInstallments: 3,
        dueDayOfMonth: 20,
        startDate: _month(-1, 25),
        paymentMethod: 'debit_card',
      ),
    ];

/// Gastos fixos. No mes corrente aparecem 1, 2, 3, 6 e 7
/// (55.90 + 1800 + 210.50 + 30 + 10 = 2106.40); o 4 so no mes que vem; o 5
/// nunca (inativo).
List<FixedCostModel> _fixedCosts() => [
      fakeFixedCost(
        id: 1,
        name: 'Netflix',
        amount: 55.9,
        category: 'streaming',
        createdAt: _month(-3),
      ),
      fakeFixedCost(
        id: 2,
        name: 'Aluguel',
        amount: 1800,
        dueDayOfMonth: 5,
        category: 'rent',
        createdAt: _month(-6),
      ),
      fakeFixedCost(
        id: 3,
        name: 'Luz',
        amount: 210.5,
        dueDayOfMonth: 28,
        category: 'utility',
        createdAt: _month(-1),
      ),
      fakeFixedCost(
        id: 4,
        name: 'Seguro',
        amount: 120,
        category: 'insurance',
        createdAt: _month(1, 1),
      ),
      fakeFixedCost(
        id: 5,
        name: 'Inativo',
        amount: 99,
        createdAt: _month(-2),
        isActive: false,
      ),
      fakeFixedCost(
        id: 6,
        name: 'Assinatura X',
        amount: 30,
        dueDayOfMonth: 1,
        category: 'subscription',
        createdAt: _month(-2),
      ),
      fakeFixedCost(
        id: 7,
        name: 'Diverso',
        amount: 10,
        createdAt: _month(0, 1),
      ),
    ];

Finder _tab(String label) => find.descendant(
      of: find.byType(AppUnderlineTabs),
      matching: find.text(label),
    );

Finder _section(String title) => find.widgetWithText(SectionHeader, title);

Finder _tile(String title) => find.widgetWithText(FinanceRecordTile, title);

Finder _inTile(String title, Finder matching) =>
    find.descendant(of: _tile(title), matching: matching);

Finder _hero(Finder matching) =>
    find.descendant(of: find.byType(BalanceHeroCard), matching: matching);

Future<void> _openTab(WidgetTester tester, String label) async {
  await tester.tap(_tab(label));
  await tester.pumpAndSettle();
}

Future<void> _tapMonth(WidgetTester tester, String tooltip,
    [int times = 1]) async {
  for (var i = 0; i < times; i++) {
    await tester.tap(find.byTooltip(tooltip));
    await tester.pumpAndSettle();
  }
}

Future<void> _reveal(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
}

Future<void> _tapButton(WidgetTester tester, Finder finder) async {
  await _reveal(tester, finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _openChoiceSheet(WidgetTester tester) async {
  await tester.tap(find.byType(FloatingActionButton));
  await tester.pumpAndSettle();
}

Future<void> _openInstallmentSheet(WidgetTester tester) async {
  await _openChoiceSheet(tester);
  await tester.tap(find.widgetWithText(FilledButton, 'Parcela'));
  await tester.pumpAndSettle();
}

Future<void> _openFixedCostSheet(WidgetTester tester) async {
  await _openChoiceSheet(tester);
  await tester.tap(find.widgetWithText(OutlinedButton, 'Gasto Fixo'));
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

Future<void> _submit(WidgetTester tester) async {
  final button = find.widgetWithText(FilledButton, 'Adicionar').last;
  await tester.ensureVisible(button);
  await tester.pumpAndSettle();
  await tester.tap(button);
  await tester.pumpAndSettle();
}

Future<void> _chooseFrom(WidgetTester tester, String option) async {
  await tester.tap(find.byType(DropdownButtonFormField<String>));
  await tester.pumpAndSettle();
  await tester.tap(find.text(option).last);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() async {
    await loadRedesignFonts();
    await initializeDateFormatting('pt_BR');
  });

  group('loading and header', () {
    testWidgets('loads installments and fixed costs once, with the token', (
      tester,
    ) async {
      final r = await _pump(tester);

      expect(r.installments.loadCalls, ['test-token']);
      expect(r.fixedCosts.loadCalls, ['test-token']);
    });

    testWidgets('does not load without a token', (tester) async {
      final r = await _pump(tester, token: null);

      expect(r.installments.loadCalls, isEmpty);
      expect(r.fixedCosts.loadCalls, isEmpty);
    });

    testWidgets('shows the title, the subtitle and the hero label', (
      tester,
    ) async {
      await _pump(tester);

      expect(find.text('Dashboard / Fatura'), findsOneWidget);
      expect(
        find.text('Acompanhe seus compromissos e gastos'),
        findsOneWidget,
      );
      expect(_hero(find.text('Compromissos do Mês')), findsOneWidget);
    });

    testWidgets('the hero shows the month total and its two parts', (
      tester,
    ) async {
      await _pump(
        tester,
        installmentSeed: _installments,
        fixedCostSeed: _fixedCosts,
      );

      // 400,00 (parcelas) + 2106,40 (fixos)
      expect(_hero(find.text('R\$ 2506,40')), findsOneWidget);
      expect(
        _hero(find.text(_nb('Parcelas: R\$ 400,00  •  Fixos: R\$ 2106,40'))),
        findsOneWidget,
      );
    });

    testWidgets('an empty month shows zeros', (tester) async {
      await _pump(tester);

      expect(_hero(find.text('R\$ 0,00')), findsOneWidget);
      expect(
        _hero(find.text(_nb('Parcelas: R\$ 0,00  •  Fixos: R\$ 0,00'))),
        findsOneWidget,
      );
    });

    testWidgets('back pops the screen and navigates nowhere else', (
      tester,
    ) async {
      final r = await _pump(tester, pushed: true);
      await tester.tap(find.byTooltip('Voltar'));
      await tester.pumpAndSettle();

      expect(r.log.events, ['pop null']);
      expect(find.text(kOriginScreenText), findsOneWidget);
    });

    testWidgets('opening the screen navigates nowhere', (tester) async {
      final r = await _pump(tester, pushed: true);
      expect(r.log.events, isEmpty);
    });
  });

  group('month navigation', () {
    testWidgets('starts on the current month', (tester) async {
      await _pump(tester);
      expect(find.text(_monthLabel(_now)), findsOneWidget);
    });

    testWidgets('previous and next move one month at a time', (tester) async {
      await _pump(tester);

      await _tapMonth(tester, 'Mês anterior');
      expect(find.text(_monthLabel(_month(-1))), findsOneWidget);

      await _tapMonth(tester, 'Mês anterior');
      expect(find.text(_monthLabel(_month(-2))), findsOneWidget);

      await _tapMonth(tester, 'Próximo mês', 3);
      expect(find.text(_monthLabel(_month(1))), findsOneWidget);
    });

    testWidgets('crosses the year boundary in both directions', (
      tester,
    ) async {
      await _pump(tester);

      await _tapMonth(tester, 'Mês anterior', _now.month);
      expect(find.text('Dezembro ${_now.year - 1}'), findsOneWidget);

      await _tapMonth(tester, 'Próximo mês');
      expect(find.text('Janeiro ${_now.year}'), findsOneWidget);
    });

    testWidgets('asks both providers for the SELECTED month', (tester) async {
      final r = await _pump(
        tester,
        installmentSeed: _installments,
        fixedCostSeed: _fixedCosts,
      );

      await _tapMonth(tester, 'Mês anterior', 2);

      final target = _month(-2, 1);
      for (final asked in [
        r.installments.totalCalls.last,
        r.fixedCosts.totalCalls.last,
      ]) {
        expect((asked.year, asked.month), (target.year, target.month));
      }
    });

    testWidgets('changing the month does NOT reload from the backend', (
      tester,
    ) async {
      final r = await _pump(tester);

      await _tapMonth(tester, 'Próximo mês', 2);
      await _tapMonth(tester, 'Mês anterior', 3);

      expect(r.installments.loadCalls, hasLength(1));
      expect(r.fixedCosts.loadCalls, hasLength(1));
    });

    testWidgets('the hero follows the selected month', (tester) async {
      await _pump(
        tester,
        installmentSeed: _installments,
        fixedCostSeed: _fixedCosts,
      );

      await _tapMonth(tester, 'Próximo mês');

      // parcelas: 1 (100) + 2 (200) + 4 (400) + 6 (100) = 800
      // fixos: 55.90 + 1800 + 210.50 + 120 + 30 + 10 = 2226.40
      expect(_hero(find.text('R\$ 3026,40')), findsOneWidget);
      expect(
        _hero(find.text(_nb('Parcelas: R\$ 800,00  •  Fixos: R\$ 2226,40'))),
        findsOneWidget,
      );
    });
  });

  group('tabs', () {
    testWidgets('has Contas first and Dashboard second, Contas selected', (
      tester,
    ) async {
      await _pump(tester);

      final labels =
          tester.widget<AppUnderlineTabs>(find.byType(AppUnderlineTabs)).labels;
      expect(labels, ['Contas', 'Dashboard']);

      final controller = tester.widget<TabBar>(find.byType(TabBar)).controller!;
      expect(controller.length, 2);
      expect(controller.index, 0);
      expect(_section('Parcelas'), findsOneWidget);
      expect(find.text('Pagamentos por Tipo'), findsNothing);
    });

    testWidgets('tapping Dashboard shows the dashboard page', (tester) async {
      await _pump(tester);
      await _openTab(tester, 'Dashboard');

      final controller = tester.widget<TabBar>(find.byType(TabBar)).controller!;
      expect(controller.index, 1);
      expect(find.text('Pagamentos por Tipo'), findsOneWidget);
      expect(_section('Parcelas'), findsNothing);

      await _openTab(tester, 'Contas');
      expect(controller.index, 0);
      expect(_section('Parcelas'), findsOneWidget);
    });

    testWidgets('swiping the pages switches tabs (TabBarView)', (tester) async {
      await _pump(tester);
      final controller = tester.widget<TabBar>(find.byType(TabBar)).controller!;

      await tester.fling(find.byType(TabBarView), const Offset(-400, 0), 1000);
      await tester.pumpAndSettle();
      expect(controller.index, 1);
      expect(find.text('Pagamentos por Tipo'), findsOneWidget);

      await tester.fling(find.byType(TabBarView), const Offset(400, 0), 1000);
      await tester.pumpAndSettle();
      expect(controller.index, 0);
      expect(_section('Parcelas'), findsOneWidget);
    });

    testWidgets('the selected month is kept when the tab changes', (
      tester,
    ) async {
      await _pump(
        tester,
        installmentSeed: _installments,
        fixedCostSeed: _fixedCosts,
      );

      await _tapMonth(tester, 'Mês anterior');
      await _openTab(tester, 'Dashboard');
      expect(find.text(_monthLabel(_month(-1))), findsOneWidget);

      await _openTab(tester, 'Contas');
      expect(find.text(_monthLabel(_month(-1))), findsOneWidget);
    });
  });

  group('Contas tab', () {
    testWidgets('lists only the installments active in the month', (
      tester,
    ) async {
      await _pump(tester, installmentSeed: _installments);

      expect(_tile('Apple Store'), findsOneWidget);
      expect(_tile('Geladeira'), findsOneWidget);
      expect(_tile('Fone'), findsOneWidget);
      expect(_tile('Curso'), findsNothing); // ja terminou
      expect(_tile('Notebook'), findsNothing); // comeca no mes que vem
      expect(_tile('Inativa'), findsNothing); // inativa
      expect(find.byType(FinanceRecordTile), findsNWidgets(3));
      expect(
        find.descendant(of: _section('Parcelas'), matching: find.text('3')),
        findsOneWidget,
      );
    });

    testWidgets('an installment shows name, progress, method, date and value', (
      tester,
    ) async {
      await _pump(tester, installmentSeed: _installments);

      // titulo = loja quando ha; senao o nome
      expect(_inTile('Apple Store', find.text('Apple Store')), findsOneWidget);
      expect(_tile('iPhone'), findsNothing);
      expect(_tile('Geladeira'), findsOneWidget);

      expect(
        _inTile(
          'Apple Store',
          find.text(
            '3 de 12 parcelas • vence dia 10\n'
            '💳 Crédito • ${_short(_month(-2, 12))}',
          ),
        ),
        findsOneWidget,
      );
      expect(_inTile('Apple Store', find.text('R\$ 100,00')), findsOneWidget);
      expect(_inTile('Geladeira', find.text('R\$ 200,00')), findsOneWidget);
      expect(
        _inTile(
            'Geladeira', find.textContaining('1 de 3 parcelas • vence dia 5')),
        findsOneWidget,
      );
      expect(
          _inTile('Geladeira', find.textContaining('📱 PIX')), findsOneWidget);
      expect(
        _inTile('Fone', find.textContaining('🏧 Débito')),
        findsOneWidget,
      );
    });

    testWidgets('the window ends exactly at the last installment month', (
      tester,
    ) async {
      await _pump(
        tester,
        installmentSeed: () => [
          // 3 parcelas: comecou ha 2 meses -> este e o ULTIMO mes (3 de 3)
          fakeInstallment(
            id: 1,
            name: 'Ultimo mes',
            totalAmount: 300,
            totalInstallments: 3,
            startDate: _month(-2),
          ),
          // comecou ha 3 meses -> ja acabou (o mes seguinte ao ultimo)
          fakeInstallment(
            id: 2,
            name: 'Acabou',
            totalAmount: 300,
            totalInstallments: 3,
            startDate: _month(-3),
          ),
          // comeca este mes -> aparece (1 de 3); o mes anterior ao inicio nao
          fakeInstallment(
            id: 3,
            name: 'Comeca hoje',
            totalAmount: 300,
            totalInstallments: 3,
            startDate: _month(0, 1),
          ),
          fakeInstallment(
            id: 4,
            name: 'Comeca amanha',
            totalAmount: 300,
            totalInstallments: 3,
            startDate: _month(1, 1),
          ),
        ],
      );

      expect(_tile('Ultimo mes'), findsOneWidget);
      expect(
        _inTile('Ultimo mes', find.textContaining('3 de 3 parcelas')),
        findsOneWidget,
      );
      expect(_tile('Acabou'), findsNothing);
      expect(_tile('Comeca hoje'), findsOneWidget);
      expect(_tile('Comeca amanha'), findsNothing);
    });

    testWidgets('the progress follows the selected month', (tester) async {
      await _pump(tester, installmentSeed: _installments);

      await _tapMonth(tester, 'Próximo mês');

      expect(
        _inTile('Apple Store', find.textContaining('4 de 12 parcelas')),
        findsOneWidget,
      );
      // a que comeca no mes que vem passa a aparecer
      expect(_tile('Notebook'), findsOneWidget);
      expect(
        _inTile('Notebook', find.textContaining('1 de 6 parcelas')),
        findsOneWidget,
      );
    });

    testWidgets('lists the fixed costs of the month with category and day', (
      tester,
    ) async {
      await _pump(tester, fixedCostSeed: _fixedCosts);

      expect(find.byType(FinanceRecordTile), findsNWidgets(5));
      expect(_tile('Seguro'), findsNothing); // so no mes que vem
      expect(_tile('Inativo'), findsNothing);
      expect(
        find.descendant(of: _section('Gastos Fixos'), matching: find.text('5')),
        findsOneWidget,
      );

      expect(
        _inTile('Netflix', find.text('Streaming • todo dia 15')),
        findsOneWidget,
      );
      expect(_inTile('Netflix', find.text('R\$ 55,90')), findsOneWidget);
      expect(
        _inTile('Aluguel', find.text('Aluguel • todo dia 5')),
        findsOneWidget,
      );
      expect(
        _inTile('Luz', find.text('Utilidade • todo dia 28')),
        findsOneWidget,
      );
      expect(
        _inTile('Assinatura X', find.text('Assinatura • todo dia 1')),
        findsOneWidget,
      );
      expect(
        _inTile('Diverso', find.text('Outro • todo dia 15')),
        findsOneWidget,
      );
    });

    testWidgets('a fixed cost created later shows up when the month advances', (
      tester,
    ) async {
      await _pump(tester, fixedCostSeed: _fixedCosts);

      await _tapMonth(tester, 'Próximo mês');
      expect(_tile('Seguro'), findsOneWidget);
      expect(
        _inTile('Seguro', find.text('Seguro • todo dia 15')),
        findsOneWidget,
      );
    });

    testWidgets('each fixed-cost category keeps its own icon', (tester) async {
      await _pump(tester, fixedCostSeed: _fixedCosts);
      await _tapMonth(tester, 'Próximo mês');

      final icons = {
        'Netflix': Icons.play_circle_outline,
        'Aluguel': Icons.home_outlined,
        'Luz': Icons.lightbulb_outline,
        'Assinatura X': Icons.card_membership,
        'Seguro': Icons.security_outlined,
        'Diverso': Icons.category_outlined,
      };
      icons.forEach((name, icon) {
        expect(_inTile(name, find.byIcon(icon)), findsOneWidget, reason: name);
      });
    });

    testWidgets('empty sections explain what to do and offer the action', (
      tester,
    ) async {
      await _pump(tester);

      expect(find.text('Nenhuma parcela cadastrada'), findsOneWidget);
      expect(
        find.text(
            'Adicione suas compras parceladas para não perder os vencimentos.'),
        findsOneWidget,
      );
      expect(find.text('Nenhum gasto fixo cadastrado'), findsOneWidget);
      expect(
        find.text(
            'Adicione seus gastos fixos para manter seu orçamento sob controle.'),
        findsOneWidget,
      );
      expect(find.text('Adicionar parcela'), findsOneWidget);
      expect(find.text('Adicionar gasto fixo'), findsOneWidget);
    });

    testWidgets('the section headers carry no count when empty', (
      tester,
    ) async {
      await _pump(tester);

      expect(
        find.descendant(of: _section('Parcelas'), matching: find.text('0')),
        findsNothing,
      );
      expect(
        find.descendant(of: _section('Gastos Fixos'), matching: find.text('0')),
        findsNothing,
      );
    });

    testWidgets('"Adicionar parcela" opens the installment sheet', (
      tester,
    ) async {
      await _pump(tester);

      await _tapButton(
          tester, find.widgetWithText(OutlinedButton, 'Adicionar parcela'));

      expect(find.text('Nova Parcela'), findsOneWidget);
      expect(find.text('Novo Gasto Fixo'), findsNothing);
    });

    testWidgets('"Adicionar gasto fixo" opens the fixed cost sheet', (
      tester,
    ) async {
      await _pump(tester);

      await _tapButton(
        tester,
        find.widgetWithText(OutlinedButton, 'Adicionar gasto fixo'),
      );

      expect(find.text('Novo Gasto Fixo'), findsOneWidget);
      expect(find.text('Nova Parcela'), findsNothing);
    });
  });

  group('Dashboard tab', () {
    testWidgets('shows the installment and fixed cost cards', (tester) async {
      await _pump(
        tester,
        installmentSeed: _installments,
        fixedCostSeed: _fixedCosts,
      );
      await _openTab(tester, 'Dashboard');

      final cards = find.byType(FinanceMetricCard);
      expect(cards, findsNWidgets(2));
      expect(find.descendant(of: cards.at(0), matching: find.text('Parcelas')),
          findsOneWidget);
      expect(
          find.descendant(of: cards.at(0), matching: find.text('R\$ 400,00')),
          findsOneWidget);
      expect(
          find.descendant(of: cards.at(0), matching: find.text('3 parcelas')),
          findsOneWidget);
      expect(find.descendant(of: cards.at(1), matching: find.text('Fixos')),
          findsOneWidget);
      expect(
          find.descendant(of: cards.at(1), matching: find.text('R\$ 2106,40')),
          findsOneWidget);
      expect(
          find.descendant(
              of: cards.at(1), matching: find.text('5 gastos fixos')),
          findsOneWidget);
    });

    testWidgets('the counts are singular when there is one', (tester) async {
      await _pump(
        tester,
        installmentSeed: () => [_installments().first],
        fixedCostSeed: () => [_fixedCosts().first],
      );
      await _openTab(tester, 'Dashboard');

      expect(find.text('1 parcela'), findsOneWidget);
      expect(find.text('1 gasto fixo'), findsOneWidget);
    });

    testWidgets('the total sums installments and fixed costs', (tester) async {
      await _pump(
        tester,
        installmentSeed: _installments,
        fixedCostSeed: _fixedCosts,
      );
      await _openTab(tester, 'Dashboard');

      final total = find.byType(TonalSummaryCard);
      expect(total, findsOneWidget);
      expect(find.descendant(of: total, matching: find.text('Total do Mês')),
          findsOneWidget);
      expect(find.descendant(of: total, matching: find.text('R\$ 2506,40')),
          findsOneWidget);
      expect(
        find.descendant(
            of: total, matching: find.text('Somando parcelas e fixos')),
        findsOneWidget,
      );
    });

    testWidgets('the cards follow the selected month', (tester) async {
      await _pump(
        tester,
        installmentSeed: _installments,
        fixedCostSeed: _fixedCosts,
      );
      await _openTab(tester, 'Dashboard');

      await _tapMonth(tester, 'Próximo mês');

      final cards = find.byType(FinanceMetricCard);
      expect(
          find.descendant(of: cards.at(0), matching: find.text('R\$ 800,00')),
          findsOneWidget);
      expect(
          find.descendant(of: cards.at(0), matching: find.text('4 parcelas')),
          findsOneWidget);
      expect(
          find.descendant(of: cards.at(1), matching: find.text('R\$ 2226,40')),
          findsOneWidget);
      expect(
          find.descendant(
              of: cards.at(1), matching: find.text('6 gastos fixos')),
          findsOneWidget);
      expect(
        find.descendant(
            of: find.byType(TonalSummaryCard),
            matching: find.text('R\$ 3026,40')),
        findsOneWidget,
      );
    });

    testWidgets('payments by type: label, share and bar per method', (
      tester,
    ) async {
      await _pump(tester, installmentSeed: _installments);
      await _openTab(tester, 'Dashboard');

      // 100 credito + 200 pix + 100 debito = 400
      expect(find.text('💳 Crédito'), findsOneWidget);
      expect(find.text('📱 PIX'), findsOneWidget);
      expect(find.text('🏧 Débito'), findsOneWidget);
      expect(find.text('25.0%'), findsNWidgets(2));
      expect(find.text('50.0%'), findsOneWidget);

      final bars = tester
          .widgetList<LinearProgressIndicator>(
              find.byType(LinearProgressIndicator))
          .map((b) => b.value)
          .toList();
      expect(bars, [0.25, 0.5, 0.25]);
    });

    testWidgets('payments by type only count the installments of the month', (
      tester,
    ) async {
      await _pump(tester, installmentSeed: _installments);
      await _openTab(tester, 'Dashboard');
      await _tapMonth(tester, 'Próximo mês');

      // credito: 100 (iPhone) + 400 (Notebook); pix 200; debito 100 (Fone)
      // total 800 -> 62.5% / 25.0% / 12.5%
      expect(find.text('62.5%'), findsOneWidget);
      expect(find.text('25.0%'), findsOneWidget);
      expect(find.text('12.5%'), findsOneWidget);
    });

    testWidgets('without installments it shows the empty state and the tip', (
      tester,
    ) async {
      await _pump(tester, fixedCostSeed: _fixedCosts);
      await _openTab(tester, 'Dashboard');

      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(find.text('Sem dados de parcelas'), findsOneWidget);
      expect(
        find.text(
            'Adicione suas parcelas e gastos fixos para visualizar o resumo por tipo.'),
        findsOneWidget,
      );
      expect(find.text('Adicionar pagamento'), findsOneWidget);
      expect(find.byType(TipCard), findsOneWidget);
      expect(find.text('Dica'), findsOneWidget);
    });

    testWidgets('with installments the empty state and the tip are gone', (
      tester,
    ) async {
      await _pump(tester, installmentSeed: _installments);
      await _openTab(tester, 'Dashboard');

      expect(find.text('Sem dados de parcelas'), findsNothing);
      expect(find.byType(TipCard), findsNothing);
    });

    testWidgets('"Adicionar pagamento" opens the add sheet', (tester) async {
      await _pump(tester);
      await _openTab(tester, 'Dashboard');

      await _tapButton(
          tester, find.widgetWithText(FilledButton, 'Adicionar pagamento'));

      expect(find.text('Adicionar'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Parcela'), findsOneWidget);
      expect(find.widgetWithText(OutlinedButton, 'Gasto Fixo'), findsOneWidget);
    });
  });

  group('add flow', () {
    testWidgets('the FAB opens the choice sheet', (tester) async {
      await _pump(tester);
      await _openChoiceSheet(tester);

      expect(find.text('Adicionar'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Parcela'), findsOneWidget);
      expect(find.widgetWithText(OutlinedButton, 'Gasto Fixo'), findsOneWidget);
    });

    testWidgets('"Parcela" swaps the choice sheet for the installment sheet', (
      tester,
    ) async {
      await _pump(tester);
      await _openInstallmentSheet(tester);

      expect(find.text('Nova Parcela'), findsOneWidget);
      expect(find.widgetWithText(OutlinedButton, 'Gasto Fixo'), findsNothing);
    });

    testWidgets('"Gasto Fixo" swaps the choice sheet for the fixed cost sheet',
        (
      tester,
    ) async {
      await _pump(tester);
      await _openFixedCostSheet(tester);

      expect(find.text('Novo Gasto Fixo'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Parcela'), findsNothing);
    });

    testWidgets('the FAB is reachable from both tabs', (tester) async {
      await _pump(tester);
      await _openTab(tester, 'Dashboard');
      await _openChoiceSheet(tester);

      expect(find.text('Adicionar'), findsOneWidget);
    });
  });

  group('installment form', () {
    testWidgets('has the same fields, in the same order, with the same hints', (
      tester,
    ) async {
      await _pump(tester);
      await _openInstallmentSheet(tester);

      final labels = tester
          .widgetList<AppFormField>(find.byType(AppFormField))
          .map((f) => f.label)
          .toList();
      expect(labels, [
        'Nome da Compra',
        'Loja/Empresa',
        'Valor Total',
        'Parcelas',
        'Dia de Vencimento',
      ]);
      expect(find.text('Meio de Pagamento'), findsOneWidget);
      expect(find.text('Data de Início'), findsOneWidget);
      expect(find.text('Ex: iPhone 15 Pro'), findsOneWidget);
      expect(find.text('Ex: Apple Store'), findsOneWidget);
      expect(find.text('Ex: 2400.00'), findsOneWidget);
      expect(find.text('Ex: 12'), findsOneWidget);
      expect(find.text('Ex: 10'), findsOneWidget);
    });

    testWidgets('starts with day 10, credit card and the viewed month', (
      tester,
    ) async {
      await _pump(tester);
      await _tapMonth(tester, 'Próximo mês');
      await _openInstallmentSheet(tester);

      expect(find.text('10'), findsOneWidget); // dia de vencimento
      expect(find.text('💳 Cartão de Crédito'), findsOneWidget);
      final next = _month(1, 1);
      expect(
        find.text(DateFormat('dd/MM/yyyy').format(next)),
        findsOneWidget,
      );
    });

    testWidgets('offers the six payment methods', (tester) async {
      await _pump(tester);
      await _openInstallmentSheet(tester);

      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();

      for (final label in [
        '💳 Cartão de Crédito',
        '🏧 Cartão de Débito',
        '📱 PIX',
        '💵 Dinheiro',
        '🏦 Transferência',
        '📋 Outro',
      ]) {
        expect(find.text(label), findsWidgets, reason: label);
      }
    });

    testWidgets('submits the exact payload and closes the sheet', (
      tester,
    ) async {
      final r = await _pump(tester);
      await _openInstallmentSheet(tester);

      await _enter(tester, 'Nome da Compra', 'iPhone 15');
      await _enter(tester, 'Valor Total', '2400.00');
      await _enter(tester, 'Parcelas', '12');
      await _submit(tester);

      final call = r.installments.addCalls.single;
      expect(call.token, 'test-token');
      expect(call.name, 'iPhone 15');
      expect(call.totalAmount, 2400.0);
      expect(call.totalInstallments, 12);
      expect(call.dueDayOfMonth, 10);
      expect(call.paymentMethod, 'credit_card');
      expect(call.merchantName, isNull);
      expect(call.description, isNull);
      expect(
        (call.startDate.year, call.startDate.month, call.startDate.day),
        (_now.year, _now.month, _now.day),
      );
      expect(find.text('Nova Parcela'), findsNothing);
    });

    testWidgets('sends the merchant, the day and the method that were typed', (
      tester,
    ) async {
      final r = await _pump(tester);
      await _openInstallmentSheet(tester);

      await _enter(tester, 'Nome da Compra', 'Sofá');
      await _enter(tester, 'Loja/Empresa', 'Tok&Stok');
      await _chooseFrom(tester, '📱 PIX');
      await _enter(tester, 'Valor Total', '900');
      await _enter(tester, 'Parcelas', '3');
      await _enter(tester, 'Dia de Vencimento', '25');
      await _submit(tester);

      final call = r.installments.addCalls.single;
      expect(call.merchantName, 'Tok&Stok');
      expect(call.paymentMethod, 'pix');
      expect(call.totalAmount, 900.0);
      expect(call.totalInstallments, 3);
      expect(call.dueDayOfMonth, 25);
    });

    testWidgets('the start date can be changed with the date picker', (
      tester,
    ) async {
      final r = await _pump(tester);
      await _openInstallmentSheet(tester);

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

      await _enter(tester, 'Nome da Compra', 'x');
      await _enter(tester, 'Valor Total', '10');
      await _enter(tester, 'Parcelas', '2');
      await _submit(tester);

      expect(
        r.installments.addCalls.single.startDate,
        DateTime(_now.year, _now.month, 15),
      );
    });

    testWidgets('a missing required field sends nothing and keeps the sheet', (
      tester,
    ) async {
      for (final skipped in [
        'Nome da Compra',
        'Valor Total',
        'Parcelas',
        'Dia de Vencimento'
      ]) {
        final r = await _pump(tester);
        await _openInstallmentSheet(tester);

        final values = {
          'Nome da Compra': 'x',
          'Valor Total': '10',
          'Parcelas': '2',
          'Dia de Vencimento': '10',
        };
        for (final entry in values.entries) {
          await _enter(
              tester, entry.key, entry.key == skipped ? '' : entry.value);
        }
        await _submit(tester);

        expect(r.installments.addCalls, isEmpty, reason: skipped);
        expect(find.text('Nova Parcela'), findsOneWidget, reason: skipped);
        expect(find.byType(SnackBar), findsNothing, reason: skipped);
      }
    });

    testWidgets('without a token nothing is sent and the sheet stays', (
      tester,
    ) async {
      final r = await _pump(tester, token: null);
      await _openInstallmentSheet(tester);

      await _enter(tester, 'Nome da Compra', 'x');
      await _enter(tester, 'Valor Total', '10');
      await _enter(tester, 'Parcelas', '2');
      await _submit(tester);

      expect(r.installments.addCalls, isEmpty);
      expect(find.text('Nova Parcela'), findsOneWidget);
    });

    // Comportamento legado, mantido: um valor que nao e numero (ou usa virgula)
    // lanca no `double.parse`, fora de qualquer try. Nada e enviado e a sheet
    // fica aberta. Bug conhecido, NAO corrigido nesta fase.
    testWidgets('a non numeric total throws before sending (legacy)', (
      tester,
    ) async {
      final r = await _pump(tester);
      await _openInstallmentSheet(tester);

      await _enter(tester, 'Nome da Compra', 'x');
      await _enter(tester, 'Valor Total', '2400,00');
      await _enter(tester, 'Parcelas', '2');
      await _submit(tester);

      expect(tester.takeException(), isA<FormatException>());
      expect(r.installments.addCalls, isEmpty);
      expect(find.text('Nova Parcela'), findsOneWidget);
    });
  });

  group('fixed cost form', () {
    testWidgets('has the same fields, in the same order, with the same hints', (
      tester,
    ) async {
      await _pump(tester);
      await _openFixedCostSheet(tester);

      final labels = tester
          .widgetList<AppFormField>(find.byType(AppFormField))
          .map((f) => f.label)
          .toList();
      expect(labels, ['Nome', 'Valor', 'Dia de Vencimento']);
      expect(find.text('Categoria'), findsOneWidget);
      expect(find.text('Ex: Netflix'), findsOneWidget);
      expect(find.text('Ex: 55.90'), findsOneWidget);
      expect(find.text('Ex: 15'), findsOneWidget);
    });

    testWidgets('starts with day 15 and category Outro', (tester) async {
      await _pump(tester);
      await _openFixedCostSheet(tester);

      expect(find.text('15'), findsOneWidget);
      expect(find.text('📋 Outro'), findsOneWidget);
    });

    testWidgets('offers the six categories', (tester) async {
      await _pump(tester);
      await _openFixedCostSheet(tester);

      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();

      for (final label in [
        '🎬 Streaming',
        '🏠 Aluguel',
        '⚡ Utilidade',
        '📜 Assinatura',
        '🛡️ Seguro',
        '📋 Outro',
      ]) {
        expect(find.text(label), findsWidgets, reason: label);
      }
    });

    testWidgets('submits the payload, accepts a comma and closes the sheet', (
      tester,
    ) async {
      final r = await _pump(tester);
      await _openFixedCostSheet(tester);

      await _enter(tester, 'Nome', 'Netflix');
      await _enter(tester, 'Valor', '55,90');
      await _enter(tester, 'Dia de Vencimento', '8');
      await _chooseFrom(tester, '🎬 Streaming');
      await _submit(tester);

      expect(r.fixedCosts.addCalls.single, (
        token: 'test-token',
        name: 'Netflix',
        amount: 55.9,
        dueDayOfMonth: 8,
        category: 'streaming',
        description: null,
      ));
      expect(find.text('Novo Gasto Fixo'), findsNothing);
    });

    testWidgets('accepts a dot as the decimal separator too', (tester) async {
      final r = await _pump(tester);
      await _openFixedCostSheet(tester);

      await _enter(tester, 'Nome', 'Luz');
      await _enter(tester, 'Valor', '210.5');
      await _submit(tester);

      expect(r.fixedCosts.addCalls.single.amount, 210.5);
      expect(r.fixedCosts.addCalls.single.category, 'other');
      expect(r.fixedCosts.addCalls.single.dueDayOfMonth, 15);
    });

    testWidgets('an invalid amount shows "Valor inválido" and sends nothing', (
      tester,
    ) async {
      final r = await _pump(tester);
      await _openFixedCostSheet(tester);

      await _enter(tester, 'Nome', 'Luz');
      await _enter(tester, 'Valor', 'abc');
      await _submit(tester);

      expect(r.fixedCosts.addCalls, isEmpty);
      expect(find.text('Valor inválido'), findsOneWidget);
      expect(find.text('Novo Gasto Fixo'), findsOneWidget);
    });

    testWidgets('an invalid day is reported the same way', (tester) async {
      final r = await _pump(tester);
      await _openFixedCostSheet(tester);

      await _enter(tester, 'Nome', 'Luz');
      await _enter(tester, 'Valor', '10');
      await _enter(tester, 'Dia de Vencimento', 'x');
      await _submit(tester);

      expect(r.fixedCosts.addCalls, isEmpty);
      expect(find.text('Valor inválido'), findsOneWidget);
    });

    testWidgets('a missing required field sends nothing and stays silent', (
      tester,
    ) async {
      for (final skipped in ['Nome', 'Valor', 'Dia de Vencimento']) {
        final r = await _pump(tester);
        await _openFixedCostSheet(tester);

        final values = {'Nome': 'x', 'Valor': '10', 'Dia de Vencimento': '15'};
        for (final entry in values.entries) {
          await _enter(
              tester, entry.key, entry.key == skipped ? '' : entry.value);
        }
        await _submit(tester);

        expect(r.fixedCosts.addCalls, isEmpty, reason: skipped);
        expect(find.text('Novo Gasto Fixo'), findsOneWidget, reason: skipped);
        expect(find.byType(SnackBar), findsNothing, reason: skipped);
      }
    });

    testWidgets('without a token nothing is sent and the sheet stays', (
      tester,
    ) async {
      final r = await _pump(tester, token: null);
      await _openFixedCostSheet(tester);

      await _enter(tester, 'Nome', 'Luz');
      await _enter(tester, 'Valor', '10');
      await _submit(tester);

      expect(r.fixedCosts.addCalls, isEmpty);
      expect(find.text('Novo Gasto Fixo'), findsOneWidget);
    });
  });

  group('removing an installment', () {
    Finder remove() => find.byTooltip('Remover Apple Store');

    testWidgets('asks for confirmation before doing anything', (tester) async {
      final r = await _pump(tester, installmentSeed: _installments);

      await _tapButton(tester, remove());

      expect(find.text('Remover Parcela?'), findsOneWidget);
      expect(find.text('Esta ação não pode ser desfeita.'), findsOneWidget);
      expect(find.text('Cancelar'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Remover'), findsOneWidget);
      expect(r.installments.removeCalls, isEmpty);
    });

    testWidgets('cancel closes the dialog and removes nothing', (tester) async {
      final r = await _pump(tester, installmentSeed: _installments);

      await _tapButton(tester, remove());
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(find.text('Remover Parcela?'), findsNothing);
      expect(r.installments.removeCalls, isEmpty);
      expect(_tile('Apple Store'), findsOneWidget);
    });

    testWidgets('confirm removes that installment with the token', (
      tester,
    ) async {
      final r = await _pump(tester, installmentSeed: _installments);

      await _tapButton(tester, remove());
      await tester.tap(find.widgetWithText(FilledButton, 'Remover'));
      await tester.pumpAndSettle();

      expect(r.installments.removeCalls, [(token: 'test-token', id: 1)]);
      expect(find.text('Remover Parcela?'), findsNothing);
      expect(_tile('Apple Store'), findsNothing);
      expect(_tile('Geladeira'), findsOneWidget);
    });

    testWidgets('the dialog stays open until the removal finishes', (
      tester,
    ) async {
      final r = await _pump(tester, installmentSeed: _installments);
      r.installments.removeGate = Completer<void>();

      await _tapButton(tester, remove());
      await tester.tap(find.widgetWithText(FilledButton, 'Remover'));
      await tester.pumpAndSettle();

      // pedido enviado, mas ainda pendente: o dialogo continua na tela
      expect(r.installments.removeCalls, hasLength(1));
      expect(find.text('Remover Parcela?'), findsOneWidget);

      r.installments.removeGate!.complete();
      await tester.pumpAndSettle();

      expect(find.text('Remover Parcela?'), findsNothing);
      expect(_tile('Apple Store'), findsNothing);
    });

    testWidgets('without a token the dialog does not even open', (
      tester,
    ) async {
      final r =
          await _pump(tester, installmentSeed: _installments, token: null);

      await _tapButton(tester, remove());

      expect(find.text('Remover Parcela?'), findsNothing);
      expect(r.installments.removeCalls, isEmpty);
    });

    testWidgets('never touches the fixed costs provider', (tester) async {
      final r = await _pump(
        tester,
        installmentSeed: _installments,
        fixedCostSeed: _fixedCosts,
      );

      await _tapButton(tester, remove());
      await tester.tap(find.widgetWithText(FilledButton, 'Remover'));
      await tester.pumpAndSettle();

      expect(r.fixedCosts.removeCalls, isEmpty);
    });
  });

  group('removing a fixed cost', () {
    Finder remove() => find.byTooltip('Remover Netflix');

    testWidgets('asks for confirmation before doing anything', (tester) async {
      final r = await _pump(tester, fixedCostSeed: _fixedCosts);

      await _tapButton(tester, remove());

      expect(find.text('Remover Gasto Fixo?'), findsOneWidget);
      expect(find.text('Esta ação não pode ser desfeita.'), findsOneWidget);
      expect(r.fixedCosts.removeCalls, isEmpty);
    });

    testWidgets('cancel closes the dialog and removes nothing', (tester) async {
      final r = await _pump(tester, fixedCostSeed: _fixedCosts);

      await _tapButton(tester, remove());
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(find.text('Remover Gasto Fixo?'), findsNothing);
      expect(r.fixedCosts.removeCalls, isEmpty);
      expect(_tile('Netflix'), findsOneWidget);
    });

    testWidgets('confirm removes that fixed cost with the token', (
      tester,
    ) async {
      final r = await _pump(tester, fixedCostSeed: _fixedCosts);

      await _tapButton(tester, remove());
      await tester.tap(find.widgetWithText(FilledButton, 'Remover'));
      await tester.pumpAndSettle();

      expect(r.fixedCosts.removeCalls, [(token: 'test-token', id: 1)]);
      expect(find.text('Remover Gasto Fixo?'), findsNothing);
      expect(_tile('Netflix'), findsNothing);
    });

    testWidgets('the dialog stays open until the removal finishes', (
      tester,
    ) async {
      final r = await _pump(tester, fixedCostSeed: _fixedCosts);
      r.fixedCosts.removeGate = Completer<void>();

      await _tapButton(tester, remove());
      await tester.tap(find.widgetWithText(FilledButton, 'Remover'));
      await tester.pumpAndSettle();

      expect(r.fixedCosts.removeCalls, hasLength(1));
      expect(find.text('Remover Gasto Fixo?'), findsOneWidget);

      r.fixedCosts.removeGate!.complete();
      await tester.pumpAndSettle();

      expect(find.text('Remover Gasto Fixo?'), findsNothing);
    });

    testWidgets('without a token the dialog does not even open', (
      tester,
    ) async {
      final r = await _pump(tester, fixedCostSeed: _fixedCosts, token: null);

      await _tapButton(tester, remove());

      expect(find.text('Remover Gasto Fixo?'), findsNothing);
      expect(r.fixedCosts.removeCalls, isEmpty);
    });
  });
}
