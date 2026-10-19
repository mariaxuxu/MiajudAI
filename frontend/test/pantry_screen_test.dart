// Preservacao de comportamento da tela de Despensa (PantryScreen).
//
// Cada caso prova que a UI aciona o PantryProvider com os argumentos certos,
// que os steppers escrevem direto na despensa, que chegar a 0 remove, e que
// busca e estados (vazio / carregando / erro) se comportam como o ticket pede.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miajudai/models/pantry_entry_model.dart';
import 'package:miajudai/models/pantry_item_model.dart';
import 'package:miajudai/providers/auth_provider.dart';
import 'package:miajudai/providers/pantry_provider.dart';
import 'package:miajudai/screens/pantry_screen.dart';
import 'package:provider/provider.dart';

import 'support/fake_auth_provider.dart';
import 'support/fake_pantry_provider.dart';
import 'support/pump_screen.dart';
import 'support/test_fonts.dart';

PantryItem _rice() => fakePantryItem(id: 10, name: 'Arroz', emoji: '🍚');
PantryItem _detergent() => fakePantryItem(
      id: 20,
      name: 'Detergente',
      emoji: '🧴',
      domain: 'domestic',
    );

List<PantryEntry> _riceOnly() => [
      fakePantryEntry(id: 1, item: _rice(), quantity: 1),
    ];

List<PantryEntry> _bothDomains() => [
      fakePantryEntry(id: 1, item: _rice(), quantity: 3),
      fakePantryEntry(id: 2, item: _detergent(), quantity: 2),
    ];

Future<FakePantryProvider> _pump(
  WidgetTester tester, {
  List<PantryEntry> Function()? seed,
  String? token = 'test-token',
  bool pushed = false,
}) async {
  final pantry = FakePantryProvider();
  if (seed != null) pantry.items = seed();
  await pumpScreen(
    tester,
    const PantryScreen(),
    pantry: pantry,
    pushed: pushed,
    setup: (a) => a.token = token,
  );
  return pantry;
}

/// Toca o "−" da linha [name] (tooltip `Diminuir $name`).
Future<void> _decrement(WidgetTester tester, String name) async {
  await tester.tap(find.byTooltip('Diminuir $name'));
  await tester.pumpAndSettle();
}

