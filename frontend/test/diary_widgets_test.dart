// Componentes do Diario (MoodSelector, CategoryChips, DiaryEntryCard,
// DiaryEmptyArt) e as capacidades novas do AppFormField (varias linhas e
// obrigatorio).
//
// Os seletores so apresentam e avisam: aqui se prova que cada toque sai com o
// `value` certo, que a selecao nao depende so da cor (semantica e glifo) e que
// tudo cede em vez de estourar em telas estreitas e com texto ampliado.

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miajudai/theme/app_theme.dart';
import 'package:miajudai/theme/tokens/app_colors_semantic.dart';
import 'package:miajudai/widgets/common/app_form_field.dart';
import 'package:miajudai/widgets/diary/category_chips.dart';
import 'package:miajudai/widgets/diary/diary_empty_art.dart';
import 'package:miajudai/widgets/diary/diary_entry_card.dart';
import 'package:miajudai/widgets/diary/mood_selector.dart';

import 'support/test_fonts.dart';

const _moods = [
  MoodOption(value: 'happy', emoji: '😊', label: 'Feliz'),
  MoodOption(value: 'sad', emoji: '😢', label: 'Triste'),
  MoodOption(value: 'neutral', emoji: '😐', label: 'Neutro'),
];

const _categories = [
  CategoryOption(
    value: 'finance',
    label: 'Finanças',
    icon: Icons.bar_chart_rounded,
  ),
  CategoryOption(
    value: 'food',
    label: 'Alimentação',
    icon: Icons.restaurant_rounded,
  ),
  CategoryOption(value: 'domestic', label: 'Casa', icon: Icons.home_outlined),
  CategoryOption(
      value: 'calendar', label: 'Agenda', icon: Icons.event_outlined),
];

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  double width = 342,
  double textScale = 1,
}) async {
  tester.view.physicalSize = Size(width, 800);
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(() {
    tester.view.reset();
    tester.platformDispatcher.clearTextScaleFactorTestValue();
  });

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(8),
          child: child,
        ),
      ),
    ),
  );
}

