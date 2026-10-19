// Componentes compartilhados que a Fase D estendeu ou criou: o hero navy
// (BalanceHeroCard, agora com icone e faixa de controle opcionais), a pilula de
// mes (HeroMonthSwitcher), o card de metrica e a arte de estado vazio.
//
// O que importa aqui e (1) o card SEM controle continuar sendo lido como um
// bloco unico, exatamente como as telas aprovadas o usam, (2) o controle ficar
// acessivel quando existe e (3) os defaults dos componentes estendidos
// continuarem os mesmos.

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miajudai/widgets/finance/balance_hero_card.dart';
import 'package:miajudai/widgets/finance/finance_empty_art.dart';
import 'package:miajudai/widgets/finance/finance_metric_card.dart';
import 'package:miajudai/widgets/finance/finance_tone.dart';
import 'package:miajudai/widgets/finance/hero_month_switcher.dart';

import 'support/test_fonts.dart';

Widget _host(Widget child) => MaterialApp(
      home: Scaffold(
        body: Center(child: SizedBox(width: 342, child: child)),
      ),
    );

void main() {
  setUpAll(loadRedesignFonts);

  group('BalanceHeroCard', () {
    testWidgets('without a control it reads as ONE block', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _host(
          const BalanceHeroCard(
            label: 'Saldo total',
            value: 'R\$ 10,00',
            caption: '2 contas',
          ),
        ),
      );

      expect(
        find.bySemanticsLabel('Saldo total, R\$ 10,00, 2 contas'),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel('Saldo total'), findsNothing);
      expect(find.bySemanticsLabel('R\$ 10,00, 2 contas'), findsNothing);
      handle.dispose();
    });

    testWidgets('an icon is decorative and does not change the reading', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _host(
          const BalanceHeroCard(
            icon: Icons.description_outlined,
            label: 'Saldo total',
            value: 'R\$ 10,00',
            caption: '2 contas',
          ),
        ),
      );

      expect(find.byIcon(Icons.description_outlined), findsOneWidget);
      expect(
        find.bySemanticsLabel('Saldo total, R\$ 10,00, 2 contas'),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets(
        'with a control the label and the value are read apart, and '
        'the control stays reachable and works', (tester) async {
      final handle = tester.ensureSemantics();
      final taps = <String>[];
      await tester.pumpWidget(
        _host(
          BalanceHeroCard(
            label: 'Compromissos do Mês',
            value: 'R\$ 10,00',
            caption: 'Parcelas: R\$ 4,00',
            control: HeroMonthSwitcher(
              label: 'Setembro 2026',
              onPrevious: () => taps.add('previous'),
              onNext: () => taps.add('next'),
            ),
          ),
        ),
      );

      expect(find.bySemanticsLabel('Compromissos do Mês'), findsOneWidget);
      expect(
        find.bySemanticsLabel('R\$ 10,00, Parcelas: R\$ 4,00'),
        findsOneWidget,
      );
      // Os botoes tem de existir na arvore de semantica, com acao de toque.
      for (final tooltip in ['Mês anterior', 'Próximo mês']) {
        final data =
            tester.getSemantics(find.byTooltip(tooltip)).getSemanticsData();
        expect(data.hasAction(ui.SemanticsAction.tap), isTrue, reason: tooltip);
        expect(data.tooltip, tooltip);
      }
      expect(find.bySemanticsLabel('Setembro 2026'), findsOneWidget);

      await tester.tap(find.byTooltip('Mês anterior'));
      await tester.tap(find.byTooltip('Próximo mês'));
      expect(taps, ['previous', 'next']);
      handle.dispose();
    });

    testWidgets('the value shrinks instead of overflowing', (tester) async {
      await tester.pumpWidget(
        _host(
          const BalanceHeroCard(
            label: 'Compromissos do Mês',
            value: 'R\$ 123456789012,34',
            caption: 'x',
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('HeroMonthSwitcher', () {
    testWidgets('both steps are 48dp targets and the month is a live region', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _host(
          HeroMonthSwitcher(
            label: 'Setembro 2026',
            onPrevious: () {},
            onNext: () {},
          ),
        ),
      );

      for (final tooltip in ['Mês anterior', 'Próximo mês']) {
        final size = tester.getSize(find.byTooltip(tooltip));
        expect(size.width, greaterThanOrEqualTo(48), reason: tooltip);
        expect(size.height, greaterThanOrEqualTo(48), reason: tooltip);
      }
      expect(
        tester
            .getSemantics(find.text('Setembro 2026'))
            .flagsCollection
            .isLiveRegion,
        isTrue,
      );
      handle.dispose();
    });
  });

  group('FinanceMetricCard', () {
    testWidgets('reads as one block: label, value, caption', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _host(
          const FinanceMetricCard(
            tone: FinanceTone.installment,
            icon: Icons.shopping_bag_outlined,
            label: 'Parcelas',
            value: 'R\$ 400,00',
            caption: '3 parcelas',
          ),
        ),
      );

      expect(
        find.bySemanticsLabel('Parcelas, R\$ 400,00, 3 parcelas'),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets(
        'a long value shrinks inside the same line height: the card is not '
        'made taller by it', (tester) async {
      Future<double> pairHeight(String secondValue) async {
        await tester.pumpWidget(
          _host(
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Expanded(
                    child: FinanceMetricCard(
                      tone: FinanceTone.installment,
                      icon: Icons.shopping_bag_outlined,
                      label: 'Parcelas',
                      value: 'R\$ 1,00',
                      caption: '1 parcela',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FinanceMetricCard(
                      tone: FinanceTone.fixedCost,
                      icon: Icons.calendar_month_outlined,
                      label: 'Fixos',
                      value: secondValue,
                      caption: '9 gastos fixos',
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
        expect(tester.takeException(), isNull);
        return tester.getSize(find.byType(IntrinsicHeight)).height;
      }

      final short = await pairHeight('R\$ 2,00');
      final long = await pairHeight('R\$ 123456789,00');
      expect(long, short);
    });
  });

  group('FinanceEmptyArt', () {
    testWidgets('keeps the receipt with a plus seal by default', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(const FinanceEmptyArt(tone: FinanceTone.income)),
      );

      expect(find.byIcon(Icons.receipt_long_outlined), findsOneWidget);
      expect(find.byIcon(Icons.add_rounded), findsOneWidget);
    });

    testWidgets('accepts another glyph and another seal', (tester) async {
      await tester.pumpWidget(
        _host(
          const FinanceEmptyArt(
            tone: FinanceTone.fixedCost,
            icon: Icons.calendar_month_outlined,
            sealIcon: Icons.attach_money_rounded,
          ),
        ),
      );

      expect(find.byIcon(Icons.calendar_month_outlined), findsOneWidget);
      expect(find.byIcon(Icons.attach_money_rounded), findsOneWidget);
      expect(find.byIcon(Icons.receipt_long_outlined), findsNothing);
      expect(find.byIcon(Icons.add_rounded), findsNothing);
    });
  });
}
