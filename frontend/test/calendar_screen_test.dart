// Preservacao de comportamento da tela de Calendario (CalendarScreen).
//
// Cada caso prova que a UI redesenhada continua acionando o EventProvider com
// os MESMOS argumentos, na MESMA ordem (salvar avisa e fecha SEM esperar o
// provider; o recarregamento vem depois), mantendo as MESMAS validacoes e o
// MESMO fluxo de remocao, e que o `TableCalendar` recebe os MESMOS parametros
// funcionais (dia focado/selecionado, callbacks, carregador de eventos).
//
// Os localizadores evitam depender do visual (icones e textos), para o mesmo
// arquivo poder rodar contra a tela legada e contra a redesenhada.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:miajudai/screens/calendar_screen.dart';
import 'package:miajudai/models/event_model.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:miajudai/widgets/calendar/calendar_card.dart';
import 'package:miajudai/widgets/calendar/calendar_event_tile.dart';
import 'package:miajudai/widgets/common/empty_state_card.dart';
import 'package:miajudai/widgets/common/section_header.dart';

import 'support/fake_event_provider.dart';
import 'support/pump_screen.dart';
import 'support/test_fonts.dart';

typedef _Env = ({FakeEventProvider events, RouteLog log});

final DateTime _now = DateTime.now();
final DateTime _today = DateTime(_now.year, _now.month, _now.day);

/// Um dia do mes corrente que nao e hoje e que so aparece uma vez na grade
/// (do 7 ao 24 nunca ha repeticao com os dias de meses vizinhos).
final int _otherDay = _now.day == 10 ? 11 : 10;

Future<_Env> _pump(
  WidgetTester tester, {
  List<EventModel> Function()? seed,
  String? token = 'test-token',
  bool pushed = false,
}) async {
  final events = FakeEventProvider();
  if (seed != null) events.items = seed();

  final env = await pumpScreen(
    tester,
    const CalendarScreen(),
    events: events,
    pushed: pushed,
    setup: (a) => a.token = token,
  );
  return (events: events, log: env.log);
}

List<EventModel> _twoDays() => [
      fakeEvent(id: 4, title: 'Consulta médica', date: _today),
      fakeEvent(
        id: 9,
        title: 'Reunião de pais',
        date: DateTime(_now.year, _now.month, _otherDay),
      ),
    ];

/// O `TableCalendar` e generico (o legado infere `EventModel`); o predicado
/// casa qualquer instancia.
TableCalendar<dynamic> _calendar(WidgetTester tester) => tester.widget(
      find.byWidgetPredicate((w) => w is TableCalendar),
    ) as TableCalendar<dynamic>;

