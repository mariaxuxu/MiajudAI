import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../config/constants.dart';
import '../config/routes.dart';
import '../providers/auth_provider.dart';
import '../providers/account_provider.dart';
import '../widgets/common/custom_button.dart';
import '../widgets/dialogs/delete_confirm_dialog.dart';
import '../utils/app_snackbar.dart';

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

  static InputDecoration _inputDecoration(String label, {String? hint}) =>
      InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: AppColors.textLabel, fontSize: 14),
      );

  void _showAddAccountBottomSheet() {
    final nameCtrl = TextEditingController();
    final bankCtrl = TextEditingController();
    final numberCtrl = TextEditingController();
    String selectedType = 'checking';
    final outerContext = context;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimens.radiusHeroCard),
        ),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (innerContext, sheetSetState) {
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                24, 16, 24,
                MediaQuery.of(sheetContext).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.inputBorder,
                        borderRadius:
                            BorderRadius.circular(AppDimens.radiusFull),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Nova Conta',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: nameCtrl,
                    style: const TextStyle(
                        color: AppColors.textDark, fontSize: 15),
                    decoration: _inputDecoration(
                      'Nome da conta',
                      hint: 'Ex: Conta Corrente Nubank',
                    ),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    onChanged: (v) =>
                        sheetSetState(() => selectedType = v!),
                    decoration: _inputDecoration('Tipo de conta'),
                    style: const TextStyle(
                        color: AppColors.textDark, fontSize: 15),
                    items: const [
                      DropdownMenuItem(
                          value: 'checking',
                          child: Text('Conta Corrente')),
                      DropdownMenuItem(
                          value: 'savings',
                          child: Text('Poupança')),
                      DropdownMenuItem(
                          value: 'credit_card',
                          child: Text('Cartão de Crédito')),
                      DropdownMenuItem(
                          value: 'other', child: Text('Outra')),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: bankCtrl,
                    style: const TextStyle(
                        color: AppColors.textDark, fontSize: 15),
                    decoration: _inputDecoration(
                      'Banco (opcional)',
                      hint: 'Ex: Nubank',
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: numberCtrl,
                    style: const TextStyle(
                        color: AppColors.textDark, fontSize: 15),
                    decoration: _inputDecoration(
                      'Número da conta (opcional)',
                      hint: 'Ex: 123456-7',
                    ),
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: 'Criar conta',
                    onPressed: () {
                      final name = nameCtrl.text.trim();
                      if (name.isEmpty) {
                        AppSnackBar.error(
                            sheetContext, 'Digite o nome da conta');
                        return;
                      }
                      final auth = outerContext.read<AuthProvider>();
                      final accounts =
                          outerContext.read<AccountProvider>();
                      if (auth.authToken != null) {
                        accounts.addAccount(
                          auth.authToken!,
                          name,
                          selectedType,
                          bankCtrl.text.isEmpty ? null : bankCtrl.text,
                          numberCtrl.text.isEmpty
                              ? null
                              : numberCtrl.text,
                        );
                        Navigator.pop(sheetContext);
                        AppSnackBar.success(outerContext, 'Conta criada!');
                      }
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Finanças',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: Consumer<AccountProvider>(
        builder: (context, accountProvider, _) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(AppDimens.paddingDefault),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildBalanceCard(accountProvider),
                const SizedBox(height: 16),
                _buildQuickActions(),
                const SizedBox(height: 24),
                _buildSectionHeader(
                  'Minhas contas',
                  accountProvider.accounts.length,
                ),
                const SizedBox(height: 12),
                if (accountProvider.accounts.isEmpty)
                  _buildEmptyState(
                    icon: Icons.account_balance_outlined,
                    message: 'Nenhuma conta cadastrada',
                    subtitle:
                        'Adicione uma conta para começar a gerenciar suas finanças',
                  )
                else
                  ...accountProvider.accounts
                      .map((a) => _buildAccountCard(a, accountProvider)),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddAccountBottomSheet,
        backgroundColor: AppColors.accent,
        elevation: 2,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBalanceCard(AccountProvider accountProvider) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDeep],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Saldo Total',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.80),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.account_balance_wallet_outlined,
                color: Colors.white.withValues(alpha: 0.55),
                size: 16,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'R\$ ${accountProvider.totalBalance.toStringAsFixed(2).replaceAll('.', ',')}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${accountProvider.accounts.length} conta${accountProvider.accounts.length != 1 ? 's' : ''}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.60),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(AppDimens.radiusFull),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
            letterSpacing: -0.2,
          ),
        ),
        if (count > 0) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppDimens.radiusFull),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.accent,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAccountCard(dynamic account, AccountProvider accountProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.09),
              borderRadius:
                  BorderRadius.circular(AppDimens.radiusMedium),
            ),
            child: Icon(
              _getAccountIcon(account.type),
              color: AppColors.accent,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  account.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                    letterSpacing: -0.1,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _getAccountTypeLabel(account.type),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textLabel,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'R\$ ${account.balance.toStringAsFixed(2).replaceAll('.', ',')}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () => DeleteConfirmDialog.show(
                  context,
                  title: 'Deletar conta?',
                  message:
                      'Tem certeza que deseja deletar "${account.name}"?',
                  onConfirm: () {
                    final auth = context.read<AuthProvider>();
                    if (auth.authToken != null) {
                      accountProvider.removeAccount(
                          auth.authToken!, account.id);
                    }
                    AppSnackBar.error(context, 'Conta deletada');
                  },
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.08),
                    borderRadius:
                        BorderRadius.circular(AppDimens.radiusFull),
                  ),
                  child: const Text(
                    'Remover',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.error,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
    String? subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: AppColors.textSecondary),
          const SizedBox(height: 10),
          Text(
            message,
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textLabel,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
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
    return Row(
      children: [
        Expanded(
          child: _QuickActionCard(
            icon: Icons.trending_up_rounded,
            label: 'Receitas',
            subtitle: 'Ver entradas',
            color: AppColors.success,
            onTap: () => Navigator.pushNamed(context, AppRoutes.income),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionCard(
            icon: Icons.trending_down_rounded,
            label: 'Despesas',
            subtitle: 'Ver saídas',
            color: AppColors.error,
            onTap: () => Navigator.pushNamed(context, AppRoutes.expenses),
          ),
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  State<_QuickActionCard> createState() => _QuickActionCardState();
}

class _QuickActionCardState extends State<_QuickActionCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: _pressed
                ? widget.color.withValues(alpha: 0.06)
                : Colors.white,
            borderRadius: BorderRadius.circular(AppDimens.radiusCard),
            border: Border.all(
              color: widget.color.withValues(alpha: _pressed ? 0.35 : 0.18),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _pressed ? 0.03 : 0.06),
                blurRadius: _pressed ? 6 : 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
                ),
                child: Icon(widget.icon, color: widget.color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: widget.color,
                        letterSpacing: -0.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textLabel,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: widget.color.withValues(alpha: 0.6),
                size: 12,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