void main() {
  setUpAll(loadRedesignFonts);

  group('MoodSelector', () {
    testWidgets('mostra as opcoes na ordem recebida', (tester) async {
      await _pump(
        tester,
        MoodSelector(options: _moods, selected: 'neutral', onChanged: (_) {}),
      );

      final xs = [
        for (final label in ['Feliz', 'Triste', 'Neutro'])
          tester.getTopLeft(find.text(label)).dx,
      ];
      expect(xs, [...xs]..sort());
      expect(find.text('😊'), findsOneWidget);
    });

    testWidgets('tocar avisa com o value da opcao', (tester) async {
      final taps = <String>[];
      await _pump(
        tester,
        MoodSelector(options: _moods, selected: 'neutral', onChanged: taps.add),
      );

      await tester.tap(find.text('Feliz'));
      await tester.tap(find.text('Triste'));
      await tester.tap(find.text('Neutro'));

      expect(taps, ['happy', 'sad', 'neutral']);
    });

    testWidgets('a opcao escolhida e anunciada como marcada, as outras nao',
        (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(
        tester,
        MoodSelector(options: _moods, selected: 'sad', onChanged: (_) {}),
      );

      bool isChecked(String label) =>
          tester
              .getSemantics(find.bySemanticsLabel(label))
              .getSemanticsData()
              .flagsCollection
              .isChecked ==
          ui.CheckedState.isTrue;

      expect(isChecked('Triste'), isTrue);
      expect(isChecked('Feliz'), isFalse);
      expect(isChecked('Neutro'), isFalse);
      handle.dispose();
    });

    testWidgets('cada bloco e um botao com acao de toque e 48dp',
        (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(
        tester,
        MoodSelector(options: _moods, selected: 'neutral', onChanged: (_) {}),
        width: 240,
      );

      // O emoji e ornamental: so o rotulo escrito e lido, e uma vez so (um no
      // de semantica por bloco, sem o do texto filho).
      for (final option in _moods) {
        expect(
          find.bySemanticsLabel(RegExp(RegExp.escape(option.emoji))),
          findsNothing,
        );
        expect(
          find.bySemanticsLabel(RegExp('^${option.label}\$')),
          findsOneWidget,
        );
      }

      for (final label in ['Feliz', 'Triste', 'Neutro']) {
        final node = tester.getSemantics(find.bySemanticsLabel(label));
        final data = node.getSemanticsData();
        expect(data.hasAction(ui.SemanticsAction.tap), isTrue, reason: label);
        expect(data.flagsCollection.isButton, isTrue, reason: label);
        expect(
          data.flagsCollection.isInMutuallyExclusiveGroup,
          isTrue,
          reason: label,
        );
        expect(node.rect.width, greaterThanOrEqualTo(48), reason: label);
        expect(node.rect.height, greaterThanOrEqualTo(48), reason: label);
      }
      handle.dispose();
    });

    testWidgets('a escolha muda o contorno e o peso do rotulo, nao o tamanho',
        (tester) async {
      Future<(Size, Color?, FontWeight?)> probe(String selected) async {
        await _pump(
          tester,
          MoodSelector(
            options: _moods,
            selected: selected,
            onChanged: (_) {},
          ),
        );
        final tile = find
            .ancestor(of: find.text('Feliz'), matching: find.byType(Material))
            .first;
        final shape =
            tester.widget<Material>(tile).shape! as RoundedRectangleBorder;
        return (
          tester.getSize(tile),
          shape.side.color,
          tester.widget<Text>(find.text('Feliz')).style?.fontWeight,
        );
      }

      final on = await probe('happy');
      final off = await probe('sad');

      expect(on.$1, off.$1);
      expect(on.$2, AppSemanticColors.actionPrimary);
      expect(off.$2, Colors.transparent);
      expect(on.$3, FontWeight.w700);
      expect(off.$3, FontWeight.w500);

      // O fundo tambem muda: azul suave marcado, cinza suave nao marcado.
      Color? fillOf(String selected) => tester
          .widget<Material>(
            find
                .ancestor(
                  of: find.text('Feliz'),
                  matching: find.byType(Material),
                )
                .first,
          )
          .color;
      await probe('happy');
      expect(fillOf('happy'), AppSemanticColors.actionPrimarySubtle);
      await probe('sad');
      expect(fillOf('sad'), AppSemanticColors.surfaceSubtle);
    });

    testWidgets('em 240dp e texto ampliado os tres blocos ficam iguais',
        (tester) async {
      await _pump(
        tester,
        MoodSelector(options: _moods, selected: 'neutral', onChanged: (_) {}),
        width: 240,
        textScale: 1.6,
      );

      expect(tester.takeException(), isNull);
      final heights = [
        for (final label in ['Feliz', 'Triste', 'Neutro'])
          tester
              .getSize(
                find
                    .ancestor(
                      of: find.text(label),
                      matching: find.byType(Material),
                    )
                    .first,
              )
              .height,
      ];
      expect(heights.toSet(), hasLength(1));
    });
  });

  group('CategoryChips', () {
    Future<List<(String, bool)>> pumpChips(
      WidgetTester tester, {
      Set<String> selected = const {},
      double width = 342,
      double textScale = 1,
    }) async {
      final taps = <(String, bool)>[];
      await _pump(
        tester,
        CategoryChips(
          options: _categories,
          selected: selected,
          onChanged: (value, isSelected) => taps.add((value, isSelected)),
        ),
        width: width,
        textScale: textScale,
      );
      return taps;
    }

    testWidgets('um chip por categoria, com o rotulo', (tester) async {
      await pumpChips(tester);

      expect(find.byType(FilterChip), findsNWidgets(4));
      for (final option in _categories) {
        expect(find.text(option.label), findsOneWidget, reason: option.label);
      }
    });

    testWidgets('tocar avisa (value, passou a marcado)', (tester) async {
      final taps = await pumpChips(tester, selected: {'food'});

      await tester.tap(find.text('Finanças'));
      await tester.tap(find.text('Alimentação'));

      expect(taps, [('finance', true), ('food', false)]);
    });

    testWidgets('o chip marcado troca o icone da categoria por um check',
        (tester) async {
      await pumpChips(tester, selected: {'food'});

      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
      expect(find.byIcon(Icons.restaurant_rounded), findsNothing);
      expect(find.byIcon(Icons.bar_chart_rounded), findsOneWidget);
      expect(find.byIcon(Icons.home_outlined), findsOneWidget);
      expect(find.byIcon(Icons.event_outlined), findsOneWidget);
    });

    testWidgets('a selecao e anunciada no chip marcado', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpChips(tester, selected: {'domestic'});

      bool isSelected(String label) =>
          tester
              .getSemantics(find.text(label))
              .getSemanticsData()
              .flagsCollection
              .isSelected ==
          ui.Tristate.isTrue;

      expect(isSelected('Casa'), isTrue);
      expect(isSelected('Finanças'), isFalse);
      handle.dispose();
    });

    testWidgets('alvo de toque de 48dp e acao de toque em cada chip',
        (tester) async {
      final handle = tester.ensureSemantics();
      await pumpChips(tester);

      for (final option in _categories) {
        final node = tester.getSemantics(find.text(option.label));
        expect(
          node.getSemanticsData().hasAction(ui.SemanticsAction.tap),
          isTrue,
          reason: option.label,
        );
        expect(node.rect.height, greaterThanOrEqualTo(48),
            reason: option.label);
      }
      handle.dispose();
    });

    testWidgets('quebra de linha em 240dp com texto ampliado, sem estourar',
        (tester) async {
      await pumpChips(tester, width: 240, textScale: 1.6);

      expect(tester.takeException(), isNull);
      final tops = {
        for (final option in _categories)
          tester.getTopLeft(find.text(option.label)).dy.round(),
      };
      expect(tops.length, greaterThan(1));
    });
  });

  group('DiaryEntryCard', () {
    Future<void> pumpCard(
      WidgetTester tester, {
      List<String> tags = const ['Finanças', 'Casa'],
      String text = 'Dia produtivo no trabalho.',
      double width = 342,
      double textScale = 1,
    }) {
      return _pump(
        tester,
        DiaryEntryCard(
          emoji: '😊',
          moodLabel: 'Feliz',
          moodColor: AppSemanticColors.onFeedbackSuccess,
          timeLabel: '14:32',
          text: text,
          tagLabels: tags,
        ),
        width: width,
        textScale: textScale,
      );
    }

    testWidgets('mostra humor, hora, texto e categorias', (tester) async {
      await pumpCard(tester);

      expect(find.text('Feliz'), findsOneWidget);
      expect(find.text('14:32'), findsOneWidget);
      expect(find.text('Dia produtivo no trabalho.'), findsOneWidget);
      expect(find.text('Finanças'), findsOneWidget);
      expect(find.text('Casa'), findsOneWidget);
    });

    testWidgets('o rotulo do humor leva a cor recebida', (tester) async {
      await pumpCard(tester);

      expect(
        tester.widget<Text>(find.text('Feliz')).style?.color,
        AppSemanticColors.onFeedbackSuccess,
      );
    });

    testWidgets('sem categorias nao mostra chips', (tester) async {
      await pumpCard(tester, tags: const []);

      expect(find.text('Finanças'), findsNothing);
    });

    testWidgets('o emoji e ornamental: fora da semantica', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpCard(tester);

      expect(find.bySemanticsLabel('😊'), findsNothing);
      expect(find.bySemanticsLabel('Feliz'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('texto longo quebra em 240dp com texto ampliado',
        (tester) async {
      await pumpCard(
        tester,
        text: 'Hoje foi um dia longo, com muitas reuniões e pouco tempo para '
                'descansar, mas no fim da tarde consegui caminhar um pouco. ' *
            3,
        tags: const ['Finanças', 'Alimentação', 'Casa', 'Agenda'],
        width: 240,
        textScale: 1.6,
      );

      expect(tester.takeException(), isNull);
    });
  });

  group('DiaryEmptyArt', () {
    testWidgets('renderiza sem estourar', (tester) async {
      await _pump(tester, const Center(child: DiaryEmptyArt()));

      expect(tester.takeException(), isNull);
      expect(find.byIcon(Icons.edit_note_rounded), findsOneWidget);
      expect(find.byIcon(Icons.add_rounded), findsOneWidget);
    });
  });

  group('AppFormField: varias linhas e obrigatorio', () {
    Future<void> pumpField(
      WidgetTester tester, {
      bool isRequired = false,
      int maxLines = 1,
      int? minLines,
    }) {
      return _pump(
        tester,
        AppFormField(
          label: 'Como foi seu dia?',
          controller: TextEditingController(),
          isRequired: isRequired,
          maxLines: maxLines,
          minLines: minLines,
        ),
      );
    }

    testWidgets('por padrao e uma linha e sem asterisco', (tester) async {
      await pumpField(tester);

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.maxLines, 1);
      expect(field.minLines, isNull);
      expect(find.text('Como foi seu dia?'), findsOneWidget);
      expect(find.textContaining('*'), findsNothing);
    });

    testWidgets('maxLines e minLines chegam ao TextField', (tester) async {
      await pumpField(tester, maxLines: 6, minLines: 3);

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.maxLines, 6);
      expect(field.minLines, 3);
    });

    testWidgets('obrigatorio: asterisco no rotulo e "obrigatorio" na semantica',
        (tester) async {
      final handle = tester.ensureSemantics();
      await pumpField(tester, isRequired: true);

      expect(find.textContaining('Como foi seu dia? *'), findsOneWidget);
      expect(
        find.bySemanticsLabel('Como foi seu dia?, obrigatório'),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('obrigatorio e so apresentacao: o campo aceita vazio',
        (tester) async {
      await pumpField(tester, isRequired: true);

      final controller =
          tester.widget<TextField>(find.byType(TextField)).controller!;
      expect(controller.text, isEmpty);
      expect(tester.takeException(), isNull);
    });
  });
}
