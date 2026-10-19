import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/expense_provider.dart';
import '../providers/account_provider.dart';
import '../models/expense_model.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../theme/tokens/app_colors_semantic.dart';
import '../widgets/common/app_date_field.dart';
import '../widgets/common/app_feedback_snackbar.dart';
import '../widgets/common/app_form_dropdown.dart';
import '../widgets/common/app_form_field.dart';
import '../widgets/common/app_form_sheet.dart';
import '../widgets/common/app_module_scaffold.dart';
import '../widgets/common/app_primary_button.dart';
import '../widgets/common/app_segmented_tabs.dart';
import '../widgets/common/empty_state_card.dart';
import '../widgets/common/module_header_action.dart';
import '../widgets/common/module_screen_header.dart';
import '../widgets/common/section_header.dart';
import '../widgets/dialogs/app_confirm_dialog.dart';
import '../widgets/finance/finance_empty_art.dart';
import '../widgets/finance/finance_record_tile.dart';
import '../widgets/finance/finance_tone.dart';
import '../widgets/finance/month_selector.dart';
import '../widgets/finance/tip_card.dart';
import '../widgets/finance/tonal_summary_card.dart';

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
    _tabController = TabController(length: _expenseTypes.length, vsync: this);
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
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    });
    _reload();
  }

  void _nextMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    });
    _reload();
  }

  List<ExpenseModel> _filterExpenses(List<ExpenseModel> expenses, String type) {
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
        return expenses.where((e) => e.paymentMethod == 'credit_card').toList();
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
    int selectedCategoryId = 1; // Água (primeiro da lista)
    int? selectedAccountId;
    final outerContext = context;

    // Categories baseadas no seed-categories.js
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

    AppFormSheet.show(
      context: context,
      title: 'Nova Despesa',
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (innerContext, sheetSetState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppFormField(
                  controller: amountCtrl,
                  label: 'Valor',
                  hint: '0,00',
                  prefixText: 'R\$ ',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: AppSpacing.defaultGap),
                AppFormField(
                  controller: descCtrl,
                  label: 'Descrição',
                  hint: 'Ex: Conta de água',
                ),
                const SizedBox(height: AppSpacing.defaultGap),
                AppFormDropdown<int>(
                  label: 'Categoria',
                  value: selectedCategoryId,
                  onChanged: (v) =>
                      sheetSetState(() => selectedCategoryId = v!),
                  items: categories.entries
                      .map((e) =>
                          DropdownMenuItem(value: e.key, child: Text(e.value)))
                      .toList(),
                ),
                const SizedBox(height: AppSpacing.defaultGap),
                AppFormDropdown<String>(
                  label: 'Forma de Pagamento',
                  value: selectedPaymentMethod,
                  onChanged: (v) =>
                      sheetSetState(() => selectedPaymentMethod = v!),
                  items: const [
                    DropdownMenuItem(value: 'cash', child: Text('Dinheiro')),
                    DropdownMenuItem(
                        value: 'debit_card', child: Text('Cartão Débito')),
                    DropdownMenuItem(
                        value: 'credit_card', child: Text('Cartão Crédito')),
                    DropdownMenuItem(
                        value: 'transfer', child: Text('Transferência')),
                    DropdownMenuItem(value: 'other', child: Text('Outro')),
                  ],
                ),
                const SizedBox(height: AppSpacing.defaultGap),
                Consumer<AccountProvider>(
                  builder: (context, accountProvider, _) {
                    return AppFormDropdown<int?>(
                      label: 'Conta (opcional)',
                      value: selectedAccountId,
                      onChanged: (v) =>
                          sheetSetState(() => selectedAccountId = v),
                      items: [
                        const DropdownMenuItem(
                            value: null, child: Text('Nenhuma conta')),
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
                const SizedBox(height: AppSpacing.defaultGap),
                AppDateField(
                  label: 'Data',
                  value: selectedDate,
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
                ),
                const SizedBox(height: AppSpacing.blockGap),
                AppPrimaryButton(
                  label: 'Adicionar despesa',
                  onPressed: () {
                    final amountStr = amountCtrl.text.trim();
                    final description = descCtrl.text.trim();
                    if (amountStr.isEmpty || description.isEmpty) {
                      AppFeedbackSnackBar.error(
                          sheetContext, 'Preencha todos os campos');
                      return;
                    }
                    try {
                      final amount =
                          double.parse(amountStr.replaceAll(',', '.'));
                      final auth = outerContext.read<AuthProvider>();
                      final expenses = outerContext.read<ExpenseProvider>();
                      final accounts = outerContext.read<AccountProvider>();
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
                            .then((_) async {
                          if (!outerContext.mounted) return;
                          AppFeedbackSnackBar.success(
                              outerContext, 'Despesa adicionada!');
                          if (!sheetContext.mounted) return;
                          Navigator.pop(sheetContext);
                          // Navegar para /accounts para ver saldo atualizado
                          if (!outerContext.mounted) return;
                          Navigator.pushReplacementNamed(
                              outerContext, '/accounts');
                        });
                      }
                    } catch (_) {
                      AppFeedbackSnackBar.error(sheetContext, 'Valor inválido');
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

  void _showEditExpenseBottomSheet(ExpenseModel expense) {
    final descCtrl = TextEditingController(text: expense.description);
    final amountCtrl = TextEditingController(text: expense.amount.toString());
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

    AppFormSheet.show(
      context: context,
      title: 'Editar Despesa',
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (innerContext, sheetSetState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppFormField(
                  controller: amountCtrl,
                  label: 'Valor',
                  hint: '0,00',
                  prefixText: 'R\$ ',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: AppSpacing.defaultGap),
                AppFormField(controller: descCtrl, label: 'Descrição'),
                const SizedBox(height: AppSpacing.defaultGap),
                AppFormDropdown<int>(
                  label: 'Categoria',
                  value: selectedCategoryId,
                  onChanged: (v) =>
                      sheetSetState(() => selectedCategoryId = v!),
                  items: categories.entries
                      .map((e) =>
                          DropdownMenuItem(value: e.key, child: Text(e.value)))
                      .toList(),
                ),
                const SizedBox(height: AppSpacing.defaultGap),
                AppFormDropdown<String>(
                  label: 'Forma de Pagamento',
                  value: selectedPaymentMethod,
                  onChanged: (v) =>
                      sheetSetState(() => selectedPaymentMethod = v!),
                  items: const [
                    DropdownMenuItem(value: 'cash', child: Text('Dinheiro')),
                    DropdownMenuItem(
                        value: 'debit_card', child: Text('Cartão Débito')),
                    DropdownMenuItem(
                        value: 'credit_card', child: Text('Cartão Crédito')),
                    DropdownMenuItem(
                        value: 'transfer', child: Text('Transferência')),
                    DropdownMenuItem(value: 'other', child: Text('Outro')),
                  ],
                ),
                const SizedBox(height: AppSpacing.blockGap),
                AppPrimaryButton(
                  label: 'Salvar alterações',
                  onPressed: () {
                    final amountStr = amountCtrl.text.trim();
                    final description = descCtrl.text.trim();
                    if (amountStr.isEmpty || description.isEmpty) {
                      AppFeedbackSnackBar.error(
                          sheetContext, 'Preencha todos os campos');
                      return;
                    }
                    try {
                      final amount =
                          double.parse(amountStr.replaceAll(',', '.'));
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
                          AppFeedbackSnackBar.success(
                              outerContext, 'Despesa atualizada!');
                        });
                      }
                    } catch (_) {
                      AppFeedbackSnackBar.error(sheetContext, 'Valor inválido');
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
        title: 'Despesas',
        subtitle: 'Acompanhe seus gastos e mantenha o controle',
        onBack: () => Navigator.pop(context),
        actions: [
          ModuleHeaderAction(
            icon: Icons.trending_up_rounded,
            tooltip: 'Receitas',
            onPressed: () => Navigator.pushNamed(context, '/income'),
          ),
        ],
      ),
      topBar: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSegmentedTabs(
            controller: _tabController,
            labels: _expenseTypes,
          ),
          const SizedBox(height: AppSpacing.labelGap),
          MonthSelector(
            month: _selectedMonth,
            onPrevious: _previousMonth,
            onNext: _nextMonth,
          ),
        ],
      ),
      // Cada aba rola sozinha (TabBarView), como no legado.
      scrollable: false,
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddExpenseBottomSheet,
        tooltip: 'Adicionar despesa',
        child: const Icon(Icons.add),
      ),
      child: Consumer<ExpenseProvider>(
        builder: (context, expenseProvider, _) {
          return TabBarView(
            controller: _tabController,
            children: _expenseTypes.map((type) {
              final filtered = _filterExpenses(expenseProvider.expenses, type);
              final total =
                  filtered.fold<double>(0, (sum, e) => sum + e.amount);
              return _buildTabContent(filtered, total, type);
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildTabContent(
      List<ExpenseModel> expenses, double total, String type) {
    return ModuleScrollBody(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSummaryCard(total, expenses.length, type),
          const SizedBox(height: AppSpacing.blockGap),
          SectionHeader(
            title: type == 'Tudo' ? 'Todas as despesas' : type,
            count: expenses.length,
            accent: FinanceTone.expense.accent,
          ),
          const SizedBox(height: AppSpacing.itemGap),
          if (expenses.isEmpty) ...[
            _buildEmptyState(),
            const SizedBox(height: AppSpacing.blockGap),
            _buildTips(),
          ] else
            ...expenses.map((e) => _buildExpenseCard(e)),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(double total, int count, String type) {
    return TonalSummaryCard(
      tone: FinanceTone.expense,
      icon: Icons.trending_down_rounded,
      // O total e o da aba (filtrado), entao o rotulo diz de qual aba e.
      label:
          type == 'Tudo' ? 'Total de despesas no mês' : 'Total de $type no mês',
      value: 'R\$ ${total.toStringAsFixed(2).replaceAll('.', ',')}',
      caption: switch (count) {
        0 => 'Nenhuma despesa registrada',
        1 => '1 despesa registrada',
        _ => '$count despesas registradas',
      },
    );
  }

  Widget _buildExpenseCard(ExpenseModel expense) {
    return FinanceRecordTile(
      tone: FinanceTone.expense,
      icon: _getCategoryIcon(expense.categoryId),
      title: expense.description,
      subtitle: DateFormat('dd/MM/yyyy').format(expense.expenseDate),
      amount: 'R\$ ${expense.amount.toStringAsFixed(2).replaceAll('.', ',')}',
      actions: [
        IconButton(
          tooltip: 'Editar ${expense.description}',
          icon: const Icon(Icons.edit_outlined),
          color: AppSemanticColors.actionPrimary,
          onPressed: () => _showEditExpenseBottomSheet(expense),
        ),
        IconButton(
          tooltip: 'Remover ${expense.description}',
          icon: const Icon(Icons.delete_outline_rounded),
          color: AppSemanticColors.onFeedbackError,
          onPressed: () => AppConfirmDialog.show(
            context,
            title: 'Deletar despesa?',
            message: 'Tem certeza que deseja deletar "${expense.description}"?',
            onConfirm: () {
              final auth = context.read<AuthProvider>();
              if (auth.authToken != null) {
                context
                    .read<ExpenseProvider>()
                    .removeExpense(auth.authToken!, expense.id);
              }
              AppFeedbackSnackBar.error(context, 'Despesa deletada');
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return EmptyStateCard(
      art: const FinanceEmptyArt(tone: FinanceTone.expense),
      title: 'Nenhuma despesa neste mês',
      message:
          'Registre seus gastos para acompanhar para onde seu dinheiro está indo.',
      actionLabel: 'Adicionar despesa',
      onAction: _showAddExpenseBottomSheet,
      actionStyle: EmptyStateActionStyle.filled,
    );
  }

  Widget _buildTips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(
            'Dicas para começar',
            style: AppTypography.headlineSmall.copyWith(
              color: AppSemanticColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.itemGap),
        const TipCard(
          tone: FinanceTone.expense,
          title: 'Categorize seus gastos',
          message:
              'Use categorias para entender melhor seus hábitos e identificar oportunidades de economia.',
        ),
      ],
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
