import 'package:flutter/foundation.dart';
import 'package:miajudai/models/pantry_entry_model.dart';
import 'package:miajudai/models/pantry_item_model.dart';
import 'package:miajudai/providers/pantry_provider.dart';

/// `PantryProvider` de teste.
///
/// O real instancia `PantryService` (HTTP). Este fake serve os dados que o
/// teste define e REGISTRA cada chamada com os argumentos recebidos, para
/// provar que a UI aciona o provider exatamente do mesmo jeito.
///
/// Espelha a semantica do provider real que a tela observa:
///  - `adjustQuantity` com 0 remove a linha (PATCH-to-0);
///  - `commitCart` soma o carrinho as contagens e devolve `applied`.
class FakePantryProvider extends ChangeNotifier implements PantryProvider {
  List<PantryEntry> items = [];
  List<PantryItem> catalogItems = [];

  final List<String> loadCalls = [];
  final List<String> catalogCalls = [];
  final List<({String token, int itemId, int quantity})> adjustCalls = [];
  final List<
      ({
        String token,
        String commitKey,
        List<({int itemId, int quantity})> items,
      })> commitCalls = [];
  final List<({String token, String name, String domain})> createCalls = [];

  @override
  bool isLoading = false;

  @override
  String? error;

  /// Quando true, `commitCart` devolve `applied: false` (replay).
  bool commitIsReplay = false;

  /// Quando definido, a proxima chamada a `commitCart` lanca (falha de rede).
  /// Consumido uma vez: o retry seguinte passa.
  Object? commitErrorOnce;

  @override
  List<PantryEntry> get entries => items;

  @override
  List<PantryItem> get catalog => catalogItems;

  @override
  bool get isEmpty => items.isEmpty;

  @override
  int quantityOf(int itemId) {
    for (final entry in items) {
      if (entry.itemId == itemId) return entry.quantity;
    }
    return 0;
  }

  @override
  Future<bool> createItem(String token, String name, String domain) async {
    createCalls.add((token: token, name: name, domain: domain));
    // Reproduz a INSERCAO em ordem do provider real: as telas dependem de um
    // item novo ficar selecionavel sem reload. O append sem posicao, a
    // publicacao do evento e o emoji do servidor sao asseverados em
    // `pantry_provider_test.dart` — este fake prova que a TELA pede a criacao.
    final index = catalogItems.indexWhere(
      (existing) =>
          existing.name.toLowerCase().compareTo(name.toLowerCase()) > 0,
    );
    if (index == -1) {
      catalogItems.add(fakePantryItem(id: -1, name: name, domain: domain));
    } else {
      catalogItems.insert(
        index,
        fakePantryItem(id: -1, name: name, domain: domain),
      );
    }
    return true;
  }

  @override
  Future<void> loadPantry(String token) async => loadCalls.add(token);

  @override
  Future<void> loadCatalog(String token) async => catalogCalls.add(token);

  @override
  Future<void> adjustQuantity(String token, int itemId, int quantity) async {
    adjustCalls.add((token: token, itemId: itemId, quantity: quantity));
    if (quantity == 0) {
      items.removeWhere((e) => e.itemId == itemId);
    } else {
      final index = items.indexWhere((e) => e.itemId == itemId);
      if (index == -1) {
        final item = catalogItems.firstWhere((i) => i.id == itemId);
        items.add(
          PantryEntry(
            id: itemId,
            itemId: itemId,
            quantity: quantity,
            item: item,
          ),
        );
      } else {
        items[index] = items[index].copyWith(quantity: quantity);
      }
    }
    notifyListeners();
  }

  @override
  Future<bool> commitCart(
    String token,
    String commitKey,
    List<({int itemId, int quantity})> cartItems,
  ) async {
    commitCalls.add((token: token, commitKey: commitKey, items: cartItems));

    final error = commitErrorOnce;
    if (error != null) {
      commitErrorOnce = null;
      throw error;
    }

    if (commitIsReplay) return false;

    for (final item in cartItems) {
      final index = items.indexWhere((e) => e.itemId == item.itemId);
      if (index == -1) {
        final catalogItem = catalogItems.firstWhere((i) => i.id == item.itemId);
        items.add(
          PantryEntry(
            id: item.itemId,
            itemId: item.itemId,
            quantity: item.quantity,
            item: catalogItem,
          ),
        );
      } else {
        items[index] = items[index].copyWith(
          quantity: items[index].quantity + item.quantity,
        );
      }
    }
    notifyListeners();
    return true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

PantryItem fakePantryItem({
  required int id,
  required String name,
  String emoji = '🍚',
  String domain = 'food',
}) =>
    PantryItem(id: id, name: name, emoji: emoji, domain: domain);

PantryEntry fakePantryEntry({
  required int id,
  required PantryItem item,
  required int quantity,
}) =>
    PantryEntry(id: id, itemId: item.id, quantity: quantity, item: item);
