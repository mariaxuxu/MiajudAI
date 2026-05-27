import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../config/constants.dart';
import '../providers/auth_provider.dart';
import '../providers/expense_provider.dart';
import '../providers/account_provider.dart';
import '../models/expense_model.dart';
import '../widgets/common/custom_button.dart';
import '../widgets/dialogs/delete_confirm_dialog.dart';
import '../utils/app_snackbar.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen>
    with TickerProviderStateMixin {
  late DateTime _selectedMonth;
  late TabController _tabController;
  final List<String> _expenseTypes = [
    'Tudo',
    'Contas Fixas',
    'Variáveis',
    'Cartão',
  ];

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime.now();
    _tabController =
        TabController(length: _expenseTypes.length, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _reload());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _reload() {
    final auth = context.read<AuthProvider>();
    if (auth.authToken != null) {
      context.read<ExpenseProvider>().loadExpenses(
        auth.authToken!,
        month: _selectedMonth.month,
        year: _selectedMonth.year,
      );
    }
  }

  void _previousMonth() {
    setState(() {
      _selectedMonth =
          DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    });
    _reload();
  }

  void _nextMonth() {
    setState(() {
      _selectedMonth =
          DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    });
    _reload();
  }

  static InputDecoration _inputDecoration(String label,
          {String? hint, String? prefix}) =>
      InputDecoration(
        labelText: label,
        hintText: hint,
        prefixText: prefix,
        labelStyle:
            const TextStyle(color: AppColors.textLabel, fontSize: 14),
      );

  List<ExpenseModel> _filterExpenses(
      List<ExpenseModel> expenses, String type) {
    switch (type) {
      case 'Contas Fixas':
        return expenses
            .where((e) => [1, 2, 3, 4].contains(e.categoryId))
            .toList();
      case 'Variáveis':
        return expenses
            .where((e) =>
                ![1, 2, 3, 4, 12].contains(e.categoryId) &&
                e.paymentMethod != 'credit_card')
            .toList();
      case 'Cartão':
        return expenses
            .where((e) => e.paymentMethod == 'credit_card')
            .toList();
      default:
        return expenses;
    }
  }

  void _showAddExpenseBottomSheet() {
    final descCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    String selectedPaymentMethod = 'cash';
    String selectedStatus = 'paid';
    DateTime selectedDate = _selectedMonth;
    int selectedCategoryId = 1;
    int? selectedAccountId;
    final outerContext = context;

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
                    'Nova Despesa',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: amountCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    style: const TextStyle(
                        color: AppColors.textDark, fontSize: 15),
                    decoration: _inputDecoration('Valor',
                        hint: '0,00', prefix: 'R\$ '),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: descCtrl,
                    style: const TextStyle(
                        color: AppColors.textDark, fontSize: 15),
                    decoration: _inputDecoration('Descrição',
                        hint: 'Ex: Conta de água'),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<int>(
                    value: selectedCategoryId,
                    onChanged: (v) =>
                        sheetSetState(() => selectedCategoryId = v!),
                    decoration: _inputDecoration('Categoria'),
                    style: const TextStyle(
                        color: AppColors.textDark, fontSize: 15),
                    items: categories.entries
                        .map((e) => DropdownMenuItem(
                            value: e.key, child: Text(e.value)))
                        .toList(),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    value: selectedPaymentMethod,
                    onChanged: (v) =>
                        sheetSetState(() => selectedPaymentMethod = v!),
                    decoration:
                        _inputDecoration('Forma de Pagamento'),
                    style: const TextStyle(
                        color: AppColors.textDark, fontSize: 15),
                    items: const [
                      DropdownMenuItem(
                          value: 'cash', child: Text('Dinheiro')),
                      DropdownMenuItem(
                          value: 'debit_card',
                          child: Text('Cartão Débito')),
                      DropdownMenuItem(
                          value: 'credit_card',
                          child: Text('Cartão Crédito')),
                      DropdownMenuItem(
                          value: 'transfer',
                          child: Text('Transferência')),
                      DropdownMenuItem(
                          value: 'other', child: Text('Outro')),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Consumer<AccountProvider>(
                    builder: (context, accountProvider, _) {
                      return DropdownButtonFormField<int?>(
                        value: selectedAccountId,
                        onChanged: (v) =>
                            sheetSetState(() => selectedAccountId = v),
                        decoration:
                            _inputDecoration('Conta (opcional)'),
                        style: const TextStyle(
                            color: AppColors.textDark, fontSize: 15),
                        items: [
                          const DropdownMenuItem(
                              value: null,
                              child: Text('Nenhuma conta')),
                          ...accountProvider.accounts.map(
                            (a) => DropdownMenuItem(
                              value: a.id,
                              child: Text(
                                  '${a.name} (R\$ ${a.balance.toStringAsFixed(2)})'),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: innerContext,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2050),
                      );
                      if (date != null) {
                        sheetSetState(() => selectedDate = date);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.inputFill,
                        border:
                            Border.all(color: AppColors.inputBorder),
                        borderRadius: BorderRadius.circular(
                            AppDimens.radiusInput),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            color: AppColors.textLabel,
                            size: 18,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            DateFormat('dd/MM/yyyy')
                                .format(selectedDate),
                            style: const TextStyle(
                              color: AppColors.textDark,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: 'Adicionar despesa',
                    onPressed: () {
                      final amountStr = amountCtrl.text.trim();
                      final description = descCtrl.text.trim();
                      if (amountStr.isEmpty || description.isEmpty) {
                        AppSnackBar.error(sheetContext,
                            'Preencha todos os campos');
                        return;
                      }
                      try {
                        final amount = double.parse(
                            amountStr.replaceAll(',', '.'));
                        final auth = outerContext.read<AuthProvider>();
                        final expenses =
                            outerContext.read<ExpenseProvider>();
                        final accounts =
                            outerContext.read<AccountProvider>();
                        if (auth.authToken != null) {
                          expenses
                              .addExpense(
                            auth.authToken!,
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
                          )
                              .then((_) {
                            if (selectedAccountId != null) {
                              accounts.subtractFromAccountBalance(
                                  selectedAccountId!, amount);
                            }
                            if (!sheetContext.mounted) return;
                            Navigator.pop(sheetContext);
                            if (!outerContext.mounted) return;
                            AppSnackBar.success(
                                outerContext, 'Despesa adicionada!');
                          });
                        }
                      } catch (_) {
                        AppSnackBar.error(sheetContext, 'Valor inválido');
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

  void _showEditExpenseBottomSheet(ExpenseModel expense) {
    final descCtrl =
        TextEditingController(text: expense.description);
    final amountCtrl =
        TextEditingController(text: expense.amount.toString());
    String selectedPaymentMethod = expense.paymentMethod;
    String selectedStatus = expense.status;
    DateTime selectedDate = expense.expenseDate;
    int selectedCategoryId = expense.categoryId;
    final outerContext = context;

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
                    'Editar Despesa',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: amountCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    style: const TextStyle(
                        color: AppColors.textDark, fontSize: 15),
                    decoration: _inputDecoration('Valor',
                        hint: '0,00', prefix: 'R\$ '),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: descCtrl,
                    style: const TextStyle(
                        color: AppColors.textDark, fontSize: 15),
                    decoration: _inputDecoration('Descrição'),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<int>(
                    value: selectedCategoryId,
                    onChanged: (v) =>
                        sheetSetState(() => selectedCategoryId = v!),
                    decoration: _inputDecoration('Categoria'),
                    style: const TextStyle(
                        color: AppColors.textDark, fontSize: 15),
                    items: categories.entries
                        .map((e) => DropdownMenuItem(
                            value: e.key, child: Text(e.value)))
                        .toList(),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    value: selectedPaymentMethod,
                    onChanged: (v) =>
                        sheetSetState(() => selectedPaymentMethod = v!),
                    decoration:
                        _inputDecoration('Forma de Pagamento'),
                    style: const TextStyle(
                        color: AppColors.textDark, fontSize: 15),
                    items: const [
                      DropdownMenuItem(
                          value: 'cash', child: Text('Dinheiro')),
                      DropdownMenuItem(
                          value: 'debit_card',
                          child: Text('Cartão Débito')),
                      DropdownMenuItem(
                          value: 'credit_card',
                          child: Text('Cartão Crédito')),
                      DropdownMenuItem(
                          value: 'transfer',
                          child: Text('Transferência')),
                      DropdownMenuItem(
                          value: 'other', child: Text('Outro')),
                    ],
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: 'Salvar alterações',
                    onPressed: () {
                      final amountStr = amountCtrl.text.trim();
                      final description = descCtrl.text.trim();
                      if (amountStr.isEmpty || description.isEmpty) {
                        AppSnackBar.error(
                            sheetContext, 'Preencha todos os campos');
                        return;
                      }
                      try {
                        final amount = double.parse(
                            amountStr.replaceAll(',', '.'));
                        final auth = outerContext.read<AuthProvider>();
                        final expenseProvider =
                            outerContext.read<ExpenseProvider>();
                        if (auth.authToken != null) {
                          expenseProvider
                              .updateExpense(
                            auth.authToken!,
                            expense.id,
                            selectedCategoryId,
                            amount,
                            description,
                            selectedDate,
                            selectedPaymentMethod,
                            selectedStatus,
                            null,
                          )
                              .then((_) {
                            if (!sheetContext.mounted) return;
                            Navigator.pop(sheetContext);
                            if (!outerContext.mounted) return;
                            AppSnackBar.success(
                                outerContext, 'Despesa atualizada!');
                          });
                        }
                      } catch (_) {
                        AppSnackBar.error(sheetContext, 'Valor inválido');
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
          'Despesas',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.trending_up_rounded,
                color: Colors.white, size: 22),
            onPressed: () => Navigator.pushNamed(context, '/income'),
            tooltip: 'Receitas',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs:
              _expenseTypes.map((t) => Tab(text: t)).toList(),
          indicatorColor: AppColors.accent,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 13),
        ),
      ),
      body: Column(
        children: [
          _buildMonthNavigator(),
          Expanded(
            child: Consumer<ExpenseProvider>(
              builder: (context, expenseProvider, _) {
                return TabBarView(
                  controller: _tabController,
                  children: _expenseTypes.map((type) {
                    final filtered =
                        _filterExpenses(expenseProvider.expenses, type);
                    final total = filtered.fold<double>(
                        0, (sum, e) => sum + e.amount);
                    return _buildTabContent(filtered, total, type);
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddExpenseBottomSheet,
        backgroundColor: AppColors.error,
        elevation: 2,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildMonthNavigator() {
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: _previousMonth,
            child: Icon(
              Icons.chevron_left_rounded,
              color: Colors.white.withValues(alpha: 0.80),
              size: 26,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            DateFormat("MMMM 'de' y", 'pt_BR').format(_selectedMonth),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.90),
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _nextMonth,
            child: Icon(
              Icons.chevron_right_rounded,
              color: Colors.white.withValues(alpha: 0.80),
              size: 26,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(
      List<ExpenseModel> expenses, double total, String type) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(AppDimens.paddingDefault),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSummaryCard(total),
          const SizedBox(height: 20),
          _buildSectionHeader(type, expenses.length),
          const SizedBox(height: 12),
          if (expenses.isEmpty)
            _buildEmptyState()
          else
            ...expenses.map((e) => _buildExpenseCard(e)),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(double total) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.error, Color(0xFFDC2626)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        boxShadow: [
          BoxShadow(
            color: AppColors.error.withValues(alpha: 0.22),
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
                'Total gasto',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.80),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.receipt_outlined,
                color: Colors.white.withValues(alpha: 0.55),
                size: 16,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'R\$ ${total.toStringAsFixed(2).replaceAll('.', ',')}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
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
            color: AppColors.error,
            borderRadius: BorderRadius.circular(AppDimens.radiusFull),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title == 'Tudo' ? 'Todas as despesas' : title,
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
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.10),
              borderRadius:
                  BorderRadius.circular(AppDimens.radiusFull),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildExpenseCard(ExpenseModel expense) {
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
              color: AppColors.error.withValues(alpha: 0.08),
              borderRadius:
                  BorderRadius.circular(AppDimens.radiusMedium),
            ),
            child: Icon(
              _getCategoryIcon(expense.categoryId),
              color: AppColors.error,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.description,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                    letterSpacing: -0.1,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  DateFormat('dd/MM/yyyy').format(expense.expenseDate),
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
                'R\$ ${expense.amount.toStringAsFixed(2).replaceAll('.', ',')}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.error,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  GestureDetector(
                    onTap: () =>
                        _showEditExpenseBottomSheet(expense),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary
                            .withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(
                            AppDimens.radiusFull),
                      ),
                      child: const Text(
                        'Editar',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => DeleteConfirmDialog.show(
                      context,
                      title: 'Deletar despesa?',
                      message:
                          'Tem certeza que deseja deletar "${expense.description}"?',
                      onConfirm: () {
                        final auth = context.read<AuthProvider>();
                        if (auth.authToken != null) {
                          context
                              .read<ExpenseProvider>()
                              .removeExpense(
                                  auth.authToken!, expense.id);
                        }
                        AppSnackBar.error(
                            context, 'Despesa deletada');
                      },
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.error
                            .withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(
                            AppDimens.radiusFull),
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
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
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
      child: const Column(
        children: [
          Icon(Icons.receipt_long_outlined,
              size: 40, color: AppColors.textSecondary),
          SizedBox(height: 10),
          Text(
            'Nenhuma despesa neste mês',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Adicione suas despesas para acompanhar seus gastos',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textLabel,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(int categoryId) {
    switch (categoryId) {
      case 1:
        return Icons.water_drop_outlined;
      case 2:
        return Icons.bolt_outlined;
      case 3:
        return Icons.wifi_outlined;
      case 4:
        return Icons.home_outlined;
      case 5:
        return Icons.restaurant_outlined;
      case 6:
        return Icons.directions_car_outlined;
      case 7:
        return Icons.favorite_border_rounded;
      case 8:
        return Icons.school_outlined;
      case 9:
        return Icons.sports_esports_outlined;
      default:
        return Icons.receipt_outlined;
    }
  }
}
