import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/income_provider.dart';
import '../providers/account_provider.dart';
import '../models/income_model.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) => _reload());
  }

  void _reload() {
    final auth = context.read<AuthProvider>();
    if (auth.authToken != null) {
      context.read<IncomeProvider>().loadIncome(
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

  void _showAddIncomeBottomSheet() {
    final descCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    String selectedType = 'salary';
    DateTime selectedDate = _selectedMonth;
    int? selectedAccountId;
    final outerContext = context;

    AppFormSheet.show(
      context: context,
      title: 'Nova Receita',
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
                  hint: 'Ex: Salário mensal',
                ),
                const SizedBox(height: AppSpacing.defaultGap),
                AppFormDropdown<String>(
                  label: 'Tipo de receita',
                  value: selectedType,
                  onChanged: (v) => sheetSetState(() => selectedType = v!),
                  items: const [
                    DropdownMenuItem(value: 'salary', child: Text('Salário')),
                    DropdownMenuItem(
                        value: 'freelance', child: Text('Freelance')),
                    DropdownMenuItem(
                        value: 'investment', child: Text('Investimento')),
                    DropdownMenuItem(value: 'gift', child: Text('Presente')),
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
                  label: 'Adicionar receita',
                  onPressed: () {
                    final amountStr = amountCtrl.text.trim();
                    final description = descCtrl.text.trim();
                    if (amountStr.isEmpty || description.isEmpty) {
                      AppFeedbackSnackBar.error(
                          sheetContext, 'Preencha valor e descrição');
                      return;
                    }
                    try {
                      final amount =
                          double.parse(amountStr.replaceAll(',', '.'));
                      final auth = outerContext.read<AuthProvider>();
                      final income = outerContext.read<IncomeProvider>();
                      final accounts = outerContext.read<AccountProvider>();
                      if (auth.authToken != null) {
                        income
                            .addIncome(
                          auth.authToken!,
                          amount,
                          description,
                          selectedType,
                          selectedDate,
                          selectedAccountId,
                          false,
                          null,
                        )
                            .then((_) {
                          if (!outerContext.mounted) return;
                          AppFeedbackSnackBar.success(
                              outerContext, 'Receita adicionada!');
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

  void _showEditIncomeBottomSheet(IncomeModel income) {
    final descCtrl = TextEditingController(text: income.description);
    final amountCtrl = TextEditingController(text: income.amount.toString());
    String selectedType = income.type;
    DateTime selectedDate = income.incomeDate;
    final outerContext = context;

    AppFormSheet.show(
      context: context,
      title: 'Editar Receita',
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
                AppFormDropdown<String>(
                  label: 'Tipo',
                  value: selectedType,
                  onChanged: (v) => sheetSetState(() => selectedType = v!),
                  items: const [
                    DropdownMenuItem(value: 'salary', child: Text('Salário')),
                    DropdownMenuItem(
                        value: 'freelance', child: Text('Freelance')),
                    DropdownMenuItem(
                        value: 'investment', child: Text('Investimento')),
                    DropdownMenuItem(value: 'gift', child: Text('Presente')),
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
                      final incomeProvider =
                          outerContext.read<IncomeProvider>();
                      if (auth.authToken != null) {
                        incomeProvider
                            .updateIncome(
                          auth.authToken!,
                          income.id,
                          amount,
                          description,
                          selectedType,
                          selectedDate,
                        )
                            .then((_) {
                          if (!sheetContext.mounted) return;
                          Navigator.pop(sheetContext);
                          if (!outerContext.mounted) return;
                          AppFeedbackSnackBar.success(
                              outerContext, 'Receita atualizada!');
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
        title: 'Receitas',
        subtitle: 'Acompanhe suas entradas de dinheiro',
        onBack: () => Navigator.pop(context),
        actions: [
          ModuleHeaderAction(
            icon: Icons.trending_down_rounded,
            tooltip: 'Despesas',
            onPressed: () => Navigator.pushNamed(context, '/expenses'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddIncomeBottomSheet,
        tooltip: 'Adicionar receita',
        child: const Icon(Icons.add),
      ),
      child: Consumer<IncomeProvider>(
        builder: (context, incomeProvider, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MonthSelector(
                month: _selectedMonth,
                onPrevious: _previousMonth,
                onNext: _nextMonth,
              ),
              const SizedBox(height: AppSpacing.defaultGap),
              _buildSummaryCard(incomeProvider),
              const SizedBox(height: AppSpacing.blockGap),
              SectionHeader(
                title: 'Registros',
                count: incomeProvider.income.length,
                accent: FinanceTone.income.accent,
              ),
              const SizedBox(height: AppSpacing.itemGap),
              if (incomeProvider.income.isEmpty) ...[
                _buildEmptyState(),
                const SizedBox(height: AppSpacing.blockGap),
                _buildTips(),
              ] else
                ...incomeProvider.income.map((inc) => _buildIncomeCard(inc)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(IncomeProvider incomeProvider) {
    final count = incomeProvider.income.length;

    return TonalSummaryCard(
      tone: FinanceTone.income,
      icon: Icons.trending_up_rounded,
      label: 'Total de receitas no mês',
      value:
          'R\$ ${incomeProvider.monthlyTotal.toStringAsFixed(2).replaceAll('.', ',')}',
      caption: switch (count) {
        0 => 'Nenhuma receita registrada',
        1 => '1 receita registrada',
        _ => '$count receitas registradas',
      },
    );
  }

  Widget _buildIncomeCard(IncomeModel inc) {
    return FinanceRecordTile(
      tone: FinanceTone.income,
      icon: _getIncomeIcon(inc.type),
      title: inc.description,
      subtitle: DateFormat('dd/MM/yyyy').format(inc.incomeDate),
      amount: 'R\$ ${inc.amount.toStringAsFixed(2).replaceAll('.', ',')}',
      actions: [
        IconButton(
          tooltip: 'Editar ${inc.description}',
          icon: const Icon(Icons.edit_outlined),
          color: AppSemanticColors.actionPrimary,
          onPressed: () => _showEditIncomeBottomSheet(inc),
        ),
        IconButton(
          tooltip: 'Remover ${inc.description}',
          icon: const Icon(Icons.delete_outline_rounded),
          color: AppSemanticColors.onFeedbackError,
          onPressed: () => AppConfirmDialog.show(
            context,
            title: 'Deletar receita?',
            message: 'Tem certeza que deseja deletar "${inc.description}"?',
            onConfirm: () {
              final auth = context.read<AuthProvider>();
              if (auth.authToken != null) {
                context
                    .read<IncomeProvider>()
                    .removeIncome(auth.authToken!, inc.id);
              }
              AppFeedbackSnackBar.error(context, 'Receita deletada');
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return EmptyStateCard(
      art: const FinanceEmptyArt(tone: FinanceTone.income),
      title: 'Nenhuma receita registrada',
      message:
          'Adicione suas fontes de renda para acompanhar seu progresso financeiro.',
      actionLabel: 'Adicionar receita',
      onAction: _showAddIncomeBottomSheet,
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
          tone: FinanceTone.income,
          title: 'Registre suas fontes de renda',
          message:
              'Salário, freelas, investimentos... mantenha tudo organizado em um só lugar.',
        ),
      ],
    );
  }

  IconData _getIncomeIcon(String type) {
    switch (type) {
      case 'salary':
        return Icons.payments_outlined;
      case 'freelance':
        return Icons.work_outline_rounded;
      case 'investment':
        return Icons.trending_up_rounded;
      case 'gift':
        return Icons.card_giftcard_outlined;
      default:
        return Icons.monetization_on_outlined;
    }
  }
}
