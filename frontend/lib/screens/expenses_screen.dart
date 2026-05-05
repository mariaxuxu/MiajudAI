import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../config/constants.dart';
import '../providers/auth_provider.dart';
import '../providers/expense_provider.dart';
import '../providers/account_provider.dart';
import '../models/expense_model.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> with TickerProviderStateMixin {
  late DateTime _selectedMonth;
  late TabController _tabController;
  final List<String> _expenseTypes = ['Tudo', 'Contas Fixas', 'Variáveis', 'Cartão'];

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime.now();
    _tabController = TabController(length: _expenseTypes.length, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.authToken != null) {
        Provider.of<ExpenseProvider>(context, listen: false).loadExpenses(
          authProvider.authToken!,
          month: _selectedMonth.month,
          year: _selectedMonth.year,
        );
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<ExpenseModel> _filterExpensesByType(List<ExpenseModel> expenses, String type) {
    switch (type) {
      case 'Contas Fixas':
        return expenses.where((e) => [1, 2, 3, 4].contains(e.categoryId)).toList();
      case 'Variáveis':
        return expenses.where((e) => ![1, 2, 3, 4, 12].contains(e.categoryId) && e.paymentMethod != 'credit_card').toList();
      case 'Cartão':
        return expenses.where((e) => e.paymentMethod == 'credit_card').toList();
      default:
        return expenses;
    }
  }

  void _showAddExpenseBottomSheet() {
    final descriptionController = TextEditingController();
    final amountController = TextEditingController();
    String selectedPaymentMethod = 'cash';
    String selectedStatus = 'paid';
    DateTime selectedDate = _selectedMonth;
    int selectedCategoryId = 1;
    int? selectedAccountId;

    final categories = {
      1: 'Água',
      2: 'Luz',
      3: 'Internet',
      4: 'Aluguel',
      5: 'Alimentação',
      6: 'Transporte',
      7: 'Saúde',
      8: 'Educação',
      9: 'Diversão',
    };

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
                      'Nova Despesa',
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
                        hintText: 'Ex: 150.00',
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
                        hintText: 'Ex: Conta de água',
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
                    DropdownButtonFormField<int>(
                      initialValue: selectedCategoryId,
                      onChanged: (value) {
                        setState(() {
                          selectedCategoryId = value!;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Categoria',
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
                      items: categories.entries.map((e) {
                        return DropdownMenuItem(
                          value: e.key,
                          child: Text(e.value),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedPaymentMethod,
                      onChanged: (value) {
                        setState(() {
                          selectedPaymentMethod = value!;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Forma de Pagamento',
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
                        DropdownMenuItem(value: 'cash', child: Text('Dinheiro')),
                        DropdownMenuItem(value: 'debit_card', child: Text('Cartão Débito')),
                        DropdownMenuItem(value: 'credit_card', child: Text('Cartão Crédito')),
                        DropdownMenuItem(value: 'transfer', child: Text('Transferência')),
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
                            final expenseProvider =
                                Provider.of<ExpenseProvider>(context, listen: false);
                            final accountProvider =
                                Provider.of<AccountProvider>(context, listen: false);

                            if (authProvider.authToken != null) {
                              expenseProvider.addExpense(
                                authProvider.authToken!,
                                selectedCategoryId,
                                amount,
                                description,
                                selectedDate,
                                selectedAccountId,
                                selectedPaymentMethod,
                                selectedStatus,
                                false,
                                null,
                                null,
                              ).then((_) {
                                if (selectedAccountId != null) {
                                  accountProvider.subtractFromAccountBalance(selectedAccountId!, amount);
                                }
                                nav.pop();
                                messenger.showSnackBar(
                                  const SnackBar(
                                    content: Text('Despesa adicionada!'),
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
                          'Adicionar Despesa',
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

  void _showEditExpenseBottomSheet(ExpenseModel expense) {
    final descriptionController = TextEditingController(text: expense.description);
    final amountController = TextEditingController(text: expense.amount.toString());
    String selectedPaymentMethod = expense.paymentMethod;
    String selectedStatus = expense.status;
    DateTime selectedDate = expense.expenseDate;
    int selectedCategoryId = expense.categoryId;

    final categories = {
      1: 'Água',
      2: 'Luz',
      3: 'Internet',
      4: 'Aluguel',
      5: 'Alimentação',
      6: 'Transporte',
      7: 'Saúde',
      8: 'Educação',
      9: 'Diversão',
    };

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
                      'Editar Despesa',
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
                        hintText: 'Ex: 150.00',
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
                        hintText: 'Ex: Conta de água',
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
                    DropdownButtonFormField<int>(
                      initialValue: selectedCategoryId,
                      onChanged: (value) {
                        setState(() {
                          selectedCategoryId = value!;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Categoria',
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
                      items: categories.entries.map((e) {
                        return DropdownMenuItem(
                          value: e.key,
                          child: Text(e.value),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedPaymentMethod,
                      onChanged: (value) {
                        setState(() {
                          selectedPaymentMethod = value!;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Forma de Pagamento',
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
                        DropdownMenuItem(value: 'cash', child: Text('Dinheiro')),
                        DropdownMenuItem(value: 'debit_card', child: Text('Cartão Débito')),
                        DropdownMenuItem(value: 'credit_card', child: Text('Cartão Crédito')),
                        DropdownMenuItem(value: 'transfer', child: Text('Transferência')),
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
                            final expenseProvider =
                                Provider.of<ExpenseProvider>(context, listen: false);

                            if (authProvider.authToken != null) {
                              expenseProvider.updateExpense(
                                authProvider.authToken!,
                                expense.id,
                                selectedCategoryId,
                                amount,
                                description,
                                selectedDate,
                                selectedPaymentMethod,
                                selectedStatus,
                                null,
                              ).then((_) {
                                nav.pop();
                                messenger.showSnackBar(
                                  const SnackBar(
                                    content: Text('Despesa atualizada!'),
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

  void _showDeleteConfirmDialog(int expenseId, String description, double amount) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deletar despesa?'),
        content: Text('Tem certeza que deseja deletar "$description"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              final expenseProvider =
                  Provider.of<ExpenseProvider>(context, listen: false);

              if (authProvider.authToken != null) {
                expenseProvider.removeExpense(authProvider.authToken!, expenseId);
              }
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Despesa deletada'),
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
          'Minhas Despesas',
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
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: _expenseTypes.map((type) => Tab(text: type)).toList(),
          indicatorColor: const Color(0xFFFF8C00),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
        ),
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, expenseProvider, _) {
          return TabBarView(
            controller: _tabController,
            children: _expenseTypes.map((type) {
              final filteredExpenses = _filterExpensesByType(expenseProvider.expenses, type);
              final total = filteredExpenses.fold<double>(0, (sum, e) => sum + e.amount);

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimens.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
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
                              'Total Gasto',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'R\$ ${total.toStringAsFixed(2).replaceAll('.', ',')}',
                              style: AppTextStyles.displaySmall.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppDimens.paddingLarge),
                      if (filteredExpenses.isEmpty)
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
                            'Nenhuma despesa neste mês',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                      else
                        ...filteredExpenses.map<Widget>((expense) {
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
                                    color: const Color(0xFFE74C3C).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(
                                        AppDimens.radiusMedium),
                                  ),
                                  child: const Icon(
                                    Icons.shopping_cart,
                                    color: Color(0xFFE74C3C),
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: AppDimens.paddingMedium),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        expense.description,
                                        style: AppTextStyles.titleSmall.copyWith(
                                          color: const Color(0xFF1B4965),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        DateFormat('dd/MM/yyyy')
                                            .format(expense.expenseDate),
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
                                      'R\$ ${expense.amount.toStringAsFixed(2).replaceAll('.', ',')}',
                                      style: AppTextStyles.titleSmall.copyWith(
                                        color: const Color(0xFFE74C3C),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    PopupMenuButton(
                                      itemBuilder: (context) => [
                                        PopupMenuItem(
                                          child: const Text('Editar'),
                                          onTap: () {
                                            _showEditExpenseBottomSheet(expense);
                                          },
                                        ),
                                        PopupMenuItem(
                                          child: const Text('Deletar'),
                                          onTap: () {
                                            _showDeleteConfirmDialog(
                                                expense.id,
                                                expense.description,
                                                expense.amount);
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
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddExpenseBottomSheet,
        backgroundColor: const Color(0xFFFF8C00),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
