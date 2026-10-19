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
import 'package:miajudai/services/events_service.dart';
import 'package:miajudai/services/pantry_service.dart';

/// Servico falso que so conta as chamadas — o provider nao le o resultado
/// alem de guarda-lo, entao a contagem e o que importa aqui.
class _CountingPantryService extends PantryService {
  final List<String> catalogTokens = [];
  final List<String> pantryTokens = [];
  final List<({String token, String name, String domain})> createCalls = [];

  List<PantryItem> catalogResult = [];
  List<PantryEntry> pantryResult = [];

  /// O que `createItem` devolve — e o "servidor" aqui: o emoji que voltar
  /// daqui e o que o provider tem de usar, nunca um inventado no cliente.
  PantryItem? createResult;

  /// Quando definido, a proxima chamada a `createItem` lanca.
  Object? createErrorOnce;

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

  @override
  Future<PantryItem> createItem(
    String token,
    String name,
    String domain,
  ) async {
    createCalls.add((token: token, name: name, domain: domain));

    final error = createErrorOnce;
    if (error != null) {
      createErrorOnce = null;
      throw error;
    }

    return createResult ?? PantryItem(id: 99, name: name, emoji: '🍽️', domain: domain);
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

  // `publishEvent` descarta eventos sem token, e so o singleton os guarda num
  // buffer inspecionavel. O dispose cancela o timer de flush e limpa o buffer,
  // entao os testes leem `bufferedEvents` ANTES do tearDown.
  setUp(() => EventsService().setToken('token'));
  tearDown(() => EventsService().dispose());

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

  group('createItem', () {
    test('envia nome e dominio, nunca o emoji', () async {
      final service = _CountingPantryService()
        ..catalogResult = [_rice()]
        ..createResult = PantryItem(
          id: 42,
          name: 'Chimichurri',
          emoji: '🍽️',
          domain: 'food',
        );
      final provider = PantryProvider(pantryService: service);

      await provider.createItem('token', 'Chimichurri', 'food');

      final call = service.createCalls.single;
      expect(call.token, 'token');
      expect(call.name, 'Chimichurri');
      expect(call.domain, 'food');
    });

    test('anexa o item do SERVIDOR ao catalogo, sem recarregar', () async {
      // O emoji do servidor e a fonte da verdade: um item montado no cliente
      // renderizaria com um emoji diferente do que um reload mostraria.
      final service = _CountingPantryService()
        ..catalogResult = [_rice()]
        ..createResult = PantryItem(
          id: 42,
          name: 'Chimichurri',
          emoji: '🍽️',
          domain: 'food',
        );
      final provider = PantryProvider(pantryService: service);

      await provider.loadCatalog('token');
      final ok = await provider.createItem('token', 'Chimichurri', 'food');

      expect(ok, isTrue);
      expect(provider.catalog.map((i) => i.name), ['Arroz', 'Chimichurri']);
      final appended = provider.catalog.last;
      expect(appended.id, 42);
      expect(appended.emoji, '🍽️');
      // Nenhum getCatalog extra: o item novo entra na lista ja carregada.
      expect(service.catalogTokens, ['token']);
    });

    test('entra na posicao alfabetica, nao no fim', () async {
      // O servidor devolve o catalogo em ordem de nome; sem isso o item novo
      // cairia no fim da lista ate o proximo reload.
      final service = _CountingPantryService()
        ..catalogResult = [
          PantryItem(id: 10, name: 'Arroz', emoji: '🍚', domain: 'food'),
          PantryItem(id: 11, name: 'Feijão', emoji: '🫘', domain: 'food'),
        ]
        ..createResult = PantryItem(
          id: 12,
          name: 'Chimichurri',
          emoji: '🍽️',
          domain: 'food',
        );
      final provider = PantryProvider(pantryService: service);

      await provider.loadCatalog('token');
      await provider.createItem('token', 'Chimichurri', 'food');

      expect(provider.catalog.map((i) => i.name), [
        'Arroz',
        'Chimichurri',
        'Feijão',
      ]);
    });

    test('ordena sem depender da caixa', () async {
      final service = _CountingPantryService()
        ..catalogResult = [
          PantryItem(id: 10, name: 'aveia', emoji: '🥣', domain: 'food'),
        ]
        ..createResult = PantryItem(
          id: 12,
          name: 'Arroz',
          emoji: '🍽️',
          domain: 'food',
        );
      final provider = PantryProvider(pantryService: service);

      await provider.loadCatalog('token');
      await provider.createItem('token', 'Arroz', 'food');

      // 'Arroz' antes de 'aveia' — comparar 'A' com 'a' cru jogaria o novo
      // item para o fim.
      expect(provider.catalog.map((i) => i.name), ['Arroz', 'aveia']);
    });

    test('publica pantry_item_created com o id e o dominio', () async {
      final service = _CountingPantryService()
        ..createResult = PantryItem(
          id: 42,
          name: 'Chimichurri',
          emoji: '🍽️',
          domain: 'domestic',
        );
      final provider = PantryProvider(pantryService: service);

      await provider.createItem('token', 'Chimichurri', 'domestic');

      final event = EventsService().bufferedEvents.single;
      expect(event['action'], 'pantry_item_created');
      expect(event['metadata'], {'item_id': 42, 'domain': 'domestic'});
    });

    test('uma falha nao encosta no catalogo nem publica evento', () async {
      final service = _CountingPantryService()
        ..catalogResult = [_rice()]
        ..createErrorOnce = Exception('500');
      final provider = PantryProvider(pantryService: service);

      await provider.loadCatalog('token');
      final ok = await provider.createItem('token', 'Chimichurri', 'food');

      expect(ok, isFalse);
      expect(provider.catalog.map((i) => i.name), ['Arroz']);
      expect(provider.error, isNotNull);
      expect(EventsService().bufferedEvents, isEmpty);
    });
  });
}
