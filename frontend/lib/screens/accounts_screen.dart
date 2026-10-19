import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/routes.dart';
import '../providers/auth_provider.dart';
import '../providers/account_provider.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../theme/tokens/app_colors_semantic.dart';
import '../theme/tokens/app_primitives.dart';
import '../widgets/common/app_feedback_snackbar.dart';
import '../widgets/common/app_form_dropdown.dart';
import '../widgets/common/app_form_field.dart';
import '../widgets/common/app_form_sheet.dart';
import '../widgets/common/app_module_scaffold.dart';
import '../widgets/common/app_primary_button.dart';
import '../widgets/common/empty_state_card.dart';
import '../widgets/common/module_screen_header.dart';
import '../widgets/common/section_header.dart';
import '../widgets/dialogs/app_confirm_dialog.dart';
import '../widgets/finance/balance_hero_card.dart';
import '../widgets/home/quick_action_card.dart';

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.authToken != null) {
        context.read<AccountProvider>().loadAccounts(auth.authToken!);
      }
    });
  }

  void _showAddAccountBottomSheet() {
    final nameCtrl = TextEditingController();
    final bankCtrl = TextEditingController();
    final numberCtrl = TextEditingController();
    String selectedType = 'checking';
    final outerContext = context;

    AppFormSheet.show(
      context: context,
      title: 'Nova Conta',
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (innerContext, sheetSetState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppFormField(
                  controller: nameCtrl,
                  label: 'Nome da conta',
                  hint: 'Ex: Conta Corrente Nubank',
                ),
                const SizedBox(height: AppSpacing.defaultGap),
                AppFormDropdown<String>(
                  label: 'Tipo de conta',
                  value: selectedType,
                  onChanged: (v) => sheetSetState(() => selectedType = v!),
                  items: const [
                    DropdownMenuItem(
                        value: 'checking', child: Text('Conta Corrente')),
                    DropdownMenuItem(value: 'savings', child: Text('Poupança')),
                    DropdownMenuItem(
                        value: 'credit_card', child: Text('Cartão de Crédito')),
                    DropdownMenuItem(value: 'other', child: Text('Outra')),
                  ],
                ),
                const SizedBox(height: AppSpacing.defaultGap),
                AppFormField(
                  controller: bankCtrl,
                  label: 'Banco (opcional)',
                  hint: 'Ex: Nubank',
                ),
                const SizedBox(height: AppSpacing.defaultGap),
                AppFormField(
                  controller: numberCtrl,
                  label: 'Número da conta (opcional)',
                  hint: 'Ex: 123456-7',
                ),
                const SizedBox(height: AppSpacing.blockGap),
                AppPrimaryButton(
                  label: 'Criar conta',
                  onPressed: () {
                    final name = nameCtrl.text.trim();
                    if (name.isEmpty) {
                      AppFeedbackSnackBar.error(
                          sheetContext, 'Digite o nome da conta');
                      return;
                    }
                    final auth = outerContext.read<AuthProvider>();
                    final accounts = outerContext.read<AccountProvider>();
                    if (auth.authToken != null) {
                      accounts.addAccount(
                        auth.authToken!,
                        name,
                        selectedType,
                        bankCtrl.text.isEmpty ? null : bankCtrl.text,
                        numberCtrl.text.isEmpty ? null : numberCtrl.text,
                      );
                      Navigator.pop(sheetContext);
                      AppFeedbackSnackBar.success(
                          outerContext, 'Conta criada!');
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppModuleScaffold(
      header: ModuleScreenHeader(
        title: 'Finanças',
        subtitle: 'Controle suas contas e gastos',
        onBack: () => Navigator.pop(context),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddAccountBottomSheet,
        tooltip: 'Adicionar conta',
        child: const Icon(Icons.add),
      ),
      child: Consumer<AccountProvider>(
        builder: (context, accountProvider, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildBalanceCard(accountProvider),
              const SizedBox(height: AppSpacing.defaultGap),
              _buildQuickActions(),
              const SizedBox(height: AppSpacing.blockGap),
              SectionHeader(
                title: 'Minhas contas',
                count: accountProvider.accounts.length,
              ),
              const SizedBox(height: AppSpacing.itemGap),
              if (accountProvider.accounts.isEmpty)
                EmptyStateCard(
                  art: const Icon(
                    Icons.account_balance_outlined,
                    size: 56,
                    color: AppSemanticColors.textTertiary,
                  ),
                  title: 'Nenhuma conta cadastrada',
                  message:
                      'Adicione sua primeira conta para acompanhar seu saldo e movimentações.',
                  actionLabel: 'Adicionar conta',
                  onAction: _showAddAccountBottomSheet,
                )
              else
                ...accountProvider.accounts
                    .map((a) => _buildAccountCard(a, accountProvider)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBalanceCard(AccountProvider accountProvider) {
    return BalanceHeroCard(
      label: 'Saldo total',
      value:
          'R\$ ${accountProvider.totalBalance.toStringAsFixed(2).replaceAll('.', ',')}',
      caption:
          '${accountProvider.accounts.length} conta${accountProvider.accounts.length != 1 ? 's' : ''}',
    );
  }

  Widget _buildAccountCard(dynamic account, AccountProvider accountProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.itemGap),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.cardPadding,
        AppSpacing.cardPadding,
        AppSpacing.labelGap,
        AppSpacing.cardPadding,
      ),
      decoration: BoxDecoration(
        color: AppSemanticColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppPrimitives.shadowSm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExcludeSemantics(
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTone.blue.surface,
                borderRadius: BorderRadius.circular(AppRadius.control),
              ),
              child: Icon(
                _getAccountIcon(account.type),
                color: AppTone.blue.foreground,
                size: AppSizes.iconLg,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.itemGap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  account.name,
                  style: AppTypography.titleMedium.copyWith(
                    color: AppSemanticColors.textPrimary,
                  ),
                ),
                Text(
                  _getAccountTypeLabel(account.type),
                  style: AppTypography.bodySmall.copyWith(
                    color: AppSemanticColors.textSecondaryStrong,
                  ),
                ),
                const SizedBox(height: AppSpacing.labelGap),
                Text(
                  'R\$ ${account.balance.toStringAsFixed(2).replaceAll('.', ',')}',
                  style: AppTypography.headlineSmall.copyWith(
                    color: AppSemanticColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Remover ${account.name}',
            icon: const Icon(Icons.delete_outline_rounded),
            color: AppSemanticColors.onFeedbackError,
            onPressed: () => AppConfirmDialog.show(
              context,
              title: 'Deletar conta?',
              message: 'Tem certeza que deseja deletar "${account.name}"?',
              onConfirm: () {
                final auth = context.read<AuthProvider>();
                if (auth.authToken != null) {
                  accountProvider.removeAccount(auth.authToken!, account.id);
                }
                AppFeedbackSnackBar.error(context, 'Conta deletada');
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _getAccountIcon(String type) {
    switch (type) {
      case 'checking':
        return Icons.account_balance_outlined;
      case 'savings':
        return Icons.savings_outlined;
      case 'credit_card':
        return Icons.credit_card_outlined;
      default:
        return Icons.wallet_outlined;
    }
  }

  String _getAccountTypeLabel(String type) {
    switch (type) {
      case 'checking':
        return 'Conta Corrente';
      case 'savings':
        return 'Poupança';
      case 'credit_card':
        return 'Cartão de Crédito';
      default:
        return 'Outra';
    }
  }

  Widget _buildQuickActions() {
    // IntrinsicHeight iguala a altura dos dois cards se uma descricao quebrar
    // (texto ampliado ou tela estreita), como na home.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: QuickActionCard(
              icon: Icons.trending_up_rounded,
              title: 'Receitas',
              description: 'Ver entradas',
              tone: AppTone.green,
              onTap: () => Navigator.pushNamed(context, AppRoutes.income),
            ),
          ),
          const SizedBox(width: AppSpacing.itemGap),
          Expanded(
            child: QuickActionCard(
              icon: Icons.trending_down_rounded,
              title: 'Despesas',
              description: 'Ver saídas',
              tone: AppTone.red,
              onTap: () => Navigator.pushNamed(context, AppRoutes.expenses),
            ),
          ),
        ],
      ),
    );
  }
}
