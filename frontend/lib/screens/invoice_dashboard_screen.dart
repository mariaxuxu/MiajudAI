import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/installment_provider.dart';
import '../providers/fixed_cost_provider.dart';
import '../models/installment_model.dart';
import '../models/fixed_cost_model.dart';
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
import '../widgets/common/app_underline_tabs.dart';
import '../widgets/common/empty_state_card.dart';
import '../widgets/common/module_screen_header.dart';
import '../widgets/common/section_header.dart';
import '../widgets/dialogs/app_confirm_dialog.dart';
import '../widgets/finance/balance_hero_card.dart';
import '../widgets/finance/finance_empty_art.dart';
import '../widgets/finance/finance_metric_card.dart';
import '../widgets/finance/finance_record_tile.dart';
import '../widgets/finance/finance_tone.dart';
import '../widgets/finance/hero_month_switcher.dart';
import '../widgets/finance/tip_card.dart';
import '../widgets/finance/tonal_summary_card.dart';

class InvoiceDashboardScreen extends StatefulWidget {
  const InvoiceDashboardScreen({super.key});

  @override
  State<InvoiceDashboardScreen> createState() => _InvoiceDashboardScreenState();
}

class _InvoiceDashboardScreenState extends State<InvoiceDashboardScreen>
    with TickerProviderStateMixin {
  late DateTime _selectedDate;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.authToken != null) {
        context.read<InstallmentProvider>().loadInstallments(auth.authToken!);
        context.read<FixedCostProvider>().loadFixedCosts(auth.authToken!);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _previousMonth() {
    setState(() =>
        _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1));
  }

  void _nextMonth() {
    setState(() =>
        _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1));
  }

  Widget _buildAccountsTab(
      InstallmentProvider instProvider, FixedCostProvider fixedProvider) {
    final installments =
        _getActiveInstallmentsForMonth(instProvider, _selectedDate);
    final fixedCosts = _getFixedCostsForMonth(fixedProvider, _selectedDate);

    return ModuleScrollBody(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSectionHeader('Parcelas', installments.length),
          const SizedBox(height: AppSpacing.itemGap),
          if (installments.isEmpty)
            _buildInstallmentsEmptyState()
          else
            ...installments.map((inst) => _buildInstallmentCard(context, inst)),
          const SizedBox(height: AppSpacing.blockGap),
          _buildSectionHeader('Gastos Fixos', fixedCosts.length),
          const SizedBox(height: AppSpacing.itemGap),
          if (fixedCosts.isEmpty)
            _buildFixedCostsEmptyState()
          else
            ...fixedCosts.map((cost) => _buildFixedCostCard(context, cost)),
        ],
      ),
    );
  }

  Widget _buildDashboardTab(
      InstallmentProvider instProvider, FixedCostProvider fixedProvider) {
    final installmentTotal = instProvider.getMonthlyTotal(_selectedDate);
    final fixedCostTotal = fixedProvider.getMonthlyTotal(_selectedDate);
    final totalMonth = installmentTotal + fixedCostTotal;
    final installmentCount =
        _getActiveInstallmentsForMonth(instProvider, _selectedDate).length;
    final fixedCostCount =
        _getFixedCostsForMonth(fixedProvider, _selectedDate).length;

    return ModuleScrollBody(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: FinanceMetricCard(
                    tone: FinanceTone.installment,
                    icon: Icons.shopping_bag_outlined,
                    label: 'Parcelas',
                    value: _money(installmentTotal),
                    caption: installmentCount == 1
                        ? '1 parcela'
                        : '$installmentCount parcelas',
                  ),
                ),
                const SizedBox(width: AppSpacing.itemGap),
                Expanded(
                  child: FinanceMetricCard(
                    tone: FinanceTone.fixedCost,
                    icon: Icons.calendar_month_outlined,
                    label: 'Fixos',
                    value: _money(fixedCostTotal),
                    caption: fixedCostCount == 1
                        ? '1 gasto fixo'
                        : '$fixedCostCount gastos fixos',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.itemGap),
          TonalSummaryCard(
            tone: FinanceTone.neutral,
            icon: Icons.trending_up_rounded,
            label: 'Total do Mês',
            value: _money(totalMonth),
            caption: 'Somando parcelas e fixos',
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          Semantics(
            header: true,
            child: Text(
              'Pagamentos por Tipo',
              style: AppTypography.headlineSmall.copyWith(
                color: AppSemanticColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.itemGap),
          ..._buildPaymentMethodStats(instProvider),
        ],
      ),
    );
  }

  List<Widget> _buildPaymentMethodStats(InstallmentProvider provider) {
    final methods = <String, double>{};
    for (final inst
        in _getActiveInstallmentsForMonth(provider, _selectedDate)) {
      methods.update(inst.paymentMethod, (v) => v + inst.installmentValue,
          ifAbsent: () => inst.installmentValue);
    }
    if (methods.isEmpty) {
      return [
        _buildPaymentsEmptyState(),
        const SizedBox(height: AppSpacing.blockGap),
        const TipCard(
          tone: FinanceTone.installment,
          title: 'Dica',
          message:
              'Mantenha seus compromissos em dia e tenha mais controle do seu orçamento.',
        ),
      ];
    }
    final total = methods.values.reduce((a, b) => a + b);
    return [
      Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: const BorderSide(color: AppSemanticColors.border),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (index, e) in methods.entries.indexed) ...[
                if (index > 0) const SizedBox(height: AppSpacing.defaultGap),
                _buildPaymentMethodRow(e.key, e.value, total),
              ],
            ],
          ),
        ),
      ),
    ];
  }

  Widget _buildPaymentMethodRow(String method, double value, double total) {
    final percent = ((value / total) * 100).toStringAsFixed(1);
    final label = _getPaymentMethodLabel(method);

    // Lido como uma frase ("Crédito, 80.0%"); a barra e so a versao visual dela.
    return Semantics(
      container: true,
      label: '$label, $percent%',
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppSemanticColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.labelGap),
                Text(
                  '$percent%',
                  style: AppTypography.labelMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppSemanticColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.labelGap),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.full),
              child: LinearProgressIndicator(
                value: value / total,
                minHeight: 8,
                backgroundColor: AppSemanticColors.surfaceSubtle,
                valueColor: AlwaysStoppedAnimation(
                  method == 'credit_card'
                      ? AppTone.blue.foreground
                      : AppTone.amber.foreground,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddBottomSheet(BuildContext context) {
    AppFormSheet.show(
      context: context,
      title: 'Adicionar',
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppPrimaryButton(
            label: 'Parcela',
            onPressed: () {
              Navigator.pop(sheetContext);
              _showInstallmentBottomSheet(context);
            },
          ),
          const SizedBox(height: AppSpacing.itemGap),
          OutlinedButton(
            onPressed: () {
              Navigator.pop(sheetContext);
              _showFixedCostBottomSheet(context);
            },
            child: const Text('Gasto Fixo'),
          ),
        ],
      ),
    );
  }

  void _showInstallmentBottomSheet(BuildContext context) {
    AppFormSheet.show(
      context: context,
      title: 'Nova Parcela',
      builder: (sheetContext) => _InstallmentForm(selectedDate: _selectedDate),
    );
  }

  void _showFixedCostBottomSheet(BuildContext context) {
    AppFormSheet.show(
      context: context,
      title: 'Novo Gasto Fixo',
      builder: (sheetContext) => const _FixedCostForm(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<InstallmentProvider, FixedCostProvider>(
      builder: (_, installmentProvider, fixedCostProvider, __) {
        final installmentTotal =
            installmentProvider.getMonthlyTotal(_selectedDate);
        final fixedCostTotal = fixedCostProvider.getMonthlyTotal(_selectedDate);
        final totalMonth = installmentTotal + fixedCostTotal;

        return AppModuleScaffold(
          header: ModuleScreenHeader(
            title: 'Dashboard / Fatura',
            subtitle: 'Acompanhe seus compromissos e gastos',
            onBack: () => Navigator.pop(context),
          ),
          topBar: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeroCard(totalMonth, installmentTotal, fixedCostTotal),
              const SizedBox(height: AppSpacing.labelGap),
              AppUnderlineTabs(
                controller: _tabController,
                labels: const ['Contas', 'Dashboard'],
              ),
            ],
          ),
          // Cada aba rola sozinha (TabBarView), como no legado.
          scrollable: false,
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddBottomSheet(context),
            tooltip: 'Adicionar',
            child: const Icon(Icons.add),
          ),
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildAccountsTab(installmentProvider, fixedCostProvider),
              _buildDashboardTab(installmentProvider, fixedCostProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeroCard(
      double totalMonth, double installmentTotal, double fixedCostTotal) {
    final monthName = DateFormat('MMMM', 'pt_BR').format(_selectedDate);
    final year = _selectedDate.year;

    return BalanceHeroCard(
      icon: Icons.description_outlined,
      label: 'Compromissos do Mês',
      value: _money(totalMonth),
      // Espacos sem quebra depois de "Parcelas:", "Fixos:" e "R$": a legenda
      // so quebra no marcador central, nunca entre um rotulo e o seu valor.
      caption:
          'Parcelas: ${_money(installmentTotal)}  •  Fixos: ${_money(fixedCostTotal)}'
              .replaceAll('R\$ ', 'R\$\u{A0}')
              .replaceAll(': ', ':\u{A0}'),
      control: HeroMonthSwitcher(
        label: '${monthName.capitalize()} $year',
        onPrevious: _previousMonth,
        onNext: _nextMonth,
      ),
    );
  }

  Widget _buildInstallmentCard(BuildContext context, InstallmentModel inst) {
    final name = inst.merchantName ?? inst.name;

    return FinanceRecordTile(
      tone: FinanceTone.installment,
      icon: Icons.shopping_bag_outlined,
      title: name,
      subtitle:
          '${inst.getPaidInstallmentsForDate(_selectedDate)} de ${inst.totalInstallments} parcelas • vence dia ${inst.dueDayOfMonth}\n'
          '${_getPaymentMethodLabel(inst.paymentMethod)} • ${_formatDateShort(inst.startDate)}',
      amount: _money(inst.installmentValue),
      actions: [
        IconButton(
          tooltip: 'Remover $name',
          icon: const Icon(Icons.delete_outline_rounded),
          color: AppSemanticColors.onFeedbackError,
          onPressed: () => _deleteInstallment(context, inst.id),
        ),
      ],
    );
  }

  Widget _buildFixedCostCard(BuildContext context, FixedCostModel cost) {
    return FinanceRecordTile(
      tone: FinanceTone.fixedCost,
      icon: _getCategoryIcon(cost.category),
      title: cost.name,
      subtitle:
          '${_getCategoryLabel(cost.category)} • todo dia ${cost.dueDayOfMonth}',
      amount: _money(cost.amount),
      actions: [
        IconButton(
          tooltip: 'Remover ${cost.name}',
          icon: const Icon(Icons.delete_outline_rounded),
          color: AppSemanticColors.onFeedbackError,
          onPressed: () => _deleteFixedCost(context, cost.id),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    // As duas secoes usam a barra ambar, como no prototipo.
    return SectionHeader(
      title: title,
      count: count,
      accent: FinanceTone.fixedCost.accent,
    );
  }

  Widget _buildInstallmentsEmptyState() {
    return EmptyStateCard(
      art: const FinanceEmptyArt(
        tone: FinanceTone.fixedCost,
        sealIcon: Icons.schedule_rounded,
      ),
      title: 'Nenhuma parcela cadastrada',
      message:
          'Adicione suas compras parceladas para não perder os vencimentos.',
      actionLabel: 'Adicionar parcela',
      onAction: () => _showInstallmentBottomSheet(context),
    );
  }

  Widget _buildFixedCostsEmptyState() {
    return EmptyStateCard(
      art: const FinanceEmptyArt(
        tone: FinanceTone.fixedCost,
        icon: Icons.calendar_month_outlined,
        sealIcon: Icons.attach_money_rounded,
      ),
      title: 'Nenhum gasto fixo cadastrado',
      message:
          'Adicione seus gastos fixos para manter seu orçamento sob controle.',
      actionLabel: 'Adicionar gasto fixo',
      onAction: () => _showFixedCostBottomSheet(context),
    );
  }

  Widget _buildPaymentsEmptyState() {
    return EmptyStateCard(
      art: const FinanceEmptyArt(
        tone: FinanceTone.installment,
        icon: Icons.description_outlined,
        sealIcon: Icons.pie_chart_outline_rounded,
      ),
      title: 'Sem dados de parcelas',
      message:
          'Adicione suas parcelas e gastos fixos para visualizar o resumo por tipo.',
      actionLabel: 'Adicionar pagamento',
      onAction: () => _showAddBottomSheet(context),
      actionStyle: EmptyStateActionStyle.filled,
    );
  }

  IconData _getCategoryIcon(String category) {
    return switch (category) {
      'streaming' => Icons.play_circle_outline,
      'rent' => Icons.home_outlined,
      'utility' => Icons.lightbulb_outline,
      'subscription' => Icons.card_membership,
      'insurance' => Icons.security_outlined,
      _ => Icons.category_outlined,
    };
  }

  void _deleteInstallment(BuildContext context, int id) {
    final auth = context.read<AuthProvider>();
    if (auth.authToken == null) return;

    AppConfirmDialog.showAwaiting(
      context,
      title: 'Remover Parcela?',
      message: 'Esta ação não pode ser desfeita.',
      confirmLabel: 'Remover',
      onConfirm: () => context
          .read<InstallmentProvider>()
          .removeInstallment(auth.authToken!, id),
    );
  }

  void _deleteFixedCost(BuildContext context, int id) {
    final auth = context.read<AuthProvider>();
    if (auth.authToken == null) return;

    AppConfirmDialog.showAwaiting(
      context,
      title: 'Remover Gasto Fixo?',
      message: 'Esta ação não pode ser desfeita.',
      confirmLabel: 'Remover',
      onConfirm: () => context
          .read<FixedCostProvider>()
          .removeFixedCost(auth.authToken!, id),
    );
  }

  List<InstallmentModel> _getActiveInstallmentsForMonth(
      InstallmentProvider provider, DateTime month) {
    return provider.installments.where((inst) {
      if (!inst.isActive) return false;
      final startDate = inst.startDate;
      final monthsDiff =
          (month.year - startDate.year) * 12 + (month.month - startDate.month);
      return monthsDiff >= 0 && monthsDiff < inst.totalInstallments;
    }).toList();
  }

  List<FixedCostModel> _getFixedCostsForMonth(
      FixedCostProvider provider, DateTime month) {
    return provider.getFixedCostsForMonth(month);
  }

  String _money(double value) =>
      'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';

  String _formatDateShort(DateTime date) {
    final months = [
      'jan',
      'fev',
      'mar',
      'abr',
      'mai',
      'jun',
      'jul',
      'ago',
      'set',
      'out',
      'nov',
      'dez'
    ];
    return '${date.day} ${months[date.month - 1]}';
  }

  String _getPaymentMethodLabel(String method) {
    const labels = {
      'credit_card': '💳 Crédito',
      'debit_card': '🏧 Débito',
      'pix': '📱 PIX',
      'cash': '💵 Dinheiro',
      'transfer': '🏦 Transferência',
      'other': '📋 Outro',
    };
    return labels[method] ?? method;
  }

  String _getCategoryLabel(String category) {
    const labels = {
      'streaming': 'Streaming',
      'rent': 'Aluguel',
      'utility': 'Utilidade',
      'subscription': 'Assinatura',
      'insurance': 'Seguro',
      'other': 'Outro',
    };
    return labels[category] ?? category;
  }
}

class _InstallmentForm extends StatefulWidget {
  final DateTime selectedDate;

  const _InstallmentForm({required this.selectedDate});

  @override
  State<_InstallmentForm> createState() => _InstallmentFormState();
}

class _InstallmentFormState extends State<_InstallmentForm> {
  final _nameController = TextEditingController();
  final _merchantController = TextEditingController();
  final _totalAmountController = TextEditingController();
  final _installmentsController = TextEditingController();
  final _dayController = TextEditingController();
  late DateTime _startDate;
  String _paymentMethod = 'credit_card';

  @override
  void initState() {
    super.initState();
    _startDate = widget.selectedDate;
    _dayController.text = '10';
  }

  @override
  @override
  void dispose() {
    _merchantController.dispose();
    _nameController.dispose();
    _totalAmountController.dispose();
    _installmentsController.dispose();
    _dayController.dispose();
    super.dispose();
  }

  void _selectDate() async {
    final picked = await showDatePicker(
        context: context,
        initialDate: _startDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100));
    if (picked != null) setState(() => _startDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppFormField(
            controller: _nameController,
            label: 'Nome da Compra',
            hint: 'Ex: iPhone 15 Pro'),
        const SizedBox(height: AppSpacing.defaultGap),
        AppFormField(
            controller: _merchantController,
            label: 'Loja/Empresa',
            hint: 'Ex: Apple Store'),
        const SizedBox(height: AppSpacing.defaultGap),
        AppFormDropdown<String>(
          label: 'Meio de Pagamento',
          value: _paymentMethod,
          items: const [
            DropdownMenuItem(
                value: 'credit_card', child: Text('💳 Cartão de Crédito')),
            DropdownMenuItem(
                value: 'debit_card', child: Text('🏧 Cartão de Débito')),
            DropdownMenuItem(value: 'pix', child: Text('📱 PIX')),
            DropdownMenuItem(value: 'cash', child: Text('💵 Dinheiro')),
            DropdownMenuItem(
                value: 'transfer', child: Text('🏦 Transferência')),
            DropdownMenuItem(value: 'other', child: Text('📋 Outro')),
          ],
          onChanged: (value) =>
              setState(() => _paymentMethod = value ?? 'credit_card'),
        ),
        const SizedBox(height: AppSpacing.defaultGap),
        AppFormField(
          controller: _totalAmountController,
          label: 'Valor Total',
          hint: 'Ex: 2400.00',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        const SizedBox(height: AppSpacing.defaultGap),
        AppFormField(
            controller: _installmentsController,
            label: 'Parcelas',
            hint: 'Ex: 12',
            keyboardType: TextInputType.number),
        const SizedBox(height: AppSpacing.defaultGap),
        AppFormField(
            controller: _dayController,
            label: 'Dia de Vencimento',
            hint: 'Ex: 10',
            keyboardType: TextInputType.number),
        const SizedBox(height: AppSpacing.defaultGap),
        AppDateField(
            label: 'Data de Início', value: _startDate, onTap: _selectDate),
        const SizedBox(height: AppSpacing.blockGap),
        AppPrimaryButton(
          label: 'Adicionar',
          onPressed: () {
            final auth = context.read<AuthProvider>();
            if (auth.authToken != null &&
                _nameController.text.isNotEmpty &&
                _totalAmountController.text.isNotEmpty &&
                _installmentsController.text.isNotEmpty &&
                _dayController.text.isNotEmpty) {
              context.read<InstallmentProvider>().addInstallment(
                    auth.authToken!,
                    name: _nameController.text,
                    totalAmount: double.parse(_totalAmountController.text),
                    totalInstallments: int.parse(_installmentsController.text),
                    dueDayOfMonth: int.parse(_dayController.text),
                    startDate: _startDate,
                    paymentMethod: _paymentMethod,
                    merchantName: _merchantController.text.isNotEmpty
                        ? _merchantController.text
                        : null,
                  );
              Navigator.pop(context);
            }
          },
        ),
      ],
    );
  }
}

class _FixedCostForm extends StatefulWidget {
  const _FixedCostForm();

  @override
  State<_FixedCostForm> createState() => _FixedCostFormState();
}

class _FixedCostFormState extends State<_FixedCostForm> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _dayController = TextEditingController();
  String _selectedCategory = 'other';

  @override
  void initState() {
    super.initState();
    _dayController.text = '15';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _dayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppFormField(
            controller: _nameController, label: 'Nome', hint: 'Ex: Netflix'),
        const SizedBox(height: AppSpacing.defaultGap),
        AppFormField(
          controller: _amountController,
          label: 'Valor',
          hint: 'Ex: 55.90',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        const SizedBox(height: AppSpacing.defaultGap),
        AppFormField(
            controller: _dayController,
            label: 'Dia de Vencimento',
            hint: 'Ex: 15',
            keyboardType: TextInputType.number),
        const SizedBox(height: AppSpacing.defaultGap),
        AppFormDropdown<String>(
          label: 'Categoria',
          value: _selectedCategory,
          items: const [
            DropdownMenuItem(value: 'streaming', child: Text('🎬 Streaming')),
            DropdownMenuItem(value: 'rent', child: Text('🏠 Aluguel')),
            DropdownMenuItem(value: 'utility', child: Text('⚡ Utilidade')),
            DropdownMenuItem(
                value: 'subscription', child: Text('📜 Assinatura')),
            DropdownMenuItem(value: 'insurance', child: Text('🛡️ Seguro')),
            DropdownMenuItem(value: 'other', child: Text('📋 Outro')),
          ],
          onChanged: (v) => setState(() => _selectedCategory = v ?? 'other'),
        ),
        const SizedBox(height: AppSpacing.blockGap),
        AppPrimaryButton(
          label: 'Adicionar',
          onPressed: () {
            final auth = context.read<AuthProvider>();
            if (auth.authToken != null &&
                _nameController.text.isNotEmpty &&
                _amountController.text.isNotEmpty &&
                _dayController.text.isNotEmpty) {
              try {
                final amount =
                    double.parse(_amountController.text.replaceAll(',', '.'));
                context.read<FixedCostProvider>().addFixedCost(
                      auth.authToken!,
                      name: _nameController.text,
                      amount: amount,
                      dueDayOfMonth: int.parse(_dayController.text),
                      category: _selectedCategory,
                    );
                Navigator.pop(context);
              } catch (e) {
                AppFeedbackSnackBar.error(context, 'Valor inválido');
              }
            }
          },
        ),
      ],
    );
  }
}

extension StringExt on String {
  String capitalize() => '${this[0].toUpperCase()}${substring(1)}';
}
