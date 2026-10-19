// Preservacao de comportamento do chat da Luna (FinancialChatScreen).
//
// Cada caso prova que a UI redesenhada continua enviando o MESMO texto ao
// MESMO provider, do mesmo jeito (com token, so quando ha texto, limpando o
// campo so quando o texto vem do campo), e voltando/limpando como antes.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:miajudai/models/chat_message.dart';
import 'package:miajudai/screens/chat/financial_chat_screen.dart';
import 'package:miajudai/widgets/chat/chat_error_banner.dart';
import 'package:miajudai/widgets/chat/chat_message_bubble.dart';

import 'support/fake_auth_provider.dart';
import 'support/fake_chat_provider.dart';
import 'support/pump_screen.dart';
import 'support/test_fonts.dart';

/// As quatro perguntas sugeridas ANTES do redesign, na mesma ordem.
const _originalSuggestions = [
  'Qual meu saldo atual?',
  'Como estão meus gastos este mês?',
  'Onde estou gastando mais?',
  'Tenho dinheiro sobrando?',
];

const _hint = 'Pergunte sobre suas finanças...';

final _sendButton = find.byTooltip('Enviar mensagem');
final _optionsMenu = find.byTooltip('Mais opções');

ChatMessage _msg(String text, {required bool isUser, DateTime? at}) =>
    ChatMessage(
      text: text,
      isUser: isUser,
      timestamp: at ?? DateTime(2026, 1, 5, 14, 32),
    );

/// Monta o chat empilhado sobre uma origem, como no app real (`pushNamed`).
Future<({FakeChatProvider chat, FakeAuthProvider auth, RouteLog log})> _open(
  WidgetTester tester, {
  List<ChatMessage> messages = const [],
  bool loading = false,
  String? error,
  String? token = 'test-token',
}) async {
  final chat = FakeChatProvider()..items = [...messages];
  final env = await pumpScreen(
    tester,
    const FinancialChatScreen(),
    chat: chat,
    pushed: true,
    setup: (a) => a.token = token,
  );

  if (loading || error != null) {
    chat.update(loading: loading, errorMessage: error);
    // O indicador "digitando" anima em loop: pumpAndSettle nunca terminaria.
    await tester.pump(const Duration(milliseconds: 100));
  }
  return (chat: chat, auth: env.auth, log: env.log);
}

String _fieldText(WidgetTester tester) =>
    tester.widget<TextField>(find.byType(TextField)).controller!.text;

