// Componentes do Calendario (CalendarCard, CalendarEventTile) e o `autofocus`
// de AppFormField.
//
// O CalendarCard so ESTILIZA o TableCalendar: aqui se prova que os callbacks
// chegam como o TableCalendar os entrega (mesmos argumentos), que os botoes de
// mes movem a mesma pagina que os chevrons nativos moveriam e que a grade
// cumpre o alvo de toque de 48dp na largura de referencia.

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:miajudai/theme/app_theme.dart';
import 'package:miajudai/theme/tokens/app_colors_semantic.dart';
import 'package:miajudai/widgets/calendar/calendar_card.dart';
import 'package:miajudai/widgets/calendar/calendar_empty_art.dart';
import 'package:miajudai/widgets/calendar/calendar_event_tile.dart';
import 'package:miajudai/widgets/common/app_form_field.dart';

import 'support/test_fonts.dart';

/// Largura util do card na referencia: 390 menos o gutter de 24 dos dois lados.
const double _cardWidth = 342;

final DateTime _focused = DateTime(2026, 9, 21);

typedef _Calls = ({
  List<({DateTime selected, DateTime focused})> selected,
  List<DateTime> pages,
});

Future<_Calls> _pumpCard(
  WidgetTester tester, {
  List<dynamic> Function(DateTime day)? eventLoader,
  bool Function(DateTime day)? selectedDayPredicate,
  double width = _cardWidth,

  /// Como a tela real: o dia focado recebido no toque volta como `focusedDay`.
  bool followFocus = false,
}) async {
  tester.view.physicalSize = const Size(390, 844) * 2;
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);

  final calls = (
    selected: <({DateTime selected, DateTime focused})>[],
    pages: <DateTime>[],
  );

  var focusedDay = _focused;
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: width,
            child: StatefulBuilder(
              builder: (context, setState) => CalendarCard(
                firstDay: DateTime.utc(2000),
                lastDay: DateTime.utc(2050),
                focusedDay: focusedDay,
                selectedDayPredicate: selectedDayPredicate ??
                    (day) =>
                        day.year == 2026 && day.month == 9 && day.day == 21,
                onDaySelected: (selected, focused) {
                  calls.selected.add((selected: selected, focused: focused));
                  if (followFocus) setState(() => focusedDay = focused);
                },
                onPageChanged: calls.pages.add,
                eventLoader: eventLoader ?? (_) => const [],
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return calls;
}

void main() {
  setUpAll(() async {
    await loadRedesignFonts();
    await initializeDateFormatting('pt_BR');
  });

  group('CalendarCard', () {
    testWidgets('titulo do mes a esquerda e dias da semana em portugues',
        (tester) async {
      await _pumpCard(tester);

      expect(find.text('Setembro 2026'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('Setembro 2026')).dx,
        lessThan(tester.getTopLeft(find.byTooltip('Mês anterior')).dx),
      );
      for (final label in ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb']) {
        expect(find.text(label), findsOneWidget, reason: label);
      }
      // Domingo primeiro, como o TableCalendar por padrao.
      expect(
        tester.getTopLeft(find.text('Dom')).dx,
        lessThan(tester.getTopLeft(find.text('Sáb')).dx),
      );
    });

    testWidgets('mes seguinte: mesma pagina, mesmo callback, titulo novo',
        (tester) async {
      final calls = await _pumpCard(tester);

      await tester.tap(find.byTooltip('Próximo mês'));
      await tester.pumpAndSettle();

      expect(find.text('Outubro 2026'), findsOneWidget);
      expect(find.text('Setembro 2026'), findsNothing);
      expect(calls.pages.map((d) => (d.year, d.month)), [(2026, 10)]);
      expect(calls.selected, isEmpty);
    });

    testWidgets('mes anterior, duas vezes', (tester) async {
      final calls = await _pumpCard(tester);

      await tester.tap(find.byTooltip('Mês anterior'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Mês anterior'));
      await tester.pumpAndSettle();

      expect(find.text('Julho 2026'), findsOneWidget);
      expect(calls.pages.map((d) => (d.year, d.month)), [(2026, 8), (2026, 7)]);
    });

    testWidgets('arrastar a grade tambem troca o mes e atualiza o titulo',
        (tester) async {
      final calls = await _pumpCard(tester);

      await tester.drag(find.text('15'), const Offset(-300, 0));
      await tester.pumpAndSettle();

      expect(find.text('Outubro 2026'), findsOneWidget);
      expect(calls.pages.map((d) => (d.year, d.month)), [(2026, 10)]);
    });

    testWidgets('tocar num dia entrega (dia, dia focado) como o TableCalendar',
        (tester) async {
      final calls = await _pumpCard(tester);

      await tester.tap(find.text('15'));
      await tester.pumpAndSettle();

      expect(calls.selected, hasLength(1));
      expect(calls.selected.single.selected, DateTime.utc(2026, 9, 15));
      expect(calls.selected.single.focused, DateTime.utc(2026, 9, 15));
      expect(calls.pages, isEmpty);
    });

    // Comportamento nativo do TableCalendar (o legado e igual): tocar num dia
    // de outro mes seleciona o dia, entrega o ultimo dia do mes exibido como
    // dia focado e NAO troca de pagina.
    testWidgets('tocar num dia de outro mes seleciona sem trocar de mes',
        (tester) async {
      final calls = await _pumpCard(tester, followFocus: true);

      await tester.tap(
        find.byKey(const ValueKey('CellContent-2026-10-1')),
      );
      await tester.pumpAndSettle();

      expect(calls.selected.single.selected, DateTime.utc(2026, 10, 1));
      expect(calls.selected.single.focused, DateTime.utc(2026, 9, 30));
      expect(find.text('Setembro 2026'), findsOneWidget);
      expect(calls.pages, isEmpty);
    });

    testWidgets('botoes de mes: 48dp, com rotulo e acao de toque',
        (tester) async {
      final handle = tester.ensureSemantics();
      await _pumpCard(tester);

      for (final tooltip in ['Mês anterior', 'Próximo mês']) {
        final size = tester.getSize(find.byTooltip(tooltip));
        expect(size.width, greaterThanOrEqualTo(48), reason: tooltip);
        expect(size.height, greaterThanOrEqualTo(48), reason: tooltip);
        expect(
          tester
              .getSemantics(find.byTooltip(tooltip))
              .getSemanticsData()
              .hasAction(ui.SemanticsAction.tap),
          isTrue,
          reason: tooltip,
        );
      }
      handle.dispose();
    });

    testWidgets('o titulo e uma regiao viva e um cabecalho', (tester) async {
      final handle = tester.ensureSemantics();
      await _pumpCard(tester);

      final data =
          tester.getSemantics(find.text('Setembro 2026')).getSemanticsData();
      expect(data.flagsCollection.isLiveRegion, isTrue);
      expect(data.flagsCollection.isHeader, isTrue);
      handle.dispose();
    });

    testWidgets(
        'toda celula da grade tem alvo de 48dp na largura de referencia',
        (tester) async {
      await _pumpCard(tester);

      final cells = find.byWidgetPredicate(
        (w) =>
            w.key is ValueKey<String> &&
            (w.key! as ValueKey<String>).value.startsWith('CellContent-'),
      );
      expect(cells, findsNWidgets(35)); // setembro/2026 ocupa 5 semanas

      for (final cell in cells.evaluate()) {
        final tap = find
            .ancestor(
              of: find.byWidget(cell.widget),
              matching: find.byType(GestureDetector),
            )
            .first;
        final size = tester.getSize(tap);
        expect(size.width, greaterThanOrEqualTo(48),
            reason: '${cell.widget.key}');
        expect(size.height, greaterThanOrEqualTo(48),
            reason: '${cell.widget.key}');
      }
    });

    testWidgets('o destaque do dia e um quadrado de 34dp em qualquer largura',
        (tester) async {
      for (final width in [_cardWidth, 288.0, 382.0]) {
        await _pumpCard(tester, width: width);

        final highlight = tester.getSize(
          find
              .descendant(
                of: find.byKey(const ValueKey('CellContent-2026-9-21')),
                matching: find.byType(DecoratedBox),
              )
              .first,
        );
        expect(highlight.width, closeTo(34, 0.5), reason: 'largura $width');
        expect(highlight.height, closeTo(34, 0.5), reason: 'largura $width');
      }
    });

    testWidgets('marcador unico por dia com evento, sempre na cor de acao',
        (tester) async {
      await _pumpCard(
        tester,
        eventLoader: (day) {
          if (day.month != 9) return const [];
          if (day.day == 12) return const ['a', 'b', 'c']; // varios no dia
          if (day.day == 3) return const ['a'];
          return const [];
        },
      );

      final markers = find.byWidgetPredicate((w) {
        if (w is! Container) return false;
        final d = w.decoration;
        return d is BoxDecoration &&
            d.shape == BoxShape.circle &&
            d.color == AppSemanticColors.actionPrimary;
      });
      expect(markers, findsNWidgets(2));
    });

    testWidgets('dia selecionado: texto claro; dia de outro mes: secundario',
        (tester) async {
      await _pumpCard(tester);

      Color colorOf(String key) => tester
          .widget<Text>(
            find.descendant(
              of: find.byKey(ValueKey(key)),
              matching: find.byType(Text),
            ),
          )
          .style!
          .color!;

      expect(colorOf('CellContent-2026-9-21'), AppSemanticColors.onAction);
      expect(colorOf('CellContent-2026-9-15'), AppSemanticColors.textPrimary);
      expect(colorOf('CellContent-2026-10-1'), AppSemanticColors.textSecondary);
    });

    testWidgets('em 320dp e texto ampliado o titulo quebra em vez de estourar',
        (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 1.6;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await _pumpCard(tester, width: 288);

      expect(tester.takeException(), isNull);
      expect(find.byTooltip('Próximo mês'), findsOneWidget);
    });
  });

  group('CalendarEventTile', () {
    testWidgets('mostra titulo, data e as acoes recebidas', (tester) async {
      var removed = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: CalendarEventTile(
              title: 'Consulta médica',
              dateLabel: '21 de setembro',
              actions: [
                IconButton(
                  tooltip: 'Remover Consulta médica',
                  icon: const Icon(Icons.delete_outline_rounded),
                  onPressed: () => removed++,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Consulta médica'), findsOneWidget);
      expect(find.text('21 de setembro'), findsOneWidget);
      await tester.tap(find.byTooltip('Remover Consulta médica'));
      expect(removed, 1);
    });

    testWidgets('titulo longo quebra em 240dp sem estourar', (tester) async {
      tester.view.physicalSize = const Size(240, 600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      tester.platformDispatcher.textScaleFactorTestValue = 1.6;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: CalendarEventTile(
              title:
                  'Reunião de pais e mestres sobre o planejamento do segundo semestre',
              dateLabel: '21 de setembro',
              actions: [
                IconButton(
                  tooltip: 'Remover',
                  icon: const Icon(Icons.delete_outline_rounded),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('o icone decorativo fica fora da semantica', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: CalendarEventTile(
              title: 'Consulta médica',
              dateLabel: '21 de setembro',
            ),
          ),
        ),
      );

      expect(find.bySemanticsLabel('Consulta médica'), findsOneWidget);
      expect(find.byIcon(Icons.event_rounded), findsOneWidget);
      expect(
        find.ancestor(
          of: find.byIcon(Icons.event_rounded),
          matching: find.byType(ExcludeSemantics),
        ),
        findsWidgets,
      );
      handle.dispose();
    });
  });

  group('CalendarEmptyArt', () {
    testWidgets('renderiza a Luna recortada sem estourar', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
            home: Scaffold(body: Center(child: CalendarEmptyArt()))),
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(Image), findsOneWidget);
    });
  });

  group('AppFormField.autofocus', () {
    testWidgets('padrao e falso: as outras telas nao mudam', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppFormField(
              label: 'Nome',
              controller: TextEditingController(),
            ),
          ),
        ),
      );

      expect(
          tester.widget<TextField>(find.byType(TextField)).autofocus, isFalse);
    });

    testWidgets('quando ligado, o campo abre focado', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppFormField(
              label: 'Nome',
              controller: TextEditingController(),
              autofocus: true,
            ),
          ),
        ),
      );
      await tester.pump();

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.autofocus, isTrue);
      expect(
        tester
            .widget<EditableText>(find.byType(EditableText))
            .focusNode
            .hasFocus,
        isTrue,
      );
    });
  });
}
