// Harness de validacao visual do redesign.
//
// Renderiza cada tela redesenhada na viewport de referencia do Design System
// (390 x 844) e em outras larguras, e verifica: sem overflow, quanto do
// conteudo fica abaixo da dobra e alvos de toque/rotulos de acessibilidade.
// Opcionalmente grava um PNG para comparacao com o prototipo correspondente
// em `referencesForNewDesign/`.
//
// Uso:
//   flutter test test/redesign_screenshot_test.dart
//     -> so as verificacoes de layout (rapido, encerra sozinho)
//
//   flutter test test/redesign_screenshot_test.dart --plain-name "login" ^
//     --dart-define=REDESIGN_CAPTURE=login
//     -> tambem grava build/redesign_screenshots/<tela>_390x844.png
//        (valores: splash | login | signup | login-errors | signup-states | home |
//         home-scrolled | luna | luna-chat | luna-error | accounts-empty |
//         accounts | accounts-sheet | accounts-dialog | accounts-snackbar)
//
// A captura e opt-in e limitada a UMA tela por processo: depois de
// `RenderRepaintBoundary.toImage` o rasterizador fica ocupado, o proximo
// `pump` nao retorna e o processo nao encerra sozinho. Por isso a imagem e
// sempre a ULTIMA coisa que cada teste faz, e o `--plain-name` seleciona qual.
//
// MaterialIcons e Inter sao carregadas a mao (ver support/test_fonts.dart).

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miajudai/models/chat_message.dart';
import 'package:miajudai/models/user_model.dart';
import 'package:miajudai/providers/account_provider.dart';
import 'package:miajudai/providers/auth_provider.dart';
import 'package:miajudai/providers/chat_provider.dart';
import 'package:miajudai/screens/accounts_screen.dart';
import 'package:miajudai/screens/auth/login_screen.dart';
import 'package:miajudai/screens/auth/signup_screen.dart';
import 'package:miajudai/screens/chat/financial_chat_screen.dart';
import 'package:miajudai/screens/splash_screen.dart';
import 'package:miajudai/screens/welcome_screen.dart';
import 'package:miajudai/widgets/agents/agent_card.dart';
import 'package:provider/provider.dart';

import 'support/fake_account_provider.dart';
import 'support/fake_auth_provider.dart';
import 'support/fake_chat_provider.dart';
import 'support/test_fonts.dart';

const Size kReferenceViewport = Size(390, 844);
const double kPixelRatio = 2;

/// Qual tela gravar em PNG: 'splash', 'login', 'signup', 'home',
/// 'home-scrolled', 'login-errors', 'signup-states', 'luna', 'luna-chat',
/// 'luna-error', 'accounts-empty', 'accounts', 'accounts-sheet',
/// 'accounts-dialog', 'accounts-snackbar' ou vazio (nenhuma).
const String kCapture = String.fromEnvironment('REDESIGN_CAPTURE');

const List<String> _assetsToPrecache = [
  'assets/images/brand/logo_mark.png',
  'assets/images/todos_agents.jpg',
  'assets/images/luna.png',
  'assets/images/otto.png',
  'assets/images/tina.png',
];

const List<Size> _otherViewports = [
  Size(320, 640), // menor Android comum
  Size(360, 800),
  Size(430, 932), // iPhone Pro Max
];

