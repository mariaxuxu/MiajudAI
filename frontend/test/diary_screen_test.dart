// Preservacao de comportamento da tela do Diario (DiaryScreen).
//
// Cada caso prova que a UI redesenhada continua acionando o DiaryProvider com
// os MESMOS argumentos, com as MESMAS guardas (texto vazio, sem token), o MESMO
// fluxo de abrir/cancelar/salvar o formulario e o MESMO reset ao trocar de dia,
// e que o `TableCalendar` recebe os MESMOS parametros funcionais.
//
// Os localizadores evitam depender do visual (textos e icones), para o mesmo
// arquivo poder rodar contra a tela legada e contra a redesenhada.

import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:miajudai/models/diary_entry_model.dart';
import 'package:miajudai/screens/diary_screen.dart';
import 'package:miajudai/theme/tokens/app_colors_semantic.dart';
import 'package:miajudai/widgets/calendar/calendar_card.dart';
import 'package:miajudai/widgets/common/empty_state_card.dart';
import 'package:miajudai/widgets/common/section_header.dart';
import 'package:miajudai/widgets/diary/category_chips.dart';
import 'package:miajudai/widgets/diary/diary_entry_card.dart';
import 'package:miajudai/widgets/diary/mood_selector.dart';
import 'package:table_calendar/table_calendar.dart';

import 'support/fake_diary_provider.dart';
import 'support/pump_screen.dart';
import 'support/test_fonts.dart';

typedef _Env = ({FakeDiaryProvider diary, RouteLog log});

final DateTime _now = DateTime.now();
final DateTime _today = DateTime(_now.year, _now.month, _now.day);

/// Um dia do mes corrente que nao e hoje e que so aparece uma vez na grade
/// (do 7 ao 24 nunca ha repeticao com os dias de meses vizinhos).
final int _otherDay = _now.day == 10 ? 11 : 10;

Future<_Env> _pump(
  WidgetTester tester, {
  List<DiaryEntry> Function()? seed,
  String? token = 'test-token',
  bool pushed = false,
}) async {
  final diary = FakeDiaryProvider();
  if (seed != null) diary.items = seed();

  final env = await pumpScreen(
    tester,
    const DiaryScreen(),
    diary: diary,
    pushed: pushed,
    setup: (a) => a.token = token,
  );
  return (diary: diary, log: env.log);
}

List<DiaryEntry> _todayEntries() => [
      fakeDiaryEntry(
        id: 1,
        text: 'Dia produtivo no trabalho',
        mood: 'happy',
        tags: ['finance', 'domestic'],
        createdAt: DateTime(_now.year, _now.month, _now.day, 14, 32),
      ),
      fakeDiaryEntry(
        id: 2,
        text: 'Noite tranquila em casa',
        mood: 'sad',
        createdAt: DateTime(_now.year, _now.month, _now.day, 21, 5),
      ),
    ];

List<DiaryEntry> _otherDayEntry() => [
      fakeDiaryEntry(
        id: 3,
        text: 'Passeio no parque',
        mood: 'neutral',
        createdAt: DateTime(_now.year, _now.month, _otherDay, 9, 0),
      ),
    ];

/// O `TableCalendar` e generico; o predicado casa qualquer instancia.
TableCalendar<dynamic> _calendar(WidgetTester tester) => tester.widget(
      find.byWidgetPredicate((w) => w is TableCalendar),
    ) as TableCalendar<dynamic>;

final Finder _saveButton = find.byWidgetPredicate(
  (w) => w is Text && (w.data ?? '').startsWith('Salvar'),
);

final Finder _nextMonthIcon = find.byWidgetPredicate(
  (w) =>
      w is Icon &&
      (w.icon == Icons.chevron_right || w.icon == Icons.chevron_right_rounded),
);

/// Rola ate o alvo (a tela e uma coluna rolavel) e toca.
Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

