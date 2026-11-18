// Preservacao de comportamento da tela unificada de financas (FinanceScreen):
// contas + parcelas + gastos fixos em uma so tela com abas.
//
// Cada caso prova que a tela continua acionando os MESMOS providers, com o
// MESMO token, e que as tres abas (Contas | Parcelas | Dashboard) entregam o
// MESMO conteudo das telas antigas, sem perder nenhuma funcionalidade.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:miajudai/models/account_model.dart';
import 'package:miajudai/models/fixed_cost_model.dart';
import 'package:miajudai/models/installment_model.dart';
import 'package:miajudai/screens/finance_screen.dart';
import 'package:miajudai/widgets/common/app_underline_tabs.dart';

import 'support/fake_account_provider.dart';
import 'support/fake_fixed_cost_provider.dart';
import 'support/fake_installment_provider.dart';
import 'support/pump_screen.dart';
import 'support/test_fonts.dart';

typedef _Env = ({
  FakeAccountProvider accounts,
  FakeInstallmentProvider installments,
  FakeFixedCostProvider fixedCosts,
  RouteLog log,
});

final DateTime _now = DateTime.now();

Future<_Env> _pump(
  WidgetTester tester, {
  List<AccountModel> accounts = const [],
  List<InstallmentModel> installments = const [],
  List<FixedCostModel> fixedCosts = const [],
  String? token = 'test-token',
}) async {
  final acc = FakeAccountProvider()..items = [...accounts];
  final inst = FakeInstallmentProvider()..items = [...installments];
  final fix = FakeFixedCostProvider()..items = [...fixedCosts];
  final env = await pumpScreen(
    tester,
    const FinanceScreen(),
    accounts: acc,
    installments: inst,
    fixedCosts: fix,
    setup: (a) => a.token = token,
  );
  return (accounts: acc, installments: inst, fixedCosts: fix, log: env.log);
}

void main() {
  setUpAll(() async {
    await loadRedesignFonts();
    await initializeDateFormatting('pt_BR');
  });

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

  testWidgets('shows the title and three tabs, Contas first', (tester) async {
    await _pump(tester);

    expect(find.text('Finanças e Faturas'), findsOneWidget);
    final tabs =
        tester.widget<AppUnderlineTabs>(find.byType(AppUnderlineTabs)).labels;
    expect(tabs, ['Contas', 'Parcelas', 'Dashboard']);

    final controller = tester.widget<TabBar>(find.byType(TabBar)).controller!;
    expect(controller.length, 3);
    expect(controller.index, 0);
  });

  testWidgets('Contas tab shows the accounts section', (tester) async {
    await _pump(
      tester,
      accounts: [fakeAccount(id: 1, name: 'Nubank', balance: 100)],
    );

    expect(find.text('Minhas contas'), findsOneWidget);
    expect(find.text('Nubank'), findsOneWidget);
  });

  testWidgets('Contas tab keeps the Receitas/Despesas shortcuts', (
    tester,
  ) async {
    await _pump(tester);

    expect(find.text('Receitas'), findsOneWidget);
    expect(find.text('Despesas'), findsOneWidget);
  });

  testWidgets('Parcelas tab lists the installments of the month', (
    tester,
  ) async {
    await _pump(
      tester,
      installments: [
        fakeInstallment(
          id: 1,
          name: 'iPhone',
          merchantName: 'Apple Store',
          totalAmount: 1200,
          totalInstallments: 12,
          dueDayOfMonth: 10,
          startDate: DateTime(_now.year, _now.month, 1),
        ),
      ],
    );

    await tester.tap(find.text('Parcelas'));
    await tester.pumpAndSettle();

    expect(find.text('Apple Store'), findsOneWidget);
  });

  testWidgets('Dashboard tab shows fixed costs and the month total', (
    tester,
  ) async {
    await _pump(
      tester,
      fixedCosts: [
        fakeFixedCost(
          id: 1,
          name: 'Netflix',
          amount: 55.9,
          category: 'streaming',
          createdAt: DateTime(_now.year, _now.month - 1, 1),
        ),
      ],
    );

    await tester.tap(find.text('Dashboard'));
    await tester.pumpAndSettle();

    expect(find.text('Total do Mês'), findsOneWidget);
    expect(find.text('Netflix'), findsOneWidget);
  });

  testWidgets('the FAB follows the active tab', (tester) async {
    await _pump(tester);

    expect(find.byTooltip('Adicionar conta'), findsOneWidget);

    await tester.tap(find.text('Parcelas'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Nova parcela'), findsOneWidget);

    await tester.tap(find.text('Dashboard'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Novo gasto fixo'), findsOneWidget);
  });
}
