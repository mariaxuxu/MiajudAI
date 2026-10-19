import 'package:flutter/foundation.dart';

import '../config/event_actions.dart';
import '../models/pantry_entry_model.dart';
import '../models/pantry_item_model.dart';
import '../services/events_service.dart';
import '../services/pantry_service.dart';

/// Estado da despensa: as linhas do usuario mais o catalogo global, ambos em
/// memoria para que busca e filtro fiquem no cliente.
///
/// Os steppers da tela de Despensa escrevem direto via [adjustQuantity]; o
/// carrinho da tela de Catalogo e estado efemero DAQUELA tela e nunca mora aqui.
class PantryProvider extends ChangeNotifier {
  PantryProvider({PantryService? pantryService})
      : _pantryService = pantryService ?? PantryService();

  final PantryService _pantryService;

  List<PantryEntry> _entries = [];
  List<PantryItem> _catalog = [];
  bool _isLoading = false;
  String? _error;

  List<PantryEntry> get entries => _entries;
  List<PantryItem> get catalog => _catalog;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool get isEmpty => _entries.isEmpty;

  /// Quantos pacotes de [itemId] o usuario tem; 0 quando nao tem nenhum.
  int quantityOf(int itemId) {
    for (final entry in _entries) {
      if (entry.itemId == itemId) return entry.quantity;
    }
    return 0;
  }

  Future<void> loadPantry(String token) async {
    _setLoading(true);
    _clearError();
    notifyListeners();

    try {
      _entries = await _pantryService.getPantry(token);
    } catch (e) {
      _setError('Não foi possível carregar sua despensa.');
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  /// Busca o catalogo global. Roda a CADA abertura da tela de Catalogo: o item
  /// pode ter sido criado por outro usuario entre duas aberturas, e um cache de
  /// sessao mostraria uma lista desatualizada. Busca e filtro ficam no cliente.
  Future<void> loadCatalog(String token) async {
    _setLoading(true);
    _clearError();
    notifyListeners();

    try {
      _catalog = await _pantryService.getCatalog(token);
    } catch (e) {
      _setError('Não foi possível carregar o catálogo.');
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  /// Creates a global catalog item and makes it selectable right away.
  ///
  /// The item added is the one the SERVER returned, not one rebuilt here: the
  /// emoji is assigned server-side from the domain, and a local guess would
  /// render differently from what a reload shows. It is INSERTED into the
  /// already-loaded [_catalog] in name order — the same order `GET
  /// /pantry/items` returns — instead of reloading it, so the item is
  /// selectable in the CURRENT open AND sits where a reload would put it.
  ///
  /// Returns whether the item was created, so the sheet can tell success from
  /// a failure; the error itself stays in [error], as in [adjustQuantity].
  Future<bool> createItem(String token, String name, String domain) async {
    _clearError();

    try {
      final item = await _pantryService.createItem(token, name, domain);
      final index = _catalog.indexWhere(
        (existing) =>
            existing.name.toLowerCase().compareTo(item.name.toLowerCase()) > 0,
      );
      if (index == -1) {
        _catalog.add(item);
      } else {
        _catalog.insert(index, item);
      }
      EventsService().publishEvent(
        EventActions.pantryItemCreated,
        metadata: {'item_id': item.id, 'domain': item.domain},
      );
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Não foi possível criar o item.');
      notifyListeners();
      return false;
    }
  }

  /// Sets [quantity] for a pantry row. Reaching 0 removes the item and
  /// publishes a `pantry_item_removed` event; individual taps do not.
  Future<void> adjustQuantity(String token, int itemId, int quantity) async {
    _clearError();

    try {
      final result = await _pantryService.updateQuantity(token, itemId, quantity);

      if (result.isRemoved) {
        final removedId = result.removedItemId!;
        _entries.removeWhere((e) => e.itemId == removedId);
        EventsService().publishEvent(
          EventActions.pantryItemRemoved,
          metadata: {'item_id': removedId},
        );
      } else {
        final entry = result.entry!;
        final index = _entries.indexWhere((e) => e.itemId == itemId);
        if (index == -1) {
          _entries.add(entry);
        } else {
          _entries[index] = entry;
        }
      }

      notifyListeners();
    } catch (e) {
      _setError('Não foi possível atualizar a quantidade.');
      notifyListeners();
    }
  }

  /// Commits a market trip in one batch. Returns whether it was applied
  /// (`false` on a replay of the same [commitKey]) so the caller can tell a
  /// real commit from a double-tap.
  Future<bool> commitCart(
    String token,
    String commitKey,
    List<({int itemId, int quantity})> items,
  ) async {
    if (items.isEmpty) return false;

    _setError(null);
    final applied = await _pantryService.commit(token, commitKey, items);

    if (applied) {
      _entries = await _pantryService.getPantry(token);
      EventsService().publishEvent(
        EventActions.pantryCommit,
        metadata: {
          'items': items.length,
          'packs': items.fold(0, (sum, i) => sum + i.quantity),
        },
      );
    }

    notifyListeners();
    return applied;
  }

  void _setLoading(bool value) => _isLoading = value;
  void _setError(String? value) => _error = value;
  void _clearError() => _error = null;
}
