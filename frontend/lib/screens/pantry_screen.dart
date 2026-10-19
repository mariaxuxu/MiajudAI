import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/routes.dart';
import '../models/pantry_entry_model.dart';
import '../models/pantry_item_model.dart';
import '../providers/auth_provider.dart';
import '../providers/pantry_provider.dart';
import '../theme/app_spacing.dart';
import '../theme/tokens/app_colors_semantic.dart';
import '../widgets/common/app_module_scaffold.dart';
import '../widgets/common/empty_state_card.dart';
import '../widgets/common/module_screen_header.dart';
import '../widgets/common/section_header.dart';
import '../widgets/pantry/no_results_note.dart';
import '../widgets/pantry/pantry_item_row.dart';
import '../widgets/pantry/pantry_search_field.dart';

/// A despensa do usuario: o que ele tem em casa, em Cozinha e Domestico.
///
/// Os steppers −/+ daqui escrevem direto na despensa via `PATCH`; chegar a 0
/// remove o item (o backend reporta `{ removed: true }`).
class PantryScreen extends StatefulWidget {
  const PantryScreen({super.key});

  @override
  State<PantryScreen> createState() => _PantryScreenState();
}

class _PantryScreenState extends State<PantryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  /// Itens com um ajuste em voo, para nao disparar um segundo PATCH enquanto
  /// o primeiro ainda nao voltou.
  final Set<int> _pending = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.authToken != null) {
        context.read<PantryProvider>().loadPantry(auth.authToken!);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _adjust(PantryEntry entry, int nextQuantity) async {
    final token = context.read<AuthProvider>().authToken;
    if (token == null || _pending.contains(entry.itemId)) return;

    setState(() => _pending.add(entry.itemId));
    try {
      await context
          .read<PantryProvider>()
          .adjustQuantity(token, entry.itemId, nextQuantity);
    } finally {
      if (mounted) setState(() => _pending.remove(entry.itemId));
    }
  }

  void _openCatalog() {
    Navigator.pushNamed(context, AppRoutes.pantryCatalog);
  }

  List<PantryEntry> _filtered(PantryProvider pantry) {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return pantry.entries;
    return pantry.entries
        .where((e) => e.name.toLowerCase().contains(query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return AppModuleScaffold(
      header: ModuleScreenHeader(
        title: 'Despensa',
        subtitle: 'O que você tem em casa',
        onBack: () => Navigator.pop(context),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCatalog,
        icon: const Icon(Icons.shopping_cart_outlined),
        label: const Text('Fiz compras'),
      ),
      child: Consumer<PantryProvider>(
        builder: (context, pantry, _) {
          if (pantry.isLoading && pantry.entries.isEmpty && pantry.error == null) {
            return const _PantryLoading();
          }
          if (pantry.error != null && pantry.entries.isEmpty) {
            return _PantryError(
              message: pantry.error!,
              onRetry: () {
                final token = context.read<AuthProvider>().authToken;
                if (token != null) pantry.loadPantry(token);
              },
            );
          }
          if (pantry.entries.isEmpty) {
            return _PantryEmptyState(onStart: _openCatalog);
          }

          final filtered = _filtered(pantry);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PantrySearchField(
                controller: _searchController,
                hint: 'Buscar item...',
                onChanged: (value) => setState(() => _query = value),
              ),
              const SizedBox(height: AppSpacing.blockGap),
              if (filtered.isEmpty)
                NoResultsNote(query: _searchController.text.trim())
              else
                for (final domain in PantryDomain.values)
                  ..._buildDomainSection(domain, pantry, filtered),
              const SizedBox(height: AppModuleScaffold.fabClearance),
            ],
          );
        },
      ),
    );
  }

  /// Uma secao (Cozinha / Domestico) so aparece quando tem itens: o cabecalho
  /// de uma secao vazia seria ruido.
  List<Widget> _buildDomainSection(
    PantryDomain domain,
    PantryProvider pantry,
    List<PantryEntry> filtered,
  ) {
    final items =
        filtered.where((e) => e.domain == domain.value).toList();
    if (items.isEmpty) return const [];

    return [
      SectionHeader(
        title: domain.label,
        count: items.length,
        accent: domain == PantryDomain.domestic
            ? AppAgent.tina.accent
            : AppAgent.otto.accent,
      ),
      const SizedBox(height: AppSpacing.itemGap),
      for (final entry in items) _buildRow(entry, pantry),
      const SizedBox(height: AppSpacing.blockGap),
    ];
  }

  Widget _buildRow(PantryEntry entry, PantryProvider pantry) {
    final busy = _pending.contains(entry.itemId) || pantry.isLoading;

    return PantryItemRow(
      emoji: entry.emoji,
      name: entry.name,
      quantity: entry.quantity,
      onIncrement: busy ? () {} : () => _adjust(entry, entry.quantity + 1),
      // − em quantidade 1 remove: o PATCH com 0 e o que apaga a linha.
      onDecrement: busy ? null : () => _adjust(entry, entry.quantity - 1),
    );
  }
}

class _PantryLoading extends StatelessWidget {
  const _PantryLoading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.sectionGap),
      child: Center(
        child: CircularProgressIndicator(
          semanticsLabel: 'Carregando despensa',
        ),
      ),
    );
  }
}

class _PantryError extends StatelessWidget {
  const _PantryError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return EmptyStateCard(
      art: const Icon(
        Icons.cloud_off_rounded,
        size: 56,
        color: AppSemanticColors.onFeedbackError,
      ),
      title: 'Não deu para abrir a despensa',
      message: message,
      actionLabel: 'Tentar de novo',
      onAction: onRetry,
    );
  }
}

class _PantryEmptyState extends StatelessWidget {
  const _PantryEmptyState({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return EmptyStateCard(
      art: const Text('🛒', style: TextStyle(fontSize: 56)),
      title: 'Sua despensa está vazia',
      message:
          'Toque em "Fiz compras" depois do mercado para começar a registrar '
          'o que você tem em casa.',
      actionLabel: 'Fiz compras',
      onAction: onStart,
      actionIcon: Icons.shopping_cart_outlined,
      actionStyle: EmptyStateActionStyle.filled,
    );
  }
}