/// Toca no dia do mes corrente. Volta ao topo antes: `ensureVisible` sobre um
/// dia rolaria tambem o `PageView` horizontal do calendario e mostraria dois
/// meses ao mesmo tempo.
Future<void> _tapDay(WidgetTester tester, int day) async {
  tester
      .state<ScrollableState>(find.byType(Scrollable).first)
      .position
      .jumpTo(0);
  await tester.pump();
  await tester.tap(
    find.byKey(ValueKey('CellContent-${_now.year}-${_now.month}-$day')),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

Future<void> _openForm(WidgetTester tester) async {
  final empty = find.text('Escrever entrada');
  await _tap(
    tester,
    empty.evaluate().isNotEmpty ? empty : find.text('Adicionar outra entrada'),
  );
}

Future<void> _write(WidgetTester tester, String text) async {
  await tester.ensureVisible(find.byType(TextField));
  await tester.enterText(find.byType(TextField), text);
  await tester.pump();
}

Future<void> _save(WidgetTester tester) async {
  await _tap(tester, _saveButton);
  await tester.pumpAndSettle();
}

String _fieldText(WidgetTester tester) =>
    tester.widget<TextField>(find.byType(TextField)).controller!.text;

void main() {
  setUpAll(() async {
    await loadRedesignFonts();
    await initializeDateFormatting('pt_BR');
  });

  group('carga', () {
    testWidgets('carrega o mes corrente uma vez, com o token', (tester) async {
      final r = await _pump(tester);

      expect(r.diary.loadCalls, hasLength(1));
      expect(r.diary.loadCalls.single.token, 'test-token');
      final month = r.diary.loadCalls.single.month;
      expect((month.year, month.month), (_now.year, _now.month));
    });

    testWidgets('sem token nao carrega nada', (tester) async {
      final r = await _pump(tester, token: null);

      expect(r.diary.loadCalls, isEmpty);
    });
  });

  group('calendario', () {
    testWidgets('abre em hoje, com o mesmo intervalo e em portugues',
        (tester) async {
      await _pump(tester);

      final calendar = _calendar(tester);
      expect(isSameDay(calendar.focusedDay, _today), isTrue);
      expect(calendar.selectedDayPredicate!(_today), isTrue);
      expect(calendar.firstDay, DateTime.utc(2024));
      expect(calendar.lastDay, DateTime.utc(2027));
      expect(calendar.locale, 'pt_BR');
    });

    testWidgets('o carregador de eventos e o entriesForDay do provider',
        (tester) async {
      await _pump(
        tester,
        seed: () => [..._todayEntries(), ..._otherDayEntry()],
      );

      final loader = _calendar(tester).eventLoader!;
      expect(loader(_today), hasLength(2));
      expect(
        loader(DateTime.utc(_now.year, _now.month, _otherDay)),
        hasLength(1),
      );
      expect(loader(DateTime(2025, 1, 1)), isEmpty);
    });

    testWidgets('tocar em outro dia troca a selecao e o dia focado',
        (tester) async {
      await _pump(tester);

      await _tapDay(tester, _otherDay);

      final other = DateTime.utc(_now.year, _now.month, _otherDay);
      expect(_calendar(tester).selectedDayPredicate!(other), isTrue);
      expect(_calendar(tester).selectedDayPredicate!(_today), isFalse);
      expect(isSameDay(_calendar(tester).focusedDay, other), isTrue);
    });

    // O legado atribui _focusedDay em onPageChanged SEM setState e recarrega o
    // mes novo; a tela nao se reconstroi (o formulario aberto continua aberto).
    testWidgets('trocar de mes recarrega, sem reconstruir nem fechar o form',
        (tester) async {
      final r = await _pump(tester);
      await _openForm(tester);
      await _write(tester, 'rascunho');
      final before = _calendar(tester).focusedDay;

      await _tap(tester, _nextMonthIcon);
      await tester.pump(const Duration(milliseconds: 500));

      expect(r.diary.loadCalls, hasLength(2));
      final next = DateTime(_now.year, _now.month + 1);
      expect(r.diary.loadCalls.last.token, 'test-token');
      expect(
        (r.diary.loadCalls.last.month.year, r.diary.loadCalls.last.month.month),
        (next.year, next.month),
      );
      expect(_calendar(tester).focusedDay, before);
      expect(_fieldText(tester), 'rascunho');

      // Uma reconstrucao qualquer (provider notifica) ja enxerga o mes novo,
      // mas a selecao continua no dia que estava selecionado.
      r.diary.refresh();
      await tester.pump();
      final focused = _calendar(tester).focusedDay;
      expect((focused.year, focused.month), (next.year, next.month));
      expect(_calendar(tester).selectedDayPredicate!(_today), isTrue);
      expect(_calendar(tester).selectedDayPredicate!(focused), isFalse);
    });

    testWidgets('trocar de mes sem token nao recarrega', (tester) async {
      final r = await _pump(tester, token: null);

      await _tap(tester, _nextMonthIcon);
      await tester.pump(const Duration(milliseconds: 500));

      expect(r.diary.loadCalls, isEmpty);
    });
  });

  // Depois de trocar de mes, o dia FOCADO (mes novo) e o dia SELECIONADO (o que
  // estava selecionado) divergem: tudo que depende do dia usa o selecionado.
  group('dia selecionado depois de trocar de mes', () {
    Future<_Env> pumpAfterMonthChange(WidgetTester tester) async {
      final r = await _pump(tester, seed: _todayEntries);
      await _tap(tester, _nextMonthIcon);
      await tester.pump(const Duration(milliseconds: 500));
      r.diary.refresh(); // reconstroi a tela, que passa a enxergar o mes novo
      await tester.pump();
      return r;
    }

    testWidgets('a lista continua sendo a do dia selecionado', (tester) async {
      await pumpAfterMonthChange(tester);

      expect(find.text('Dia produtivo no trabalho'), findsOneWidget);
      expect(find.text('Noite tranquila em casa'), findsOneWidget);
    });

    testWidgets('salvar envia o dia selecionado, nao o do mes novo',
        (tester) async {
      final r = await pumpAfterMonthChange(tester);
      await _openForm(tester);
      await _write(tester, 'Meu dia');

      await _save(tester);

      expect(isSameDay(r.diary.saveCalls.single.date, _today), isTrue);
    });
  });

  group('dia sem entradas', () {
    testWidgets('mostra o aviso e o convite, sem formulario', (tester) async {
      await _pump(tester);

      expect(find.text('Nenhuma entrada para este dia'), findsOneWidget);
      expect(find.text('Escrever entrada'), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('escrever entrada abre o formulario completo', (tester) async {
      await _pump(tester);

      await _openForm(tester);

      expect(find.byType(TextField), findsOneWidget);
      expect(find.textContaining('Como foi seu dia?'), findsOneWidget);
      expect(find.text('Como você está se sentindo?'), findsOneWidget);
      for (final mood in ['Feliz', 'Triste', 'Neutro']) {
        expect(find.text(mood), findsOneWidget, reason: mood);
      }
      expect(find.text('Categorias (opcional)'), findsOneWidget);
      for (final tag in ['Finanças', 'Alimentação', 'Casa', 'Agenda']) {
        expect(find.text(tag), findsOneWidget, reason: tag);
      }
      expect(find.text('Cancelar'), findsOneWidget);
      expect(_saveButton, findsOneWidget);
      expect(find.text('Nenhuma entrada para este dia'), findsNothing);
    });

    testWidgets('o campo tem a dica e o teclado de texto do legado',
        (tester) async {
      await _pump(tester);
      await _openForm(tester);

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.decoration!.hintText, 'Escreva aqui seus pensamentos...');
      expect(field.maxLines, 6);
      expect(field.keyboardType, TextInputType.text);
    });
  });

  group('dia com entradas', () {
    testWidgets('lista humor, hora, texto e categorias de cada entrada',
        (tester) async {
      await _pump(tester, seed: _todayEntries);

      expect(find.text('Dia produtivo no trabalho'), findsOneWidget);
      expect(find.text('Noite tranquila em casa'), findsOneWidget);
      expect(find.text('Feliz'), findsOneWidget);
      expect(find.text('Triste'), findsOneWidget);
      expect(find.text('14:32'), findsOneWidget);
      expect(find.text('21:05'), findsOneWidget);
      expect(find.text('Finanças'), findsOneWidget);
      expect(find.text('Casa'), findsOneWidget);
      expect(find.text('Adicionar outra entrada'), findsOneWidget);
      expect(find.text('Nenhuma entrada para este dia'), findsNothing);
      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('mantem a ordem que o provider entrega', (tester) async {
      await _pump(tester, seed: _todayEntries);

      expect(
        tester.getTopLeft(find.text('Dia produtivo no trabalho')).dy,
        lessThan(tester.getTopLeft(find.text('Noite tranquila em casa')).dy),
      );
    });

    testWidgets('so lista as entradas do dia selecionado', (tester) async {
      await _pump(
        tester,
        seed: () => [..._todayEntries(), ..._otherDayEntry()],
      );

      expect(find.text('Passeio no parque'), findsNothing);

      await _tapDay(tester, _otherDay);

      expect(find.text('Passeio no parque'), findsOneWidget);
      expect(find.text('Dia produtivo no trabalho'), findsNothing);
    });

    testWidgets('adicionar outra entrada abre o formulario no lugar da lista',
        (tester) async {
      await _pump(tester, seed: _todayEntries);

      await _openForm(tester);

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Dia produtivo no trabalho'), findsNothing);
      expect(find.text('Adicionar outra entrada'), findsNothing);
    });
  });

  group('formulario', () {
    testWidgets('trocar de dia fecha o formulario e zera os campos',
        (tester) async {
      final r = await _pump(tester);
      await _openForm(tester);
      await _write(tester, 'rascunho');
      await _tap(tester, find.text('Feliz'));
      await _tap(tester, find.text('Casa'));

      await _tapDay(tester, _otherDay);

      expect(find.byType(TextField), findsNothing);
      expect(find.text('Nenhuma entrada para este dia'), findsOneWidget);

      await _openForm(tester);
      expect(_fieldText(tester), isEmpty);
      await _write(tester, 'novo');
      await _save(tester);
      expect(r.diary.saveCalls.single.mood, 'neutral');
      expect(r.diary.saveCalls.single.tags, isEmpty);
    });

    testWidgets('cancelar fecha o formulario e zera os campos', (tester) async {
      final r = await _pump(tester);
      await _openForm(tester);
      await _write(tester, 'rascunho');
      await _tap(tester, find.text('Triste'));
      await _tap(tester, find.text('Agenda'));

      await _tap(tester, find.text('Cancelar'));

      expect(find.byType(TextField), findsNothing);
      expect(find.text('Nenhuma entrada para este dia'), findsOneWidget);
      expect(r.diary.saveCalls, isEmpty);

      await _openForm(tester);
      expect(_fieldText(tester), isEmpty);
      await _write(tester, 'novo');
      await _save(tester);
      expect(r.diary.saveCalls.single.mood, 'neutral');
      expect(r.diary.saveCalls.single.tags, isEmpty);
    });

    testWidgets('texto vazio nao salva, avisa e mantem o formulario',
        (tester) async {
      final r = await _pump(tester);
      await _openForm(tester);

      await _save(tester);

      expect(r.diary.saveCalls, isEmpty);
      expect(
        find.text('Escreva algo no diário antes de salvar'),
        findsOneWidget,
      );
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('so espacos tambem nao salva', (tester) async {
      final r = await _pump(tester);
      await _openForm(tester);
      await _write(tester, '     ');

      await _save(tester);

      expect(r.diary.saveCalls, isEmpty);
      expect(
        find.text('Escreva algo no diário antes de salvar'),
        findsOneWidget,
      );
    });

    testWidgets('sem token nao salva, avisa e mantem o formulario',
        (tester) async {
      final r = await _pump(tester, token: null);
      await _openForm(tester);
      await _write(tester, 'Meu dia');

      await _save(tester);

      expect(r.diary.saveCalls, isEmpty);
      expect(find.text('Não autenticado'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(_fieldText(tester), 'Meu dia');
    });

    testWidgets('salva o texto aparado, humor neutro e sem categorias',
        (tester) async {
      final r = await _pump(tester);
      await _openForm(tester);
      await _write(tester, '  Meu dia  ');

      await _save(tester);

      final call = r.diary.saveCalls.single;
      expect(call.text, 'Meu dia');
      expect(call.mood, 'neutral');
      expect(call.tags, isEmpty);
      expect(call.token, 'test-token');
      expect(isSameDay(call.date, _today), isTrue);
    });

    testWidgets('o humor escolhido e o que vai; o ultimo toque vale',
        (tester) async {
      final r = await _pump(tester);
      await _openForm(tester);
      await _write(tester, 'Meu dia');

      await _tap(tester, find.text('Feliz'));
      await _tap(tester, find.text('Triste'));
      await _save(tester);

      expect(r.diary.saveCalls.single.mood, 'sad');
    });

    testWidgets('Feliz envia happy', (tester) async {
      final r = await _pump(tester);
      await _openForm(tester);
      await _write(tester, 'Meu dia');

      await _tap(tester, find.text('Feliz'));
      await _save(tester);

      expect(r.diary.saveCalls.single.mood, 'happy');
    });

    testWidgets('as categorias vao na ordem em que foram marcadas',
        (tester) async {
      final r = await _pump(tester);
      await _openForm(tester);
      await _write(tester, 'Meu dia');

      await _tap(tester, find.text('Alimentação'));
      await _tap(tester, find.text('Finanças'));
      await _tap(tester, find.text('Agenda'));
      await _tap(tester, find.text('Casa'));
      await _tap(tester, find.text('Agenda')); // desmarca
      await _save(tester);

      expect(r.diary.saveCalls.single.tags, ['food', 'finance', 'domestic']);
    });

    testWidgets('cada categoria envia o seu valor', (tester) async {
      final r = await _pump(tester);
      await _openForm(tester);
      await _write(tester, 'Meu dia');

      await _tap(tester, find.text('Finanças'));
      await _tap(tester, find.text('Alimentação'));
      await _tap(tester, find.text('Casa'));
      await _tap(tester, find.text('Agenda'));
      await _save(tester);

      expect(
        r.diary.saveCalls.single.tags,
        ['finance', 'food', 'domestic', 'calendar'],
      );
    });

    testWidgets('salva no dia que o usuario tocou (mesmo valor do dia)',
        (tester) async {
      final r = await _pump(tester);
      await _tapDay(tester, _otherDay);
      await _openForm(tester);
      await _write(tester, 'Meu dia');

      await _save(tester);

      expect(
        r.diary.saveCalls.single.date,
        DateTime.utc(_now.year, _now.month, _otherDay),
      );
    });

    testWidgets('salvar com sucesso avisa, fecha, zera e mostra a entrada',
        (tester) async {
      await _pump(tester);
      await _openForm(tester);
      await _write(tester, 'Meu dia');
      await _tap(tester, find.text('Feliz'));

      await _save(tester);

      expect(find.text('Entrada salva!'), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
      expect(find.text('Meu dia'), findsOneWidget); // agora na lista
      expect(find.text('Adicionar outra entrada'), findsOneWidget);

      // O formulario reaberto esta zerado.
      await _openForm(tester);
      expect(_fieldText(tester), isEmpty);
    });

    testWidgets('falha ao salvar avisa e preserva o que foi escrito',
        (tester) async {
      final r = await _pump(tester);
      r.diary.saveError = Exception('boom');
      await _openForm(tester);
      await _write(tester, 'Meu dia');
      await _tap(tester, find.text('Feliz'));

      await _save(tester);

      expect(find.text('Erro ao salvar: Exception: boom'), findsOneWidget);
      expect(find.text('Entrada salva!'), findsNothing);
      expect(find.byType(TextField), findsOneWidget);
      expect(_fieldText(tester), 'Meu dia');
    });

    // isLoading so chega a tela quando a recarga do mes notifica: nessa fase o
    // botao fica inerte e um segundo toque nao envia de novo.
    testWidgets('durante a recarga o botao fica inerte e nao envia de novo',
        (tester) async {
      final r = await _pump(tester);
      r.diary.reloadGate = Completer<void>();
      await _openForm(tester);
      await _write(tester, 'Meu dia');
      await tester.ensureVisible(_saveButton);
      await tester.pump();
      final center = tester.getCenter(_saveButton);

      await tester.tap(_saveButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.tapAt(center);
      await tester.pump();
      expect(r.diary.saveCalls, hasLength(1));
      expect(find.text('Entrada salva!'), findsNothing);

      r.diary.reloadGate!.complete();
      await tester.pumpAndSettle();

      expect(r.diary.saveCalls, hasLength(1));
      expect(find.text('Entrada salva!'), findsOneWidget);
    });
  });

  group('navegacao', () {
    testWidgets('voltar faz pop', (tester) async {
      final r = await _pump(tester, pushed: true);

      await tester.tap(find.byType(IconButton).first);
      await tester.pumpAndSettle();

      expect(r.log.events, ['pop null']);
      expect(find.text(kOriginScreenText), findsOneWidget);
    });
  });
  // Visual redesenhado: so faz sentido contra a tela nova (o legado tinha outro
  // texto e outros componentes).
  group('contrato visual', () {
    String dayTitle(DateTime day) {
      final text = DateFormat("EEEE, d 'de' MMMM 'de' y", 'pt_BR').format(day);
      return '${text[0].toUpperCase()}${text.substring(1)}';
    }

    bool isChecked(WidgetTester tester, String label) =>
        tester
            .getSemantics(find.bySemanticsLabel(label))
            .getSemanticsData()
            .flagsCollection
            .isChecked ==
        ui.CheckedState.isTrue;

    testWidgets('cabecalho com titulo e subtitulo, sem elementos inventados',
        (tester) async {
      await _pump(tester);

      expect(find.text('Meu Diário'), findsOneWidget);
      expect(
        find.text('Registre seus dias e veja sua evolução'),
        findsOneWidget,
      );
      // Elementos do prototipo sem comportamento no app ficam de fora.
      expect(find.text('Hoje'), findsNothing);
      expect(find.text('Ver compromissos'), findsNothing);
      expect(find.text('0/500'), findsNothing);
    });

    testWidgets('depois de trocar de mes a secao segue no dia selecionado',
        (tester) async {
      final r = await _pump(tester);

      await _tap(tester, _nextMonthIcon);
      await tester.pump(const Duration(milliseconds: 500));
      r.diary.refresh();
      await tester.pump();

      expect(find.text(dayTitle(_today)), findsOneWidget);
    });

    testWidgets('o calendario e o CalendarCard do Design System',
        (tester) async {
      await _pump(tester);

      expect(find.byType(CalendarCard), findsOneWidget);
      expect(find.text(CalendarCard.monthLabel(_now)), findsOneWidget);
    });

    testWidgets('a secao leva o dia por extenso e acompanha a selecao',
        (tester) async {
      await _pump(tester);

      expect(find.text(dayTitle(_today)), findsOneWidget);
      expect(tester.widget<SectionHeader>(find.byType(SectionHeader)).count, 0);

      await _tapDay(tester, _otherDay);

      expect(
        find.text(dayTitle(DateTime(_now.year, _now.month, _otherDay))),
        findsOneWidget,
      );
      expect(find.text(dayTitle(_today)), findsNothing);
    });

    testWidgets('dia vazio: estado vazio com o convite para escrever',
        (tester) async {
      await _pump(tester);

      expect(find.byType(EmptyStateCard), findsOneWidget);
      expect(find.text('Nenhuma entrada para este dia'), findsOneWidget);
      expect(find.byType(DiaryEntryCard), findsNothing);
    });

    testWidgets('dia com entradas: um cartao por entrada e o convite extra',
        (tester) async {
      await _pump(tester, seed: _todayEntries);

      expect(find.byType(DiaryEntryCard), findsNWidgets(2));
      expect(find.byType(EmptyStateCard), findsNothing);
      expect(find.text('Adicionar outra entrada'), findsOneWidget);
    });

    testWidgets('o formulario e salvar/cancelar, sem a copia do prototipo',
        (tester) async {
      await _pump(tester);
      await _openForm(tester);

      expect(find.text('Salvar registro'), findsOneWidget);
      expect(find.text('Cancelar'), findsOneWidget);
      expect(find.byType(EmptyStateCard), findsNothing);
      // As 4 categorias do legado, nao as 9 do prototipo.
      expect(find.byType(FilterChip), findsNWidgets(4));
      expect(find.byType(MoodSelector), findsOneWidget);
      expect(find.byType(CategoryChips), findsOneWidget);
    });

    testWidgets('o campo obrigatorio e anunciado como tal', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester);
      await _openForm(tester);

      // O rotulo se junta a dica do campo na mesma leitura.
      expect(
        find.bySemanticsLabel(RegExp(r'^Como foi seu dia\?, obrigatório')),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('o humor neutro abre marcado e a troca move a marca',
        (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester);
      await _openForm(tester);

      expect(isChecked(tester, 'Neutro'), isTrue);
      expect(isChecked(tester, 'Feliz'), isFalse);

      await _tap(tester, find.text('Feliz'));

      expect(isChecked(tester, 'Feliz'), isTrue);
      expect(isChecked(tester, 'Neutro'), isFalse);
      handle.dispose();
    });

    testWidgets('as categorias abrem desmarcadas e o toque marca e desmarca',
        (tester) async {
      await _pump(tester);
      await _openForm(tester);

      bool marked(String label) => tester
          .widget<FilterChip>(
            find.ancestor(
              of: find.text(label),
              matching: find.byType(FilterChip),
            ),
          )
          .selected;

      expect(marked('Casa'), isFalse);
      await _tap(tester, find.text('Casa'));
      expect(marked('Casa'), isTrue);
      await _tap(tester, find.text('Casa'));
      expect(marked('Casa'), isFalse);
    });

    testWidgets('os humores vem na ordem Feliz, Triste, Neutro',
        (tester) async {
      await _pump(tester);
      await _openForm(tester);

      final options = tester.widget<MoodSelector>(find.byType(MoodSelector));
      expect(
        options.options.map((o) => (o.value, o.label)),
        [('happy', 'Feliz'), ('sad', 'Triste'), ('neutral', 'Neutro')],
      );
      expect(options.selected, 'neutral');
    });

    testWidgets('cada categoria tem o seu icone', (tester) async {
      await _pump(tester);
      await _openForm(tester);

      IconData? iconOf(String label) => tester
          .widget<Icon>(
            find.descendant(
              of: find.ancestor(
                of: find.text(label),
                matching: find.byType(FilterChip),
              ),
              matching: find.byType(Icon),
            ),
          )
          .icon;

      expect(iconOf('Finanças'), Icons.bar_chart_rounded);
      expect(iconOf('Alimentação'), Icons.restaurant_rounded);
      expect(iconOf('Casa'), Icons.home_outlined);
      expect(iconOf('Agenda'), Icons.event_outlined);
    });

    testWidgets('a cor do humor: feliz verde, triste azul, neutro cinza',
        (tester) async {
      await _pump(
        tester,
        seed: () => [
          fakeDiaryEntry(
            id: 1,
            text: 'a',
            mood: 'happy',
            createdAt: DateTime(_now.year, _now.month, _now.day, 8),
          ),
          fakeDiaryEntry(
            id: 2,
            text: 'b',
            mood: 'sad',
            createdAt: DateTime(_now.year, _now.month, _now.day, 9),
          ),
          fakeDiaryEntry(
            id: 3,
            text: 'c',
            mood: 'neutral',
            createdAt: DateTime(_now.year, _now.month, _now.day, 10),
          ),
        ],
      );

      final cards = tester
          .widgetList<DiaryEntryCard>(find.byType(DiaryEntryCard))
          .toList();
      expect(cards.map((c) => c.moodLabel), ['Feliz', 'Triste', 'Neutro']);
      expect(cards.map((c) => c.emoji), ['😊', '😢', '😐']);
      expect(cards.map((c) => c.moodColor), [
        AppSemanticColors.onFeedbackSuccess,
        AppSemanticColors.actionPrimary,
        AppSemanticColors.textSecondaryStrong,
      ]);
    });

    testWidgets('uma categoria desconhecida aparece com o proprio valor',
        (tester) async {
      await _pump(
        tester,
        seed: () => [
          fakeDiaryEntry(
            id: 1,
            text: 'a',
            tags: ['finance', 'work'],
            createdAt: DateTime(_now.year, _now.month, _now.day, 8),
          ),
        ],
      );

      expect(
        tester.widget<DiaryEntryCard>(find.byType(DiaryEntryCard)).tagLabels,
        ['Finanças', 'work'],
      );
    });

    testWidgets('durante a recarga o botao mostra o carregamento',
        (tester) async {
      final r = await _pump(tester);
      r.diary.reloadGate = Completer<void>();
      await _openForm(tester);
      await _write(tester, 'Meu dia');

      await _tap(tester, _saveButton);
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.bySemanticsLabel('Carregando'), findsWidgets);

      r.diary.reloadGate!.complete();
      await tester.pumpAndSettle();
    });
  });
}
