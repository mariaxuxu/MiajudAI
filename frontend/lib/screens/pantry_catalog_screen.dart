import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/pantry_item_model.dart';
import '../providers/auth_provider.dart';
import '../providers/pantry_provider.dart';
import '../theme/app_spacing.dart';
import '../theme/tokens/app_colors_semantic.dart';
import '../widgets/common/app_feedback_snackbar.dart';
import '../widgets/common/app_module_scaffold.dart';
import '../widgets/common/empty_state_card.dart';
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
