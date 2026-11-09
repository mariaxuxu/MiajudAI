import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/pantry_item_model.dart';
import '../providers/auth_provider.dart';
import '../providers/pantry_provider.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../theme/tokens/app_colors_semantic.dart';
import '../widgets/common/app_feedback_snackbar.dart';
import '../widgets/common/app_form_dropdown.dart';
import '../widgets/common/app_form_field.dart';
import '../widgets/common/app_form_sheet.dart';
import '../widgets/common/app_module_scaffold.dart';
import '../widgets/common/app_primary_button.dart';
import '../widgets/common/empty_state_card.dart';
import '../widgets/common/module_header_action.dart';
import '../widgets/common/module_screen_header.dart';
import '../widgets/diary/category_chips.dart';
import '../widgets/pantry/cart_confirm_bar.dart';
import '../widgets/pantry/no_results_note.dart';
import '../widgets/pantry/pantry_item_row.dart';
import '../widgets/pantry/pantry_search_field.dart';

/// O catalogo completo em tela cheia: lista plana + busca + chips de dominio.
///
/// O carrinho e estado efemero DESTA tela (memoria apenas, descartado ao sair
/// ou confirmar). Nenhum toque em −/+ escreve na despensa: so o confirmar
/// grava, num unico commit em lote.
class PantryCatalogScreen extends StatefulWidget {
  const PantryCatalogScreen({super.key});

  @override
  State<PantryCatalogScreen> createState() => _PantryCatalogScreenState();
}

