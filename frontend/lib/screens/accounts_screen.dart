import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/constants.dart';
import '../config/routes.dart';
import '../providers/auth_provider.dart';
import '../providers/account_provider.dart';

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
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.authToken != null) {
        Provider.of<AccountProvider>(context, listen: false)
            .loadAccounts(authProvider.authToken!);
      }
    });
  }

  void _showAddAccountBottomSheet() {
    final nameController = TextEditingController();
    final bankNameController = TextEditingController();
    final accountNumberController = TextEditingController();
    String selectedType = 'checking';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Nova Conta',
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: const Color(0xFF1B4965),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Nome da conta',
                        hintText: 'Ex: Minha Conta Corrente',
                        hintStyle: TextStyle(color: AppColors.textHint),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
                          borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
                          borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
                          borderSide: const BorderSide(
                            color: Color(0xFFFF8C00),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedType,
                      onChanged: (value) {
                        setState(() {
                          selectedType = value!;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Tipo de conta',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
                          borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
                          borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
                          borderSide: const BorderSide(
                            color: Color(0xFFFF8C00),
                            width: 2,
                          ),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'checking', child: Text('Conta Corrente')),
                        DropdownMenuItem(value: 'savings', child: Text('Poupança')),
                        DropdownMenuItem(value: 'credit_card', child: Text('Cartão de Crédito')),
                        DropdownMenuItem(value: 'other', child: Text('Outra')),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: bankNameController,
                      decoration: InputDecoration(
                        labelText: 'Banco (opcional)',
                        hintText: 'Ex: Banco do Brasil',
                        hintStyle: TextStyle(color: AppColors.textHint),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
                          borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
                          borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
                          borderSide: const BorderSide(
                            color: Color(0xFFFF8C00),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: accountNumberController,
                      decoration: InputDecoration(
                        labelText: 'Número da conta (opcional)',
                        hintText: 'Ex: 123456-7',
                        hintStyle: TextStyle(color: AppColors.textHint),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
                          borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
                          borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
                          borderSide: const BorderSide(
                            color: Color(0xFFFF8C00),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          final name = nameController.text.trim();
                          if (name.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Digite o nome da conta'),
                                backgroundColor: Color(0xFF1B4965),
                              ),
                            );
                            return;
                          }

                          final authProvider =
                              Provider.of<AuthProvider>(context, listen: false);
                          final accountProvider =
                              Provider.of<AccountProvider>(context, listen: false);

                          if (authProvider.authToken != null) {
                            accountProvider.addAccount(
                              authProvider.authToken!,
                              name,
                              selectedType,
                              bankNameController.text.isEmpty ? null : bankNameController.text,
                              accountNumberController.text.isEmpty
                                  ? null
                                  : accountNumberController.text,
                            );
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Conta criada!'),
                                backgroundColor: Color(0xFF1B4965),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF8C00),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppDimens.radiusDefault),
                          ),
                        ),
                        child: Text(
                          'Criar Conta',
                          style: AppTextStyles.titleSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmDialog(int accountId, String accountName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deletar conta?'),
        content: Text('Tem certeza que deseja deletar "$accountName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              final accountProvider =
                  Provider.of<AccountProvider>(context, listen: false);

              if (authProvider.authToken != null) {
                accountProvider.removeAccount(authProvider.authToken!, accountId);
              }
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Conta deletada'),
                  backgroundColor: AppColors.error,
                ),
              );
            },
            child: const Text(
              'Deletar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B4965),
        elevation: 0,
        title: const Text(
          'Minhas Contas',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.attach_money, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, '/income'),
            tooltip: 'Minhas Rendas',
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, '/expenses'),
            tooltip: 'Minhas Despesas',
          ),
        ],
      ),
      body: Consumer<AccountProvider>(
        builder: (context, accountProvider, _) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(AppDimens.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Total Balance Card
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B4965),
                      borderRadius: BorderRadius.circular(AppDimens.radiusLarge),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(AppDimens.paddingMedium),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Saldo Total',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'R\$ ${accountProvider.totalBalance.toStringAsFixed(2).replaceAll('.', ',')}',
                          style: AppTextStyles.displaySmall.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimens.paddingLarge),
                  // Accounts List
                  if (accountProvider.accounts.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(AppDimens.paddingMedium),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(AppDimens.radiusLarge),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        'Nenhuma conta cadastrada',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  else
                    ...accountProvider.accounts.map<Widget>((account) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(AppDimens.radiusLarge),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(AppDimens.paddingMedium),
                        child: Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF8C00).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(
                                    AppDimens.radiusMedium),
                              ),
                              child: Icon(
                                _getAccountIcon(account.type),
                                color: const Color(0xFFFF8C00),
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: AppDimens.paddingMedium),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    account.name,
                                    style: AppTextStyles.titleSmall.copyWith(
                                      color: const Color(0xFF1B4965),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _getAccountTypeLabel(account.type),
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.textSecondary,
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
                                  style: AppTextStyles.titleSmall.copyWith(
                                    color: const Color(0xFF1B4965),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                PopupMenuButton(
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      child: const Text('Deletar'),
                                      onTap: () {
                                        _showDeleteConfirmDialog(
                                            account.id, account.name);
                                      },
                                    ),
                                  ],
                                  child: const Icon(
                                    Icons.more_vert,
                                    color: Color(0xFFFF8C00),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'chat',
            onPressed: () => Navigator.pushNamed(context, AppRoutes.chat),
            backgroundColor: const Color(0xFFFF8C00),
            child: const Icon(Icons.smart_toy_outlined, color: Colors.white),
          ),
          const SizedBox(width: 12),
          FloatingActionButton(
            heroTag: 'add',
            onPressed: _showAddAccountBottomSheet,
            backgroundColor: const Color(0xFFFF8C00),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
    );
  }

  IconData _getAccountIcon(String type) {
    switch (type) {
      case 'checking':
        return Icons.account_balance;
      case 'savings':
        return Icons.savings;
      case 'credit_card':
        return Icons.credit_card;
      default:
        return Icons.wallet;
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
}