void main() {
  setUpAll(loadRedesignFonts);

  group('empty state', () {
    testWidgets('shows the agent intro, suggestions and composer', (
      tester,
    ) async {
      await _open(tester);

      expect(find.text('Luna - Assistente Financeira'), findsOneWidget);
      expect(find.text('Assistente Financeira'), findsOneWidget);
      expect(
        find.text('Pergunte qualquer coisa sobre suas finanças'),
        findsOneWidget,
      );
      expect(find.text('Sugestões'), findsOneWidget);
      for (final q in _originalSuggestions) {
        expect(find.text(q), findsOneWidget);
      }
      expect(find.text(_hint), findsOneWidget);
    });

    testWidgets('has no options menu while there is nothing to clear', (
      tester,
    ) async {
      await _open(tester);
      expect(_optionsMenu, findsNothing);
    });
  });

  group('suggestions send the original question', () {
    for (final q in _originalSuggestions) {
      testWidgets('"$q"', (tester) async {
        final env = await _open(tester);

        await tester.ensureVisible(find.text(q));
        await tester.tap(find.text(q));
        await tester.pump();

        expect(env.chat.sent, [(text: q, token: 'test-token')]);
      });
    }

    testWidgets('leave a draft in the field untouched', (tester) async {
      final env = await _open(tester);
      await tester.enterText(find.byType(TextField), 'rascunho');

      await tester.tap(find.text(_originalSuggestions.first));
      await tester.pump();

      expect(env.chat.sent.single.text, _originalSuggestions.first);
      expect(_fieldText(tester), 'rascunho');
    });

    testWidgets('send nothing without a token', (tester) async {
      final env = await _open(tester, token: null);

      await tester.tap(find.text(_originalSuggestions.first));
      await tester.pump();

      expect(env.chat.sent, isEmpty);
    });
  });

  group('composer', () {
    testWidgets('send button sends the trimmed text and clears the field', (
      tester,
    ) async {
      final env = await _open(tester);
      await tester.enterText(find.byType(TextField), '  quanto gastei?  ');

      await tester.tap(_sendButton);
      await tester.pump();

      expect(env.chat.sent, [(text: 'quanto gastei?', token: 'test-token')]);
      expect(_fieldText(tester), isEmpty);
    });

    testWidgets('the keyboard "send" action sends too', (tester) async {
      final env = await _open(tester);
      await tester.enterText(find.byType(TextField), 'oi');

      await tester.testTextInput.receiveAction(TextInputAction.send);
      await tester.pump();

      expect(env.chat.sent, [(text: 'oi', token: 'test-token')]);
      expect(_fieldText(tester), isEmpty);
    });

    testWidgets('ignores whitespace-only text', (tester) async {
      final env = await _open(tester);
      await tester.enterText(find.byType(TextField), '   ');

      await tester.tap(_sendButton);
      await tester.pump();

      expect(env.chat.sent, isEmpty);
    });

    testWidgets('without a token nothing is sent and the text is kept', (
      tester,
    ) async {
      final env = await _open(tester, token: null);
      await tester.enterText(find.byType(TextField), 'oi');

      await tester.tap(_sendButton);
      await tester.pump();

      expect(env.chat.sent, isEmpty);
      expect(_fieldText(tester), 'oi');
    });

    testWidgets('is disabled while a reply is loading', (tester) async {
      final env = await _open(
        tester,
        messages: [_msg('oi', isUser: true)],
        loading: true,
      );

      expect(tester.widget<TextField>(find.byType(TextField)).enabled, false);
      expect(
        tester
            .widget<IconButton>(
                find.widgetWithIcon(IconButton, Icons.send_rounded))
            .onPressed,
        isNull,
      );

      await tester.tap(_sendButton, warnIfMissed: false);
      await tester.pump();
      expect(env.chat.sent, isEmpty);
    });
  });

  group('conversation', () {
    testWidgets('renders both authors with their time', (tester) async {
      await _open(
        tester,
        messages: [
          _msg('Quanto gastei?', isUser: true, at: DateTime(2026, 1, 5, 9, 5)),
          _msg('Você gastou R\$ 100.', isUser: false),
        ],
      );

      expect(find.text('Quanto gastei?'), findsOneWidget);
      expect(find.text('Você gastou R\$ 100.'), findsOneWidget);
      expect(find.text('09:05'), findsOneWidget);
      expect(find.text('14:32'), findsOneWidget);
      // O estado inicial some quando ha conversa.
      expect(find.text('Sugestões'), findsNothing);
    });

    testWidgets('announces who wrote each message', (tester) async {
      final handle = tester.ensureSemantics();
      await _open(
        tester,
        messages: [
          _msg('Oi', isUser: true),
          _msg('Olá!', isUser: false),
        ],
      );

      // Cada bolha e UMA parada do leitor de tela: autor, texto e horario.
      expect(find.bySemanticsLabel(RegExp('^Você\nOi\n')), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp('^Luna\nOlá!\n')), findsOneWidget);
      handle.dispose();
    });

    testWidgets('shows the typing bubble while loading', (tester) async {
      await _open(
        tester,
        messages: [_msg('Oi', isUser: true)],
        loading: true,
      );

      expect(find.byType(AgentTypingBubble), findsOneWidget);
    });

    testWidgets('first message still loading shows typing, not the intro', (
      tester,
    ) async {
      final env = await _open(tester);
      env.chat.update(items: [_msg('Oi', isUser: true)], loading: true);
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(AgentTypingBubble), findsOneWidget);
      expect(find.text('Sugestões'), findsNothing);
    });

    testWidgets('shows the provider error, and hides it when cleared', (
      tester,
    ) async {
      final env = await _open(
        tester,
        messages: [_msg('Oi', isUser: true)],
        error: 'Não foi possível conectar ao assistente. Tente novamente.',
      );

      expect(find.byType(ChatErrorBanner), findsOneWidget);
      expect(
        find.text('Não foi possível conectar ao assistente. Tente novamente.'),
        findsOneWidget,
      );

      env.chat.update(errorMessage: null);
      await tester.pump();
      expect(find.byType(ChatErrorBanner), findsNothing);
    });

    testWidgets('timestamps use the HH:mm format', (tester) async {
      final at = DateTime(2026, 3, 9, 7, 3);
      await _open(tester, messages: [_msg('Oi', isUser: true, at: at)]);
      expect(find.text(DateFormat('HH:mm').format(at)), findsOneWidget);
      expect(find.text('07:03'), findsOneWidget);
    });
  });

  group('header actions', () {
    testWidgets('options menu clears the conversation', (tester) async {
      final env = await _open(
        tester,
        messages: [_msg('Oi', isUser: true), _msg('Olá!', isUser: false)],
      );

      expect(_optionsMenu, findsOneWidget);
      await tester.tap(_optionsMenu);
      await tester.pumpAndSettle();
      expect(env.chat.clearCalls, 0, reason: 'abrir o menu nao limpa nada');

      await tester.tap(find.text('Limpar conversa'));
      await tester.pumpAndSettle();

      expect(env.chat.clearCalls, 1);
      // Sem mensagens, voltam o estado inicial e o menu some.
      expect(find.text('Sugestões'), findsOneWidget);
      expect(_optionsMenu, findsNothing);
    });

    testWidgets('back pops the route (does not replace it)', (tester) async {
      final env = await _open(tester);
      expect(find.text(kOriginScreenText), findsNothing);

      await tester.tap(find.byTooltip('Voltar'));
      await tester.pumpAndSettle();

      expect(env.log.events, ['pop null']);
      expect(find.text(kOriginScreenText), findsOneWidget);
    });
  });

  group('layout', () {
    const widths = [320.0, 360.0, 390.0, 430.0];

    Future<void> resize(WidgetTester tester, Size logical) async {
      tester.view.physicalSize = logical * 2;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(
        tester.takeException(),
        isNull,
        reason:
            'overflow em ${logical.width.toInt()}x${logical.height.toInt()}',
      );
    }

    for (final w in widths) {
      testWidgets('empty state fits at ${w.toInt()}px wide', (tester) async {
        await _open(tester);
        await resize(tester, Size(w, 640));
        await resize(tester, Size(w, 844));
      });

      testWidgets('conversation fits at ${w.toInt()}px wide', (tester) async {
        await _open(
          tester,
          messages: [
            _msg('Uma pergunta bem longa ' * 6, isUser: true),
            _msg('Uma resposta bem longa da Luna ' * 8, isUser: false),
          ],
          error: 'Não foi possível conectar ao assistente. Tente novamente.',
        );
        await resize(tester, Size(w, 640));
        await resize(tester, Size(w, 844));
      });
    }

    testWidgets('empty state fits with the keyboard open', (tester) async {
      await _open(tester);
      tester.view.viewInsets = const FakeViewPadding(bottom: 600); // 300dp
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(tester.takeException(), isNull);
      // O campo de mensagem continua na tela, acima do teclado.
      final composerBottom = tester.getBottomLeft(find.byType(TextField)).dy;
      expect(composerBottom, lessThanOrEqualTo(844 - 300));
    });

    testWidgets('empty state fits with large text (150%)', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 1.5;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await _open(tester);
      await resize(tester, const Size(390, 844));
      await resize(tester, const Size(320, 640));
    });

    testWidgets('empty state meets tap-target and label guidelines', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await _open(tester);

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      handle.dispose();
    });

    testWidgets('conversation meets tap-target and label guidelines', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await _open(
        tester,
        messages: [_msg('Oi', isUser: true), _msg('Olá!', isUser: false)],
      );

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      handle.dispose();
    });
  });
}