class _PantryCatalogScreenState extends State<PantryCatalogScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Map<int, int> _cart = {};
  String _query = '';
  String _domainFilter = _allDomains;

  /// Gerado UMA vez, na abertura do carrinho, e reusado em cada retry: e o que
  /// torna o confirmar idempotente.
  final String _commitKey = const Uuid().v4();

  bool _isCommitting = false;

  static const String _allDomains = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.authToken != null) {
        final pantry = context.read<PantryProvider>();
        // O catalogo mostra "você tem N", entao a despensa tambem precisa
        // estar carregada.
        pantry.loadCatalog(auth.authToken!);
        pantry.loadPantry(auth.authToken!);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<PantryItem> _filtered(PantryProvider pantry) {
    final query = _query.trim().toLowerCase();

    return pantry.catalog.where((item) {
      final matchesDomain =
          _domainFilter == _allDomains || item.domain == _domainFilter;
      final matchesQuery =
          query.isEmpty || item.name.toLowerCase().contains(query);
      return matchesDomain && matchesQuery;
    }).toList();
  }

  int get _itemCount => _cart.length;
  int get _packCount => _cart.values.fold(0, (sum, q) => sum + q);

  void _increment(PantryItem item) {
    setState(() => _cart[item.id] = (_cart[item.id] ?? 0) + 1);
  }

  void _decrement(PantryItem item) {
    final current = _cart[item.id] ?? 0;
    if (current <= 0) return;
    setState(() {
      if (current == 1) {
        _cart.remove(item.id);
      } else {
        _cart[item.id] = current - 1;
      }
    });
  }

  Future<void> _showCreateItemSheet() {
    // A sheet e uma rota: o corpo dela precisa de um widget com estado PROPRIO
    // (o `StatefulBuilder` nao tem `dispose`, e o controller seria descartado
    // enquanto a animacao de saida ainda desenha o campo).
    //
    // O catalogo vai como uma COPIA: nada muda a lista enquanto a sheet esta
    // aberta (criar fecha a sheet), entao nao ha por que a sheet ler o provider
    // pelo contexto da rota dela — as leituras de estado ficam todas aqui.
    return AppFormSheet.show(
      context: context,
      title: 'Novo item',
      builder: (sheetContext) => _CreateItemSheet(
        catalog: context.read<PantryProvider>().catalog,
        onSubmit: (name, domain) => _submitCreate(sheetContext, name, domain),
        onUseExisting: (item) => _useExisting(sheetContext, item),
      ),
    );
  }

  /// Adiciona um item a compra atual: fecha a sheet de criacao e conta 1
  /// pacote do item sugerido. "Usar esse" nesta tela significa usar na compra
  /// de hoje — a barra de confirmar mostra o efeito na hora.
  void _useExisting(BuildContext sheetContext, PantryItem item) {
    Navigator.pop(sheetContext);
    _increment(item);
    AppFeedbackSnackBar.success(context, '${item.name} entrou na compra.');
  }

  /// Cria o item e fecha a sheet. Uma falha mantem a sheet aberta com o texto
  /// intacto, para o usuario tentar de novo — o erro fica no provider.
  Future<void> _submitCreate(
    BuildContext sheetContext,
    String rawName,
    String domain,
  ) async {
    final name = rawName.trim();
    if (name.isEmpty) {
      AppFeedbackSnackBar.error(sheetContext, 'Digite o nome do item');
      return;
    }

    final token = context.read<AuthProvider>().authToken;
    if (token == null) return;

    final created =
        await context.read<PantryProvider>().createItem(token, name, domain);

    if (created) {
      Navigator.pop(sheetContext);
      if (!mounted) return;
      AppFeedbackSnackBar.success(context, '$name foi criado.');
    } else if (sheetContext.mounted) {
      AppFeedbackSnackBar.error(sheetContext, 'Não foi possível criar o item.');
    }
  }

  Future<void> _confirm() async {
    final token = context.read<AuthProvider>().authToken;
    if (token == null || _cart.isEmpty || _isCommitting) return;

    setState(() => _isCommitting = true);
    try {
      final items = [
        for (final entry in _cart.entries)
          (itemId: entry.key, quantity: entry.value),
      ];
      final applied = await context
          .read<PantryProvider>()
          .commitCart(token, _commitKey, items);

      if (!mounted) return;

      if (applied) {
        AppFeedbackSnackBar.success(context, 'Compras registradas!');
        Navigator.pop(context);
      } else {
        // Replay: o mesmo commit_key ja tinha sido aplicado. Nada mudou.
        AppFeedbackSnackBar.success(context, 'Essas compras já foram salvas.');
      }
    } catch (e) {
      if (mounted) {
        AppFeedbackSnackBar.error(context, 'Não foi possível salvar as compras.');
      }
    } finally {
      if (mounted) setState(() => _isCommitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppModuleScaffold(
      header: ModuleScreenHeader(
        title: 'Catálogo',
        subtitle: 'O que você está comprando hoje',
        onBack: () => Navigator.pop(context),
        actions: [
          ModuleHeaderAction(
            icon: Icons.add_rounded,
            tooltip: 'Criar item',
            onPressed: _showCreateItemSheet,
          ),
        ],
      ),
      bottomBar: CartConfirmBar(
        itemCount: _itemCount,
        packCount: _packCount,
        onConfirm: _confirm,
        isLoading: _isCommitting,
      ),
      child: Consumer<PantryProvider>(
        builder: (context, pantry, _) {
          if (pantry.isLoading && pantry.catalog.isEmpty) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.sectionGap),
              child: Center(
                child: CircularProgressIndicator(
                  semanticsLabel: 'Carregando catálogo',
                ),
              ),
            );
          }
          if (pantry.error != null && pantry.catalog.isEmpty) {
            return EmptyStateCard(
              art: const Icon(
                Icons.cloud_off_rounded,
                size: 56,
                color: AppSemanticColors.onFeedbackError,
              ),
              title: 'Não deu para abrir o catálogo',
              message: pantry.error!,
              actionLabel: 'Tentar de novo',
              onAction: () {
                final token = context.read<AuthProvider>().authToken;
                if (token != null) pantry.loadCatalog(token);
              },
            );
          }

          final filtered = _filtered(pantry);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PantrySearchField(
                controller: _searchController,
                hint: 'Buscar no catálogo...',
                onChanged: (value) => setState(() => _query = value),
              ),
              const SizedBox(height: AppSpacing.defaultGap),
              _buildDomainChips(),
              const SizedBox(height: AppSpacing.blockGap),
              if (filtered.isEmpty)
                NoResultsNote(query: _searchController.text.trim())
              else
                for (final item in filtered) _buildRow(item, pantry),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDomainChips() {
    return CategoryChips(
      options: [
        const CategoryOption(
          value: _allDomains,
          label: 'Todos',
          icon: Icons.apps_rounded,
        ),
        CategoryOption(
          value: PantryDomain.food.value,
          label: PantryDomain.food.label,
          icon: Icons.restaurant_rounded,
        ),
        CategoryOption(
          value: PantryDomain.domestic.value,
          label: PantryDomain.domestic.label,
          icon: Icons.home_outlined,
        ),
      ],
      selected: {_domainFilter},
      onChanged: (value, _) => setState(() => _domainFilter = value),
    );
  }

  Widget _buildRow(PantryItem item, PantryProvider pantry) {
    final cartQuantity = _cart[item.id] ?? 0;

    return CatalogItemRow(
      emoji: item.emoji,
      name: item.name,
      ownedQuantity: pantry.quantityOf(item.id),
      cartQuantity: cartQuantity,
      onIncrement: () => _increment(item),
      onDecrement: cartQuantity == 0 ? null : () => _decrement(item),
    );
  }
}

/// Corpo da sheet de criacao: nome + categoria, com o gate de sugestao.
///
/// E um `StatefulWidget` (nao um `StatefulBuilder`) porque o controller do
/// nome precisa de `dispose` no tempo certo — a sheet e uma rota, e o ultimo
/// frame da animacao de saida ainda desenha o campo.
class _CreateItemSheet extends StatefulWidget {
  const _CreateItemSheet({
    required this.catalog,
    required this.onSubmit,
    required this.onUseExisting,
  });

  /// O catalogo ja carregado, sobre o qual o match de duplicata roda. Passado
  /// do corpo da tela: a sheet NAO le o provider pelo proprio contexto de rota.
  final List<PantryItem> catalog;

  final void Function(String name, String domain) onSubmit;
  final ValueChanged<PantryItem> onUseExisting;

  @override
  State<_CreateItemSheet> createState() => _CreateItemSheetState();
}

class _CreateItemSheetState extends State<_CreateItemSheet> {
  final TextEditingController _nameCtrl = TextEditingController();
  String _domain = PantryDomain.food.value;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  /// Candidatos do catalogo JA carregado que parecem o nome digitado. Sem
  /// requisicao: e o mesmo conjunto em memoria que a busca da tela filtra.
  /// Casa nos dois sentidos ("arroz" acha "Arroz Integral" e vice-versa) e
  /// ignora acento e caixa, para "Feijao" ainda achar "Feijão". Abaixo de 3
  /// letras e ruido demais para sugerir.
  List<PantryItem> _matches() {
    final query = _normalize(_nameCtrl.text);
    if (query.length < 3) return const [];

    return widget.catalog
        .where(
          (item) =>
              _normalize(item.name).contains(query) ||
              query.contains(_normalize(item.name)),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _nameCtrl,
      builder: (context, _, __) {
        final matches = _matches();

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppFormField(
              controller: _nameCtrl,
              label: 'Nome do item',
              hint: 'Ex: Chimichurri',
              isRequired: true,
              autofocus: true,
            ),
            const SizedBox(height: AppSpacing.defaultGap),
            AppFormDropdown<String>(
              label: 'Categoria',
              value: _domain,
              onChanged: (v) => setState(() => _domain = v!),
              items: [
                for (final domain in PantryDomain.values)
                  DropdownMenuItem(
                    value: domain.value,
                    child: Text(domain.label),
                  ),
              ],
            ),
            if (matches.isEmpty) ...[
              const SizedBox(height: AppSpacing.blockGap),
              AppPrimaryButton(
                label: 'Criar item',
                onPressed: () => widget.onSubmit(_nameCtrl.text, _domain),
              ),
            ] else ...[
              const SizedBox(height: AppSpacing.defaultGap),
              _ExistingMatches(
                matches: matches,
                onUse: widget.onUseExisting,
              ),
              const SizedBox(height: AppSpacing.blockGap),
              // O gate: com um parecido em tela, a acao primaria de criar some
              // e so a confirmacao explicita de que o item e novo cria — em
              // botao secundario, para nao convidar ao toque. Um aviso que
              // ainda deixasse criar nao cumpriria o ticket.
              OutlinedButton(
                onPressed: () => widget.onSubmit(_nameCtrl.text, _domain),
                child: const Text('É um item novo — criar'),
              ),
            ],
          ],
        );
      },
    );
  }
}

/// Minusculas sem acento, para o match nao depender de como o usuario digitou
/// uma palavra que o catalogo guarda acentuada.
String _normalize(String value) {
  const from = 'áàâãäéèêëíìîïóòôõöúùûüç';
  const to = 'aaaaaeeeeiiiiooooouuuuc';

  final buffer = StringBuffer();
  for (final char in value.trim().toLowerCase().split('')) {
    final index = from.indexOf(char);
    buffer.write(index == -1 ? char : to[index]);
  }
  return buffer.toString();
}

/// Sugestoes de itens ja existentes para quem esta criando um parecido.
///
/// Cada linha leva o item para a COMPRA atual e abandona a criacao — e a
/// alternativa a duplicar o catalogo com uma variacao de escrita.
class _ExistingMatches extends StatelessWidget {
  const _ExistingMatches({required this.matches, required this.onUse});

  final List<PantryItem> matches;
  final ValueChanged<PantryItem> onUse;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Já existe algo parecido — usar esse?',
          style: AppTypography.labelMedium.copyWith(
            color: AppSemanticColors.textSecondaryStrong,
          ),
        ),
        const SizedBox(height: AppSpacing.labelGap),
        for (final item in matches) _buildMatch(context, item),
      ],
    );
  }

  Widget _buildMatch(BuildContext context, PantryItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.labelGap),
      child: OutlinedButton(
        onPressed: () => onUse(item),
        child: Row(
          children: [
            ExcludeSemantics(
              child: Text(item.emoji, style: const TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: AppSpacing.labelGap),
            Expanded(
              child: Text(
                item.name,
                textAlign: TextAlign.start,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.add_rounded, size: AppSizes.iconMd),
          ],
        ),
      ),
    );
  }
}
