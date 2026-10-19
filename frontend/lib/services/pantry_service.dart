import '../models/pantry_entry_model.dart';
import '../models/pantry_item_model.dart';
import 'api_service.dart';

/// Acesso HTTP aos endpoints da despensa, todos atras do token de auth.
///
/// Espelha os contratos do backend:
///  - `GET /pantry/items`      → o catalogo global
///  - `GET /pantry`            → as linhas do usuario (cada uma com seu item)
///  - `PATCH /pantry`          → define a quantidade; 0 remove a linha
///  - `POST /pantry/commit`    → incrementa o carrinho num lote idempotente
class PantryService {
  final ApiService _apiService = ApiService();

  Future<List<PantryItem>> getCatalog(String token) async {
    final response = await _apiService.get('/pantry/items', token: token);
    final items = response['items'] as List<dynamic>? ?? [];
    return items
        .map((i) => PantryItem.fromJson(i as Map<String, dynamic>))
        .toList();
  }

  Future<List<PantryEntry>> getPantry(String token) async {
    final response = await _apiService.get('/pantry', token: token);
    final rows = response['pantry'] as List<dynamic>? ?? [];
    return rows
        .map((r) => PantryEntry.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  /// Sets the saved quantity for [itemId]. A [quantity] of 0 removes the row;
  /// the backend reports that as `{ removed: true }` instead of a row.
  Future<PantryQuantityResult> updateQuantity(
    String token,
    int itemId,
    int quantity,
  ) async {
    final response = await _apiService.patch(
      '/pantry',
      {'item_id': itemId, 'quantity': quantity},
      token: token,
    );

    if (response['removed'] == true) {
      return PantryQuantityResult(removedItemId: response['item_id'] as int?);
    }

    return PantryQuantityResult(
      entry: PantryEntry.fromJson(
        response['pantry_item'] as Map<String, dynamic>,
      ),
    );
  }

  /// Commits a whole market trip. [commitKey] is minted once when the cart is
  /// opened and reused on retries, so a replay is ignored server-side.
  /// Returns whether the trip was applied (`false` on a replay).
  Future<bool> commit(
    String token,
    String commitKey,
    List<({int itemId, int quantity})> items,
  ) async {
    final response = await _apiService.post(
      '/pantry/commit',
      {
        'commit_key': commitKey,
        'items': [
          for (final item in items)
            {'item_id': item.itemId, 'quantity': item.quantity},
        ],
      },
      token: token,
    );
    return response['applied'] == true;
  }
}
