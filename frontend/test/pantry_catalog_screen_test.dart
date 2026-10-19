// Preservacao de comportamento da tela de Catalogo (PantryCatalogScreen).
//
// Cada caso prova que: o catalogo e a despensa sao carregados uma vez POR
// ABERTURA (o catalogo e global e pode mudar entre duas aberturas); busca e
// chips filtram no cliente; os steppers do carrinho comecam em 0, tem piso 0 e
// NAO escrevem na despensa; e o confirmar manda UM commit em lote com a mesma
// commit_key, sem dobrar ao reenviar.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miajudai/models/pantry_entry_model.dart';
import 'package:miajudai/models/pantry_item_model.dart';
import 'package:miajudai/screens/pantry_catalog_screen.dart';

import 'support/fake_pantry_provider.dart';
import 'support/pump_screen.dart';
import 'support/test_fonts.dart';

PantryItem _rice() => fakePantryItem(id: 10, name: 'Arroz', emoji: '🍚');
PantryItem _beans() => fakePantryItem(id: 11, name: 'Feijão', emoji: '🫘');
PantryItem _detergent() => fakePantryItem(
      id: 20,
      name: 'Detergente',
      emoji: '🧴',
      domain: 'domestic',
    );

List<PantryItem> _catalog() => [_rice(), _beans(), _detergent()];

/// A despensa ja tem 3 arroz; o catalogo tem arroz, feijao e detergente.
List<PantryEntry> _pantryWithRice() => [
      fakePantryEntry(id: 1, item: _rice(), quantity: 3),
    ];

Future<FakePantryProvider> _pump(
  WidgetTester tester, {
  List<PantryItem>? catalog,
  List<PantryEntry>? pantry,
  String? token = 'test-token',
  bool pushed = true,
}) async {
  final fake = FakePantryProvider();
  if (catalog != null) fake.catalogItems = catalog;
  if (pantry != null) fake.items = pantry;
  await pumpScreen(
    tester,
    const PantryCatalogScreen(),
    pantry: fake,
    pushed: pushed,
    setup: (a) => a.token = token,
  );
  return fake;
}

Future<void> _increment(WidgetTester tester, String name) async {
  await tester.tap(find.byTooltip('Aumentar $name'));
  await tester.pumpAndSettle();
}

/// Toca o chip de dominio com o rotulo [label] (o Text fica dentro do chip,
/// entao o alvo do toque e o FilterChip).
Future<void> _tapChip(WidgetTester tester, String label) async {
  await tester.tap(
    find.ancestor(
      of: find.text(label),
      matching: find.byType(FilterChip),
    ),
  );
  await tester.pumpAndSettle();
}

/// O IconButton dono do Tooltip do stepper (para inspecionar `onPressed`).
/// O Tooltip e filho do IconButton, entao a busca sobe pelo ancestral.
IconButton _stepButton(WidgetTester tester, String tooltip) {
  return tester.widget<IconButton>(
    find.ancestor(
      of: find.byTooltip(tooltip),
      matching: find.byType(IconButton),
    ),
  );
}

