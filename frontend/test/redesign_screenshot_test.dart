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
//         accounts | accounts-sheet | accounts-dialog | accounts-snackbar |
//         income-empty | income | income-sheet | income-edit | income-dialog |
//         expenses-empty | expenses | expenses-tab | expenses-sheet |
//         expenses-edit | expenses-dialog | invoice-empty | invoice |
//         invoice-dashboard | invoice-dashboard-empty | invoice-choice |
//         invoice-installment | invoice-fixed | invoice-dialog |
//         calendar-empty | calendar | calendar-sheet | calendar-dialog)
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
import 'package:intl/date_symbol_data_local.dart';
import 'package:miajudai/models/chat_message.dart';
import 'package:miajudai/models/user_model.dart';
import 'package:miajudai/providers/account_provider.dart';
import 'package:miajudai/providers/auth_provider.dart';
import 'package:miajudai/providers/chat_provider.dart';
import 'package:miajudai/providers/event_provider.dart';
import 'package:miajudai/providers/expense_provider.dart';
import 'package:miajudai/providers/fixed_cost_provider.dart';
import 'package:miajudai/providers/income_provider.dart';
import 'package:miajudai/providers/installment_provider.dart';
import 'package:miajudai/screens/accounts_screen.dart';
import 'package:miajudai/screens/auth/login_screen.dart';
import 'package:miajudai/screens/auth/signup_screen.dart';
import 'package:miajudai/screens/calendar_screen.dart';
import 'package:miajudai/screens/chat/financial_chat_screen.dart';
import 'package:miajudai/screens/expenses_screen.dart';
import 'package:miajudai/screens/income_screen.dart';
import 'package:miajudai/screens/invoice_dashboard_screen.dart';
import 'package:miajudai/screens/splash_screen.dart';
import 'package:miajudai/screens/welcome_screen.dart';
import 'package:miajudai/widgets/agents/agent_card.dart';
import 'package:provider/provider.dart';

import 'support/fake_account_provider.dart';
import 'support/fake_auth_provider.dart';
import 'support/fake_event_provider.dart';
import 'support/fake_expense_provider.dart';
import 'support/fake_fixed_cost_provider.dart';
import 'support/fake_income_provider.dart';
import 'support/fake_installment_provider.dart';
import 'support/fake_chat_provider.dart';
import 'support/test_fonts.dart';

const Size kReferenceViewport = Size(390, 844);
const double kPixelRatio = 2;