/// Monta [screen] uma unica vez e devolve a chave do RepaintBoundary.
Future<GlobalKey> _mount(
  WidgetTester tester,
  Widget screen, {
  void Function(FakeAuthProvider auth)? setup,
  ChatProvider? chat,
  AccountProvider? accounts,
}) async {
  // O binding de teste troca toda sombra por um bloco solido (deterministico
  // para golden tests). Nas capturas, que sao comparadas a olho com o
  // prototipo, as sombras reais importam; so as verificacoes de layout ficam
  // com o comportamento padrao.
  if (kCapture.isNotEmpty) debugDisableShadows = false;

  final key = GlobalKey();
  final auth = FakeAuthProvider();
  setup?.call(auth);

  await tester.pumpWidget(
    RepaintBoundary(
      key: key,
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: auth),
          if (chat != null)
            ChangeNotifierProvider<ChatProvider>.value(value: chat),
          if (accounts != null)
            ChangeNotifierProvider<AccountProvider>.value(value: accounts),
        ],
        child: MaterialApp(debugShowCheckedModeBanner: false, home: screen),
      ),
    ),
  );

  // Imagens de asset decodificam de forma assincrona: sem isto o PNG sai
  // com os espacos das ilustracoes vazios.
  await tester.runAsync(() async {
    final context = tester.element(find.byType(MaterialApp));
    for (final path in _assetsToPrecache) {
      await precacheImage(
        AssetImage(path),
        context,
      ).timeout(const Duration(seconds: 15));
    }
  });

  return key;
}

/// Redimensiona a viewport, relayouta e devolve quanto sobrou abaixo da dobra.
Future<double> _settleAt(WidgetTester tester, Size viewport) async {
  tester.view.physicalSize = viewport * kPixelRatio;
  tester.view.devicePixelRatio = kPixelRatio;

  // Pumps explicitos em vez de pumpAndSettle: o relogio falso precisa avancar
  // alem das animacoes de entrada (ate ~580ms), senao a captura sai com o
  // FadeTransition ainda em opacidade zero.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 700));
  await tester.pump(const Duration(milliseconds: 300));

  // Um RenderFlex overflow vira excecao no binding de teste.
  final problem = tester.takeException();
  expect(
    problem,
    isNull,
    reason: 'overflow em ${viewport.width.toInt()}x${viewport.height.toInt()}: '
        '$problem',
  );

  return tester
      .state<ScrollableState>(find.byType(Scrollable).first)
      .position
      .maxScrollExtent;
}