/// Toca o "+" da linha [name] (tooltip `Aumentar $name`).
Future<void> _increment(WidgetTester tester, String name) async {
  await tester.tap(find.byTooltip('Aumentar $name'));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(loadRedesignFonts);

  group('loading', () {
    testWidgets('loads the pantry once, with the auth token', (tester) async {
      final pantry = await _pump(tester);
      expect(pantry.loadCalls, ['test-token']);
    });

    testWidgets('does not load without a token', (tester) async {
      final pantry = await _pump(tester, token: null);
      expect(pantry.loadCalls, isEmpty);
    });
  });

  group('empty state', () {
    testWidgets('explains the pantry is empty and points to "Fiz compras"',
        (tester) async {
      await _pump(tester);

      expect(find.text('Despensa'), findsOneWidget);
      expect(find.text('Sua despensa está vazia'), findsOneWidget);
      // O CTA do estado vazio leva ao catalogo.
      expect(
        find.widgetWithText(FilledButton, 'Fiz compras'),
        findsOneWidget,
      );
    });

    testWidgets('the empty-state CTA pushes the catalog route',
        (tester) async {
      final env = await pumpScreen(
        tester,
        const PantryScreen(),
        pantry: FakePantryProvider(),
        setup: (a) => a.token = 'test-token',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Fiz compras'));
      await tester.pumpAndSettle();
      expect(env.log.events, contains('push /pantry/catalog'));
    });
  });

  group('sections', () {
    testWidgets('groups items into Cozinha and Doméstico', (tester) async {
      await _pump(tester, seed: _bothDomains);

      expect(find.text('Cozinha'), findsOneWidget);
      expect(find.text('Doméstico'), findsOneWidget);
      expect(find.text('Arroz'), findsOneWidget);
      expect(find.text('Detergente'), findsOneWidget);
      expect(find.text('🍚'), findsOneWidget);
    });

    testWidgets('a domain with no items shows no header', (tester) async {
      await _pump(tester, seed: _riceOnly);

      expect(find.text('Cozinha'), findsOneWidget);
      expect(find.text('Doméstico'), findsNothing);
    });
  });

  group('steppers write straight to the pantry', () {
    testWidgets('"+" sends quantity + 1', (tester) async {
      final pantry = await _pump(tester, seed: _bothDomains);
      await _increment(tester, 'Arroz');

      expect(pantry.adjustCalls, hasLength(1));
      expect(pantry.adjustCalls.single.token, 'test-token');
      expect(pantry.adjustCalls.single.itemId, 10);
      expect(pantry.adjustCalls.single.quantity, 4);
    });

    testWidgets('"−" sends quantity - 1', (tester) async {
      final pantry = await _pump(tester, seed: _bothDomains);
      await _decrement(tester, 'Arroz');

      expect(pantry.adjustCalls.single.quantity, 2);
    });

    testWidgets('"−" at quantity 1 sends 0, which removes the item',
        (tester) async {
      final pantry = await _pump(tester, seed: _riceOnly);
      await _decrement(tester, 'Arroz');

      expect(pantry.adjustCalls.single.quantity, 0);
      // O fake espelha o backend: 0 remove a linha.
      expect(pantry.items.where((e) => e.itemId == 10), isEmpty);
      expect(find.text('Arroz'), findsNothing);
    });

    testWidgets('"+" at quantity 1 sends 2', (tester) async {
      final pantry = await _pump(tester, seed: _riceOnly);
      await _increment(tester, 'Arroz');
      expect(pantry.adjustCalls.single.quantity, 2);
    });
  });

  group('search', () {
    testWidgets('filters by name, client-side', (tester) async {
      final pantry = await _pump(tester, seed: _bothDomains);

      await tester.enterText(find.byType(TextField), 'deter');
      await tester.pumpAndSettle();

      expect(find.text('Detergente'), findsOneWidget);
      expect(find.text('Arroz'), findsNothing);
      // Filtra sobre o que ja esta carregado: nenhuma recarga.
      expect(pantry.loadCalls, hasLength(1));
    });

    testWidgets('shows a message when nothing matches', (tester) async {
      await _pump(tester, seed: _bothDomains);

      await tester.enterText(find.byType(TextField), 'xyz');
      await tester.pumpAndSettle();

      expect(find.textContaining('Nenhum item encontrado'), findsOneWidget);
    });
  });

  group('loading and error states (the accounts screen omits both)', () {
    testWidgets('shows a spinner while loading with no rows yet',
        (tester) async {
      final pantry = FakePantryProvider()..isLoading = true;
      final auth = FakeAuthProvider()..token = 'test-token';
      tester.view.physicalSize = const Size(390, 844) * 2;
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(value: auth),
            ChangeNotifierProvider<PantryProvider>.value(value: pantry),
          ],
          child: const MaterialApp(home: PantryScreen()),
        ),
      );
      // `pump`, nao `pumpAndSettle`: um spinner anima para sempre e o settle
      // nunca chegaria ao fim.
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows an error card with retry when the load failed',
        (tester) async {
      final pantry = FakePantryProvider()..error = 'Falhou';
      await pumpScreen(
        tester,
        const PantryScreen(),
        pantry: pantry,
        setup: (a) => a.token = 'test-token',
      );

      expect(find.text('Não deu para abrir a despensa'), findsOneWidget);
      await tester.tap(find.widgetWithText(OutlinedButton, 'Tentar de novo'));
      await tester.pumpAndSettle();
      expect(pantry.loadCalls, isNotEmpty);
    });
  });

  group('navigation', () {
    testWidgets('back pops the route', (tester) async {
      final env = await pumpScreen(
        tester,
        const PantryScreen(),
        pantry: FakePantryProvider(),
        pushed: true,
        setup: (a) => a.token = 'test-token',
      );
      await tester.tap(find.byTooltip('Voltar'));
      await tester.pumpAndSettle();

      expect(env.log.events, ['pop null']);
      expect(find.text(kOriginScreenText), findsOneWidget);
    });

    testWidgets('the "Fiz compras" FAB pushes the catalog', (tester) async {
      final env = await pumpScreen(
        tester,
        const PantryScreen(),
        pantry: FakePantryProvider()..items = _bothDomains(),
        setup: (a) => a.token = 'test-token',
      );
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(env.log.events, contains('push /pantry/catalog'));
    });
  });
}
