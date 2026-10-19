// Testes do PantryProvider real, com um PantryService de contagem injetado.
//
// O `FakePantryProvider` dos testes de tela REGISTRA cada chamada, mas sempre
// a executa — ele nao reproduz o guard que o provider real tinha. Por isso um
// teste de tela passa contra as duas versoes e nao consegue pegar o bug do
// "cache de sessao". Este arquivo exercita o codigo real.

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miajudai/models/pantry_entry_model.dart';
import 'package:miajudai/models/pantry_item_model.dart';
import 'package:miajudai/providers/pantry_provider.dart';
import 'package:miajudai/services/pantry_service.dart';

/// Servico falso que so conta as chamadas — o provider nao le o resultado
/// alem de guarda-lo, entao a contagem e o que importa aqui.
class _CountingPantryService extends PantryService {
  final List<String> catalogTokens = [];
  final List<String> pantryTokens = [];

  List<PantryItem> catalogResult = [];
  List<PantryEntry> pantryResult = [];

  @override
  Future<List<PantryItem>> getCatalog(String token) async {
    catalogTokens.add(token);
    return catalogResult;
  }

  @override
  Future<List<PantryEntry>> getPantry(String token) async {
    pantryTokens.add(token);
    return pantryResult;
  }
}

PantryItem _rice() =>
    PantryItem(id: 10, name: 'Arroz', emoji: '🍚', domain: 'food');

void main() {
  // O fake estende PantryService, cujo campo ApiService le o dotenv no
  // construtor — inicializar aqui evita o NotInitializedError.
  setUpAll(
    () => dotenv.loadFromString(envString: 'API_BASE_URL=http://test.local/api'),
  );

  group('loadCatalog', () {
    test('busca o catalogo global a cada chamada, nao so na primeira',
        () async {
      final service = _CountingPantryService()..catalogResult = [_rice()];
      final provider = PantryProvider(pantryService: service);

      await provider.loadCatalog('token');
      await provider.loadCatalog('token');

      // Duas aberturas de tela ⇒ duas buscas. Um cache de sessao faria uma.
      expect(service.catalogTokens, ['token', 'token']);
    });

    test('publica o resultado e sai do loading', () async {
      final service = _CountingPantryService()..catalogResult = [_rice()];
      final provider = PantryProvider(pantryService: service);

      await provider.loadCatalog('token');

      expect(provider.catalog.single.name, 'Arroz');
      expect(provider.isLoading, isFalse);
      expect(provider.error, isNull);
    });

    test('ainda rebuscada depois de um erro, mesmo com o catalogo cheio',
        () async {
      // Este era o caminho quebrado pelo guard: um load anterior deixava o
      // catalogo preenchido e o retry dava early-return.
      final service = _CountingPantryService()..catalogResult = [_rice()];
      final provider = PantryProvider(pantryService: service);

      await provider.loadCatalog('token');
      service.catalogResult = [];
      await provider.loadCatalog('token');

      expect(service.catalogTokens, hasLength(2));
      expect(provider.catalog, isEmpty);
    });
  });

  group('loadPantry', () {
    test('rebuscada a cada chamada', () async {
      final service = _CountingPantryService();
      final provider = PantryProvider(pantryService: service);

      await provider.loadPantry('token');
      await provider.loadPantry('token');

      expect(service.pantryTokens, ['token', 'token']);
    });
  });
}