/// Deixa animacoes disparadas por um toque terminarem antes de capturar.
///
/// Um unico `pump(duracao)` NAO basta: o relogio avanca antes do frame que
/// inicia a animacao, entao o fade-in do texto de erro do `InputDecorator`
/// ainda esta em opacidade zero na captura (o espaco e reservado, o texto nao
/// aparece). O primeiro `pump()` inicia a animacao; o segundo a conclui.
Future<void> _pumpAfterTap(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

/// Alvos de toque >= 48dp e rotulo em todo controle tocavel.
Future<void> _expectAccessibleTapTargets(WidgetTester tester) async {
  final handle = tester.ensureSemantics();
  await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
  handle.dispose();
}

Future<void> _writePng(GlobalKey key, String name) async {
  final boundary =
      key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final image = await boundary.toImage(pixelRatio: kPixelRatio);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();

  final dir = Directory('build/redesign_screenshots');
  dir.createSync(recursive: true);
  final file = File('${dir.path}/$name.png')
    ..writeAsBytesSync(bytes!.buffer.asUint8List());

  // ignore: avoid_print
  print('SCREENSHOT -> ${file.absolute.path}');
}

/// Roda a bateria comum a todas as telas e devolve a dobra na referencia.
///
/// A captura de imagem, quando pedida, e feita por quem chama, por ultimo.
Future<({GlobalKey key, double belowFold})> _checkScreen(
  WidgetTester tester,
  String label,
  Widget screen, {
  void Function()? extraChecks,
  void Function(FakeAuthProvider auth)? setup,
  ChatProvider? chat,
  AccountProvider? accounts,
}) async {
  addTearDown(tester.view.reset);
  final key = await _mount(
    tester,
    screen,
    setup: setup,
    chat: chat,
    accounts: accounts,
  );

  for (final viewport in _otherViewports) {
    final belowFold = await _settleAt(tester, viewport);
    extraChecks?.call();
    // ignore: avoid_print
    print(
      '$label ${viewport.width.toInt()}x${viewport.height.toInt()} '
      '| sem overflow | abaixo da dobra: ${belowFold.toStringAsFixed(1)}px',
    );
  }

  final belowFold = await _settleAt(tester, kReferenceViewport);
  extraChecks?.call();
  // ignore: avoid_print
  print(
    '$label 390x844 (referencia) | sem overflow '
    '| abaixo da dobra: ${belowFold.toStringAsFixed(1)}px',
  );

  return (key: key, belowFold: belowFold);
}

void _expectAgentsSideBySide(WidgetTester tester) {
  final finder = find.byType(AgentCard);
  expect(finder.evaluate().length, 3);

  final tops = finder
      .evaluate()
      .map((e) => tester.getTopLeft(find.byWidget(e.widget)).dy)
      .toSet();

  expect(tops.length, 1, reason: 'os 3 AgentCards devem ficar lado a lado');
}

void _loginAsPedro(FakeAuthProvider auth) {
  auth.currentUser = UserModel(
    id: '1',
    email: 'pedro@mail.com',
    fullName: 'Pedro Kelvin',
    createdAt: DateTime(2024),
  );
}

List<ChatMessage> _sampleConversation() {
  final at = DateTime(2026, 1, 5, 14, 32);
  return [
    ChatMessage(text: 'Qual meu saldo atual?', isUser: true, timestamp: at),
    ChatMessage(
      text: 'Seu saldo somado nas contas é de R\$ 4.820,00. A conta corrente '
          'tem R\$ 1.320,00 e a poupança, R\$ 3.500,00.',
      isUser: false,
      timestamp: at,
    ),
    ChatMessage(
      text: 'Onde estou gastando mais?',
      isUser: true,
      timestamp: at.add(const Duration(minutes: 1)),
    ),
  ];
}

void main() {
  setUpAll(loadRedesignFonts);

  testWidgets('splash', (tester) async {
    final r = await _checkScreen(
      tester,
      'splash',
      const SplashScreen(),
      extraChecks: () => _expectAgentsSideBySide(tester),
    );

    // Fase 1: a composicao inteira cabe em 390x844, como no prototipo.
    expect(r.belowFold, 0.0, reason: 'a splash deve caber em 390x844');

    if (kCapture == 'splash') await _writePng(r.key, 'splash_390x844');
  });

  testWidgets('login', (tester) async {
    final r = await _checkScreen(tester, 'login', const LoginScreen());

    // O login deve caber inteiro em 390x844, ilustracao inclusive.
    expect(r.belowFold, 0.0, reason: 'o login deve caber em 390x844');

    await _expectAccessibleTapTargets(tester);

    if (kCapture == 'login') await _writePng(r.key, 'login_390x844');
  });

  testWidgets('signup', (tester) async {
    final r = await _checkScreen(tester, 'signup', const SignupScreen());

    await _expectAccessibleTapTargets(tester);

    if (kCapture == 'signup') await _writePng(r.key, 'signup_390x844');
  });

  testWidgets('home', (tester) async {
    final r = await _checkScreen(
      tester,
      'home',
      const WelcomeScreen(),
      setup: _loginAsPedro,
    );

    // A home tem 6 cards + banner: rolar e esperado. O que importa e que a
    // navegacao inferior (fora do scroll) e os controles sejam acessiveis.
    await _expectAccessibleTapTargets(tester);

    if (kCapture == 'home') {
      await _writePng(r.key, 'home_390x844');
    }
  });

  // A home rolada ate o fim: mostra a ultima fileira de cards e o banner.
  testWidgets('home scrolled', (tester) async {
    addTearDown(tester.view.reset);
    final key =
        await _mount(tester, const WelcomeScreen(), setup: _loginAsPedro);
    await _settleAt(tester, kReferenceViewport);

    await tester.drag(find.byType(Scrollable).first, const Offset(0, -900));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(tester.takeException(), isNull);

    if (kCapture == 'home-scrolled') {
      await _writePng(key, 'home_scrolled_390x844');
    }
  });

  // Chat da Luna: estado inicial (sugestoes), conversa e erro.
  testWidgets('luna', (tester) async {
    final r = await _checkScreen(
      tester,
      'luna',
      const FinancialChatScreen(),
      chat: FakeChatProvider(),
    );

    // O estado inicial cabe inteiro em 390x844, como no prototipo.
    expect(r.belowFold, 0.0, reason: 'o chat vazio deve caber em 390x844');

    await _expectAccessibleTapTargets(tester);

    if (kCapture == 'luna') await _writePng(r.key, 'luna_390x844');
  });

  testWidgets('luna chat', (tester) async {
    final chat = FakeChatProvider()
      ..items = _sampleConversation()
      ..loading = true;
    addTearDown(tester.view.reset);
    final key = await _mount(tester, const FinancialChatScreen(), chat: chat);
    await _settleAt(tester, kReferenceViewport);
    expect(tester.takeException(), isNull);

    if (kCapture == 'luna-chat') await _writePng(key, 'luna_chat_390x844');
  });

  testWidgets('luna error', (tester) async {
    final chat = FakeChatProvider()
      ..items = _sampleConversation().take(1).toList()
      ..errorMessage =
          'Não foi possível conectar ao assistente. Tente novamente.';
    addTearDown(tester.view.reset);
    final key = await _mount(tester, const FinancialChatScreen(), chat: chat);
    await _settleAt(tester, kReferenceViewport);
    expect(tester.takeException(), isNull);

    if (kCapture == 'luna-error') await _writePng(key, 'luna_error_390x844');
  });

  // Financas (fase A): estado vazio, com contas, sheet, dialogo e aviso.
  FakeAccountProvider withAccounts() => FakeAccountProvider()
    ..items = [
      fakeAccount(id: 1, name: 'Conta Corrente Nubank', balance: 1320),
      fakeAccount(
        id: 2,
        name: 'Reserva de emergencia com nome bem comprido',
        type: 'savings',
        balance: 123456.78,
      ),
      fakeAccount(id: 3, name: 'Cartao', type: 'credit_card', balance: -89.9),
    ];

  testWidgets('accounts empty', (tester) async {
    final r = await _checkScreen(
      tester,
      'accounts-empty',
      const AccountsScreen(),
      accounts: FakeAccountProvider(),
    );
    await _expectAccessibleTapTargets(tester);

    if (kCapture == 'accounts-empty') {
      await _writePng(r.key, 'accounts_empty_390x844');
    }
  });

  testWidgets('accounts', (tester) async {
    final r = await _checkScreen(
      tester,
      'accounts',
      const AccountsScreen(),
      accounts: withAccounts(),
    );
    await _expectAccessibleTapTargets(tester);

    if (kCapture == 'accounts') await _writePng(r.key, 'accounts_390x844');
  });

  // Texto ampliado: o layout tem de ceder (rolar/quebrar), nunca estourar.
  testWidgets('accounts large text', (tester) async {
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    tester.platformDispatcher.textScaleFactorTestValue = 1.6;
    await _mount(tester, const AccountsScreen(), accounts: withAccounts());
    for (final viewport in [..._otherViewports, kReferenceViewport]) {
      await _settleAt(tester, viewport);
    }
  });

  testWidgets('accounts sheet', (tester) async {
    addTearDown(tester.view.reset);
    final key = await _mount(
      tester,
      const AccountsScreen(),
      accounts: FakeAccountProvider(),
    );
    await _settleAt(tester, kReferenceViewport);

    await tester.tap(find.byType(FloatingActionButton));
    await _pumpAfterTap(tester);
    await _pumpAfterTap(tester);
    expect(find.text('Nova Conta'), findsOneWidget);

    for (final viewport in _otherViewports) {
      tester.view.physicalSize = viewport * kPixelRatio;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull, reason: 'sheet em $viewport');
    }

    // Menor tela com o teclado aberto: os campos rolam, nada estoura.
    tester.view.physicalSize = const Size(320, 640) * kPixelRatio;
    tester.view.viewInsets = const FakeViewPadding(bottom: 500);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull, reason: 'sheet com teclado');
    tester.view.resetViewInsets();

    tester.view.physicalSize = kReferenceViewport * kPixelRatio;
    await _pumpAfterTap(tester);
    await _expectAccessibleTapTargets(tester);

    if (kCapture == 'accounts-sheet') {
      await _writePng(key, 'accounts_sheet_390x844');
    }
  });

  testWidgets('accounts dialog', (tester) async {
    addTearDown(tester.view.reset);
    final key = await _mount(
      tester,
      const AccountsScreen(),
      accounts: withAccounts(),
    );
    await _settleAt(tester, kReferenceViewport);

    await tester.tap(find.byTooltip('Remover Conta Corrente Nubank'));
    await _pumpAfterTap(tester);
    await _pumpAfterTap(tester);
    expect(find.text('Deletar conta?'), findsOneWidget);

    for (final viewport in _otherViewports) {
      tester.view.physicalSize = viewport * kPixelRatio;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull, reason: 'dialogo em $viewport');
    }

    tester.view.physicalSize = kReferenceViewport * kPixelRatio;
    await _pumpAfterTap(tester);
    await _expectAccessibleTapTargets(tester);

    if (kCapture == 'accounts-dialog') {
      await _writePng(key, 'accounts_dialog_390x844');
    }
  });

  testWidgets('accounts snackbar', (tester) async {
    addTearDown(tester.view.reset);
    final key = await _mount(
      tester,
      const AccountsScreen(),
      accounts: FakeAccountProvider(),
    );
    await _settleAt(tester, kReferenceViewport);

    await tester.tap(find.byType(FloatingActionButton));
    await _pumpAfterTap(tester);
    await _pumpAfterTap(tester);
    await tester.enterText(find.byType(TextField).first, 'Nubank');
    await tester.tap(find.widgetWithText(FilledButton, 'Criar conta'));
    await _pumpAfterTap(tester);
    await _pumpAfterTap(tester);

    expect(find.text('Conta criada!'), findsOneWidget);
    expect(tester.takeException(), isNull);

    if (kCapture == 'accounts-snackbar') {
      await _writePng(key, 'accounts_snackbar_390x844');
    }
  });

  // Estados: mensagens de validacao e medidor de forca de senha. Cobrem o que
  // o estado inicial nao mostra (contraste do texto de erro, cores do medidor).
  testWidgets('login errors', (tester) async {
    addTearDown(tester.view.reset);
    final key = await _mount(tester, const LoginScreen());
    await _settleAt(tester, kReferenceViewport);

    await tester.enterText(find.byType(TextFormField).at(0), 'nao-e-email');
    await tester.enterText(find.byType(TextFormField).at(1), '123');
    await tester.tap(find.byType(FilledButton));
    await _pumpAfterTap(tester);

    expect(find.text('Email inválido'), findsOneWidget);
    expect(find.text('Mínimo 6 caracteres'), findsOneWidget);
    expect(tester.takeException(), isNull);

    if (kCapture == 'login-errors') {
      await _writePng(key, 'login_errors_390x844');
    }
  });

  testWidgets('signup states', (tester) async {
    addTearDown(tester.view.reset);
    final key = await _mount(tester, const SignupScreen());
    await _settleAt(tester, kReferenceViewport);

    // nome vazio, email invalido, senha "Boa" (3 barras), confirmacao errada
    await tester.enterText(find.byType(TextFormField).at(1), 'ana@');
    await tester.enterText(find.byType(TextFormField).at(2), 'Abc123');
    await tester.enterText(find.byType(TextFormField).at(3), 'diferente');
    await tester.pump();
    await tester.ensureVisible(find.byType(FilledButton));
    await tester.tap(find.byType(FilledButton));
    await _pumpAfterTap(tester);

    expect(find.text('Informe seu nome'), findsOneWidget);
    expect(find.text('Email inválido'), findsOneWidget);
    expect(find.text('Boa'), findsOneWidget);
    expect(find.text('As senhas não coincidem'), findsOneWidget);
    expect(tester.takeException(), isNull);

    if (kCapture == 'signup-states') {
      await _writePng(key, 'signup_states_390x844');
    }
  });
}
