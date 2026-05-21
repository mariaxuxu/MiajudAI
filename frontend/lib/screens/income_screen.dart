import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../config/constants.dart';
import '../providers/auth_provider.dart';
import '../providers/income_provider.dart';
import '../providers/account_provider.dart';
import '../models/income_model.dart';

class IncomeScreen extends StatefulWidget {
  const IncomeScreen({super.key});

  @override
  State<IncomeScreen> createState() => _IncomeScreenState();
}

class _IncomeScreenState extends State<IncomeScreen> {
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.authToken != null) {
        Provider.of<IncomeProvider>(context, listen: false).loadIncome(
          authProvider.authToken!,
          month: _selectedMonth.month,
          year: _selectedMonth.year,
        );
      }
    });
  }

  void _showAddIncomeBottomSheet() {
    final descriptionController = TextEditingController();
    final amountController = TextEditingController();
    String selectedType = 'salary';
    DateTime selectedDate = _selectedMonth;
    int? selectedAccountId;

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
                      'Nova Renda',
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: const Color(0xFF1B4965),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Valor',
                        hintText: 'Ex: 2500.00',
                        prefixText: 'R\$ ',
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
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Descrição',
                        hintText: 'Ex: Salário mensal',
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
                        labelText: 'Tipo de renda',
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
                        DropdownMenuItem(value: 'salary', child: Text('Salário')),
                        DropdownMenuItem(value: 'freelance', child: Text('Freelance')),
                        DropdownMenuItem(value: 'investment', child: Text('Investimento')),
                        DropdownMenuItem(value: 'gift', child: Text('Presente')),
                        DropdownMenuItem(value: 'other', child: Text('Outro')),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Consumer<AccountProvider>(
                      builder: (context, accountProvider, _) {
                        return DropdownButtonFormField<int?>(
                          initialValue: selectedAccountId,
                          onChanged: (value) {
                            setState(() {
                              selectedAccountId = value;
                            });
                          },
                          decoration: InputDecoration(
                            labelText: 'Conta (opcional)',
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
                          items: [
                            const DropdownMenuItem(value: null, child: Text('Nenhuma conta')),
                            ...accountProvider.accounts.map(
                              (account) => DropdownMenuItem(
                                value: account.id,
                                child: Text('${account.name} (R\$ ${account.balance.toStringAsFixed(2)})'),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2050),
                        );
                        if (date != null) {
                          setState(() {
                            selectedDate = date;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimens.paddingSmall,
                          vertical: AppDimens.paddingSmall,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFE8E8E8)),
                          borderRadius:
                              BorderRadius.circular(AppDimens.radiusDefault),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today,
                                color: const Color(0xFFFF8C00)),
                            const SizedBox(width: 12),
                            Text(
                              DateFormat('dd/MM/yyyy').format(selectedDate),
                              style: AppTextStyles.titleSmall.copyWith(
                                color: const Color(0xFF1B4965),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          final amountStr = amountController.text.trim();
                          final description = descriptionController.text.trim();

                          if (amountStr.isEmpty || description.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Preencha valor e descrição'),
                                backgroundColor: Color(0xFF1B4965),
                              ),
                            );
                            return;
                          }

                          try {
                            final amount = double.parse(amountStr);
                            final authProvider =
                                Provider.of<AuthProvider>(context, listen: false);
                            final incomeProvider =
                                Provider.of<IncomeProvider>(context, listen: false);
                            final accountProvider =
                                Provider.of<AccountProvider>(context, listen: false);

                            if (authProvider.authToken != null) {
                              incomeProvider.addIncome(
                                authProvider.authToken!,
                                amount,
                                description,
                                selectedType,
                                selectedDate,
                                selectedAccountId,
                                false,
                                null,
                              );

                              if (selectedAccountId != null) {
                                accountProvider.addToAccountBalance(selectedAccountId!, amount);
                              }

                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Renda adicionada!'),
                                  backgroundColor: Color(0xFF1B4965),
                                ),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Valor inválido'),
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
                          'Adicionar Renda',
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

  void _showEditIncomeBottomSheet(IncomeModel income) {
    final descriptionController = TextEditingController(text: income.description);
    final amountController = TextEditingController(text: income.amount.toString());
    String selectedType = income.type;
    DateTime selectedDate = income.incomeDate;

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
                      'Editar Renda',
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: const Color(0xFF1B4965),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Valor',
                        hintText: 'Ex: 2500.00',
                        prefixText: 'R\$ ',
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
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Descrição',
                        hintText: 'Ex: Salário mensal',
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
                        labelText: 'Tipo',
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
                        DropdownMenuItem(value: 'salary', child: Text('Salário')),
                        DropdownMenuItem(value: 'freelance', child: Text('Freelance')),
                        DropdownMenuItem(value: 'investment', child: Text('Investimento')),
                        DropdownMenuItem(value: 'gift', child: Text('Presente')),
                        DropdownMenuItem(value: 'other', child: Text('Outro')),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          final amountStr = amountController.text.trim();
                          final description = descriptionController.text.trim();
                          final messenger = ScaffoldMessenger.of(context);
                          final nav = Navigator.of(context);

                          if (amountStr.isEmpty || description.isEmpty) {
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('Preencha todos os campos'),
                                backgroundColor: Color(0xFF1B4965),
                              ),
                            );
                            return;
                          }

                          try {
                            final amount = double.parse(amountStr);
                            final authProvider =
                                Provider.of<AuthProvider>(context, listen: false);
                            final incomeProvider =
                                Provider.of<IncomeProvider>(context, listen: false);

                            if (authProvider.authToken != null) {
                              incomeProvider.updateIncome(
                                authProvider.authToken!,
                                income.id,
                                amount,
                                description,
                                selectedType,
                                selectedDate,
                              ).then((_) {
                                nav.pop();
                                messenger.showSnackBar(
                                  const SnackBar(
                                    content: Text('Renda atualizada!'),
                                    backgroundColor: Color(0xFF1B4965),
                                  ),
                                );
                              });
                            }
                          } catch (e) {
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('Valor inválido'),
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
                          'Salvar Alterações',
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

  void _showDeleteConfirmDialog(int incomeId, String description, double amount) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deletar renda?'),
        content: Text('Tem certeza que deseja deletar "$description"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              final incomeProvider =
                  Provider.of<IncomeProvider>(context, listen: false);

              if (authProvider.authToken != null) {
                incomeProvider.removeIncome(authProvider.authToken!, incomeId);
              }
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Renda deletada'),
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
          'Minhas Rendas',
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
            icon: const Icon(Icons.shopping_cart, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, '/expenses'),
            tooltip: 'Minhas Despesas',
          ),
        ],
      ),
      body: Consumer<IncomeProvider>(
        builder: (context, incomeProvider, _) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(AppDimens.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Monthly Total Card
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
                          '${DateFormat('MMMM', 'pt_BR').format(_selectedMonth)} de ${_selectedMonth.year}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'R\$ ${incomeProvider.monthlyTotal.toStringAsFixed(2).replaceAll('.', ',')}',
                          style: AppTextStyles.displaySmall.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimens.paddingLarge),
                  // Income List
                  if (incomeProvider.income.isEmpty)
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
                        'Nenhuma renda registrada',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  else
                    ...incomeProvider.income.map<Widget>((inc) {
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
                                color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(
                                    AppDimens.radiusMedium),
                              ),
                              child: Icon(
                                _getIncomeIcon(inc.type),
                                color: const Color(0xFF4CAF50),
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: AppDimens.paddingMedium),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    inc.description,
                                    style: AppTextStyles.titleSmall.copyWith(
                                      color: const Color(0xFF1B4965),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    DateFormat('dd/MM/yyyy').format(inc.incomeDate),
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
                                  'R\$ ${inc.amount.toStringAsFixed(2).replaceAll('.', ',')}',
                                  style: AppTextStyles.titleSmall.copyWith(
                                    color: const Color(0xFF4CAF50),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                PopupMenuButton(
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      child: const Text('Editar'),
                                      onTap: () {
                                        _showEditIncomeBottomSheet(inc);
                                      },
                                    ),
                                    PopupMenuItem(
                                      child: const Text('Deletar'),
                                      onTap: () {
                                        _showDeleteConfirmDialog(
                                            inc.id, inc.description, inc.amount);
                                      },
                                    ),
                                  ],
                                  child: const Icon(
                                    Icons.more_vert,
                                    color: Color(0xFF4CAF50),
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddIncomeBottomSheet,
        backgroundColor: const Color(0xFFFF8C00),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  IconData _getIncomeIcon(String type) {
    switch (type) {
      case 'salary':
        return Icons.payments;
      case 'freelance':
        return Icons.work;
      case 'investment':
        return Icons.trending_up;
      case 'gift':
        return Icons.card_giftcard;
      default:
        return Icons.monetization_on;
    }
  }
}