Future<void> _tapDay(WidgetTester tester, int day) async {
  await tester.tap(find.text('$day'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

Future<void> _openSheet(WidgetTester tester) async {
  await tester.tap(find.byType(FloatingActionButton));
  await tester.pumpAndSettle();
}

Future<void> _save(WidgetTester tester, String title) async {
  await tester.enterText(find.byType(TextField), title);
  await tester.tap(find.text('Salvar compromisso'));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() async {
    await loadRedesignFonts();
    await initializeDateFormatting('pt_BR');
  });

  group('carga', () {
    testWidgets('carrega os compromissos uma vez, com o token', (tester) async {
      final r = await _pump(tester);
      expect(r.events.loadCalls, ['test-token']);
    });

    testWidgets('sem token nao carrega nada', (tester) async {
      final r = await _pump(tester, token: null);
      expect(r.events.loadCalls, isEmpty);
    });
  });

  group('dia selecionado', () {
    testWidgets('abre em hoje e lista so os compromissos de hoje',
        (tester) async {
      await _pump(tester, seed: _twoDays);

      expect(find.text('Consulta médica'), findsOneWidget);
      expect(find.text('Reunião de pais'), findsNothing);
      expect(isSameDay(_calendar(tester).focusedDay, _today), isTrue);
      expect(_calendar(tester).selectedDayPredicate!(_today), isTrue);
    });

    testWidgets('tocar em outro dia troca a lista e a selecao', (tester) async {
      await _pump(tester, seed: _twoDays);

      await _tapDay(tester, _otherDay);

      expect(find.text('Reunião de pais'), findsOneWidget);
      expect(find.text('Consulta médica'), findsNothing);
      final other = DateTime.utc(_now.year, _now.month, _otherDay);
      expect(_calendar(tester).selectedDayPredicate!(other), isTrue);
      expect(_calendar(tester).selectedDayPredicate!(_today), isFalse);
      expect(isSameDay(_calendar(tester).focusedDay, other), isTrue);
    });

    testWidgets('o carregador de eventos e o eventsForDay do provider',
        (tester) async {
      await _pump(tester, seed: _twoDays);

      final loader = _calendar(tester).eventLoader!;
      expect(loader(_today).map((e) => (e as EventModel).title),
          ['Consulta médica']);
      expect(
        loader(DateTime.utc(_now.year, _now.month, _otherDay))
            .map((e) => (e as EventModel).title),
        ['Reunião de pais'],
      );
      expect(loader(DateTime(2030, 1, 1)), isEmpty);
    });

    testWidgets('o intervalo navegavel e 2000 a 2050', (tester) async {
      await _pump(tester);

      expect(_calendar(tester).firstDay, DateTime.utc(2000));
      expect(_calendar(tester).lastDay, DateTime.utc(2050));
    });

    // O legado atribui _focusedDay em onPageChanged SEM setState: a tela nao
    // se reconstroi ao trocar de mes, so quando outra coisa a reconstroi.
    testWidgets('trocar de mes nao reconstroi a tela nem muda a selecao',
        (tester) async {
      final r = await _pump(tester, seed: _twoDays);
      final before = _calendar(tester).focusedDay;

      await tester.tap(find.byIcon(Icons.chevron_right_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(_calendar(tester).focusedDay, before);
      expect(find.text('Consulta médica'), findsOneWidget);
      expect(_calendar(tester).selectedDayPredicate!(_today), isTrue);

      // Uma reconstrucao qualquer (provider notifica) ja enxerga o novo mes.
      r.events.refresh();
      await tester.pump();
      final focused = _calendar(tester).focusedDay;
      expect((
        focused.year,
        focused.month
      ), (
        DateTime(_now.year, _now.month + 1).year,
        DateTime(_now.year, _now.month + 1).month
      ));
    });
  });

  // Depois de tocar num dia e trocar de mes, o dia FOCADO (mes novo) e o dia
  // SELECIONADO (o tocado) divergem: tudo que depende do dia usa o selecionado.
  group('dia selecionado depois de trocar de mes', () {
    Future<_Env> pumpAfterMonthChange(WidgetTester tester) async {
      final r = await _pump(tester, seed: _twoDays);
      await _tapDay(tester, _otherDay);
      await tester.tap(find.byIcon(Icons.chevron_right_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      r.events.refresh(); // reconstroi a tela, que passa a enxergar o mes novo
      await tester.pump();
      return r;
    }

    testWidgets('a lista continua sendo a do dia tocado', (tester) async {
      await pumpAfterMonthChange(tester);

      expect(find.text('Reunião de pais'), findsOneWidget);
    });

    testWidgets('a sheet mostra a data do dia tocado, nao a do mes novo',
        (tester) async {
      await pumpAfterMonthChange(tester);
      await _openSheet(tester);

      final selected = DateTime(_now.year, _now.month, _otherDay);
      expect(
        find.text(DateFormat("d 'de' MMMM 'de' y", 'pt_BR').format(selected)),
        findsOneWidget,
      );
    });

    testWidgets('salvar envia o dia tocado, nao o do mes novo', (tester) async {
      final r = await pumpAfterMonthChange(tester);
      await _openSheet(tester);

      await _save(tester, 'Dentista');

      expect(
        r.events.addCalls.single.date,
        DateTime.utc(_now.year, _now.month, _otherDay),
      );
    });
  });

  group('novo compromisso', () {
    testWidgets('a sheet mostra o titulo e a data selecionada', (tester) async {
      await _pump(tester);
      await _openSheet(tester);

      expect(find.text('Novo Compromisso'), findsOneWidget);
      expect(
        find.text(DateFormat("d 'de' MMMM 'de' y", 'pt_BR').format(_today)),
        findsOneWidget,
      );
    });

    testWidgets('a data da sheet acompanha o dia tocado', (tester) async {
      await _pump(tester);
      await _tapDay(tester, _otherDay);
      await _openSheet(tester);

      final other = DateTime(_now.year, _now.month, _otherDay);
      expect(
        find.text(DateFormat("d 'de' MMMM 'de' y", 'pt_BR').format(other)),
        findsOneWidget,
      );
    });

    testWidgets('o campo abre focado e com a dica de exemplo', (tester) async {
      await _pump(tester);
      await _openSheet(tester);

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.autofocus, isTrue);
      expect(field.decoration!.hintText, 'Ex: Consulta médica');
      expect(find.text('Descrição'), findsOneWidget);
    });

    testWidgets('vazio nao salva, avisa e mantem a sheet', (tester) async {
      final r = await _pump(tester);
      await _openSheet(tester);

      await tester.tap(find.text('Salvar compromisso'));
      await tester.pumpAndSettle();

      expect(r.events.addCalls, isEmpty);
      expect(find.text('Digite uma descrição'), findsOneWidget);
      expect(find.text('Novo Compromisso'), findsOneWidget);
    });

    testWidgets('so espacos tambem nao salva', (tester) async {
      final r = await _pump(tester);
      await _openSheet(tester);

      await _save(tester, '    ');

      expect(r.events.addCalls, isEmpty);
      expect(find.text('Digite uma descrição'), findsOneWidget);
      expect(find.text('Novo Compromisso'), findsOneWidget);
    });

    testWidgets('salva com o titulo aparado e o dia selecionado',
        (tester) async {
      final r = await _pump(tester);
      await _openSheet(tester);

      await _save(tester, '  Dentista  ');

      final call = r.events.addCalls.single;
      expect(call.token, 'test-token');
      expect(call.title, 'Dentista');
      expect(isSameDay(call.date, _today), isTrue);
      expect(find.text('Novo Compromisso'), findsNothing);
      expect(find.text('Compromisso salvo!'), findsOneWidget);
    });

    testWidgets('salva no dia que o usuario tocou (mesmo valor do dia)',
        (tester) async {
      final r = await _pump(tester);
      await _tapDay(tester, _otherDay);
      await _openSheet(tester);

      await _save(tester, 'Dentista');

      expect(r.events.addCalls.single.date,
          DateTime.utc(_now.year, _now.month, _otherDay));
    });

    testWidgets('fecha e avisa SEM esperar o provider; recarrega depois',
        (tester) async {
      final r = await _pump(tester);
      r.events.addGate = Completer<void>();
      await _openSheet(tester);

      await _save(tester, 'Dentista');

      // O provider ainda nao terminou: sheet fechada, aviso na tela e nenhum
      // recarregamento alem do da abertura.
      expect(find.text('Novo Compromisso'), findsNothing);
      expect(find.text('Compromisso salvo!'), findsOneWidget);
      expect(r.events.loadCalls, ['test-token']);

      r.events.addGate!.complete();
      await tester.pumpAndSettle();

      expect(r.events.loadCalls, ['test-token', 'test-token']);
      expect(find.text('Dentista'), findsOneWidget);
    });

    testWidgets('sem token nao salva, nao fecha e nao avisa', (tester) async {
      final r = await _pump(tester, token: null);
      await _openSheet(tester);

      await _save(tester, 'Dentista');

      expect(r.events.addCalls, isEmpty);
      expect(find.text('Novo Compromisso'), findsOneWidget);
      expect(find.text('Compromisso salvo!'), findsNothing);
    });
  });

  group('remocao', () {
    testWidgets('pede confirmacao com o titulo do compromisso', (tester) async {
      await _pump(tester, seed: _twoDays);

      await tester.tap(find.byIcon(Icons.delete_outline_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Deletar compromisso?'), findsOneWidget);
      expect(
        find.text('Tem certeza que deseja remover "Consulta médica"?'),
        findsOneWidget,
      );
    });

    testWidgets('cancelar fecha sem remover nem avisar', (tester) async {
      final r = await _pump(tester, seed: _twoDays);

      await tester.tap(find.byIcon(Icons.delete_outline_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(r.events.removeCalls, isEmpty);
      expect(find.text('Deletar compromisso?'), findsNothing);
      expect(find.text('Compromisso removido'), findsNothing);
      expect(find.text('Consulta médica'), findsOneWidget);
    });

    testWidgets('confirmar remove pelo id, fecha e avisa', (tester) async {
      final r = await _pump(tester, seed: _twoDays);

      await tester.tap(find.byIcon(Icons.delete_outline_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Deletar'));
      await tester.pumpAndSettle();

      expect(r.events.removeCalls, [(token: 'test-token', id: 4)]);
      expect(find.text('Deletar compromisso?'), findsNothing);
      expect(find.text('Compromisso removido'), findsOneWidget);
      expect(find.text('Consulta médica'), findsNothing);
    });

    testWidgets('remove o compromisso certo quando ha mais de um no dia',
        (tester) async {
      final r = await _pump(
        tester,
        seed: () => [
          fakeEvent(id: 4, title: 'Consulta médica', date: _today),
          fakeEvent(id: 5, title: 'Academia', date: _today),
        ],
      );

      await tester.tap(find.byIcon(Icons.delete_outline_rounded).at(1));
      await tester.pumpAndSettle();
      expect(
        find.text('Tem certeza que deseja remover "Academia"?'),
        findsOneWidget,
      );
      await tester.tap(find.text('Deletar'));
      await tester.pumpAndSettle();

      expect(r.events.removeCalls, [(token: 'test-token', id: 5)]);
    });

    // O legado avisa "removido" mesmo sem token, embora nada seja enviado.
    testWidgets('sem token nao remove, mas avisa como o legado',
        (tester) async {
      final r = await _pump(tester, seed: _twoDays, token: null);

      await tester.tap(find.byIcon(Icons.delete_outline_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Deletar'));
      await tester.pumpAndSettle();

      expect(r.events.removeCalls, isEmpty);
      expect(find.text('Compromisso removido'), findsOneWidget);
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
    String capitalized(String text) =>
        '${text[0].toUpperCase()}${text.substring(1)}';

    String dayTitle(DateTime day) =>
        capitalized(DateFormat("EEEE, d 'de' MMMM", 'pt_BR').format(day));

    testWidgets('cabecalho com titulo e subtitulo, sem acoes inventadas',
        (tester) async {
      await _pump(tester);

      expect(find.text('Calendário'), findsOneWidget);
      expect(find.text('Organize seus compromissos'), findsOneWidget);
      // Elementos do prototipo sem comportamento no app ficam de fora.
      expect(find.text('Hoje'), findsNothing);
      expect(find.text('Ver agenda'), findsNothing);
      expect(find.byIcon(Icons.more_vert), findsNothing);
    });

    testWidgets('o card mostra o mes corrente e os botoes trocam de mes',
        (tester) async {
      await _pump(tester);

      expect(find.text(CalendarCard.monthLabel(_now)), findsOneWidget);

      await tester.tap(find.byTooltip('Próximo mês'));
      await tester.pumpAndSettle();

      expect(
        find.text(CalendarCard.monthLabel(DateTime(_now.year, _now.month + 1))),
        findsOneWidget,
      );
    });

    testWidgets('a secao leva o dia por extenso e acompanha a selecao',
        (tester) async {
      await _pump(tester, seed: _twoDays);

      expect(find.text(dayTitle(_today)), findsOneWidget);

      await _tapDay(tester, _otherDay);
      expect(
        find.text(dayTitle(DateTime(_now.year, _now.month, _otherDay))),
        findsOneWidget,
      );
      expect(find.text(dayTitle(_today)), findsNothing);
    });

    testWidgets('o contador da secao e o numero de compromissos do dia',
        (tester) async {
      await _pump(
        tester,
        seed: () => [
          fakeEvent(id: 4, title: 'Consulta médica', date: _today),
          fakeEvent(id: 5, title: 'Academia', date: _today),
          fakeEvent(id: 6, title: 'Mercado', date: _today),
        ],
      );

      expect(tester.widget<SectionHeader>(find.byType(SectionHeader)).count, 3);
      expect(find.byType(CalendarEventTile), findsNWidgets(3));
    });

    testWidgets('um item por compromisso: titulo, data e remover com rotulo',
        (tester) async {
      await _pump(tester, seed: _twoDays);

      expect(find.byType(CalendarEventTile), findsOneWidget);
      expect(find.text('Consulta médica'), findsOneWidget);
      expect(
        find.text(DateFormat("d 'de' MMMM", 'pt_BR').format(_today)),
        findsOneWidget,
      );
      expect(find.byTooltip('Remover Consulta médica'), findsOneWidget);
    });

    testWidgets('dia sem compromissos mostra o estado livre com CTA',
        (tester) async {
      await _pump(tester);

      expect(find.byType(EmptyStateCard), findsOneWidget);
      expect(find.text('Seu dia está livre!'), findsOneWidget);
      expect(
        find.textContaining('Nenhum compromisso neste dia.'),
        findsOneWidget,
      );
      expect(find.text('Adicionar compromisso'), findsOneWidget);
      expect(find.byType(CalendarEventTile), findsNothing);
      expect(
        tester.widget<SectionHeader>(find.byType(SectionHeader)).count,
        0,
      );
    });

    testWidgets('com compromissos o estado livre some', (tester) async {
      await _pump(tester, seed: _twoDays);

      expect(find.byType(EmptyStateCard), findsNothing);
      expect(find.text('Seu dia está livre!'), findsNothing);
    });

    // O CTA e so um segundo caminho para a sheet que o FAB ja abre.
    testWidgets('o CTA abre a mesma sheet do FAB, com o dia selecionado',
        (tester) async {
      final r = await _pump(tester);

      await tester.tap(find.text('Adicionar compromisso'));
      await tester.pumpAndSettle();

      expect(find.text('Novo Compromisso'), findsOneWidget);
      expect(
        find.text(DateFormat("d 'de' MMMM 'de' y", 'pt_BR').format(_today)),
        findsOneWidget,
      );
      expect(r.events.addCalls, isEmpty);
      expect(r.log.events.where((e) => e.startsWith('push')).length, 1);
    });

    testWidgets('o FAB tem rotulo', (tester) async {
      await _pump(tester);

      expect(find.byTooltip('Adicionar compromisso'), findsWidgets);
      expect(
        find.descendant(
          of: find.byType(FloatingActionButton),
          matching: find.byIcon(Icons.add),
        ),
        findsOneWidget,
      );
    });
  });
}
