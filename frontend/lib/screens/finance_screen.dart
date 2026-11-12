import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/fixed_cost_model.dart';
import '../models/installment_model.dart';
import '../providers/auth_provider.dart';
import '../providers/fixed_cost_provider.dart';
import '../providers/installment_provider.dart';
import '../theme/app_spacing.dart';
import '../theme/tokens/app_colors_semantic.dart';
import '../widgets/common/app_form_sheet.dart';
import '../widgets/common/app_module_scaffold.dart';
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
import '../widgets/finance/tonal_summary_card.dart';
import 'accounts_screen.dart';
import 'invoice_dashboard_screen.dart';

/// Tela unificada de finanças: contas bancárias, parcelas e gastos fixos em uma
/// única tela com abas. Substitui os dois cards antigos ("Finanças" e
/// "Dashboard / Fatura") por um só destino.
class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key});

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen>
    with TickerProviderStateMixin {
  late DateTime _selectedDate;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _tabController = TabController(length: 3, vsync: this);
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

  void _showInstallmentSheet() {
    AppFormSheet.show(
      context: context,
      title: 'Nova Parcela',
      builder: (_) => InstallmentForm(selectedDate: _selectedDate),
    );
  }

  void _showFixedCostSheet() {
    AppFormSheet.show(
      context: context,
      title: 'Novo Gasto Fixo',
      builder: (_) => const FixedCostForm(),
    );
  }

  Widget _buildFab() {
    final index = _tabController.index;
    switch (index) {
      case 0:
        return FloatingActionButton(
          onPressed: () => showAddAccountSheet(context),
          tooltip: 'Adicionar conta',
          child: const Icon(Icons.add),
        );
      case 1:
        return FloatingActionButton(
          onPressed: _showInstallmentSheet,
          tooltip: 'Nova parcela',
          child: const Icon(Icons.add),
        );
      default:
        return FloatingActionButton(
          onPressed: _showFixedCostSheet,
          tooltip: 'Novo gasto fixo',
          child: const Icon(Icons.add),
        );
    }
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
            title: 'Finanças e Faturas',
            subtitle: 'Controle suas contas, parcelas e gastos',
            onBack: () => Navigator.pop(context),
          ),
          topBar: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeroCard(totalMonth, installmentTotal, fixedCostTotal),
              const SizedBox(height: AppSpacing.labelGap),
              AppUnderlineTabs(
                controller: _tabController,
                labels: const ['Contas', 'Parcelas', 'Dashboard'],
              ),
            ],
          ),
          scrollable: false,
          floatingActionButton: ListenableBuilder(
            listenable: _tabController,
            builder: (_, __) => _buildFab(),
          ),
          child: TabBarView(
            controller: _tabController,
            children: [
              ModuleScrollBody(child: const AccountsTab()),
              ModuleScrollBody(
                child: _buildParcelasTab(installmentProvider),
              ),
              ModuleScrollBody(
                child: _buildDashboardTab(
                    installmentProvider, fixedCostProvider),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeroCard(
      double totalMonth, double installmentTotal, double fixedCostTotal) {
    final monthName = DateFormat('MMMM', 'pt_BR').format(_selectedDate);
    final monthLabel =
        '${monthName[0].toUpperCase()}${monthName.substring(1)} ${_selectedDate.year}';

    return BalanceHeroCard(
      icon: Icons.description_outlined,
      label: 'Compromissos do Mês',
      value: _money(totalMonth),
      caption:
          'Parcelas: ${_money(installmentTotal)}  •  Fixos: ${_money(fixedCostTotal)}'
              .replaceAll('R\$ ', 'R\$\u{A0}')
              .replaceAll(': ', ':\u{A0}'),
      control: HeroMonthSwitcher(
        label: monthLabel,
        onPrevious: _previousMonth,
        onNext: _nextMonth,
      ),
    );
  }

  Widget _buildParcelasTab(InstallmentProvider provider) {
    final installments =
        _getActiveInstallmentsForMonth(provider, _selectedDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionHeader('Parcelas', installments.length),
        const SizedBox(height: AppSpacing.itemGap),
        if (installments.isEmpty)
          EmptyStateCard(
            art: const FinanceEmptyArt(
              tone: FinanceTone.installment,
              sealIcon: Icons.schedule_rounded,
            ),
            title: 'Nenhuma parcela cadastrada',
            message:
                'Adicione suas compras parceladas para não perder os vencimentos.',
            actionLabel: 'Adicionar parcela',
            onAction: _showInstallmentSheet,
          )
        else
          ...installments.map((inst) => _buildInstallmentCard(inst)),
      ],
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

    return Column(
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
        const SizedBox(height: AppSpacing.blockGap),
        _buildSectionHeader('Gastos Fixos', fixedCostCount),
        const SizedBox(height: AppSpacing.itemGap),
        if (fixedCostCount == 0)
          EmptyStateCard(
            art: const FinanceEmptyArt(
              tone: FinanceTone.fixedCost,
              icon: Icons.calendar_month_outlined,
              sealIcon: Icons.attach_money_rounded,
            ),
            title: 'Nenhum gasto fixo cadastrado',
            message:
                'Adicione seus gastos fixos para manter seu orçamento sob controle.',
            actionLabel: 'Adicionar gasto fixo',
            onAction: _showFixedCostSheet,
          )
        else
          ..._getFixedCostsForMonth(fixedProvider, _selectedDate)
              .map((cost) => _buildFixedCostCard(cost)),
      ],
    );
  }

  Widget _buildInstallmentCard(InstallmentModel inst) {
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
          onPressed: () => _deleteInstallment(inst.id),
        ),
      ],
    );
  }

  Widget _buildFixedCostCard(FixedCostModel cost) {
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
          onPressed: () => _deleteFixedCost(cost.id),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return SectionHeader(
      title: title,
      count: count,
      accent: FinanceTone.fixedCost.accent,
    );
  }

  void _deleteInstallment(int id) {
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

  void _deleteFixedCost(int id) {
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
    const months = [
      'jan', 'fev', 'mar', 'abr', 'mai', 'jun',
      'jul', 'ago', 'set', 'out', 'nov', 'dez', //
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
}
