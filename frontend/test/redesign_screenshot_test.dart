// Harness de validacao visual do redesign.
//
// Nao testa comportamento: renderiza uma tela na viewport de referencia do
// Design System (390 x 844) e grava um PNG, para comparacao com o prototipo
// correspondente em `referencesForNewDesign/`.
//
// Uso:
//   flutter test test/redesign_screenshot_test.dart
//     -> so as verificacoes de layout (rapido, sai limpo)
//
//   flutter test test/redesign_screenshot_test.dart //     --dart-define=REDESIGN_CAPTURE=true
//     -> tambem grava o PNG em `build/redesign_screenshots/`
//
// A captura e opt-in porque `RenderRepaintBoundary.toImage` deixa o
// rasterizador ocupado e o processo de teste nao encerra sozinho depois
// dela. Sem a flag, este arquivo roda normal junto com o resto da suite.
//
// Duas particularidades deste harness:
//  - MaterialIcons e as TTFs do Inter sao carregadas a mao. `flutter test`
//    nao carrega fonte nenhuma por padrao, e sem isto icones e textos saem
//    como retangulos vazios no PNG.
//  - so UMA captura de imagem por processo de teste. Uma segunda chamada a
//    `RenderRepaintBoundary.toImage` no mesmo binding nao retorna, entao as
//    demais larguras sao verificadas so por layout (overflow e dobra).

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miajudai/screens/splash_screen.dart';
import 'package:miajudai/widgets/agents/agent_card.dart';

const Size kReferenceViewport = Size(390, 844);
const double kPixelRatio = 2;

/// Gravar o PNG? Ver o cabecalho: a captura impede o processo de encerrar.
const bool kCapture = bool.fromEnvironment('REDESIGN_CAPTURE');

const List<String> _assetsToPrecache = [
  'assets/images/brand/logo_mark.png',
  'assets/images/luna.png',
  'assets/images/otto.png',
  'assets/images/tina.png',
];

/// Raiz do SDK, para achar a fonte de icones do Material.
String get _flutterRoot =>
    Platform.environment['FLUTTER_ROOT'] ??
    r'C:\Users\PedroKelvin\AppData\Local\flutter-sdk';

Future<void> _loadFonts() async {
  final inter = FontLoader('Inter');
  for (final w in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
    final bytes = File('assets/fonts/Inter-$w.ttf').readAsBytesSync();
    inter.addFont(Future.value(ByteData.view(bytes.buffer)));
  }
  await inter.load();

  final iconsFile = File(
    '$_flutterRoot/bin/cache/artifacts/material_fonts/'
    'materialicons-regular.otf',
  );
  if (iconsFile.existsSync()) {
    final icons = FontLoader('MaterialIcons')
      ..addFont(
        Future.value(ByteData.view(iconsFile.readAsBytesSync().buffer)),
      );
    await icons.load();
  } else {
    // ignore: avoid_print
    print(
      'AVISO: MaterialIcons nao encontrada em ${iconsFile.path} — '
      'os icones sairao como retangulos vazios no PNG.',
    );
  }
}

/// Monta [screen] uma unica vez e devolve um verificador de viewports.
///
/// ORDEM IMPORTA: `RenderRepaintBoundary.toImage` deixa o rasterizador ocupado
/// e o primeiro `pump` posterior nao retorna. Por isso a captura da imagem e
/// sempre a ULTIMA coisa que este arquivo faz.
Future<GlobalKey> _mount(WidgetTester tester, Widget screen) async {
  final key = GlobalKey();

  await tester.pumpWidget(
    RepaintBoundary(
      key: key,
      child: MaterialApp(debugShowCheckedModeBanner: false, home: screen),
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
  // alem da animacao de entrada (650ms), senao a captura sai com o
  // FadeTransition ainda em opacidade zero.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 700));
  await tester.pump(const Duration(milliseconds: 300));

  // Um RenderFlex overflow vira excecao no binding de teste.
  final problem = tester.takeException();
  expect(
    problem,
    isNull,
    reason: 'overflow em ${viewport.width.toInt()}x'
        '${viewport.height.toInt()}: $problem',
  );

  return tester
      .state<ScrollableState>(find.byType(Scrollable).first)
      .position
      .maxScrollExtent;
}

/// Os tres AgentCards compartilham a mesma coordenada vertical?
void _expectAgentsSideBySide(WidgetTester tester, Size viewport) {
  final finder = find.byType(AgentCard);
  expect(finder.evaluate().length, 3);

  final tops = finder
      .evaluate()
      .map((e) => tester.getTopLeft(find.byWidget(e.widget)).dy)
      .toSet();

  expect(
    tops.length,
    1,
    reason: 'os 3 AgentCards deveriam estar lado a lado em '
        '${viewport.width.toInt()}px, nao empilhados',
  );
}

Future<void> _writePng(WidgetTester tester, GlobalKey key, String name) async {
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

void main() {
  setUpAll(_loadFonts);

  testWidgets('fase 1 — tela publica', (tester) async {
    addTearDown(tester.view.reset);

    final key = await _mount(tester, const SplashScreen());

    // 1) Larguras alternativas primeiro: nenhuma pode gerar overflow, e os
    //    tres agentes tem de continuar lado a lado em todas.
    for (final viewport in const [
      Size(320, 640), // menor Android comum
      Size(360, 800),
      Size(430, 932), // iPhone Pro Max
    ]) {
      final belowFold = await _settleAt(tester, viewport);
      _expectAgentsSideBySide(tester, viewport);

      // ignore: avoid_print
      print(
        'VIEWPORT ${viewport.width.toInt()}x${viewport.height.toInt()} '
        '| sem overflow | 3 cards lado a lado '
        '| abaixo da dobra: ${belowFold.toStringAsFixed(1)}px',
      );
    }

    // 2) Viewport de referencia do Design System.
    final belowFold = await _settleAt(tester, kReferenceViewport);
    _expectAgentsSideBySide(tester, kReferenceViewport);

    // ignore: avoid_print
    print(
      'VIEWPORT 390x844 (referencia) | sem overflow | 3 cards lado a lado '
      '| abaixo da dobra: ${belowFold.toStringAsFixed(1)}px',
    );

    // Criterio da Fase 1: a composicao inteira cabe em 390x844, como no
    // prototipo — nada de rodape abaixo da dobra na viewport de referencia.
    expect(
      belowFold,
      0.0,
      reason: 'o conteudo deveria caber inteiro em 390x844',
    );

    // 3) Captura por ultimo — depois disto nenhum pump retorna.
    if (kCapture) {
      await _writePng(tester, key, 'fase1_tela_publica_390x844');
    } else {
      // ignore: avoid_print
      print(
        'captura de imagem desligada — use '
        '--dart-define=REDESIGN_CAPTURE=true para gravar o PNG',
      );
    }
  });
}