void main() {
  setUpAll(loadRedesignFonts);

  group('loading', () {
    testWidgets('fetches catalog and pantry once per open, with the token',
        (tester) async {
      final fake = await _pump(tester, catalog: _catalog());
      expect(fake.catalogCalls, ['test-token']);
      expect(fake.loadCalls, ['test-token']);
    });

    testWidgets('the flat list shows every item with how many you own',
        (tester) async {
      await _pump(
        tester,
        catalog: _catalog(),
        pantry: _pantryWithRice(),
      );

      expect(find.text('Arroz'), findsOneWidget);
      expect(find.text('Feijão'), findsOneWidget);
      expect(find.text('Detergente'), findsOneWidget);
      // "você tem 3" ao lado do arroz; os outros, 0.
      expect(find.text('você tem 3'), findsOneWidget);
      expect(find.text('você tem 0'), findsNWidgets(2));
      // Lista plana: "Cozinha" so aparece como chip de dominio, nunca como
      // cabecalho de secao — entao ha exatamente um (o chip).
      expect(find.text('Cozinha'), findsOneWidget);
    });

    testWidgets('does not fetch without a token', (tester) async {
      final fake = await _pump(tester, catalog: _catalog(), token: null);
      expect(fake.catalogCalls, isEmpty);
    });
  });

  group('search and domain chips filter client-side', () {
    testWidgets('search filters by name', (tester) async {
      await _pump(tester, catalog: _catalog());

      await tester.enterText(find.byType(TextField), 'fei');
      await tester.pumpAndSettle();

      expect(find.text('Feijão'), findsOneWidget);
      expect(find.text('Arroz'), findsNothing);
      expect(find.text('Detergente'), findsNothing);
    });

    testWidgets('the "Doméstico" chip keeps only domestic items',
        (tester) async {
      await _pump(tester, catalog: _catalog());

      await _tapChip(tester, 'Doméstico');

      expect(find.text('Detergente'), findsOneWidget);
      expect(find.text('Arroz'), findsNothing);
      expect(find.text('Feijão'), findsNothing);
    });

    testWidgets('the "Cozinha" chip keeps only food items', (tester) async {
      await _pump(tester, catalog: _catalog());

      await _tapChip(tester, 'Cozinha');

      expect(find.text('Arroz'), findsOneWidget);
      expect(find.text('Feijão'), findsOneWidget);
      expect(find.text('Detergente'), findsNothing);
    });
  });

  group('the cart never writes to the pantry on its own', () {
    testWidgets('steppers start at 0 and "+" only fills the cart',
        (tester) async {
      final fake = await _pump(
        tester,
        catalog: _catalog(),
        pantry: _pantryWithRice(),
      );

      await _increment(tester, 'Arroz');

      // Nenhum PATCH: o carrinho e efemero.
      expect(fake.adjustCalls, isEmpty);
      // O resumo da barra reflete 1 item / 1 pacote.
      expect(find.text('1 item · 1 pacote'), findsOneWidget);
      // O arroz continua com 3 na despensa.
      expect(find.text('você tem 3'), findsOneWidget);
    });

    testWidgets('"−" is disabled at cart quantity 0 (floor)', (tester) async {
      await _pump(tester, catalog: _catalog());

      expect(_stepButton(tester, 'Diminuir Arroz').onPressed, isNull);
    });

    testWidgets('"−" undoes a "+" and returns the cart to empty',
        (tester) async {
      await _pump(tester, catalog: _catalog());

      await _increment(tester, 'Arroz');
      expect(find.text('1 item · 1 pacote'), findsOneWidget);

      await tester.tap(find.byTooltip('Diminuir Arroz'));
      await tester.pumpAndSettle();

      expect(find.text('Carrinho vazio'), findsOneWidget);
    });
  });

  group('confirm commits the whole cart in one batch', () {
    testWidgets('empty cart disables confirm', (tester) async {
      await _pump(tester, catalog: _catalog());

      final confirm = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Confirmar'),
      );
      expect(confirm.enabled, isFalse);
      expect(find.text('Carrinho vazio'), findsOneWidget);
    });

    testWidgets('committing {arroz: 2} sends one batch and pops back',
        (tester) async {
      final fake = await _pump(
        tester,
        catalog: _catalog(),
        pantry: _pantryWithRice(),
      );

      await _increment(tester, 'Arroz');
      await _increment(tester, 'Arroz');
      expect(find.text('1 item · 2 pacotes'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Confirmar'));
      await tester.pumpAndSettle();

      expect(fake.commitCalls, hasLength(1));
      final call = fake.commitCalls.single;
      expect(call.token, 'test-token');
      expect(call.items, hasLength(1));
      expect(call.items.single.itemId, 10);
      // Commit e INCREMENTO: manda 2, nao 5.
      expect(call.items.single.quantity, 2);
      // A despensa passou de 3 para 5.
      expect(fake.quantityOf(10), 5);
      expect(find.text('Compras registradas!'), findsOneWidget);
    });

    testWidgets('retrying after a failure reuses the SAME commit_key',
        (tester) async {
      // A chave e gerada uma vez, na abertura do carrinho; um retry depois de
      // timeout precisa reenviar a MESMA chave para o servidor ignorar o
      // replay. Aqui o primeiro commit falha, o segundo passa.
      final fake = await _pump(tester, catalog: _catalog())
        ..commitErrorOnce = Exception('timeout');

      await _increment(tester, 'Feijão');
      await tester.tap(find.widgetWithText(FilledButton, 'Confirmar'));
      await tester.pumpAndSettle();

      expect(find.text('Não foi possível salvar as compras.'), findsOneWidget);
      // O carrinho sobrevive a falha.
      expect(find.text('1 item · 1 pacote'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Confirmar'));
      await tester.pumpAndSettle();

      expect(fake.commitCalls, hasLength(2));
      expect(
        fake.commitCalls[1].commitKey,
        fake.commitCalls[0].commitKey,
      );
    });

    testWidgets('an applied:false replay is reported, not doubled',
        (tester) async {
      final fake = await _pump(
        tester,
        catalog: _catalog(),
        pantry: _pantryWithRice(),
      )..commitIsReplay = true;

      await _increment(tester, 'Arroz');
      await tester.tap(find.widgetWithText(FilledButton, 'Confirmar'));
      await tester.pumpAndSettle();

      expect(find.text('Essas compras já foram salvas.'), findsOneWidget);
      // Nada foi somado.
      expect(fake.quantityOf(10), 3);
    });
  });
}