/// Qual tela gravar em PNG: 'splash', 'login', 'signup', 'home',
/// 'home-scrolled', 'login-errors', 'signup-states', 'luna', 'luna-chat',
/// 'luna-error', 'accounts-empty', 'accounts', 'accounts-sheet',
/// 'accounts-dialog', 'accounts-snackbar', 'income-empty', 'income',
/// 'income-sheet', 'income-edit', 'income-dialog', 'expenses-empty',
/// 'expenses', 'expenses-tab', 'expenses-sheet', 'expenses-edit',
/// 'expenses-dialog', 'invoice-empty', 'invoice', 'invoice-dashboard',
/// 'invoice-dashboard-empty', 'invoice-choice', 'invoice-installment',
/// 'invoice-fixed', 'invoice-dialog', 'calendar-empty', 'calendar',
/// 'calendar-sheet', 'calendar-dialog' ou vazio (nenhuma).
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
  IncomeProvider? income,
  ExpenseProvider? expenses,
  InstallmentProvider? installments,
  FixedCostProvider? fixedCosts,
  EventProvider? events,
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
          if (income != null)
            ChangeNotifierProvider<IncomeProvider>.value(value: income),
          if (expenses != null)
            ChangeNotifierProvider<ExpenseProvider>.value(value: expenses),
          if (installments != null)
            ChangeNotifierProvider<InstallmentProvider>.value(
              value: installments,
            ),
          if (fixedCosts != null)
            ChangeNotifierProvider<FixedCostProvider>.value(
              value: fixedCosts,
            ),
          if (events != null)
            ChangeNotifierProvider<EventProvider>.value(value: events),
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
      .state<ScrollableState>(
        find
            .byWidgetPredicate(
              (w) => w is Scrollable && w.axis == Axis.vertical,
            )
            .first,
      )
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
  IncomeProvider? income,
  ExpenseProvider? expenses,
  InstallmentProvider? installments,
  FixedCostProvider? fixedCosts,
  EventProvider? events,
}) async {
  addTearDown(tester.view.reset);
  final key = await _mount(
    tester,
    screen,
    setup: setup,
    chat: chat,
    accounts: accounts,
    income: income,
    expenses: expenses,
    installments: installments,
    fixedCosts: fixedCosts,
    events: events,
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
  setUpAll(() async {
    await loadRedesignFonts();
    await initializeDateFormatting('pt_BR');
  });

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

  // Receitas (fase B): vazio, com registros, texto ampliado, sheets e dialogo.
  FakeIncomeProvider withIncomes() => FakeIncomeProvider()
    ..total = 8420.5
    ..items = [
      fakeIncome(
        id: 1,
        description: 'Salário mensal',
        amount: 5200,
        date: DateTime(2026, 9, 5),
      ),
      fakeIncome(
        id: 2,
        description:
            'Freelance: identidade visual para cliente com nome bem comprido',
        amount: 2450.5,
        type: 'freelance',
        date: DateTime(2026, 9, 12),
      ),
      fakeIncome(
        id: 3,
        description: 'Dividendos',
        amount: 620,
        type: 'investment',
        date: DateTime(2026, 9, 15),
      ),
      fakeIncome(
        id: 4,
        description: 'Presente',
        amount: 150,
        type: 'gift',
        date: DateTime(2026, 9, 18),
      ),
    ];

  FakeAccountProvider withTwoAccounts() => FakeAccountProvider()
    ..items = [
      fakeAccount(id: 7, name: 'Conta Corrente Nubank', balance: 1320),
      fakeAccount(id: 9, name: 'Reserva', type: 'savings', balance: 3500.5),
    ];

  testWidgets('income empty', (tester) async {
    final r = await _checkScreen(
      tester,
      'income-empty',
      const IncomeScreen(),
      income: FakeIncomeProvider(),
      accounts: FakeAccountProvider(),
    );
    await _expectAccessibleTapTargets(tester);

    if (kCapture == 'income-empty') {
      await _writePng(r.key, 'income_empty_390x844');
    }
  });

  testWidgets('income', (tester) async {
    final r = await _checkScreen(
      tester,
      'income',
      const IncomeScreen(),
      income: withIncomes(),
      accounts: FakeAccountProvider(),
    );
    await _expectAccessibleTapTargets(tester);

    if (kCapture == 'income') await _writePng(r.key, 'income_390x844');
  });

  // Texto ampliado: o layout tem de ceder (rolar/quebrar), nunca estourar.
  testWidgets('income large text', (tester) async {
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    tester.platformDispatcher.textScaleFactorTestValue = 1.6;
    await _mount(
      tester,
      const IncomeScreen(),
      income: withIncomes(),
      accounts: FakeAccountProvider(),
    );
    for (final viewport in [..._otherViewports, kReferenceViewport]) {
      await _settleAt(tester, viewport);
    }
  });

  testWidgets('income sheet', (tester) async {
    addTearDown(tester.view.reset);
    final key = await _mount(
      tester,
      const IncomeScreen(),
      income: FakeIncomeProvider(),
      accounts: withTwoAccounts(),
    );
    await _settleAt(tester, kReferenceViewport);

    await tester.tap(find.byType(FloatingActionButton));
    await _pumpAfterTap(tester);
    await _pumpAfterTap(tester);
    expect(find.text('Nova Receita'), findsOneWidget);

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

    if (kCapture == 'income-sheet') {
      await _writePng(key, 'income_sheet_390x844');
    }
  });

  testWidgets('income edit sheet', (tester) async {
    addTearDown(tester.view.reset);
    final key = await _mount(
      tester,
      const IncomeScreen(),
      income: withIncomes(),
      accounts: FakeAccountProvider(),
    );
    await _settleAt(tester, kReferenceViewport);

    await tester.tap(find.byTooltip('Editar Dividendos'));
    await _pumpAfterTap(tester);
    await _pumpAfterTap(tester);
    expect(find.text('Editar Receita'), findsOneWidget);

    for (final viewport in _otherViewports) {
      tester.view.physicalSize = viewport * kPixelRatio;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull, reason: 'edicao em $viewport');
    }

    tester.view.physicalSize = kReferenceViewport * kPixelRatio;
    await _pumpAfterTap(tester);
    await _expectAccessibleTapTargets(tester);

    if (kCapture == 'income-edit') {
      await _writePng(key, 'income_edit_390x844');
    }
  });

  testWidgets('income dialog', (tester) async {
    addTearDown(tester.view.reset);
    final key = await _mount(
      tester,
      const IncomeScreen(),
      income: withIncomes(),
      accounts: FakeAccountProvider(),
    );
    await _settleAt(tester, kReferenceViewport);

    await tester.tap(find.byTooltip('Remover Dividendos'));
    await _pumpAfterTap(tester);
    await _pumpAfterTap(tester);
    expect(find.text('Deletar receita?'), findsOneWidget);

    for (final viewport in _otherViewports) {
      tester.view.physicalSize = viewport * kPixelRatio;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull, reason: 'dialogo em $viewport');
    }

    tester.view.physicalSize = kReferenceViewport * kPixelRatio;
    await _pumpAfterTap(tester);
    await _expectAccessibleTapTargets(tester);

    if (kCapture == 'income-dialog') {
      await _writePng(key, 'income_dialog_390x844');
    }
  });

  // Despesas (fase C): vazio, com registros, aba filtrada, texto ampliado,
  // sheets e dialogo.
  FakeExpenseProvider withExpenses() => FakeExpenseProvider()
    ..items = [
      fakeExpense(
        id: 1,
        description: 'Conta de água',
        amount: 89.9,
        categoryId: 1,
        date: DateTime(2026, 9, 5),
      ),
      fakeExpense(
        id: 2,
        description: 'Aluguel do apartamento com nome bem comprido mesmo',
        amount: 1500,
        categoryId: 4,
        paymentMethod: 'transfer',
        date: DateTime(2026, 9, 6),
      ),
      fakeExpense(
        id: 3,
        description: 'Mercado',
        amount: 320.45,
        categoryId: 5,
        paymentMethod: 'debit_card',
        date: DateTime(2026, 9, 9),
      ),
      fakeExpense(
        id: 4,
        description: 'Notebook',
        amount: 2500,
        categoryId: 8,
        paymentMethod: 'credit_card',
        date: DateTime(2026, 9, 12),
      ),
      fakeExpense(
        id: 5,
        description: 'Uber',
        amount: 40,
        categoryId: 6,
        paymentMethod: 'credit_card',
        date: DateTime(2026, 9, 14),
      ),
    ];

  testWidgets('expenses empty', (tester) async {
    final r = await _checkScreen(
      tester,
      'expenses-empty',
      const ExpensesScreen(),
      expenses: FakeExpenseProvider(),
      accounts: FakeAccountProvider(),
    );
    await _expectAccessibleTapTargets(tester);

    if (kCapture == 'expenses-empty') {
      await _writePng(r.key, 'expenses_empty_390x844');
    }
  });

  testWidgets('expenses', (tester) async {
    final r = await _checkScreen(
      tester,
      'expenses',
      const ExpensesScreen(),
      expenses: withExpenses(),
      accounts: FakeAccountProvider(),
    );
    await _expectAccessibleTapTargets(tester);

    if (kCapture == 'expenses') await _writePng(r.key, 'expenses_390x844');
  });

  // Aba filtrada: troca de aba com o layout em todas as larguras.
  testWidgets('expenses tab', (tester) async {
    addTearDown(tester.view.reset);
    final key = await _mount(
      tester,
      const ExpensesScreen(),
      expenses: withExpenses(),
      accounts: FakeAccountProvider(),
    );
    await _settleAt(tester, kReferenceViewport);

    await tester.tap(find.text('Cartão').first);
    await _pumpAfterTap(tester);
    await _pumpAfterTap(tester);

    for (final viewport in [..._otherViewports, kReferenceViewport]) {
      await _settleAt(tester, viewport);
    }
    await _expectAccessibleTapTargets(tester);

    if (kCapture == 'expenses-tab') {
      await _writePng(key, 'expenses_tab_390x844');
    }
  });

  // Texto ampliado: o layout tem de ceder (rolar/quebrar), nunca estourar.
  testWidgets('expenses large text', (tester) async {
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    tester.platformDispatcher.textScaleFactorTestValue = 1.6;
    await _mount(
      tester,
      const ExpensesScreen(),
      expenses: withExpenses(),
      accounts: FakeAccountProvider(),
    );
    for (final viewport in [..._otherViewports, kReferenceViewport]) {
      await _settleAt(tester, viewport);
    }
  });

  testWidgets('expenses sheet', (tester) async {
    addTearDown(tester.view.reset);
    final key = await _mount(
      tester,
      const ExpensesScreen(),
      expenses: FakeExpenseProvider(),
      accounts: withTwoAccounts(),
    );
    await _settleAt(tester, kReferenceViewport);

    await tester.tap(find.byType(FloatingActionButton));
    await _pumpAfterTap(tester);
    await _pumpAfterTap(tester);
    expect(find.text('Nova Despesa'), findsOneWidget);

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

    if (kCapture == 'expenses-sheet') {
      await _writePng(key, 'expenses_sheet_390x844');
    }
  });

  testWidgets('expenses edit sheet', (tester) async {
    addTearDown(tester.view.reset);
    final key = await _mount(
      tester,
      const ExpensesScreen(),
      expenses: withExpenses(),
      accounts: FakeAccountProvider(),
    );
    await _settleAt(tester, kReferenceViewport);

    await tester.tap(find.byTooltip('Editar Mercado'));
    await _pumpAfterTap(tester);
    await _pumpAfterTap(tester);
    expect(find.text('Editar Despesa'), findsOneWidget);

    for (final viewport in _otherViewports) {
      tester.view.physicalSize = viewport * kPixelRatio;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull, reason: 'edicao em $viewport');
    }

    tester.view.physicalSize = kReferenceViewport * kPixelRatio;
    await _pumpAfterTap(tester);
    await _expectAccessibleTapTargets(tester);

    if (kCapture == 'expenses-edit') {
      await _writePng(key, 'expenses_edit_390x844');
    }
  });

  testWidgets('expenses dialog', (tester) async {
    addTearDown(tester.view.reset);
    final key = await _mount(
      tester,
      const ExpensesScreen(),
      expenses: withExpenses(),
      accounts: FakeAccountProvider(),
    );
    await _settleAt(tester, kReferenceViewport);

    await tester.tap(find.byTooltip('Remover Mercado'));
    await _pumpAfterTap(tester);
    await _pumpAfterTap(tester);
    expect(find.text('Deletar despesa?'), findsOneWidget);

    for (final viewport in _otherViewports) {
      tester.view.physicalSize = viewport * kPixelRatio;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull, reason: 'dialogo em $viewport');
    }

    tester.view.physicalSize = kReferenceViewport * kPixelRatio;
    await _pumpAfterTap(tester);
    await _expectAccessibleTapTargets(tester);

    if (kCapture == 'expenses-dialog') {
      await _writePng(key, 'expenses_dialog_390x844');
    }
  });

  // Dashboard / Fatura (fase D): as duas abas, vazio e com dados, texto
  // ampliado, sheets e dialogo. Os dados sao relativos a hoje porque a tela
  // abre no mes corrente.
  DateTime monthsAgo(int n, [int day = 12]) {
    final now = DateTime.now();
    return DateTime(now.year, now.month - n, day);
  }

  FakeInstallmentProvider withInstallments() => FakeInstallmentProvider()
    ..items = [
      fakeInstallment(
        id: 1,
        name: 'iPhone 15 Pro',
        merchantName: 'Apple Store',
        totalAmount: 7200,
        totalInstallments: 12,
        dueDayOfMonth: 10,
        startDate: monthsAgo(2),
      ),
      fakeInstallment(
        id: 2,
        name: 'Geladeira com nome bem comprido para testar a quebra de linha',
        totalAmount: 2400,
        totalInstallments: 6,
        dueDayOfMonth: 5,
        startDate: monthsAgo(0, 3),
        paymentMethod: 'pix',
      ),
      fakeInstallment(
        id: 3,
        name: 'Curso de inglês',
        totalAmount: 900,
        totalInstallments: 3,
        dueDayOfMonth: 20,
        startDate: monthsAgo(1, 25),
        paymentMethod: 'debit_card',
      ),
    ];

  FakeFixedCostProvider withFixedCosts() => FakeFixedCostProvider()
    ..items = [
      fakeFixedCost(
        id: 1,
        name: 'Netflix',
        amount: 55.9,
        category: 'streaming',
        createdAt: monthsAgo(3),
      ),
      fakeFixedCost(
        id: 2,
        name: 'Aluguel do apartamento',
        amount: 1800,
        dueDayOfMonth: 5,
        category: 'rent',
        createdAt: monthsAgo(6),
      ),
      fakeFixedCost(
        id: 3,
        name: 'Conta de luz',
        amount: 210.5,
        dueDayOfMonth: 28,
        category: 'utility',
        createdAt: monthsAgo(1),
      ),
    ];

  Future<void> openDashboardTab(WidgetTester tester) async {
    await tester.tap(find.text('Dashboard').first);
    await _pumpAfterTap(tester);
    await _pumpAfterTap(tester);
  }

  testWidgets('invoice empty', (tester) async {
    final r = await _checkScreen(
      tester,
      'invoice-empty',
      const InvoiceDashboardScreen(),
      installments: FakeInstallmentProvider(),
      fixedCosts: FakeFixedCostProvider(),
    );
    await _expectAccessibleTapTargets(tester);

    if (kCapture == 'invoice-empty') {
      await _writePng(r.key, 'invoice_empty_390x844');
    }
  });

  testWidgets('invoice', (tester) async {
    final r = await _checkScreen(
      tester,
      'invoice',
      const InvoiceDashboardScreen(),
      installments: withInstallments(),
      fixedCosts: withFixedCosts(),
    );
    await _expectAccessibleTapTargets(tester);

    if (kCapture == 'invoice') await _writePng(r.key, 'invoice_390x844');
  });

  testWidgets('invoice dashboard', (tester) async {
    addTearDown(tester.view.reset);
    final key = await _mount(
      tester,
      const InvoiceDashboardScreen(),
      installments: withInstallments(),
      fixedCosts: withFixedCosts(),
    );
    await _settleAt(tester, kReferenceViewport);
    await openDashboardTab(tester);

    for (final viewport in [..._otherViewports, kReferenceViewport]) {
      await _settleAt(tester, viewport);
    }
    await _expectAccessibleTapTargets(tester);

    if (kCapture == 'invoice-dashboard') {
      await _writePng(key, 'invoice_dashboard_390x844');
    }
  });

  testWidgets('invoice dashboard empty', (tester) async {
    addTearDown(tester.view.reset);
    final key = await _mount(
      tester,
      const InvoiceDashboardScreen(),
      installments: FakeInstallmentProvider(),
      fixedCosts: FakeFixedCostProvider(),
    );
    await _settleAt(tester, kReferenceViewport);
    await openDashboardTab(tester);

    for (final viewport in [..._otherViewports, kReferenceViewport]) {
      await _settleAt(tester, viewport);
    }
    await _expectAccessibleTapTargets(tester);

    if (kCapture == 'invoice-dashboard-empty') {
      await _writePng(key, 'invoice_dashboard_empty_390x844');
    }
  });

  // Texto ampliado: o layout tem de ceder (rolar/quebrar), nunca estourar.
  testWidgets('invoice large text', (tester) async {
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    tester.platformDispatcher.textScaleFactorTestValue = 1.6;
    await _mount(
      tester,
      const InvoiceDashboardScreen(),
      installments: withInstallments(),
      fixedCosts: withFixedCosts(),
    );
    for (final viewport in [..._otherViewports, kReferenceViewport]) {
      await _settleAt(tester, viewport);
    }
    await openDashboardTab(tester);
    for (final viewport in [..._otherViewports, kReferenceViewport]) {
      await _settleAt(tester, viewport);
    }
  });

  testWidgets('invoice choice sheet', (tester) async {
    addTearDown(tester.view.reset);
    final key = await _mount(
      tester,
      const InvoiceDashboardScreen(),
      installments: FakeInstallmentProvider(),
      fixedCosts: FakeFixedCostProvider(),
    );
    await _settleAt(tester, kReferenceViewport);

    await tester.tap(find.byType(FloatingActionButton));
    await _pumpAfterTap(tester);
    await _pumpAfterTap(tester);
    expect(find.text('Adicionar'), findsOneWidget);

    for (final viewport in _otherViewports) {
      tester.view.physicalSize = viewport * kPixelRatio;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull, reason: 'sheet em $viewport');
    }

    tester.view.physicalSize = kReferenceViewport * kPixelRatio;
    await _pumpAfterTap(tester);
    await _expectAccessibleTapTargets(tester);

    if (kCapture == 'invoice-choice') {
      await _writePng(key, 'invoice_choice_390x844');
    }
  });

  testWidgets('invoice installment sheet', (tester) async {
    addTearDown(tester.view.reset);
    final key = await _mount(
      tester,
      const InvoiceDashboardScreen(),
      installments: FakeInstallmentProvider(),
      fixedCosts: FakeFixedCostProvider(),
    );
    await _settleAt(tester, kReferenceViewport);

    await tester.tap(find.byType(FloatingActionButton));
    await _pumpAfterTap(tester);
    await _pumpAfterTap(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Parcela'));
    await _pumpAfterTap(tester);
    await _pumpAfterTap(tester);
    expect(find.text('Nova Parcela'), findsOneWidget);

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

    if (kCapture == 'invoice-installment') {
      await _writePng(key, 'invoice_installment_390x844');
    }
  });

  testWidgets('invoice fixed cost sheet', (tester) async {
    addTearDown(tester.view.reset);
    final key = await _mount(
      tester,
      const InvoiceDashboardScreen(),
      installments: FakeInstallmentProvider(),
      fixedCosts: FakeFixedCostProvider(),
    );
    await _settleAt(tester, kReferenceViewport);

    await tester.tap(find.byType(FloatingActionButton));
    await _pumpAfterTap(tester);
    await _pumpAfterTap(tester);
    await tester.tap(find.widgetWithText(OutlinedButton, 'Gasto Fixo'));
    await _pumpAfterTap(tester);
    await _pumpAfterTap(tester);
    expect(find.text('Novo Gasto Fixo'), findsOneWidget);

    for (final viewport in _otherViewports) {
      tester.view.physicalSize = viewport * kPixelRatio;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull, reason: 'sheet em $viewport');
    }

    tester.view.physicalSize = const Size(320, 640) * kPixelRatio;
    tester.view.viewInsets = const FakeViewPadding(bottom: 500);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull, reason: 'sheet com teclado');
    tester.view.resetViewInsets();

    tester.view.physicalSize = kReferenceViewport * kPixelRatio;
    await _pumpAfterTap(tester);
    await _expectAccessibleTapTargets(tester);

    if (kCapture == 'invoice-fixed') {
      await _writePng(key, 'invoice_fixed_390x844');
    }
  });

  testWidgets('invoice dialog', (tester) async {
    addTearDown(tester.view.reset);
    final key = await _mount(
      tester,
      const InvoiceDashboardScreen(),
      installments: withInstallments(),
      fixedCosts: withFixedCosts(),
    );
    await _settleAt(tester, kReferenceViewport);

    await tester.tap(find.byTooltip('Remover Apple Store'));
    await _pumpAfterTap(tester);
    await _pumpAfterTap(tester);
    expect(find.text('Remover Parcela?'), findsOneWidget);

    for (final viewport in _otherViewports) {
      tester.view.physicalSize = viewport * kPixelRatio;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull, reason: 'dialogo em $viewport');
    }

    tester.view.physicalSize = kReferenceViewport * kPixelRatio;
    await _pumpAfterTap(tester);
    await _expectAccessibleTapTargets(tester);

    if (kCapture == 'invoice-dialog') {
      await _writePng(key, 'invoice_dialog_390x844');
    }
  });

  // Calendario. Os compromissos ficam em "hoje", o dia que a tela abre
  // selecionado, para a lista aparecer sem interacao.
  FakeEventProvider withEvents() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return FakeEventProvider()
      ..items = [
        fakeEvent(id: 1, title: 'Consulta médica', date: today),
        fakeEvent(id: 2, title: 'Reunião de pais na escola', date: today),
        fakeEvent(
          id: 3,
          title: 'Aniversário da Ana',
          date: DateTime(now.year, now.month, now.day == 12 ? 13 : 12),
        ),
        fakeEvent(
          id: 4,
          title: 'Pagar seguro',
          date: DateTime(now.year, now.month, now.day == 3 ? 4 : 3),
        ),
      ];
  }

  testWidgets('calendar empty', (tester) async {
    final r = await _checkScreen(
      tester,
      'calendar-empty',
      const CalendarScreen(),
      events: FakeEventProvider(),
    );
    await _expectAccessibleTapTargets(tester);

    if (kCapture == 'calendar-empty') {
      await _writePng(r.key, 'calendar_empty_390x844');
    }
  });

  testWidgets('calendar', (tester) async {
    final r = await _checkScreen(
      tester,
      'calendar',
      const CalendarScreen(),
      events: withEvents(),
    );
    await _expectAccessibleTapTargets(tester);

    if (kCapture == 'calendar') await _writePng(r.key, 'calendar_390x844');
  });

  // Texto ampliado: o layout tem de ceder (rolar/quebrar), nunca estourar.
  testWidgets('calendar large text', (tester) async {
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    tester.platformDispatcher.textScaleFactorTestValue = 1.6;
    await _mount(tester, const CalendarScreen(), events: withEvents());
    for (final viewport in [..._otherViewports, kReferenceViewport]) {
      await _settleAt(tester, viewport);
    }
  });

  testWidgets('calendar sheet', (tester) async {
    addTearDown(tester.view.reset);
    final key = await _mount(
      tester,
      const CalendarScreen(),
      events: FakeEventProvider(),
    );
    await _settleAt(tester, kReferenceViewport);

    await tester.tap(find.byType(FloatingActionButton));
    await _pumpAfterTap(tester);
    await _pumpAfterTap(tester);
    expect(find.text('Novo Compromisso'), findsOneWidget);

    for (final viewport in _otherViewports) {
      tester.view.physicalSize = viewport * kPixelRatio;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull, reason: 'sheet em $viewport');
    }

    tester.view.physicalSize = kReferenceViewport * kPixelRatio;
    await _pumpAfterTap(tester);
    await _expectAccessibleTapTargets(tester);

    if (kCapture == 'calendar-sheet') {
      await _writePng(key, 'calendar_sheet_390x844');
    }
  });

  testWidgets('calendar dialog', (tester) async {
    addTearDown(tester.view.reset);
    final key = await _mount(
      tester,
      const CalendarScreen(),
      events: withEvents(),
    );
    await _settleAt(tester, kReferenceViewport);

    await tester.tap(find.byTooltip('Remover Consulta médica'));
    await _pumpAfterTap(tester);
    await _pumpAfterTap(tester);
    expect(find.text('Deletar compromisso?'), findsOneWidget);

    for (final viewport in _otherViewports) {
      tester.view.physicalSize = viewport * kPixelRatio;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull, reason: 'dialogo em $viewport');
    }

    tester.view.physicalSize = kReferenceViewport * kPixelRatio;
    await _pumpAfterTap(tester);
    await _expectAccessibleTapTargets(tester);

    if (kCapture == 'calendar-dialog') {
      await _writePng(key, 'calendar_dialog_390x844');
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
